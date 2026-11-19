"""Automasi BPJS Sidik Jari (After.exe).

Fokus: proses cepat (tidak ada delay tetap yang panjang), window diaktifkan
via Win32, dan selesai/keluar dilaporkan lewat exit code.
"""

import ctypes
import ctypes.wintypes as wintypes
import os
import subprocess
import sys
import time

try:
    import mysql.connector
    from mysql.connector import Error
except Exception:
    mysql = None

    class Error(Exception):
        pass

import psutil
import pyautogui

pyautogui.FAILSAFE = False

DB_CONFIG = {
    "host": "10.30.0.15",
    "database": "sakina_pasien2",
    "user": "user_stg",
    "password": "12344321",
}

FRISTA_PATH = r"C:\frista\Frista.exe"
AFTER_PATH = (
    r"C:\Program Files (x86)\BPJS Kesehatan"
    r"\Aplikasi Sidik Jari BPJS Kesehatan\After.exe"
)

AFTER_PROCESS_NAME = "After.exe"
FRISTA_PROCESS_NAME = "Frista.exe"

POLL_INTERVAL = 0.01
AFTER_LAUNCH_TIMEOUT = 3
# AFTER_LOGIN_TIMEOUT = 12
AFTER_EXIT_TIMEOUT = 180
FRISTA_LAUNCH_TIMEOUT = 10
MAX_AFTER_ATTEMPTS = 1
FAST_FAIL_AFTER_LOGIN = 3

FRISTA_SUCCESS_TEXTS = (
    "peserta telah terdaftar hari ini",
    "peserta sudah terdaftar",
)

FRISTA_FAIL_TEXTS = (
    "tidak valid",
    "tidak ditemukan",
    "tidak sesuai",
    "belum terdaftar",
    "gagal",
    "penolakan",
)

DEFAULT_USER = None
DEFAULT_PASSWORD = None

user32 = ctypes.windll.user32
SW_RESTORE = 9

def get_account_from_db():
    """Ambil satu account aktif (tanpa no_peserta)."""
    if mysql is None:
        print("[!] mysql.connector tidak tersedia, memakai default")
        return DEFAULT_USER, DEFAULT_PASSWORD
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
    except Exception as exc:
        print(f"[!] Error ambil akun: {exc}, memakai default")
    finally:
        if cursor is not None:
            try:
                cursor.close()
            except Exception:
                pass
        if connection is not None:
            try:
                if connection.is_connected():
                    connection.close()
            except Exception:
                pass
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
    """Tutup proses secepat mungkin tanpa menunggu (taskkill /F /T detached)."""
    lower = name.lower()
    for proc in psutil.process_iter(["name"]):
        if (proc.info["name"] or "").lower() == lower:
            try:
                proc.kill()
            except Exception:
                pass
    try:
        subprocess.Popen(
            ["taskkill", "/IM", name, "/F", "/T"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0),
        )
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
        if proc is not None:
            kill_process(AFTER_PROCESS_NAME)
        return False

    login_time = time.time()
    pyautogui.write(username, interval=0.02)
    pyautogui.press("tab")
    pyautogui.write(password, interval=0.02)
    pyautogui.press("enter")
    print(">>> Auto login After.exe dikirim")

    fast_deadline = login_time + FAST_FAIL_AFTER_LOGIN
    while time.time() < fast_deadline:
        if not is_process_running(AFTER_PROCESS_NAME):
            print("[!] After.exe tertutup cepat setelah login")
            return False
        time.sleep(0.01)

    activate_window(AFTER_PROCESS_NAME, 1)

    deadline = time.time() + AFTER_EXIT_TIMEOUT
    while is_process_running(AFTER_PROCESS_NAME) and time.time() < deadline:
        time.sleep(0.02)

    if is_process_running(AFTER_PROCESS_NAME):
        print("[!] After.exe masih berjalan setelah batas waktu")
        kill_process(AFTER_PROCESS_NAME)
        return False

    if proc is None:
        print("[!] After.exe ditutup/selesai (instance lama), status tidak pasti")
        return False

    code = proc.wait()
    print(f">>> After.exe selesai, exit code: {code}")
    if (time.time() - login_time) < FAST_FAIL_AFTER_LOGIN:
        print("[!] After.exe tertutup terlalu cepat setelah login")
        return False
    return code == 0

def _mask_nomor(nomor):
    s = str(nomor or "")
    if len(s) <= 12:
        return "*" * len(s)
    return s[:4] + ("*" * (len(s) - 12)) + s[-8:]


