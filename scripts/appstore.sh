#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

APP="build/pikapik.app"
EXTENSIONS="NewFile Compress Convert"
APP_IDENTITY="${APP_IDENTITY:-Apple Distribution}"
INSTALLER_IDENTITY="${INSTALLER_IDENTITY:-3rd Party Mac Developer Installer}"

: "${TEAM_ID:?Set TEAM_ID to your Apple Developer team id (10 characters)}"
for IDENTITY in "$APP_IDENTITY" "$INSTALLER_IDENTITY"; do
    security find-identity -v | grep -q "$IDENTITY" || {
        echo "Certificate \"$IDENTITY\" not found in the keychain. Create it in developer.apple.com > Certificates, then try again." >&2
        exit 1
    }
done

APPSTORE=1 TEAM_ID="$TEAM_ID" ./scripts/build.sh

embed() {
    local PROFILE="${1:-}" TARGET="$2"
    [ -z "$PROFILE" ] || cp "$PROFILE" "$TARGET/Contents/embedded.provisionprofile"
}
embed "${APP_PROFILE:-}" "$APP"
embed "${NEWFILE_PROFILE:-}" "$APP/Contents/PlugIns/NewFile.appex"
embed "${COMPRESS_PROFILE:-}" "$APP/Contents/PlugIns/Compress.appex"
embed "${CONVERT_PROFILE:-}" "$APP/Contents/PlugIns/Convert.appex"

sign() { codesign --force --options runtime --timestamp --sign "$APP_IDENTITY" "$@"; }
for EXT in $EXTENSIONS; do
    sign --entitlements "build/$EXT.entitlements" "$APP/Contents/PlugIns/$EXT.appex"
done
sign --entitlements build/app.entitlements "$APP"

codesign --verify --deep --strict "$APP"
productbuild --component "$APP" /Applications --sign "$INSTALLER_IDENTITY" build/pikapik.pkg
echo "Done: build/pikapik.pkg (upload with Transporter or: xcrun altool --upload-package)"
