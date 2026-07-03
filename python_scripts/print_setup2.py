import pyautogui
import time
import sys
import os

if sys.platform == 'win32':
    os.system('chcp 65001 > nul')

# Langsung eksekusi tanpa delay
pyautogui.click(187, 262)
time.sleep(0.1)
pyautogui.click(185, 320)
# time.sleep(0.1)
# pyautogui.click(399, 297)
time.sleep(0.1)
pyautogui.click(366, 350)
print("DONE!")