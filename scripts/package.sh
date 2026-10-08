#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

./scripts/build.sh

APP="build/pikapik.app"
DMG="build/pikapik.dmg"
ZIP="build/pikapik.zip"
OLD_ZIP="build/pika-tools.zip"
STAGE="build/dmg"

rm -rf "$STAGE" "$DMG" "$ZIP" "$OLD_ZIP"
mkdir -p "$STAGE"
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"
hdiutil create -volname pikapik -srcfolder "$STAGE" -ov -format UDZO "$DMG" >/dev/null
rm -rf "$STAGE"

if [ -n "${NOTARY_PROFILE:-}" ]; then
    echo "Submitting for notarization"
    xcrun notarytool submit "$DMG" --keychain-profile "$NOTARY_PROFILE" --wait
    xcrun stapler staple "$DMG"
    xcrun stapler staple "$APP"
fi

ditto -c -k --keepParent "$APP" "$ZIP"
ditto "$APP" "$STAGE/pika-tools.app"
ditto -c -k --keepParent "$STAGE/pika-tools.app" "$OLD_ZIP"
rm -rf "$STAGE"

shasum -a 256 "$DMG" "$ZIP" "$OLD_ZIP"
echo "Done: $DMG, $ZIP and $OLD_ZIP for older versions that update themselves"
