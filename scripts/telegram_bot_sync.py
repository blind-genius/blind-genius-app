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
PENDING_FILE = os.path.join(BASE_DIR, "pending_approvals.json")

def load_pending():
    if os.path.exists(PENDING_FILE):
        try:
            with open(PENDING_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            return {}
    return {}

def save_pending(data):
    try:
        with open(PENDING_FILE, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
    except Exception as e:
        print(f"Error saving pending approvals: {e}")

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

    # Check if already in tracks_metadata.json
    if os.path.exists(METADATA_JSON_PATH):
        try:
            with open(METADATA_JSON_PATH, "r", encoding="utf-8") as f:
                existing = json.load(f)
                for t in existing:
                    if t.get("telegram_message_id") == msg_id or t.get("id") == msg_id:
                        print(f"  -> ALREADY IMPORTED: Track {msg_id} is already in tracks_metadata.json.")
                        return
        except Exception:
            pass

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

    title = audio.get("title") or file_name.replace(".mp3", "").replace("-", " ").replace("_", " ").title()
    if caption:
        lines = [ln.strip() for ln in caption.split("\n") if ln.strip()]
        found_specific = False
        for line in lines:
            if any(kw in line for kw in ["قطعه", "آهنگ", "موسیقی"]) and len(line) < 80:
                title = line
                found_specific = True
                break
        if not found_specific and lines and len(lines[0]) < 60:
            title = lines[0]

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

    pending = load_pending()
    if str(msg_id) in pending:
        print(f"  -> ALREADY PENDING: Track {msg_id} is already awaiting confirmation.")
        return

    pending[str(msg_id)] = post_data
    save_pending(pending)

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

    # Persist pending file to git if running in GitHub Actions
    if os.environ.get("GITHUB_ACTIONS"):
        subprocess.run(["git", "config", "user.name", "github-actions[bot]"], cwd=BASE_DIR)
        subprocess.run(["git", "config", "user.email", "github-actions[bot]@users.noreply.github.com"], cwd=BASE_DIR)
        subprocess.run(["git", "add", "pending_approvals.json"], cwd=BASE_DIR)
        subprocess.run(["git", "commit", "-m", f"chore: register pending track {msg_id}"], cwd=BASE_DIR)
        push_remote = f"https://x-access-token:{GITHUB_TOKEN}@github.com/{GITHUB_REPO}.git" if GITHUB_TOKEN else "origin"
        subprocess.run(["git", "push", push_remote, "main"], cwd=BASE_DIR)

def process_approval(msg_id, callback_query_id):
    pending = load_pending()
    if str(msg_id) not in pending:
        send_telegram("answerCallbackQuery", {
            "callback_query_id": callback_query_id,
            "text": "اطلاعات این قطعه یافت نشد یا قبلاً پردازش شده است.",
            "show_alert": True
        })
        return

    post_data = pending.pop(str(msg_id))
    save_pending(pending)

    send_telegram("answerCallbackQuery", {
        "callback_query_id": callback_query_id,
        "text": "در حال دریافت و آپلود فایل صوتی به گیت‌هاب..."
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

    # Native Python Binary Upload
    upload_url = f"{upload_base}?name={asset_name}"
    with open(local_download, "rb") as bf:
        file_bytes = bf.read()
    req_upload = urllib.request.Request(
        upload_url,
        data=file_bytes,
        headers={
            "Authorization": f"token {GITHUB_TOKEN}",
            "Content-Type": "audio/mpeg",
            "User-Agent": "BlindGeniusBot"
        },
        method="POST"
    )
    with urllib.request.urlopen(req_upload, timeout=180) as r:
        pass

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
    subprocess.run(["git", "config", "user.name", "github-actions[bot]"], cwd=BASE_DIR)
    subprocess.run(["git", "config", "user.email", "github-actions[bot]@users.noreply.github.com"], cwd=BASE_DIR)
    subprocess.run(["git", "add", "tracks_metadata.json", "tracks_metadata.enc", "pending_approvals.json"], cwd=BASE_DIR)
    subprocess.run(["git", "commit", "-m", f"feat(tracks): add track {msg_id} - {post_data['title']}"], cwd=BASE_DIR)
    push_remote = f"https://x-access-token:{GITHUB_TOKEN}@github.com/{GITHUB_REPO}.git" if GITHUB_TOKEN else "origin"
    subprocess.run(["git", "push", push_remote, "main"], cwd=BASE_DIR)

    # 6. Notify owner
    send_telegram("sendMessage", {
        "chat_id": OWNER_CHAT_ID,
        "text": f"🎉 <b>قطعه با موفقیت منتشر شد!</b>\n\n📌 <b>عنوان:</b> {post_data['title']}\n🔗 <b>لینک استریم:</b> {stream_url}\n\nفایل قفل‌شده به روزرسانی شد و تمام کاربران اپلیکیشن بدون نیاز به آپدیت این اثر را دریافت می‌کنند.",
        "parse_mode": "HTML"
    })
    print(f"SUCCESS: Track {msg_id} fully published and synced.")

def handle_private_message(message):
    from_user = message.get("from", {})
    user_id = from_user.get("id")
    chat_id = message.get("chat", {}).get("id")
    text = (message.get("text") or "").strip()

    if user_id != OWNER_CHAT_ID:
        send_telegram("sendMessage", {
            "chat_id": chat_id,
            "text": "⛔️ شما دسترسی مجاز به پنل مدیریت این ربات را ندارید."
        })
        return

    track_count = 0
    if os.path.exists(METADATA_JSON_PATH):
        try:
            with open(METADATA_JSON_PATH, "r", encoding="utf-8") as f:
                track_count = len(json.load(f))
        except Exception:
            pass

    pending = load_pending()
    pending_count = len(pending)

    if text.startswith("/status"):
        status_text = (
            f"📊 <b>وضعیت سامانه نابغه نابینا</b>\n\n"
            f"✅ ربات فعال و متصل است.\n"
            f"🎵 تعداد کل قطعات آرشیو: <b>{track_count} قطعه</b>\n"
            f"⏳ قطعات در انتظار تأیید: <b>{pending_count}</b>\n"
            f"🔒 سیستم رمزنگاری: AES-256 فعال است.\n"
            f"📡 کانال متصل: @Blind_genius1\n"
            f"👤 کاربر مدیر: سلیمان هاشمی‌زاده"
        )
        send_telegram("sendMessage", {
            "chat_id": chat_id,
            "text": status_text,
            "parse_mode": "HTML"
        })
    elif text.startswith("/title ") or text.startswith("/name "):
        new_title = text.split(" ", 1)[1].strip()
        pending = load_pending()
        if not pending:
            send_telegram("sendMessage", {
                "chat_id": chat_id,
                "text": "❌ هیچ قطعه‌ای در صف انتظار تأیید وجود ندارد."
            })
            return
        latest_id = list(pending.keys())[-1]
        pending[latest_id]["title"] = new_title
        save_pending(pending)
        send_telegram("sendMessage", {
            "chat_id": chat_id,
            "text": f"✅ عنوان قطعه شماره {latest_id} با موفقیت به «<b>{new_title}</b>» تغییر یافت.\n\nاکنون می‌توانید دکمه تأیید را لمس کنید.",
            "parse_mode": "HTML"
        })
    else:
        welcome_text = (
            f"سلام و عرض ادب جناب هاشمی‌زاده عزیز! 🎹✨\n\n"
            f"ربات دستیار اختصاصی <b>نابغه نابینا (Blind Genius)</b> آماده به کار است.\n\n"
            f"🛡 <b>وضعیت سیستم امنیتی ۳ لایه:</b>\n"
            f"• لایه ۱: جلوگیری از پیام‌های فروارد شده\n"
            f"• لایه ۲: تشخیص هوشمند فایل‌های صوتی کانال\n"
            f"• لایه ۳: استعلام تاییدیه مالکیت در همین چت\n\n"
            f"🎵 <b>آرشیو فعال:</b> {track_count} قطعه موسیقی (رمزگذاری شده با AES-256)\n"
            f"📢 <b>کانال رصد شونده:</b> @Blind_genius1\n\n"
            f"دستورات موجود:\n"
            f"/status - وضعیت سیستم و تعداد آهنگ‌ها\n"
            f"/help - راهنمای سامانه"
        )
        send_telegram("sendMessage", {
            "chat_id": chat_id,
            "text": welcome_text,
            "parse_mode": "HTML"
        })

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

                    # Check private messages
                    if "message" in update:
                        handle_private_message(update["message"])

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
                                pending = load_pending()
                                pending.pop(str(msg_id), None)
                                save_pending(pending)
                                send_telegram("answerCallbackQuery", {
                                    "callback_query_id": cb["id"],
                                    "text": "قطعه نادیده گرفته شد."
                                })
                                send_telegram("sendMessage", {
                                    "chat_id": OWNER_CHAT_ID,
                                    "text": "❌ قطعه به عنوان اثر متفرقه علامت‌گذاری و رد شد."
                                })
            if run_once:
                if offset > 0:
                    send_telegram("getUpdates", {"offset": offset, "limit": 1})
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
