#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

APP="build/pikapik.app"
EXTENSIONS="NewFile Compress Convert"
[ -n "${APPSTORE:-}" ] || EXTENSIONS="$EXTENSIONS Archive Preview"
MIN_OS="14.0"
DEV_IDENTITY="pikapik Dev"
if [ -z "${SIGN_IDENTITY:-}" ]; then
    SIGN_IDENTITY=-
    security unlock-keychain -p "" "$HOME/Library/Keychains/pikapik-dev.keychain-db" 2>/dev/null || true
    security find-certificate -c "$DEV_IDENTITY" >/dev/null 2>&1 && SIGN_IDENTITY="$DEV_IDENTITY"
fi
DEV=$([ "$SIGN_IDENTITY" = - ] || [ "$SIGN_IDENTITY" = "$DEV_IDENTITY" ] && echo 1 || true)

APPSTORE_ID=com.pikapik.tools
rm -rf build
mkdir -p "$APP/Contents/MacOS" build/strings
[ -n "${APPSTORE:-}" ] || mkdir -p "$APP/Contents/Library/LaunchServices"
[ -n "${APPSTORE:-}" ] || ./scripts/fetch-7zip.sh
for EXT in $EXTENSIONS; do mkdir -p "$APP/Contents/PlugIns/$EXT.appex/Contents/MacOS"; done
EMIT=(-Xfrontend -emit-localized-strings -Xfrontend -emit-localized-strings-path -Xfrontend build/strings)

SOURCES=()
while IFS= read -r -d '' f; do SOURCES+=("$f"); done < <(find Sources -name '*.swift' -print0)
SOURCES+=(Extensions/Convert/ConvertFormats.swift)
[ -n "${APPSTORE:-}" ] || SOURCES+=(Extensions/Preview/ZipNames.swift)

