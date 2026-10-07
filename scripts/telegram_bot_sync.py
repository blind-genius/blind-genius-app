#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Blind Genius Telegram Channel Auto-Sync Bot
3-Layer Security Pipeline for automatic audio ingestion into Blind Genius App:
Layer 1: Reject forwarded messages.
Layer 2: Filter audio/voice with channel author metadata.
Layer 3: Interactive confirmation in owner's private chat before publishing.
"""

import os
import sys
import json
import time
import base64
import urllib.request
import urllib.error
import subprocess
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad, unpad

# Load local .env if present (ignored by git)
env_file = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), ".env")
if os.path.exists(env_file):
    with open(env_file, "r", encoding="utf-8") as ef:
        for line in ef:
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                k, v = line.split("=", 1)
                os.environ.setdefault(k.strip(), v.strip())

# Configuration from Environment Variables
BOT_TOKEN = os.environ.get("BOT_TOKEN", "")
OWNER_CHAT_ID = int(os.environ.get("OWNER_CHAT_ID", "1474213563"))
CHANNEL_ID = int(os.environ.get("CHANNEL_ID", "-1004321749584")) # @Blind_genius1
GITHUB_TOKEN = os.environ.get("GITHUB_TOKEN", "")
GITHUB_REPO = os.environ.get("GITHUB_REPO", "blind-genius/blind-genius-app")
ENCRYPTION_KEY = b"BlindGeniusMusicSecretKey2026!@#" # Exactly 32 bytes for AES-256


BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
METADATA_JSON_PATH = os.path.join(BASE_DIR, "tracks_metadata.json")
METADATA_ENC_PATH = os.path.join(BASE_DIR, "tracks_metadata.enc")

# In-memory pending approval store {message_id: post_data}
pending_approvals = {}

def send_telegram(method, payload):
    url = f"https://api.telegram.org/bot{BOT_TOKEN}/{method}"
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        url, data=data,
        headers={"Content-Type": "application/json", "User-Agent": "BlindGeniusBot"}
    )
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            return json.loads(resp.read().decode())
    except Exception as e:
        print(f"Telegram API Error ({method}): {e}")
        return None

def encrypt_metadata_file():
    with open(METADATA_JSON_PATH, "r", encoding="utf-8") as f:
        plain_text = f.read()
    
    iv = os.urandom(16)
    cipher = AES.new(ENCRYPTION_KEY, AES.MODE_CBC, iv)
    padded = pad(plain_text.encode("utf-8"), AES.block_size)
    ciphertext = cipher.encrypt(padded)
    combined = base64.b64encode(iv + ciphertext).decode("utf-8")
    
    with open(METADATA_ENC_PATH, "w", encoding="utf-8") as f:
        f.write(combined)
    print("Encrypted tracks_metadata.enc successfully.")
    return combined

def handle_channel_post(post):
    msg_id = post.get("message_id")
    print(f"\n[Channel Post] Detected message ID: {msg_id}")

    # --- LAYER 1: Forward filter ---
    if post.get("forward_origin") or post.get("forward_from") or post.get("forward_from_chat"):
        print("  -> LAYER 1 REJECTED: Message is forwarded from another source.")
        return

    # --- LAYER 2: Media Type & Content Filter ---
    audio = post.get("audio") or post.get("voice")
    if not audio:
        doc = post.get("document", {})
        if doc.get("mime_type", "").startswith("audio/") or doc.get("file_name", "").endswith(".mp3"):
            audio = doc

    if not audio:
        print("  -> LAYER 2 REJECTED: Post does not contain an audio track.")
        return

    caption = post.get("caption", "").strip()
    file_name = audio.get("file_name") or f"audio_msg_{msg_id}.mp3"
    duration_secs = audio.get("duration", 180)
    mins = duration_secs // 60
    secs = duration_secs % 60
    duration_str = f"{mins:02d}:{secs:02d}"

    title = audio.get("title") or file_name.replace(".mp3", "")
    if caption:
        first_line = caption.split("\n")[0]
        if len(first_line) < 60:
            title = first_line

    post_data = {
        "id": msg_id,
        "message_id": msg_id,
        "file_id": audio.get("file_id"),
        "title": title,
        "filename": file_name,
        "caption": caption,
        "duration": duration_str,
        "duration_seconds": duration_secs,
        "telegram_link": f"https://t.me/blind_genius1/{msg_id}",
    }

    pending_approvals[msg_id] = post_data

    # --- LAYER 3: Interactive Confirmation in Owner's Private Chat ---
    text = (
        f"🎵 <b>قطعه صوتی جدید در کانال رصد شد</b>\n\n"
        f"📌 <b>عنوان:</b> {title}\n"
        f"⏱ <b>مدت زمان:</b> {duration_str}\n"
        f"📁 <b>نام فایل:</b> {file_name}\n"
        f"🔗 <b>لینک تلگرام:</b> https://t.me/blind_genius1/{msg_id}\n\n"
        f"آیا این قطعه اثر متعلق به خود شماست و به آرشیو رسمی اپلیکیشن اضافه شود؟"
    )

    keyboard = {
        "inline_keyboard": [
            [
                {"text": "✅ بله، به اپلیکیشن اضافه کن", "callback_data": f"approve_{msg_id}"},
                {"text": "❌ خیر، اثر دیگران است", "callback_data": f"reject_{msg_id}"}
            ]
        ]
    }

    send_telegram("sendMessage", {
        "chat_id": OWNER_CHAT_ID,
        "text": text,
        "parse_mode": "HTML",
        "reply_markup": keyboard
    })
    print(f"  -> LAYER 3 PENDING: Confirmation request sent to owner ({OWNER_CHAT_ID}).")

def process_approval(msg_id, callback_query_id):
    if msg_id not in pending_approvals:
        send_telegram("answerCallbackQuery", {
            "callback_query_id": callback_query_id,
            "text": "اطلاعات این قطعه منقضی شده است.",
            "show_alert": True
        })
        return

    post_data = pending_approvals.pop(msg_id)
    send_telegram("answerCallbackQuery", {
        "callback_query_id": callback_query_id,
        "text": "در حال پردازش و آپلود قطعه به گیت‌هاب..."
    })

    send_telegram("sendMessage", {
        "chat_id": OWNER_CHAT_ID,
        "text": f"⏳ قطعه «{post_data['title']}» تأیید شد. در حال دریافت از سرور تلگرام و انتشار در گیت‌هاب..."
    })

    # 1. Download file from Telegram
    file_info = send_telegram("getFile", {"file_id": post_data["file_id"]})
    if not file_info or not file_info.get("ok"):
        send_telegram("sendMessage", {
            "chat_id": OWNER_CHAT_ID,
            "text": "❌ خطا در دریافت لینک دانلود فایل از تلگرام."
        })
        return

    file_path_tg = file_info["result"]["file_path"]
    download_url = f"https://api.telegram.org/file/bot{BOT_TOKEN}/{file_path_tg}"
    local_download = os.path.join(BASE_DIR, f"temp_{msg_id}.mp3")

    req = urllib.request.Request(download_url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, timeout=120) as r, open(local_download, "wb") as f:
        f.write(r.read())

    # 2. Upload to GitHub Release
    tag_name = f"v1.0.{msg_id}-audio"
    asset_name = f"track_{msg_id}.mp3"
    
    # Create draft release
    headers = {
        "Authorization": f"token {GITHUB_TOKEN}",
        "Accept": "application/vnd.github.v3+json",
        "User-Agent": "BlindGeniusBot"
    }
    create_payload = {
        "tag_name": tag_name,
        "target_commitish": "main",
        "name": f"Blind Genius Audio - Track {msg_id}",
        "body": post_data["caption"] or post_data["title"],
        "draft": True,
        "prerelease": False
    }
    req_create = urllib.request.Request(
        f"https://api.github.com/repos/{GITHUB_REPO}/releases",
        data=json.dumps(create_payload).encode("utf-8"),
        headers=headers,
        method="POST"
    )
    with urllib.request.urlopen(req_create, timeout=15) as resp:
        rel = json.loads(resp.read().decode())
        upload_base = rel["upload_url"].split("{")[0]
        rel_id = rel["id"]

    # Upload via curl
    upload_url = f"{upload_base}?name={asset_name}"
    subprocess.run([
        "curl.exe", "-s", "-S", "-X", "POST",
        "-H", f"Authorization: token {GITHUB_TOKEN}",
        "-H", "Content-Type: audio/mpeg",
        "--data-binary", f"@{local_download}",
        upload_url
    ])

    # Publish release
    req_pub = urllib.request.Request(
        f"https://api.github.com/repos/{GITHUB_REPO}/releases/{rel_id}",
        data=json.dumps({"draft": False}).encode("utf-8"),
        headers=headers,
        method="PATCH"
    )
    urllib.request.urlopen(req_pub, timeout=15)

    if os.path.exists(local_download):
        os.remove(local_download)

    stream_url = f"https://github.com/{GITHUB_REPO}/releases/download/{tag_name}/{asset_name}"

    # 3. Update metadata JSON
    with open(METADATA_JSON_PATH, "r", encoding="utf-8") as f:
        meta_data = json.load(f)

    new_track_entry = {
        "id": msg_id,
        "title": post_data["title"],
        "filename": post_data["filename"],
        "caption": post_data["caption"],
        "tags": [t for t in post_data["caption"].split() if t.startswith("#")],
        "duration": post_data["duration"],
        "telegram_link": post_data["telegram_link"],
        "telegram_message_id": msg_id,
        "stream_url": stream_url
    }
    meta_data.append(new_track_entry)

    with open(METADATA_JSON_PATH, "w", encoding="utf-8") as f:
        json.dump(meta_data, f, ensure_ascii=False, indent=2)

    # 4. Encrypt metadata
    encrypt_metadata_file()

    # 5. Git Commit and Push
    subprocess.run(["git", "add", "tracks_metadata.json", "tracks_metadata.enc"], cwd=BASE_DIR)
    subprocess.run(["git", "commit", "-m", f"feat(tracks): add track {msg_id} - {post_data['title']}"], cwd=BASE_DIR)
    subprocess.run(["git", "push"], cwd=BASE_DIR)

    # 6. Notify owner
    send_telegram("sendMessage", {
        "chat_id": OWNER_CHAT_ID,
        "text": f"🎉 <b>قطعه با موفقیت منتشر شد!</b>\n\n📌 <b>عنوان:</b> {post_data['title']}\n🔗 <b>لینک استریم:</b> {stream_url}\n\nفایل قفل‌شده به روزرسانی شد و تمام کاربران اپلیکیشن بدون نیاز به آپدیت این اثر را دریافت می‌کنند.",
        "parse_mode": "HTML"
    })
    print(f"SUCCESS: Track {msg_id} fully published and synced.")

def poll_telegram_updates(run_once=False):
    offset = 0
    print("Bot polling started. Listening for channel posts and approvals...")
    while True:
        try:
            res = send_telegram("getUpdates", {"offset": offset, "timeout": 10 if not run_once else 1})
            if res and res.get("ok"):
                for update in res.get("result", []):
                    offset = update["update_id"] + 1

                    # Check channel posts
                    if "channel_post" in update:
                        handle_channel_post(update["channel_post"])

                    # Check callbacks (approval buttons)
                    if "callback_query" in update:
                        cb = update["callback_query"]
                        data = cb.get("data", "")
                        from_user = cb.get("from", {}).get("id")
                        if from_user == OWNER_CHAT_ID:
                            if data.startswith("approve_"):
                                msg_id = int(data.split("_")[1])
                                process_approval(msg_id, cb["id"])
                            elif data.startswith("reject_"):
                                msg_id = int(data.split("_")[1])
                                pending_approvals.pop(msg_id, None)
                                send_telegram("answerCallbackQuery", {
                                    "callback_query_id": cb["id"],
                                    "text": "قطعه نادیده گرفته شد."
                                })
                                send_telegram("sendMessage", {
                                    "chat_id": OWNER_CHAT_ID,
                                    "text": "❌ قطعه به عنوان اثر متفرقه علامت‌گذاری و رد شد."
                                })
            if run_once:
                print("One-time polling pass completed.")
                break
            time.sleep(1)
        except KeyboardInterrupt:
            print("\nBot stopped.")
            break
        except Exception as e:
            print(f"Poll loop error: {e}")
            if run_once:
                break
            time.sleep(3)

if __name__ == "__main__":
    is_once = "--once" in sys.argv
    poll_telegram_updates(run_once=is_once)

