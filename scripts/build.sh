#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

APP="build/pika-tools.app"
EXTENSIONS="NewFile Compress Convert"
MIN_OS="14.0"
SIGN_IDENTITY="${SIGN_IDENTITY:--}"

rm -rf build
mkdir -p "$APP/Contents/MacOS" build/strings
for EXT in $EXTENSIONS; do mkdir -p "$APP/Contents/PlugIns/$EXT.appex/Contents/MacOS"; done
EMIT=(-Xfrontend -emit-localized-strings -Xfrontend -emit-localized-strings-path -Xfrontend build/strings)

SOURCES=()
while IFS= read -r -d '' f; do SOURCES+=("$f"); done < <(find Sources -name '*.swift' -print0)
SOURCES+=(Extensions/Convert/ConvertFormats.swift)

FLAGS=()
if [ -d Private/Sources ] && [ -n "$(find Private/Sources -name '*.swift' -print -quit)" ]; then
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
    for EXT in $EXTENSIONS; do
        swiftc -O -whole-module-optimization \
            -module-name "$EXT" \
            -target "$ARCH-apple-macos$MIN_OS" \
            -application-extension \
            "${EMIT[@]}" \
            -Xlinker -e -Xlinker _NSExtensionMain \
            Extensions/"$EXT"/*.swift \
            -o "build/$EXT-$ARCH"
    done
done

./scripts/check-strings.sh build/strings
rm -rf build/strings

lipo -create build/pika-tools-arm64 build/pika-tools-x86_64 -output "$APP/Contents/MacOS/pika-tools"
rm build/pika-tools-arm64 build/pika-tools-x86_64
cp Sources/pika-tools/Info.plist "$APP/Contents/Info.plist"
for EXT in $EXTENSIONS; do
    APPEX="$APP/Contents/PlugIns/$EXT.appex"
    lipo -create "build/$EXT-arm64" "build/$EXT-x86_64" -output "$APPEX/Contents/MacOS/$EXT"
    rm "build/$EXT-arm64" "build/$EXT-x86_64"
    cp "Extensions/$EXT/Info.plist" "$APPEX/Contents/Info.plist"
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
        esac
        grep -E "^\"($TEXTS)\" = " "$LPROJ/Localizable.strings" > "$OUT/Localizable.strings"
        grep "^\"$NAME\" = " "$LPROJ/Localizable.strings" | sed 's/^"[^"]*"/"CFBundleDisplayName"/' > "$OUT/InfoPlist.strings"
    done
done

RES="$APP/Contents/Resources"
mkdir -p "$RES"
cp -R Resources/*.lproj "$RES/"
cp Resources/github.svg Resources/AppIcon.icon/Assets/pikapik.svg "$RES/"
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

if [ "$SIGN_IDENTITY" = "-" ]; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.pesotchi.pika-tools.dev" "$APP/Contents/Info.plist"
    /usr/libexec/PlistBuddy -c "Set :CFBundleURLTypes:0:CFBundleURLName com.pesotchi.pika-tools.dev" "$APP/Contents/Info.plist"
    /usr/libexec/PlistBuddy -c "Set :CFBundleURLTypes:0:CFBundleURLSchemes:0 pika-tools-dev" "$APP/Contents/Info.plist"
    for EXT in $EXTENSIONS; do
        PLIST="$APP/Contents/PlugIns/$EXT.appex/Contents/Info.plist"
        ID="$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$PLIST")"
        /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier ${ID/pika-tools./pika-tools.dev.}" "$PLIST"
        /usr/libexec/PlistBuddy -c "Set :PikaToolsURLScheme pika-tools-dev" "$PLIST"
    done
fi
for EXT in $EXTENSIONS; do
    sign --entitlements "Extensions/$EXT/$EXT.entitlements" "$APP/Contents/PlugIns/$EXT.appex"
done
sign "$APP"

echo "Done: $APP ($(lipo -archs "$APP/Contents/MacOS/pika-tools"))"
