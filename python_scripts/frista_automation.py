import pyautogui
import time
import subprocess
import psutil
import sys
import mysql.connector
from mysql.connector import Error

# ===== KONFIGURASI DATABASE =====
DB_CONFIG = {
    'host': '10.30.0.15', 
    'database': 'sakina_pasien2',
    'user': 'user_stg',
    'password': '12344321' 
}

def get_account_from_db():
    """
    Ambil account aktif dari database tanpa parameter no_peserta
    """
    connection = None
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        cursor = connection.cursor(dictionary=True)
        
        query = """
            SELECT username, password 
            FROM vclaim_accounts 
            WHERE is_active = 1 
            LIMIT 1
        """
        cursor.execute(query)
        
        result = cursor.fetchone()
        
        if result:
            return result['username'], result['password']
        else:
            # Fallback ke default jika tidak ditemukan
            print("Akun tidak ditemukan di database, menggunakan default")
            return "cicifitria", "Idaman99!"
            
    except Error as e:
        print(f"Error koneksi database: {e}")
        # Fallback ke default
        return "cicifitria", "Idaman99!"
    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()

# Ambil username dan password dari database (TANPA no_peserta)
username, password = get_account_from_db()
print(f"Username: {username}, Password: {'*' * len(password)}")

# Koordinat UI Frista
username_coords = (641, 381)
password_coords = (632, 446)
login_coords = (605, 529)
# no_peserta_coords = (950, 274)  # TIDAK DIPAKAI
# ambil_foto_coords = (953, 394)  # TIDAK DIPAKAI
popup_ok_coords = (745, 439)

EXPECTED_COLOR = (240, 240, 240)
FRISTA_PATH = r"C:\frista_v3.0.2\frista\Frista.exe"
# AFTER_PATH = r"C:\Program Files (x86)\BPJS Kesehatan\Aplikasi Sidik Jari BPJS Kesehatan\After.exe"  # TIDAK DIPAKAI

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

def run_after(username, password):
    """Jalankan After.exe dengan login otomatis (TANPA input no_peserta)"""
    print(">>> Menjalankan After.exe...")
    try:
        # Cegah dobel: jika After.exe sudah berjalan, jangan buka instance baru
        if not is_process_running("After.exe"):
            proc = subprocess.Popen([AFTER_PATH])
            time.sleep(3)
        else:
            proc = None
            time.sleep(2)

        # Fokus window After.exe dan login
        pyautogui.click(username_coords)
        pyautogui.typewrite(username, interval=0.05)
        pyautogui.click(password_coords)
        pyautogui.typewrite(password, interval=0.05)
        pyautogui.click(login_coords)
        print(">>> Login After.exe selesai (tanpa input no_peserta)")
        time.sleep(2)

        if proc:
            proc.wait()
            print("After.exe selesai")
    except Exception as e:
        print(">>> Gagal menjalankan After.exe:", e)

def start_frista_and_login(username, password):
    """
    Jalankan Frista, login otomatis, dan handle popup
    TANPA input no_peserta dan TANPA ambil foto
    """
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
    
    # ===== TIDAK ADA INPUT NO_PESERTA =====
    # ===== TIDAK ADA AMBIL FOTO =====
    
    print(">>> SUCCESS: Frista berhasil login (tanpa input no_peserta)")
    return True

# Eksekusi
success = start_frista_and_login(username, password)

if success:
    print("Frista berhasil login!")
    sys.exit(0)
else:
    print("Frista gagal login/verifikasi wajah")
    kill_process("Frista.exe")
    # ===== RUN AFTER TANPA NO_PESERTA =====
    # run_after(username, password)  # Hanya login, tanpa input no_peserta
    sys.exit(0)