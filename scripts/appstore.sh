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

for NAME in APP_PROFILE NEWFILE_PROFILE COMPRESS_PROFILE CONVERT_PROFILE; do
    [ -f "${!NAME:-}" ] || {
        echo "$NAME is not set or the file is missing. Set it to the .provisionprofile downloaded from developer.apple.com > Profiles for this target." >&2
        exit 1
    }
done

APPSTORE=1 TEAM_ID="$TEAM_ID" ./scripts/build.sh

cp "$APP_PROFILE" "$APP/Contents/embedded.provisionprofile"
cp "$NEWFILE_PROFILE" "$APP/Contents/PlugIns/NewFile.appex/Contents/embedded.provisionprofile"
cp "$COMPRESS_PROFILE" "$APP/Contents/PlugIns/Compress.appex/Contents/embedded.provisionprofile"
cp "$CONVERT_PROFILE" "$APP/Contents/PlugIns/Convert.appex/Contents/embedded.provisionprofile"

sign() { codesign --force --options runtime --timestamp --sign "$APP_IDENTITY" "$@"; }
for EXT in $EXTENSIONS; do
    sign --entitlements "build/$EXT.entitlements" "$APP/Contents/PlugIns/$EXT.appex"
done
sign --entitlements build/app.entitlements "$APP"

codesign --verify --deep --strict "$APP"
productbuild --component "$APP" /Applications --sign "$INSTALLER_IDENTITY" build/pikapik.pkg
echo "Done: build/pikapik.pkg (upload with Transporter or: xcrun altool --upload-package)"
