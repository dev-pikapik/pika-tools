#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

./scripts/build.sh

APP="build/pika-tools.app"
DMG="build/pika-tools.dmg"
ZIP="build/pika-tools.zip"
STAGE="build/dmg"

rm -rf "$STAGE" "$DMG" "$ZIP"
mkdir -p "$STAGE"
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"
hdiutil create -volname pika-tools -srcfolder "$STAGE" -ov -format UDZO "$DMG" >/dev/null
rm -rf "$STAGE"

if [ -n "${NOTARY_PROFILE:-}" ]; then
    echo "Отправляю на нотаризацию"
    xcrun notarytool submit "$DMG" --keychain-profile "$NOTARY_PROFILE" --wait
    xcrun stapler staple "$DMG"
    xcrun stapler staple "$APP"
fi

ditto -c -k --keepParent "$APP" "$ZIP"

shasum -a 256 "$DMG" "$ZIP"
echo "Готово: $DMG и $ZIP"
