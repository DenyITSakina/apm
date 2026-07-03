import pyautogui
import time

def find_coordinates():
    """
    Script untuk menemukan koordinat mouse
    """
    print("Gerakkan mouse ke posisi yang diinginkan...")
    print("Tekan Ctrl+C untuk berhenti")
    
    try:
        while True:
            x, y = pyautogui.position()
            print(f"Posisi: ({x}, {y})", end='\r')
            time.sleep(0.1)
    except KeyboardInterrupt:
        print("\nSelesai")

if __name__ == "__main__":
    find_coordinates()