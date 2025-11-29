import pyautogui
import time
import subprocess
import psutil
import sys

# Ambil argumen NIK / No Peserta
if len(sys.argv) < 2:
    print("Usage: python frista_auto.py <no_peserta>")
    sys.exit(1)

no_peserta = sys.argv[1]

# Koordinat UI Frista
username_coords = (641, 381)
password_coords = (632, 446)
login_coords = (605, 529)
no_peserta_coords = (950, 274)
ambil_foto_coords = (953, 394)
popup_ok_coords = (745, 439)

EXPECTED_COLOR = (240, 240, 240)
username = "cicifitria"
password = "Idaman99!"
FRISTA_PATH = r"C:\frista_v3.0.2\frista\Frista.exe"
AFTER_PATH = r"C:\Program Files (x86)\BPJS Kesehatan\Aplikasi Sidik Jari BPJS Kesehatan\After.exe"

# Utility
def is_process_running(name):
    for p in psutil.process_iter(['name']):
        if p.info['name'] and name.lower() in p.info['name'].lower():
            return True
    return False

def kill_process(name):
    for p in psutil.process_iter(['name']):
        if p.info['name'] and name.lower() in p.info['name'].lower():
            try:
                p.kill()
            except:
                pass

def click_ok_popup():
    pyautogui.moveTo(*popup_ok_coords, duration=0.2)
    pyautogui.click()
    print(">>> Tombol OK popup diklik")
    time.sleep(0.5)

def detect_nik_popup():
    """Deteksi popup NIK salah atau NIK tidak ditemukan"""
    try:
        pixel = pyautogui.pixel(*popup_ok_coords)
        if all(abs(pixel[i] - EXPECTED_COLOR[i]) < 40 for i in range(3)):
            print(">>> Popup NIK terdeteksi (salah atau tidak ditemukan)!")
            click_ok_popup()
            return True
    except Exception as e:
        print(">>> Error deteksi popup:", e)
    return False

def run_after(no_peserta):
    """Jalankan After.exe dan input NIK / login otomatis"""
    print(">>> Menjalankan After.exe...")
    try:
        proc = subprocess.Popen([AFTER_PATH])
        time.sleep(3)

        # Fokus window After.exe
        pyautogui.click(username_coords)
        pyautogui.typewrite(username, interval=0.05)
        pyautogui.click(password_coords)
        pyautogui.typewrite(password, interval=0.05)
        pyautogui.click(login_coords)
        time.sleep(2)

        # Input NIK peserta
        pyautogui.click(no_peserta_coords)
        pyautogui.typewrite(no_peserta, interval=0.05)
        print(f"Nomor peserta {no_peserta} berhasil diinput di After.exe")

        proc.wait()
        print("After.exe selesai")
    except Exception as e:
        print(">>> Gagal menjalankan After.exe:", e)

# Proses utama Frista
def start_frista_and_login():
    print("Membuka Frista...")
    proc = subprocess.Popen(FRISTA_PATH)
    time.sleep(7)

    if not is_process_running("Frista.exe"):
        print("Frista tertutup otomatis saat verifikasi wajah gagal")
        return False

    # Login otomatis
    pyautogui.click(username_coords)
    time.sleep(0.3)
    pyautogui.typewrite(username, interval=0.05)
    pyautogui.click(password_coords)
    time.sleep(0.3)
    pyautogui.typewrite(password, interval=0.05)
    time.sleep(0.3)
    pyautogui.click(login_coords)
    print("Login otomatis selesai")
    time.sleep(3)

    # Cek popup saat login
    if detect_nik_popup():
        kill_process("Frista.exe")
        return False
    

    # Input nomor peserta
    pyautogui.click(no_peserta_coords)
    time.sleep(0.3)
    pyautogui.typewrite(no_peserta, interval=0.05)
    print(f"Nomor peserta {no_peserta} berhasil diinput")
    time.sleep(2)

    # Cek popup setelah input NIK
    if detect_nik_popup():
        kill_process("Frista.exe")
        return False

    # Ambil foto dengan pengecekan popup setiap 1 detik selama 8 detik
    pyautogui.click(ambil_foto_coords)
    print("Tombol Ambil Foto diklik! Proses pengambilan foto dimulai...")

    for i in range(8):
        time.sleep(1)
        if detect_nik_popup():
            kill_process("Frista.exe")
            return False

    print(">>> SUCCESS: Foto diambil")
    return True

# Eksekusi
success = start_frista_and_login()
if success:
    print("Frista berhasil login, nomor peserta dimasukkan, foto diambil!")
    sys.exit(0)
else:
    print("Frista gagal login/verifikasi wajah atau NIK tidak ditemukan")
    kill_process("Frista.exe")
    run_after(username, password) 
    sys.exit(0)
