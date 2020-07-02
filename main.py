
from mss import mss
import pyautogui as pag
import pytesseract
import argparse
import sys
import time
import cv2
import numpy as np
import platform
import json
from pynput import keyboard, mouse
from pynput.keyboard import Key, Controller
import os
import math


SAVE_SCREENSHOT=False
RETINA=True
CUSTOM_CONFIG = r'-c tessedit_char_whitelist=0123456789 --psm 6'
CONFIG_FILE_NAME = "config.json"

if platform.system() == "Darwin":
    RETINA = True
else:
    RETINA = False
RETINA = False


class Config():
    def __init__(self):
        self.text_x = 0
        self.text_y = 0
        self.text_x_end = 400
        self.text_y_end = 400

        self.grid_x = 0
        self.grid_y = 0
        self.grid_x_end = 0
        self.grid_y_end = 0

        self.grid_x_count = 8
        self.grid_y_count = 5
        self.move_duration = 0.2
        self.loop_interval = 0.5

    def calibrate(self):
        success = self.load()
        if success:
            print("Previous config loaded successfully. Do you still want to calibrate?")
            yes = input("Press y to calibrate by force, otherwise to abort:> ")
            if str.lower(yes) != "y":
                return True
            else:
                print("The user wants to calibrate again ...")
        else:
            print("No config loaded, start to calibrate ...")

        print("Please right click the start of text area")
        (self.text_x, self.text_y) = get_position_with_click()
        time.sleep(2)
        print("Please right click the end of text area")
        (self.text_x_end, self.text_y_end) = get_position_with_click()
        time.sleep(2)
        print("Please right click the start of grid")
        (self.grid_x, self.grid_y) = get_position_with_click()
        time.sleep(2)
        print("Please right click the end of grid")
        (self.grid_x_end, self.grid_y_end) = get_position_with_click()
        time.sleep(2)

        self.save()
        print("Config saved")

    def save(self):
        global CONFIG_FILE_NAME
        try:
            with open(CONFIG_FILE_NAME, "w") as file:
                json.dump(self, file, default=lambda o: o.__dict__,
                           sort_keys=True, indent=4)
                           
        except Exception as e:
            print(f"Failed to write to {CONFIG_FILE_NAME}")
            print(e)
            return False
        return True

    def load(self):
        global CONFIG_FILE_NAME
        try:
            with open(CONFIG_FILE_NAME, "r") as file:
                json_obj = json.load(file)
                self.text_x = json_obj["text_x"]
                self.text_y = json_obj["text_y"]
                self.text_x_end = json_obj["text_x_end"]
                self.text_y_end = json_obj["text_y_end"]

                self.grid_x = json_obj["grid_x"]
                self.grid_y = json_obj["grid_y"]
                self.grid_x_end = json_obj["grid_x_end"]
                self.grid_y_end = json_obj["grid_y_end"]
        except Exception as e:
            # print(e)
            print(f"Failed to load from {CONFIG_FILE_NAME}")
            return False
        return True

CONFIG = Config()


def get_position_with_click():
    with mouse.Events() as events:
        for event in events:
            if isinstance(event, mouse.Events.Click) and event.button == mouse.Button.right:
                x, y = pag.position()
                if RETINA:
                    x *= 2
                    y *= 2
                return (x, y)


def image_to_digits(img):
    global CUSTOM_CONFIG

    img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY) # gray
    #img = cv2.bitwise_not(img) # invert
    result = pytesseract.image_to_string(img, config=CUSTOM_CONFIG)
    # add validation here
    return result

def validate_text(text):
    if text == None or len(text) != 6:
        return False
    return True


def get_index(text):
    ret = 0
    try:
        ret = int(text[0:2])
    except Exception as e:
        ret = 0
    return ret

def is_valid_index(index):
    return 1 <= index <= 40

def get_location_by_index(index, c: Config):
    # zero based
    grid_x_size = (c.grid_x_end - c.grid_x)/c.grid_x_count
    grid_y_size = (c.grid_y_end - c.grid_y)/c.grid_y_count

    x = math.floor((index-1)/ c.grid_y_count)
    y = (index - 1) % c.grid_y_count

    pos_x = x*grid_x_size + grid_x_size/2 + c.grid_x
    pos_y = y*grid_y_size + grid_y_size/2 + c.grid_y
    # TODO: add random margin
    return pos_x, pos_y


def captured_text_screens():
    global CONFIG
    mon = {'left': CONFIG.text_x, 'top': CONFIG.text_y, 
        'width': CONFIG.text_x_end - CONFIG.text_x, 'height': CONFIG.text_y_end - CONFIG.text_y}
    print(f"left: {mon['left']}, top: {mon['top']}, width: {mon['width']}, height: {mon['height']} ")
    with mss() as sct:
        while True:
            last_time = time.time()
            img = sct.grab(mon)
            img = np.array(img)
            #MSS returns raw pixels in the BGRA form (Blue, Green, Red, Alpha). reshape from BGRA to BGR
            img = cv2.cvtColor(img, cv2.COLOR_BGRA2BGR)
            yield img


def show_location():
    print('Press Ctrl-C to quit.')
    if RETINA:
        print("Retina enabled")
    try:
        while True:
            x, y = pag.position()
            if RETINA:
                x *= 2
                y *= 2
            positionStr = 'X: ' + str(x).rjust(4) + ' Y: ' + str(y).rjust(4)
            print(positionStr, end='')
            print('\b' * len(positionStr), end='', flush=True)
    except KeyboardInterrupt:
        print('\n')

def in_grid_area():
    global CONFIG
    x_now, y_now = pag.position()
    return CONFIG.grid_x <= x_now <= CONFIG.grid_x_end and CONFIG.grid_y <= y_now <= CONFIG.grid_y_end

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-s", "--show", action='store_true', help="show location")
    parser.add_argument("-t", "--test", action='store_true', help="test")
    parser.add_argument("-c", "--calibrate", action='store_true', help="calibrate")

    parser.add_argument('rest', nargs=argparse.REMAINDER)
    args = parser.parse_args()
    if args.show:
        show_location()
        os._exit(0)
    if args.test:
        CONFIG.calibrate()
        for img in captured_text_screens():
            print("Get text:", image_to_digits(img))
            time.sleep(2)     
        os._exit(0)

    # main routine
    CONFIG.calibrate()
    print("---------- started, press ctrl+C to stop ------------")
    sleep_count = 0
    for img in captured_text_screens():
        while not in_grid_area():
            time.sleep(0.1)
            sleep_count += 1
            if sleep_count % 30 == 0:
                print("Out of grid range, still alive")

        text = image_to_digits(img)
        if not validate_text(text):
            if SAVE_SCREENSHOT:
                cv2.imwrite('screen.png', img)
                print("Save screenshot to screen.png")
            print(f"Invalid text: {text}")
        else:
            print("Get text:", text)
            index = get_index(text)
            if is_valid_index(index):
                x, y = get_location_by_index(index, CONFIG)            
                pag.moveTo(x, y, duration=CONFIG.move_duration, tween=pag.easeInQuad)
            else:
                if index == 0:
                    print("No one to heal")
                else:
                    print("Invalid index", index)
                    
        time.sleep(CONFIG.loop_interval)