def get_frista_texts():
    """Baca teks UI window Frista (best-effort, untuk deteksi popup hasil)."""
    ps = r"""
$ErrorActionPreference='Stop'
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
$targets=@(Get-Process -Name Frista -ErrorAction SilentlyContinue | ForEach-Object { $_.Id })
if($targets.Count -eq 0){ exit 1 }
$cond=[System.Windows.Automation.Condition]::TrueCondition
$out=@()
foreach($p in (Get-Process -Name Frista -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 })){
  try{
    $root=[System.Windows.Automation.AutomationElement]::FromHandle($p.MainWindowHandle)
    foreach($e in $root.FindAll([System.Windows.Automation.TreeScope]::Descendants,$cond)){
      $n=$e.Current.Name
      if($n -and $n.Length -gt 1){ $out += $n }
    }
  }catch{}
}
($out | Select-Object -Unique) -join ' ~ '
"""
    try:
        r = subprocess.run(
            ["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", ps],
            capture_output=True, text=True, timeout=3,
            creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0),
        )
        return (r.stdout or "").lower()
    except Exception:
        return ""


def get_frista_texts_ocr():
    """Fallback OCR (belum tersedia): kembalikan teks kosong."""
    return ""


def _rapikan_teks(teks):
    """Lowercase, ubah pemisah '~' jadi spasi, rapatkan spasi."""
    try:
        return " ".join(str(teks or "").lower().replace("~", " ").split())
    except Exception:
        return ""


def _is_frista_terdaftar(texts):
    """True hanya bila ada 'Peserta telah terdaftar hari ini'/'Peserta sudah terdaftar'."""
    t = _rapikan_teks(texts)
    return any(k in t for k in FRISTA_SUCCESS_TEXTS)


def _is_frista_gagal(texts):
    """True bila ada teks hasil gagal (selain teks sukses)."""
    t = _rapikan_teks(texts)
    return any(k in t for k in FRISTA_FAIL_TEXTS)


