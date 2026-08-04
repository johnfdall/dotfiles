#!/usr/bin/env python3
"""Unread-mail count for waybar, read straight off ProtonMail Bridge.

Prints one line of waybar JSON. Also owns new-mail notifications: it caches the
previous count and fires notify-send when the count *rises*, so there is exactly
one IMAP poller rather than a separate notification timer.

Wired up in ~/.config/waybar/config as a custom/mail module (interval 60).
"""

import imaplib
import json
import os
import pathlib
import ssl
import subprocess
import sys

HOST = "127.0.0.1"
PORT = 1143
# Must match imap_user in neomutt's accounts/proton.rc. In Bridge's combined
# address mode this is the account's primary address, and INBOX carries mail
# for every address on the account -- so one count covers them all.
USER = "john.fredrik.dall@protonmail.com"
PASS_ENTRY = "proton/bridge"
BRIDGE_CERT = pathlib.Path.home() / ".config/protonmail/bridge-v3/cert.pem"
MAILBOX = "INBOX"

ICON = ""  # nf-fa-envelope


def state_path():
    runtime = os.environ.get("XDG_RUNTIME_DIR") or "/tmp"
    return pathlib.Path(runtime) / "waybar-mail-count"


def emit(text, tooltip, css_class):
    json.dump({"text": text, "tooltip": tooltip, "class": css_class}, sys.stdout)
    sys.stdout.write("\n")


def bridge_password():
    out = subprocess.run(
        ["pass", "show", PASS_ENTRY],
        capture_output=True,
        text=True,
        timeout=15,
    )
    if out.returncode != 0:
        raise RuntimeError(f"pass show {PASS_ENTRY} failed: {out.stderr.strip()}")
    password = out.stdout.splitlines()[0] if out.stdout else ""
    if not password:
        raise RuntimeError(f"pass entry {PASS_ENTRY} is empty")
    return password


def unread_count():
    # Bridge serves a self-signed cert. Trust that specific cert rather than
    # disabling verification outright; hostname checking is off because the
    # cert is issued to Bridge, not to the literal loopback address.
    context = ssl.create_default_context()
    if BRIDGE_CERT.exists():
        context.load_verify_locations(cafile=str(BRIDGE_CERT))
        context.check_hostname = False
    else:
        context.check_hostname = False
        context.verify_mode = ssl.CERT_NONE

    conn = imaplib.IMAP4(HOST, PORT, timeout=15)
    try:
        conn.starttls(ssl_context=context)
        conn.login(USER, bridge_password())
        conn.select(MAILBOX, readonly=True)
        typ, data = conn.search(None, "UNSEEN")
        if typ != "OK":
            raise RuntimeError(f"IMAP SEARCH returned {typ}")
        return len(data[0].split())
    finally:
        try:
            conn.logout()
        except Exception:
            pass


def notify(count, previous):
    # Only on a rise: re-reading mail elsewhere shouldn't re-notify, and a
    # steady count across polls shouldn't fire every 60s.
    if previous is None or count <= previous:
        return
    new = count - previous
    body = f"{new} new message{'s' if new != 1 else ''} ({count} unread)"
    subprocess.run(
        ["notify-send", "-a", "neomutt", "-i", "mail-unread", "New mail", body],
        check=False,
    )


def main():
    try:
        count = unread_count()
    except Exception as exc:
        # Bridge down or creds missing: stay quiet and visibly degraded rather
        # than blanking the module or spamming notifications.
        emit(ICON, f"mail unavailable: {exc}", "error")
        return

    cache = state_path()
    previous = None
    try:
        previous = int(cache.read_text().strip())
    except (OSError, ValueError):
        pass

    notify(count, previous)

    try:
        cache.write_text(str(count))
    except OSError:
        pass

    if count:
        emit(f"{ICON} {count}", f"{count} unread in {MAILBOX}", "unread")
    else:
        emit(ICON, "no unread mail", "read")


if __name__ == "__main__":
    main()
