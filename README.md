# Auto Heal

![CI](https://github.com/XuJiandong/AutoHeal/workflows/CI/badge.svg)

## Install and Run
- Install python3

- Install required python module
```bash
pip install -r requirements.txt
```

- Install "tessereact"

It's required by "pytesseract". Make sure command line "tesseract" is working.
Can use this link on windows: <https://digi.bib.uni-mannheim.de/tesseract/>, choose the latest version.
- Install "WeakAura" on Wow
 
Then import the WA_String.lua. Can find a white text shown (6 digits) on left side of the screen.

- Run
```bash
python3 main.py
```
Then follow the instructions.

## Game Setting
- Location of health text
- Location of Grid position

## Output Raid Member of the Lowest Health to Screen
WeakAura

## Take Screenshot
Python module: mss
https://pypi.org/project/mss/


## OCR Screenshot
Python module: pytesseract
https://github.com/madmaze/pytesseract


## Move Mouse
Move mouse according to the index. Python module: pyautogui pynput

https://pyautogui.readthedocs.io/en/latest/
https://pypi.org/project/pynput/

If the mouse position is out of grid range, it does nothing.
Hit Ctrl+F11 to pause, hit them again to resume.