# ===== FRISTA =====
def start_frista_and_login(username, password, nomor=None, result_file=None):
    """Buka Frista, login otomatis, isi no peserta, dan deteksi hasil jika diberikan."""
    if not os.path.exists(FRISTA_PATH):
        print(f"[!] Frista.exe tidak ditemukan: {FRISTA_PATH}")
        return False

    if not is_process_running(FRISTA_PROCESS_NAME):
        print(">>> Membuka Frista ...")
        subprocess.Popen([FRISTA_PATH])
    else:
        print(">>> Frista sudah berjalan, lanjut pengisian otomatis")

    shown = False
    deadline = time.time() + FRISTA_LAUNCH_TIMEOUT
    while time.time() < deadline:
        hwnd = find_window(FRISTA_PROCESS_NAME)
        if hwnd:
            user32.ShowWindow(hwnd, SW_RESTORE)
            user32.BringWindowToTop(hwnd)
            user32.SetForegroundWindow(hwnd)
            shown = True
            break
        if not is_process_running(FRISTA_PROCESS_NAME):
            time.sleep(0.01)
            continue
        time.sleep(0.01)

    if not shown and not wait_until(
        lambda: is_process_running(FRISTA_PROCESS_NAME), 2
    ):
        print("[!] Frista gagal start")
        return False

    try:
        time.sleep(0.1)
        if not activate_window(FRISTA_PROCESS_NAME, 2):
            hwnd = find_window(FRISTA_PROCESS_NAME)
            if hwnd:
                user32.ShowWindow(hwnd, SW_RESTORE)
                user32.BringWindowToTop(hwnd)
                user32.SetForegroundWindow(hwnd)
        hwnd = find_window(FRISTA_PROCESS_NAME)
        if hwnd:
            user32.BringWindowToTop(hwnd)
            user32.SetForegroundWindow(hwnd)

        old_pause = pyautogui.PAUSE
        pyautogui.PAUSE = 0
        try:
            pyautogui.click(667, 444)
            pyautogui.hotkey("ctrl", "a")
            pyautogui.write(username, interval=0)

            pyautogui.click(669, 513)
            pyautogui.hotkey("ctrl", "a")
            pyautogui.write(password, interval=0)

            pyautogui.click(717, 602)
            print(">>> Auto login Frista dikirim (koordinat)")

            if nomor:
                time.sleep(1.0)
                activate_window(FRISTA_PROCESS_NAME, 3)
                hwnd = find_window(FRISTA_PROCESS_NAME)
                if hwnd:
                    user32.BringWindowToTop(hwnd)
                    user32.SetForegroundWindow(hwnd)
                time.sleep(0.1)
                pyautogui.click(893, 330)
                pyautogui.hotkey("ctrl", "a")
                pyautogui.write(str(nomor), interval=0)
                pyautogui.press("enter")
                print(f">>> No peserta dikirim: {_mask_nomor(nomor)}")

                wait_total = 10
                batal_coords = [
                    (1041, 562), (1127, 584), (985, 575), (1099, 561),
                    (940, 559), (1038, 560), (1133, 575), (1111, 580),
                ]
                try:
                    import tkinter as tk

                    transparent = "#010203"
                    root = tk.Tk()
                    root.attributes("-fullscreen", True)
                    root.configure(bg=transparent)
                    root.attributes("-transparentcolor", transparent)
                    root.attributes("-topmost", True)
                    root.overrideredirect(True)
                    label = tk.Label(
                        root,
                        text=str(wait_total),
                        fg="white",
                        bg=transparent,
                        font=("Arial", 160, "bold"),
                    )
                    label.place(relx=0.5, rely=0.5, anchor="center")
                    sub = tk.Label(
                        root,
                        text=(
                            "Silakan arahkan wajah Anda ke kamera.\n"
                            "Pastikan kotak berwarna biru muncul dengan jelas.\n\n"
                            "Mohon tunggu beberapa detik hingga proses\n"
                            "pengambilan foto selesai."
                        ),
                        fg="black",
                        bg=transparent,
                        font=("Courier New", 12, "bold"),
                        justify="center",
                    )
                    sub.place(relx=0.5, rely=0.7, anchor="center")

                    state = {"n": wait_total}

                    def _refill_nomor():
                        try:
                            activate_window(FRISTA_PROCESS_NAME, 1)
                            hwnd = find_window(FRISTA_PROCESS_NAME)
                            if hwnd:
                                user32.ShowWindow(hwnd, SW_RESTORE)
                                user32.BringWindowToTop(hwnd)
                                user32.SetForegroundWindow(hwnd)
                            time.sleep(0.1)
                            pyautogui.click(893, 330)
                            time.sleep(0.05)
                            pyautogui.hotkey("ctrl", "a")
                            pyautogui.press("delete")
                            pyautogui.write(str(nomor), interval=0)
                            pyautogui.press("enter")
                        except Exception:
                            pass

                    def _poll_batal():
                        try:
                            down = bool(user32.GetAsyncKeyState(0x01) & 0x8000)
                            if down:
                                pt = wintypes.POINT()
                                if user32.GetCursorPos(ctypes.byref(pt)):
                                    for bx, by in batal_coords:
                                        if abs(pt.x - bx) <= 50 and abs(pt.y - by) <= 50:
                                            try:
                                                root.withdraw()
                                                root.update()
                                            except Exception:
                                                pass
                                            _refill_nomor()
                                            print(f">>> Batal terdeteksi, no peserta diisi ulang: {_mask_nomor(nomor)}")
                                            try:
                                                root.deiconify()
                                                root.attributes("-topmost", True)
                                                root.attributes("-fullscreen", True)
                                            except Exception:
                                                pass
                                            break
                        except Exception:
                            pass
                        try:
                            root.after(100, _poll_batal)
                        except Exception:
                            pass

                    def _tick():
                        if state["n"] <= 0:
                            try:
                                root.destroy()
                            except Exception:
                                pass
                            return
                        label.config(text=str(state["n"]))
                        state["n"] -= 1
                        root.after(1000, _tick)

                    root.after(100, _poll_batal)
                    root.after(1000, _tick)
                    root.mainloop()
                except Exception:
                    for _ in range(wait_total):
                        time.sleep(1)

                activate_window(FRISTA_PROCESS_NAME, 2)
                hwnd = find_window(FRISTA_PROCESS_NAME)
                if hwnd:
                    user32.BringWindowToTop(hwnd)
                    user32.SetForegroundWindow(hwnd)
                pyautogui.click(1032, 460)
                print(">>> Ambil foto dikirim (koordinat 1032,460)")

                print(">>> Monitoring: nomor tetap terisi, deteksi hasil Frista...")
                monitor_deadline = time.time() + 130  # detik
                last_refill = time.time()
                last_text_check = 0
                success = False
                failed = False

                def _refill_now(reason=""):
                    activate_window(FRISTA_PROCESS_NAME, 2)
                    hwnd = find_window(FRISTA_PROCESS_NAME)
                    if hwnd:
                        user32.ShowWindow(hwnd, SW_RESTORE)
                        user32.BringWindowToTop(hwnd)
                        user32.SetForegroundWindow(hwnd)
                    time.sleep(0.1)
                    pyautogui.click(893, 330)
                    time.sleep(0.05)
                    pyautogui.hotkey("ctrl", "a")
                    pyautogui.press("delete")
                    pyautogui.write(str(nomor), interval=0)
                    pyautogui.press("enter")
                    if reason:
                        print(f">>> {reason}, no peserta diisi ulang: {_mask_nomor(nomor)}")

                while time.time() < monitor_deadline:
                    if not is_process_running(FRISTA_PROCESS_NAME):
                        print(">>> Frista tertutup tanpa teks sukses")
                        break

                    now = time.time()

                    if now - last_text_check >= 0.5:
                        last_text_check = now
                        try:
                            texts = get_frista_texts()
                            if not _is_frista_terdaftar(texts):
                                texts = texts + " " + get_frista_texts_ocr()
                            if _is_frista_terdaftar(texts):
                                print(">>> Hasil Frista: Peserta telah terdaftar hari ini / sudah terdaftar (berhasil)")
                                pyautogui.click(819, 501)
                                time.sleep(0.05)
                                pyautogui.click(1301, 205)
                                success = True
                                break
                            if _is_frista_gagal(texts):
                                print(">>> Hasil Frista gagal (teks validasi tidak cocok)")
                                failed = True
                                break
                        except Exception:
                            pass

                    if not success and now - last_refill >= 8.0:
                        try:
                            texts = get_frista_texts()
                            if _is_frista_terdaftar(texts):
                                print(">>> Hasil Frista: Peserta telah terdaftar hari ini / sudah terdaftar (berhasil)")
                                pyautogui.click(819, 501)
                                time.sleep(0.05)
                                pyautogui.click(1301, 205)
                                success = True
                                break
                            if _is_frista_gagal(texts):
                                print(">>> Hasil Frista gagal (teks validasi tidak cocok)")
                                failed = True
                                break
                        except Exception:
                            pass
                        if not success:
                            _refill_now()
                            last_refill = time.time()

                    down = bool(user32.GetAsyncKeyState(0x01) & 0x8000)
                    if down:
                        pt = wintypes.POINT()
                        if user32.GetCursorPos(ctypes.byref(pt)):
                            for bx, by in batal_coords:
                                if abs(pt.x - bx) <= 60 and abs(pt.y - by) <= 60:
                                    time.sleep(0.2)
                                    _refill_now("Batal terdeteksi")
                                    last_refill = time.time()
                                    break
                    time.sleep(0.05)

                if result_file:
                    try:
                        with open(result_file, "w", encoding="utf-8") as rf:
                            rf.write("SUCCESS" if success else "FAILED")
                    except Exception:
                        pass
                if success:
                    print(">>> FRISTA_SUCCESS")
                elif failed:
                    print(">>> FRISTA_FAILED")
                else:
                    print(">>> FRISTA_FAILED (teks sukses tidak ditemukan)")

                if is_process_running(FRISTA_PROCESS_NAME):
                    kill_process(FRISTA_PROCESS_NAME)
                    print(">>> Frista ditutup")
        finally:
            pyautogui.PAUSE = old_pause
    except Exception as exc:
        print(f"[!] Gagal auto-login/isi Frista: {exc}")

    return True


