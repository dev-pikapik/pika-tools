#!/bin/bash
set -euo pipefail

DEST="/Applications/pikapik.app"
OLD="/Applications/pika-tools.app"
BUNDLE_ID="com.pesotchi.pika-tools"

say() { printf '\033[1m→ %s\033[0m\n' "$1"; }
ours() { [ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$1/Contents/Info.plist" 2>/dev/null)" = "$BUNDLE_ID" ]; }

for app in "$DEST" "$OLD"; do
    ours "$app" || continue
    say "Removing from login items"
    pkill -x pika-tools 2>/dev/null || true
    sleep 1
    open -W -n "$app" --args --uninstall 2>/dev/null || true
    break
done

pkill -x pika-tools 2>/dev/null || true

say "Deleting the app"
SUDO=""
[ -w /Applications ] || SUDO="sudo"
for app in "$DEST" "$OLD"; do
    if ours "$app"; then
        $SUDO rm -rf "$app"
    elif [ -e "$app" ]; then
        say "Leaving $app in place: it isn't the GitHub version (for example, pikapik from the App Store)"
    fi
done

FANS="/Library/PrivilegedHelperTools/$BUNDLE_ID.fans"
if [ -e "$FANS" ]; then
    say "Removing fan control"
    sudo launchctl bootout "system/$BUNDLE_ID.fans" >/dev/null 2>&1 || true
    sudo rm -f "$FANS" "/Library/LaunchDaemons/$BUNDLE_ID.fans.plist"
fi

say "Resetting permissions and settings"
tccutil reset Accessibility "$BUNDLE_ID" >/dev/null 2>&1 || true
tccutil reset ListenEvent "$BUNDLE_ID" >/dev/null 2>&1 || true
defaults delete "$BUNDLE_ID" >/dev/null 2>&1 || true

echo "pikapik is uninstalled."
