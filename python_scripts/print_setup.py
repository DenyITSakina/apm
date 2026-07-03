import pyautogui
import time
import subprocess
import sys

def print_setup_automation():
    """
    Mengotomatisasi Print Setup untuk printer thermal:
    1. Klik dropdown Size di (187, 262)
    2. Pilih ukuran 80(72.1) x 297 mm di (185, 320)
    3. Pilih Landscape di (399, 297)
    4. Klik OK di (366, 350)
    """
    
    print("=" * 60)
    print("🖨️  PRINT SETUP AUTOMATION")
    print("=" * 60)
    
    pyautogui.FAILSAFE = True
    DELAY = 0.5
    
    try:
        # Step 1: Klik dropdown Paper Size
        print("\n📌 Step 1: Mengklik dropdown Paper Size...")
        pyautogui.click(187, 262)
        time.sleep(DELAY)
        print("   ✅ Dropdown Size diklik")
        
        # Step 2: Pilih ukuran 80(72.1) x 297 mm
        print("\n📌 Step 2: Memilih ukuran 80(72.1) x 297 mm...")
        pyautogui.click(185, 320)
        time.sleep(DELAY)
        print("   ✅ Ukuran 80(72.1) x 297 mm dipilih")
        
        # Step 3: Pilih Landscape
        print("\n📌 Step 3: Memilih orientasi Landscape...")
        pyautogui.click(399, 297)
        time.sleep(DELAY)
        print("   ✅ Landscape dipilih")
        
        # Step 4: Klik OK
        print("\n📌 Step 4: Mengklik tombol OK...")
        pyautogui.click(366, 350)
        time.sleep(DELAY)
        print("   ✅ Tombol OK diklik")
        
        print("\n" + "=" * 60)
        print("✅ PRINT SETUP AUTOMATION SELESAI!")
        return True
        
    except Exception as e:
        print(f"\n❌ Error: {e}")
        return False

if __name__ == "__main__":
    print("\n🚀 Menjalankan Print Setup Automation...")
    print("⚠️  Pastikan dialog Print Setup sudah terbuka!")
    print("⏳ Script akan dimulai dalam 3 detik...")
    
    for i in range(3, 0, -1):
        print(f"   {i}...")
        time.sleep(1)
    
    print_setup_automation()