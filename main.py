from PIL import Image
import pyautogui as pag
import pytesseract
import PIL.ImageGrab
import argparse
import sys
import time

SAVE_SCREENSHOT=True
RETINA=False

#
# sample data:
# 100-200-300-400-500-600-700-800
# 10-20-30-40-50-60-70-80
# 1-2-3-4-5-6-7-8
# 
def screenshot_ocr(left_x, top_y, right_x, bottom_y):
    image = PIL.ImageGrab.grab(bbox=(left_x, top_y, right_x, bottom_y))
    if SAVE_SCREENSHOT:
        image.save("screenshot.png")
    result = pytesseract.image_to_string(image, config='digits')
    return result


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
        print(screenshot_ocr(90, 105, 460, 235))
