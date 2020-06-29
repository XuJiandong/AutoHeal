from mss import mss
import pyautogui as pag
import pytesseract
import argparse
import sys
import time
import cv2
import numpy as np


SAVE_SCREENSHOT=True
RETINA=True

CUSTOM_CONFIG = r'-c tessedit_char_whitelist=0123456789 --psm 6'
def image_to_digits(img):
    global CUSTOM_CONFIG
    img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY) # gray
    img = cv2.bitwise_not(img) # invert
    result = pytesseract.image_to_string(img, config=CUSTOM_CONFIG)
    # add validation here
    return result


def captured_screens():
    mon = {'top': 0, 'left': 0, 'width': 400, 'height': 400}
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

    parser.add_argument('rest', nargs=argparse.REMAINDER)
    args = parser.parse_args()
    if args.show:
        show_location()
        sys.exit(0)
    if args.test:
        for img in captured_screens():
            cv2.imshow("image", img)
            cv2.waitKey(0)
            # print("new image")
            print(image_to_digits(img))
            time.sleep(2)
        sys.exit(0)
