#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

APP=build/render-media.app
OUT=docs/media
DOMAIN=com.pesotchi.pika-tools.media
trap 'defaults delete "$DOMAIN" 2>/dev/null || true' EXIT
defaults delete "$DOMAIN" 2>/dev/null || true
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" "$OUT"
if [ $# -eq 0 ]; then find "$OUT" -maxdepth 1 -type f -delete; fi

SOURCES=()
while IFS= read -r -d '' f; do SOURCES+=("$f"); done < <(find Sources -name '*.swift' ! -name main.swift -print0)
swiftc -O -parse-as-library -module-name PikaTools -target "$(uname -m)-apple-macos14.0" \
    "${SOURCES[@]}" Extensions/Convert/ConvertFormats.swift scripts/render-media.swift \
    -o "$APP/Contents/MacOS/render-media"

PLIST="$APP/Contents/Info.plist"
cp Sources/pika-tools/Info.plist "$PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $DOMAIN" -c "Set :CFBundleExecutable render-media" -c "Delete :CFBundleURLTypes" "$PLIST"
cp -R Resources/*.lproj Resources/github.svg Resources/AppIcon.icns "$APP/Contents/Resources/"
codesign --force --sign - "$APP"

"$APP/Contents/MacOS/render-media" "$OUT" cards "$@" -AppleLanguages "(en)"
if [ $# -eq 0 ] || [[ " $* " == *" settings "* ]]; then
    defaults write "$DOMAIN" input-switch -bool true
    defaults write "$DOMAIN" key-repeat -bool true
    for LANGUAGE in $(basename -s .lproj Resources/*.lproj); do "$APP/Contents/MacOS/render-media" "$OUT" "$LANGUAGE" -AppleLanguages "($LANGUAGE)"; done
fi
if [ $# -eq 0 ]; then
    sips -s format png -Z 256 Resources/AppIcon.icns --out "$OUT/icon.png" >/dev/null
fi
ls -l "$OUT"
