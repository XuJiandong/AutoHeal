
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
import threading
import os


SAVE_SCREENSHOT=False
RETINA=True
CUSTOM_CONFIG = r'-c tessedit_char_whitelist=0123456789 --psm 6'
CONFIG_FILE_NAME = "config.json"

if platform.system() == "Darwin":
    RETINA = True
    print("Mac detected, set RETINA=True")
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

        self.grid_x_count = 5
        self.grid_y_count = 8

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
            print("no config loaded, start to calibrate ...")

        monitor_ctrl()
        print("Please hold ctrl key and then click the start of text area")
        (self.text_x, self.text_y) = get_position_with_ctrl_click()
        time.sleep(2)
        print("Please hold ctrl key and then click the end of text area")
        (self.text_x_end, self.text_y_end) = get_position_with_ctrl_click()
        time.sleep(2)
        print("Please hold ctrl key and then click the start of grid")
        (self.grid_x, self.grid_y) = get_position_with_ctrl_click()
        time.sleep(2)
        print("Please hold ctrl key and then click the end of grid")
        (self.grid_x_end, self.grid_y_end) = get_position_with_ctrl_click()
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
            print(f"failed to write to {CONFIG_FILE_NAME}")
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
            print(f"failed to load from {CONFIG_FILE_NAME}")
            return False
        return True

CONFIG = Config()

CTRL_PRESSED = False
def on_press(key):
    global CTRL_PRESSED
    if key == Key.ctrl:
        CTRL_PRESSED = True

def on_release(key):
    global CTRL_PRESSED
    if key == Key.ctrl:
        CTRL_PRESSED = False

def monitor_ctrl():
    def m():
        with keyboard.Listener(on_press=on_press, on_release=on_release) as listener:
            listener.join()
    thread2 = threading.Thread(target=m, args=())
    thread2.start()

def is_ctrl_pressed():
    global CTRL_PRESSED
    return CTRL_PRESSED

def get_position_with_ctrl_click():
    with mouse.Events() as events:
        for event in events:
            if isinstance(event, mouse.Events.Click) and event.button == mouse.Button.left and is_ctrl_pressed():
                x, y = pag.position()
                if RETINA:
                    x *= 2
                    y *= 2
                return (x, y)


def image_to_digits(img):
    global CUSTOM_CONFIG
    global SAVE_SCREENSHOT

    if SAVE_SCREENSHOT:
        cv2.imwrite('screen.png', img)
        print("save screenshot to screen.png")

    img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY) # gray
    img = cv2.bitwise_not(img) # invert
    result = pytesseract.image_to_string(img, config=CUSTOM_CONFIG)
    # add validation here
    return result


def captured_text_screens():
    global CONFIG
    mon = {'left': CONFIG.text_x, 'top': CONFIG.text_y, 
        'width': CONFIG.text_x_end - CONFIG.text_x, 'height': CONFIG.text_y_end - CONFIG.text_y}
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
        print("retina enabled")
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
            print("get text:", image_to_digits(img))
            time.sleep(2)     
        os._exit(0)