# ===== EKSEKUSI =====
def main():
    username, password = get_account_from_db()
    print(f"User: {username}, Password: {'*' * len(password)}")

    for attempt in range(1, MAX_AFTER_ATTEMPTS + 1):
        print(f">>> Percobaan sidik jari {attempt}/{MAX_AFTER_ATTEMPTS}")
        if run_after(username, password):
            print("[OK] Sidik jari berhasil diproses")
            return 0

        print(f"[!] Sidik jari gagal pada percobaan {attempt}")
        if is_process_running(AFTER_PROCESS_NAME):
            kill_process(AFTER_PROCESS_NAME)
        if attempt < MAX_AFTER_ATTEMPTS:
            time.sleep(0.3)

    print("[!] Sidik jari gagal, membuka Frista")
    if start_frista_and_login(username, password):
        return 2

    print("[!] Gagal membuka Frista setelah sidik jari gagal 1x")
    return 1


if __name__ == "__main__":
    args = sys.argv[1:]
    cli_user = None
    cli_pass = None
    cli_nomor = None
    cli_result = None
    i = 0
    while i < len(args):
        if args[i] in ("--username", "-u") and i + 1 < len(args):
            cli_user = args[i + 1]
            i += 2
        elif args[i] in ("--password", "-p") and i + 1 < len(args):
            cli_pass = args[i + 1]
            i += 2
        elif args[i] in ("--nomor", "-n", "--no-peserta") and i + 1 < len(args):
            cli_nomor = args[i + 1]
            i += 2
        elif args[i] in ("--result-file", "-r") and i + 1 < len(args):
            cli_result = args[i + 1]
            i += 2
        else:
            i += 1

    if any(a in ("--frista", "--frista-only", "frista") for a in args):
        if cli_user and cli_pass:
            username, password = cli_user, cli_pass
        else:
            try:
                username, password = get_account_from_db()
            except Exception as exc:
                print(f"[!] Gagal ambil akun: {exc}")
                sys.exit(1)
        print(f"User: {username}, Password: {'*' * len(password)}")
        ok = start_frista_and_login(username, password, nomor=cli_nomor, result_file=cli_result)
        sys.exit(2 if ok else 1)

    try:
        sys.exit(main())
    except Exception as exc:
        print(f"[!] Gagal: {exc}")
        sys.exit(1)
