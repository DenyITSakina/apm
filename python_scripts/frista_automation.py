"""Automasi BPJS Sidik Jari (After.exe).

Fokus: proses cepat (tidak ada delay tetap yang panjang), window diaktifkan
via Win32, dan selesai/keluar dilaporkan lewat exit code.
"""

import ctypes
import os
import subprocess
import sys
import time

import mysql.connector
import psutil
import pyautogui
from mysql.connector import Error

pyautogui.FAILSAFE = False

# ===== KONFIGURASI =====
DB_CONFIG = {
    "host": "10.30.0.15",
    "database": "sakina_pasien2",
    "user": "user_stg",
    "password": "12344321",
}

# FRISTA_PATH = r"C:\frista_v3.0.2\frista\Frista.exe"
AFTER_PATH = (
    r"C:\Program Files (x86)\BPJS Kesehatan"
    r"\Aplikasi Sidik Jari BPJS Kesehatan\After.exe"
)

AFTER_PROCESS_NAME = "After.exe"
# FRISTA_PROCESS_NAME = "Frista.exe"

# ===== WAKTU TUNGGU (detik) =====
POLL_INTERVAL = 0.1
AFTER_LAUNCH_TIMEOUT = 6
# AFTER_LOGIN_TIMEOUT = 12
AFTER_EXIT_TIMEOUT = 180
FRISTA_LAUNCH_TIMEOUT = 15

DEFAULT_USER = "cicifitria"
DEFAULT_PASSWORD = "Idaman99!"

user32 = ctypes.windll.user32
SW_RESTORE = 9


# ===== HELPER =====
def get_account_from_db():
    """Ambil satu account aktif (tanpa no_peserta)."""
    connection = None
    cursor = None
    try:
        connection = mysql.connector.connect(**DB_CONFIG, connection_timeout=5)
        cursor = connection.cursor(dictionary=True)
        cursor.execute(
            "SELECT username, password FROM vclaim_accounts "
            "WHERE is_active = 1 LIMIT 1"
        )
        result = cursor.fetchone()
        if result:
            return result["username"], result["password"]
        print("[!] Akun tidak ditemukan di database, memakai default")
    except Error as exc:
        print(f"[!] Error koneksi database: {exc}, memakai default")
    finally:
        if cursor is not None:
            try:
                cursor.close()
            except Error:
                pass
        if connection is not None and connection.is_connected():
            connection.close()
    return DEFAULT_USER, DEFAULT_PASSWORD


def process_names():
    names = []
    for proc in psutil.process_iter(["name"]):
        name = (proc.info["name"] or "").lower()
        if name:
            names.append(name)
    return names


def is_process_running(name):
    return name.lower() in process_names()


def kill_process(name):
    for proc in psutil.process_iter(["name"]):
        if (proc.info["name"] or "").lower() == name.lower():
            try:
                proc.kill()
            except Exception:
                pass


def wait_until(predicate, timeout):
    """Polling cepat: True bila predicate terpenuhi sebelum timeout."""
    deadline = time.time() + timeout
    while True:
        if predicate():
            return True
        if time.time() >= deadline:
            return False
        time.sleep(POLL_INTERVAL)


def find_window(process_name):
    """Cari HWND proses lewat EnumWindows (cepat, tanpa subprocess)."""
    handles = []

    @ctypes.WINFUNCTYPE(ctypes.c_bool, ctypes.c_void_p, ctypes.c_void_p)
    def callback(hwnd, _):
        if not user32.IsWindowVisible(hwnd):
            return True
        pid = ctypes.c_ulong()
        user32.GetWindowThreadProcessId(hwnd, ctypes.byref(pid))
        try:
            proc = psutil.Process(pid.value)
            if proc.name().lower() == process_name.lower():
                handles.append(hwnd)
        except Exception:
            pass
        return len(handles) < 1

    user32.EnumWindows(callback, 0)
    return handles[0] if handles else None


def activate_window(process_name, timeout=5):
    """Aktifkan window proses (restore bila minimize)."""
    ok = wait_until(lambda: find_window(process_name) is not None, timeout)
    hwnd = find_window(process_name)
    if not ok or not hwnd:
        return False
    user32.ShowWindow(hwnd, SW_RESTORE)
    user32.SetForegroundWindow(hwnd)
    return True


def fast_type(text, interval=0.02):
    """Tulis cepat ke field aktif."""
    pyautogui.write(text, interval=interval)


# ===== AFTER.EXE (Sidik Jari) =====
def run_after(username, password):
    """Jalankan After.exe, auto login, lalu tunggu proses selesai."""
    print(">>> Menjalankan After.exe ...")
    proc = None

    if not os.path.exists(AFTER_PATH):
        print(f"[!] After.exe tidak ditemukan: {AFTER_PATH}")
        return False

    if not is_process_running(AFTER_PROCESS_NAME):
        proc = subprocess.Popen([AFTER_PATH])
    else:
        print(">>> After.exe sudah berjalan, tidak membuka instance baru")

    if not activate_window(AFTER_PROCESS_NAME, AFTER_LAUNCH_TIMEOUT):
        print("[!] Window After.exe tidak muncul")
        kill_process(AFTER_PROCESS_NAME)
        return False

    # Auto login (username, tab, password, enter)
    pyautogui.write(username, interval=0.02)
    pyautogui.press("tab")
    pyautogui.write(password, interval=0.02)
    pyautogui.press("enter")
    print(">>> Auto login After.exe dikirim")
    time.sleep(1.0)

    activate_window(AFTER_PROCESS_NAME, 2)

    # Tunggu After.exe selesai (pasien selesai sidik jari), dibatasi waktu.
    deadline = time.time() + AFTER_EXIT_TIMEOUT
    while is_process_running(AFTER_PROCESS_NAME) and time.time() < deadline:
        time.sleep(0.25)

    if is_process_running(AFTER_PROCESS_NAME):
        print("[!] After.exe masih berjalan setelah batas waktu")
        return False

    code = proc.wait() if proc else 0
    print(f">>> After.exe selesai, exit code: {code}")
    return code == 0

# # ===== FRISTA =====
# def start_frista_and_login(username, password):
#     """Buka Frista dan login otomatis (tanpa input no_peserta)."""
#     if not os.path.exists(FRISTA_PATH):
#         print(f"[!] Frista.exe tidak ditemukan: {FRISTA_PATH}")
#         return False

#     print(">>> Membuka Frista ...")
#     subprocess.Popen([FRISTA_PATH])

#     if not wait_until(
#         lambda: is_process_running(FRISTA_PROCESS_NAME), FRISTA_LAUNCH_TIMEOUT
#     ):
#         print("[!] Frista gagal start / verifikasi wajah")
#         return False

#     activate_window("Frista.exe", 3)

#     pyautogui.write(username, interval=0.02)
#     pyautogui.press("tab")
#     pyautogui.write(password, interval=0.02)
#     pyautogui.press("enter")
#     print(">>> Auto login Frista dikirim")
#     time.sleep(1.5)

#     return True

# ===== EKSEKUSI =====
def main():
    username, password = get_account_from_db()
    print(f"User: {username}, Password: {'*' * len(password)}")

    if not run_after(username, password):
        print("[!] Sidik jari gagal diproses")
        return 1

    print("[OK] Sidik jari berhasil diproses")
    return 0


if __name__ == "__main__":
    sys.exit(main())
