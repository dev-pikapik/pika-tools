#!/bin/bash
set -euo pipefail

DEST="/Applications/pikapik.app"
OLD="/Applications/pika-tools.app"
BUNDLE_ID="com.pesotchi.pika-tools"

say() { printf '\033[1m→ %s\033[0m\n' "$1"; }

for app in "$DEST" "$OLD"; do
    [ -d "$app" ] || continue
    say "Removing from login items"
    pkill -x pika-tools 2>/dev/null || true
    sleep 1
    open -W -n "$app" --args --uninstall 2>/dev/null || true
    break
done

pkill -x pika-tools 2>/dev/null || true

say "Deleting the app"
if [ -d "$DEST" ] || [ -d "$OLD" ]; then
    SUDO=""
    [ -w /Applications ] || SUDO="sudo"
    $SUDO rm -rf "$DEST" "$OLD"
fi

say "Resetting permissions and settings"
tccutil reset Accessibility "$BUNDLE_ID" >/dev/null 2>&1 || true
tccutil reset ListenEvent "$BUNDLE_ID" >/dev/null 2>&1 || true
defaults delete "$BUNDLE_ID" >/dev/null 2>&1 || true

echo "pikapik is uninstalled."