FLAGS=()
if [ -n "${APPSTORE:-}" ]; then
    FLAGS+=(-D APPSTORE)
    KEPT=()
    for f in "${SOURCES[@]}"; do
        case $f in
            */Common/Updater.swift|*/Common/LeftoverPermissions*.swift|*/Common/SMC.swift|*/Common/FanHelperProtocol.swift|*/Common/FanControl.swift|*/Common/FanSettings.swift|*/Tools/Animations/*|*/Tools/KeyRepeat/*|*/Tools/Mouse/PointerTool.swift|*/Tools/Uninstaller/*|*/Tools/Archive/*) ;;
            *) KEPT+=("$f") ;;
        esac
    done
    SOURCES=("${KEPT[@]}")
    echo "App Store build"
elif [ -d Private/Sources ] && [ -n "$(find Private/Sources -name '*.swift' -print -quit)" ]; then
    while IFS= read -r -d '' f; do SOURCES+=("$f"); done < <(find Private/Sources -name '*.swift' -print0)
    FLAGS+=(-D PIKA_PRIVATE)
    echo "Including Private/Sources"
fi

for ARCH in arm64 x86_64; do
    echo "Building $ARCH"
    swiftc -O -whole-module-optimization \
        -module-name PikaTools \
        -target "$ARCH-apple-macos$MIN_OS" \
        ${FLAGS[@]+"${FLAGS[@]}"} \
        "${EMIT[@]}" \
        "${SOURCES[@]}" \
        -o "build/pika-tools-$ARCH"
    [ -n "${APPSTORE:-}" ] || swiftc -O -whole-module-optimization \
        -module-name FanHelper \
        -target "$ARCH-apple-macos$MIN_OS" \
        Helper/FanHelper/main.swift Sources/pika-tools/Common/SMC.swift Sources/pika-tools/Common/FanHelperProtocol.swift \
        -o "build/fan-helper-$ARCH"
    for EXT in $EXTENSIONS; do
        SHARED=(Extensions/Shared/*.swift)
        [ "$EXT" != Archive ] || SHARED+=(Sources/pika-tools/Tools/Archive/Archive.swift)
        [ "$EXT" != Preview ] || SHARED=()
        swiftc -O -whole-module-optimization \
            -module-name "$EXT" \
            -target "$ARCH-apple-macos$MIN_OS" \
            -application-extension \
            "${EMIT[@]}" \
            -Xlinker -e -Xlinker _NSExtensionMain \
            Extensions/"$EXT"/*.swift ${SHARED[@]+"${SHARED[@]}"} \
            -o "build/$EXT-$ARCH"
    done
done

[ -n "${APPSTORE:-}" ] || ./scripts/check-strings.sh build/strings
rm -rf build/strings

lipo -create build/pika-tools-arm64 build/pika-tools-x86_64 -output "$APP/Contents/MacOS/pika-tools"
rm build/pika-tools-arm64 build/pika-tools-x86_64
if [ -z "${APPSTORE:-}" ]; then
    lipo -create build/fan-helper-arm64 build/fan-helper-x86_64 -output "$APP/Contents/Library/LaunchServices/fan-helper"
    rm build/fan-helper-arm64 build/fan-helper-x86_64
    cp Vendor/7zip/7zz "$APP/Contents/MacOS/7zz"
fi
cp Sources/pika-tools/Info.plist "$APP/Contents/Info.plist"
for EXT in $EXTENSIONS; do
    APPEX="$APP/Contents/PlugIns/$EXT.appex"
    lipo -create "build/$EXT-arm64" "build/$EXT-x86_64" -output "$APPEX/Contents/MacOS/$EXT"
    rm "build/$EXT-arm64" "build/$EXT-x86_64"
    cp "Extensions/$EXT/Info.plist" "$APPEX/Contents/Info.plist"
    [ -z "${APPSTORE:-}" ] || { mkdir -p "$APPEX/Contents/Resources" && cp Resources/PrivacyInfo.xcprivacy "$APPEX/Contents/Resources/"; }
    for KEY in CFBundleShortVersionString CFBundleVersion; do
        /usr/libexec/PlistBuddy -c "Set :$KEY $(/usr/libexec/PlistBuddy -c "Print :$KEY" "$APP/Contents/Info.plist")" "$APPEX/Contents/Info.plist"
    done
    for LPROJ in Resources/*.lproj; do
        OUT="$APPEX/Contents/Resources/$(basename "$LPROJ")"
        mkdir -p "$OUT"
        case $EXT in
            NewFile) TEXTS='New File' NAME='New File in Finder' ;;
            Compress) TEXTS='Make a Smaller Copy' NAME='Smaller Copy in Finder' ;;
            Convert) TEXTS='Convert To|M4A \(Audio Only\)' NAME='Convert in Finder' ;;
            Archive) TEXTS='Extract|Create Archive…' NAME='Archives in Finder' ;;
            Preview) TEXTS='%lld items|Expands to %@|It could fill up your disk.|Protected with a password|Part of a multi-part archive|Damaged. Showing what could be read.|Only the first items are shown.|Contains a program. Open it only if you trust where it came from.' NAME='Archives in Finder' ;;
        esac
        grep -E "^\"($TEXTS)\" = " "$LPROJ/Localizable.strings" > "$OUT/Localizable.strings"
        grep "^\"$NAME\" = " "$LPROJ/Localizable.strings" | sed 's/^"[^"]*"/"CFBundleDisplayName"/' > "$OUT/InfoPlist.strings"
        [ "$EXT" != Preview ] || cp "$LPROJ/Localizable.stringsdict" "$OUT/"
    done
done

RES="$APP/Contents/Resources"
mkdir -p "$RES"
cp -R Resources/*.lproj "$RES/"
if [ -z "${APPSTORE:-}" ]; then
    FINDER_TEXT='pikapik asks Finder to move apps to the Trash when macOS doesn’t let it do that itself.'
    /usr/libexec/PlistBuddy -c "Add :NSAppleEventsUsageDescription string $FINDER_TEXT" "$APP/Contents/Info.plist"
    for LPROJ in Resources/*.lproj; do
        grep -F "\"$FINDER_TEXT\" = " "$LPROJ/Localizable.strings" | sed 's/^"[^"]*"/"NSAppleEventsUsageDescription"/' > "$RES/$(basename "$LPROJ")/InfoPlist.strings"
        grep '^"Archive" = ' "$LPROJ/Localizable.strings" >> "$RES/$(basename "$LPROJ")/InfoPlist.strings"
    done
    cp Vendor/7zip/License.txt "$RES/7-Zip License.txt"
fi
cp Resources/github.svg Resources/AppIcon.icon/Assets/pikapik.svg "$RES/"
[ -n "${APPSTORE:-}" ] && cp Resources/PrivacyInfo.xcprivacy "$RES/"
if xcrun --find actool >/dev/null 2>&1 && xcrun actool Resources/AppIcon.icon \
        --compile "$RES" \
        --app-icon AppIcon \
        --platform macosx \
        --target-device mac \
        --minimum-deployment-target "$MIN_OS" \
        --output-partial-info-plist build/icon-info.plist >build/actool.log 2>&1 \
        && [ -f "$RES/Assets.car" ]; then
    [ -f "$RES/AppIcon.icns" ] || cp Resources/AppIcon.icns "$RES/AppIcon.icns"
    /usr/libexec/PlistBuddy -c "Add :CFBundleIconName string AppIcon" "$APP/Contents/Info.plist"
    echo "Icon: Assets.car from AppIcon.icon"
else
    [ -s build/actool.log ] && tail -5 build/actool.log
    rm -f "$RES/Assets.car"
    cp Resources/AppIcon.icns "$RES/AppIcon.icns"
    echo "Icon: prebuilt AppIcon.icns"
fi
rm -f build/icon-info.plist build/actool.log

sign() {
    if [ "$SIGN_IDENTITY" = "-" ]; then
        codesign --force --sign - "$@"
    elif [[ "$SIGN_IDENTITY" == "Developer ID"* ]]; then
        codesign --force --options runtime --timestamp --sign "$SIGN_IDENTITY" "$@"
    else
        codesign --force --options runtime --sign "$SIGN_IDENTITY" "$@"
    fi
}

group_entitlements() {
    local OUT="build/$2.entitlements"
    cp "$1" "$OUT"
    local BUNDLE_ID="$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$3/Contents/Info.plist")"
    /usr/libexec/PlistBuddy -c "Add :com.apple.security.application-groups array" -c "Add :com.apple.security.application-groups:0 string $TEAM_ID.com.pesotchi.pika-tools" \
        -c "Add :com.apple.application-identifier string $TEAM_ID.$BUNDLE_ID" -c "Add :com.apple.developer.team-identifier string $TEAM_ID" "$OUT"
    echo "$OUT"
}

if [ -n "${APPSTORE:-}" ]; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $APPSTORE_ID" -c "Add :ITSAppUsesNonExemptEncryption bool false" "$APP/Contents/Info.plist"
    /usr/libexec/PlistBuddy -c "Delete :CFBundleDocumentTypes" -c "Delete :UTImportedTypeDeclarations" "$APP/Contents/Info.plist"
    /usr/libexec/PlistBuddy -c "Set :CFBundleURLTypes:0:CFBundleURLName $APPSTORE_ID" "$APP/Contents/Info.plist"
    /usr/libexec/PlistBuddy -c "Set :CFBundleURLTypes:0:CFBundleURLSchemes:0 pikapik-store" -c "Set :CFBundleURLTypes:0:CFBundleURLSchemes:1 pika-tools-store" "$APP/Contents/Info.plist"
    for EXT in $EXTENSIONS; do
        PLIST="$APP/Contents/PlugIns/$EXT.appex/Contents/Info.plist"
        ID="$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$PLIST")"
        /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier ${ID/com.pesotchi.pika-tools./$APPSTORE_ID.}" "$PLIST"
        /usr/libexec/PlistBuddy -c "Set :PikaToolsURLScheme pikapik-store" "$PLIST"
    done
elif [ -n "$DEV" ]; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.pesotchi.pika-tools.dev" "$APP/Contents/Info.plist"
    /usr/libexec/PlistBuddy -c "Set :CFBundleURLTypes:0:CFBundleURLName com.pesotchi.pika-tools.dev" "$APP/Contents/Info.plist"
    /usr/libexec/PlistBuddy -c "Set :CFBundleURLTypes:0:CFBundleURLSchemes:0 pikapik-dev" -c "Set :CFBundleURLTypes:0:CFBundleURLSchemes:1 pika-tools-dev" "$APP/Contents/Info.plist"
    for EXT in $EXTENSIONS; do
        PLIST="$APP/Contents/PlugIns/$EXT.appex/Contents/Info.plist"
        ID="$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$PLIST")"
        /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier ${ID/pika-tools./pika-tools.dev.}" "$PLIST"
        [ "$EXT" = Preview ] || /usr/libexec/PlistBuddy -c "Set :PikaToolsURLScheme pika-tools-dev" "$PLIST"
    done
fi
APP_ENTITLEMENTS=()
for EXT in $EXTENSIONS; do
    ENTITLEMENTS="Extensions/$EXT/$EXT.entitlements"
    [ -n "${APPSTORE:-}" ] && [ -n "${TEAM_ID:-}" ] && ENTITLEMENTS="$(group_entitlements "$ENTITLEMENTS" "$EXT" "$APP/Contents/PlugIns/$EXT.appex")"
    sign --entitlements "$ENTITLEMENTS" "$APP/Contents/PlugIns/$EXT.appex"
done
if [ -n "${APPSTORE:-}" ]; then
    ENTITLEMENTS=Resources/AppStore.entitlements
    [ -n "${TEAM_ID:-}" ] && ENTITLEMENTS="$(group_entitlements "$ENTITLEMENTS" app "$APP")"
    APP_ENTITLEMENTS=(--entitlements "$ENTITLEMENTS")
else
    APP_ENTITLEMENTS=(--entitlements Resources/Direct.entitlements)
    BUNDLE_ID="$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$APP/Contents/Info.plist")"
    sign --identifier "$BUNDLE_ID.fans" "$APP/Contents/Library/LaunchServices/fan-helper"
    sign --identifier "$BUNDLE_ID.7zz" "$APP/Contents/MacOS/7zz"
fi
sign ${APP_ENTITLEMENTS[@]+"${APP_ENTITLEMENTS[@]}"} "$APP"

echo "Done: $APP ($(lipo -archs "$APP/Contents/MacOS/pika-tools"))"
