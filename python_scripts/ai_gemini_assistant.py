#!/usr/bin/env python3
"""
Asisten AI (Gemini) untuk APM RSU Sakina Idaman.
- Hanya membantu panduan/navigasi check-in (BPJS/Umum).
- Tidak meminta/menyebutkan/membagikan data sensitif (nomor BPJS, NIK, RM, nama, alamat, dll).
- Mengembalikan JSON: {"reply": "...", "action": "bpjs"|"umum"|null}

Konfigurasi:
  - Env: GEMINI_API_KEY (wajib untuk panggilan Gemini), opsional GEMINI_MODEL
  - Argumen stdin: JSON {"message": "...", "history": [{"role":"user"|"model","text":"..."}]}
    atau argumen CLI: --message "..." [--api-key KEY]
"""

import json
import os
import re
import sys
import urllib.error
import urllib.request

SYSTEM_INSTRUCTION = (
    "Anda adalah asisten bantuan untuk Anjungan Pendaftaran Mandiri (APM) RSU Sakina Idaman. "
    "Tugas Anda HANYA membantu pasien memilih dan menuntun proses check-in: Cek-in BPJS dan Cek-in Umum. "
    "Aturan ketat: "
    "1) Jangan pernah meminta, menyebutkan, mengulang, atau membagikan data sensitif/pribadi pasien "
    "(nomor BPJS, NIK, nomor rekam medis, nomor booking, nama, alamat, tanggal lahir, nomor telepon, data medis). "
    "2) Jangan melakukan hal di luar bantuan navigasi/panduan check-in APM. Tolak dengan sopan dan arahkan ke petugas. "
    "3) Jawab singkat, jelas, ramah dalam Bahasa Indonesia. "
    "4) Jika pasien ingin check-in BPJS: sarankan buka Cek-in BPJS dan tuntun langkahnya "
    "(siapkan kartu/NIK/RM, masukkan/scan nomor, tekan CEK BPJS, periksa data, ikuti petunjuk sidik jari/Frista jika diminta, lanjut ke poli/loket). "
    "5) Jika pasien ingin check-in Umum: sarankan buka Cek-in Umum dan tuntun langkah serupa. "
    "6) Jika niat tidak jelas, tanyakan: ingin Cek-in BPJS atau Cek-in Umum."
)

FALLBACK_HELP = (
    "Saya hanya dapat membantu panduan check-in APM.\n"
    "- Cek-in BPJS: untuk peserta BPJS Kesehatan.\n"
    "- Cek-in Umum: untuk pasien non-BPJS.\n"
    "Pilih layanan yang sesuai dan ikuti petunjuk di layar. Jangan bagikan nomor kartu/NIK/RM kepada saya."
)


def sanitize(text: str) -> str:
    if not text:
        return ""
    # Redaksi deretan digit >= 6 agar data sensitif tidak bocor.
    return re.sub(r"\b\d{6,}\b", "[disembunyikan]", str(text))


def detect_intent(text: str):
    t = (text or "").lower()
    has_bpjs = ("bpjs" in t) or ("jkn" in t)
    has_umum = ("umum" in t) or ("non-bpjs" in t) or ("non bpjs" in t)
    if has_bpjs and not has_umum:
        return "bpjs"
    if has_umum and not has_bpjs:
        return "umum"
    # heuristik lokal pesan user
    if "bpjs" in t or "jkn" in t:
        return "bpjs"
    if "umum" in t:
        return "umum"
    return None


def local_reply(action):
    if action == "bpjs":
        return (
            "Baik, saya bantu ke Cek-in BPJS.\n"
            "Langkah: 1) Masukkan/scan nomor kartu BPJS, NIK, atau No. RM. "
            "2) Tekan CEK BPJS. 3) Periksa data lalu pilih Lanjut ke Poli atau ke Loket sesuai arahan. "
            "Silakan buka halaman Cek-in BPJS."
        )
    if action == "umum":
        return (
            "Baik, saya bantu ke Cek-in Umum.\n"
            "Langkah: 1) Masukkan/scan No. RM, NIK, atau No. Booking. "
            "2) Tekan CARI DATA. 3) Periksa data lalu ikuti petunjuk di layar. "
            "Silakan buka halaman Cek-in Umum."
        )
    return FALLBACK_HELP


def call_gemini(message, history, api_key, model):
    endpoint = (
        f"https://generativelanguage.googleapis.com/v1beta/models/"
        f"{model}:generateContent?key={api_key}"
    )
    contents = []
    for h in history or []:
        role = "user" if h.get("role") == "user" else "model"
        txt = sanitize(h.get("text", ""))
        if not txt:
            continue
        contents.append({"role": role, "parts": [{"text": txt}]})
    contents.append({"role": "user", "parts": [{"text": sanitize(message)}]})

    payload = {
        "system_instruction": {"parts": [{"text": SYSTEM_INSTRUCTION}]},
        "contents": contents,
        "generationConfig": {"temperature": 0.2, "maxOutputTokens": 256},
    }
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        endpoint, data=data, headers={"Content-Type": "application/json"}, method="POST"
    )
    with urllib.request.urlopen(req, timeout=15) as resp:
        body = json.loads(resp.read().decode("utf-8"))
    candidates = body.get("candidates") or []
    if not candidates:
        return None
    parts = (((candidates[0] or {}).get("content") or {}).get("parts")) or []
    for p in parts:
        if isinstance(p, dict) and p.get("text"):
            return str(p["text"]).strip()
    return None


def main():
    # Input: stdin JSON diprioritaskan, fallback arg --message
    payload = {}
    if not sys.stdin.isatty():
        try:
            raw = sys.stdin.read()
            if raw.strip():
                payload = json.loads(raw)
        except Exception:
            payload = {}

    message = payload.get("message")
    history = payload.get("history") or []
    api_key = payload.get("api_key") or os.environ.get("GEMINI_API_KEY", "")

    # CLI fallback
    args = sys.argv[1:]
    i = 0
    while i < len(args):
        if args[i] in ("--message", "-m") and i + 1 < len(args):
            message = message or args[i + 1]
            i += 2
        elif args[i] in ("--api-key", "-k") and i + 1 < len(args):
            api_key = api_key or args[i + 1]
            i += 2
        else:
            i += 1

    message = (message or "").strip()
    model = os.environ.get("GEMINI_MODEL", "gemini-1.5-flash")

    action = None
    reply = None
    if not message:
        reply = FALLBACK_HELP
    elif not api_key:
        action = detect_intent(message)
        reply = local_reply(action)
    else:
        try:
            reply = call_gemini(message, history, api_key, model)
        except Exception:
            reply = None
        if not reply:
            action = detect_intent(message)
            reply = local_reply(action)
        else:
            reply = sanitize(reply)

    if not action:
        action = detect_intent((reply or "") + " " + (message or ""))

    out = {"reply": reply or FALLBACK_HELP, "action": action}
    sys.stdout.write(json.dumps(out, ensure_ascii=False))
    sys.stdout.flush()


if __name__ == "__main__":
    main()
