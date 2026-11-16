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
    "Anda adalah asisten bantuan khusus Anjungan Pendaftaran Mandiri (APM) RSU Sakina Idaman. "
    "Fungsi Anda WAJIB dan HANYA membantu pasien memilih serta menuntun proses check-in: Cek-in BPJS atau Cek-in Umum. "
    "Anda tidak memiliki fungsi lain. "
    "Aturan mutlak (tidak boleh dilanggar): "
    "1) SELALU bantu dan arahkan pengguna terkait proses check-in BPJS/Umum dengan langkah yang jelas. "
    "2) TOLAK semua permintaan di luar bantuan/panduan check-in APM (percakapan umum, hiburan, opini, pengetahuan umum, diagnosis, saran medis, administrasi lain, teknis di luar APM, atau hal lain apa pun). "
    "Saat menolak, jawab singkat bahwa Anda hanya membantu check-in APM, lalu langsung bantu memilih/menuntun Cek-in BPJS atau Umum. "
    "3) Jangan pernah meminta, menyebutkan, mengulang, menyimpan, atau membagikan data sensitif/pribadi pasien "
    "(nomor BPJS, NIK, nomor rekam medis, nomor booking, nama, alamat, tanggal lahir, nomor telepon, data medis, atau data krusial lainnya). "
    "Jika pengguna mengirim data tersebut, jangan mengulangnya; ingatkan agar tidak dibagikan dan tetap bantu langkah check-in tanpa data itu. "
    "4) Jawab singkat, jelas, ramah dalam Bahasa Indonesia. "
    "5) Panduan Cek-in BPJS: pilih Cek-in BPJS, siapkan kartu BPJS/NIK/No. RM, masukkan/scan nomor di halaman Cek-in BPJS, tekan CEK BPJS, periksa data, ikuti petunjuk sidik jari/Frista bila diminta, lalu lanjut ke Poli atau Loket. "
    "6) Panduan Cek-in Umum: pilih Cek-in Umum, masukkan/scan No. RM/NIK/No. Booking, tekan CARI DATA, periksa data, lalu ikuti petunjuk di layar/ke Poli atau Loket. "
    "7) Jika niat tidak jelas, tanyakan: ingin Cek-in BPJS atau Cek-in Umum, lalu pandu langkahnya."
)

FALLBACK_HELP = (
    "Saya khusus membantu panduan check-in APM (tidak melayani hal lain).\n"
    "Silakan pilih layanan:\n"
    "- Cek-in BPJS: untuk peserta BPJS Kesehatan.\n"
    "- Cek-in Umum: untuk pasien non-BPJS.\n"
    "Ketik/pilih salah satu, saya akan menuntun langkahnya. Jangan bagikan nomor kartu/NIK/RM/data pribadi kepada saya."
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


def _env_bool(name, default):
    v = os.environ.get(name)
    if v is None:
        return default
    return str(v).strip().lower() in ("1", "true", "yes", "on")


def _env_int(name, default):
    try:
        return int(os.environ.get(name, default))
    except Exception:
        return default


def _env_float(name, default):
    try:
        return float(os.environ.get(name, default))
    except Exception:
        return default


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

    temperature = _env_float("GEMINI_TEMPERATURE", 0.7)
    top_p = _env_float("GEMINI_TOP_P", 0.95)
    top_k = _env_int("GEMINI_TOP_K", 40)
    max_tokens = _env_int("GEMINI_MAX_OUTPUT_TOKENS", 2048)
    timeout = _env_int("GEMINI_TIMEOUT", 30)
    retries = max(0, _env_int("GEMINI_MAX_RETRIES", 2))
    enable_thinking = _env_bool("GEMINI_ENABLE_THINKING", True)
    thinking_budget = _env_int("GEMINI_THINKING_BUDGET", 1024)

    generation = {
        "temperature": temperature,
        "topP": top_p,
        "topK": top_k,
        "maxOutputTokens": max_tokens,
    }
    if enable_thinking:
        generation["thinkingConfig"] = {"thinkingBudget": thinking_budget}

    payload = {
        "system_instruction": {"parts": [{"text": SYSTEM_INSTRUCTION}]},
        "contents": contents,
        "generationConfig": generation,
    }
    data = json.dumps(payload).encode("utf-8")

    attempts = retries + 1
    last_err = None
    body = None
    for i in range(attempts):
        try:
            req = urllib.request.Request(
                endpoint,
                data=data,
                headers={"Content-Type": "application/json"},
                method="POST",
            )
            with urllib.request.urlopen(req, timeout=timeout) as resp:
                body = json.loads(resp.read().decode("utf-8"))
            break
        except urllib.error.HTTPError as e:
            last_err = e
            if e.code != 429 and e.code < 500:
                break
        except Exception as e:
            last_err = e
            if i == attempts - 1:
                break
    if body is None:
        return None

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
    model = os.environ.get("GEMINI_MODEL", "gemini-2.5-flash")

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
