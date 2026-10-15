#!/bin/bash
set -eu
cd "$(dirname "$0")/.."

APP=build/pikapik.app
ID=com.pesotchi.pika-tools.dev
FOLDER="$HOME/Library/Mobile Documents/com~apple~CloudDocs/pikapik-dev"
FILE="$FOLDER/settings.json"

idle=$(ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print int($NF/1e9); exit}')
[ "$idle" -gt 120 ] || { echo "Leave the keyboard and mouse alone for 2 minutes first: this check switches between apps."; exit 1; }
[ -d "$APP" ] || { echo "Run ./scripts/build.sh first."; exit 1; }

quit() { osascript -e "tell application id \"$ID\" to quit" >/dev/null 2>&1 || true; sleep 2; }
cleanup() {
    quit
    defaults delete "$ID" settings-sync 2>/dev/null || true
    defaults delete "$ID" settings-sync-modified 2>/dev/null || true
    defaults delete "$ID" dock-hide-action 2>/dev/null || true
    rm -rf "$FOLDER"
}
trap cleanup EXIT

quit
defaults delete "$ID" dock-hide-action 2>/dev/null || true
defaults write "$ID" settings-sync -bool true
open -n "$APP"
for _ in $(seq 20); do [ -f "$FILE" ] && break; sleep 1; done
[ -f "$FILE" ] || { echo "FAIL: the app did not create $FILE"; exit 1; }

osascript -e 'tell application "Finder" to activate'
sleep 2

python3 - "$FILE" <<'EOF'
import json, sys, time
path = sys.argv[1]
with open(path, "r+") as f:
    root = json.load(f)
    root["device"] = "another-mac"
    root["modified"] = round(time.time() + 60, 3)
    root["settings"]["dock-hide-action"] = "hide"
    f.seek(0)
    f.truncate()
    json.dump(root, f)
EOF

osascript -e "tell application id \"$ID\" to activate"
for _ in $(seq 10); do
    [ "$(defaults read "$ID" dock-hide-action 2>/dev/null || true)" = hide ] && { echo "ok: newer settings from another Mac are applied, also after the app is opened"; exit 0; }
    sleep 1
done
echo "FAIL: the newer settings from the other Mac were not applied"
exit 1
