#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

APP="build/pika-tools.app"
APPEX="$APP/Contents/PlugIns/NewFile.appex"
MIN_OS="14.0"
SIGN_IDENTITY="${SIGN_IDENTITY:--}"

rm -rf build
mkdir -p "$APP/Contents/MacOS" "$APPEX/Contents/MacOS"

SOURCES=()
while IFS= read -r -d '' f; do SOURCES+=("$f"); done < <(find Sources -name '*.swift' -print0)

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
        "${SOURCES[@]}" \
        -o "build/pika-tools-$ARCH"
    swiftc -O -whole-module-optimization \
        -module-name NewFile \
        -target "$ARCH-apple-macos$MIN_OS" \
        -application-extension \
        -Xlinker -e -Xlinker _NSExtensionMain \
        Extensions/NewFile/*.swift \
        -o "build/NewFile-$ARCH"
done

lipo -create build/pika-tools-arm64 build/pika-tools-x86_64 -output "$APP/Contents/MacOS/pika-tools"
lipo -create build/NewFile-arm64 build/NewFile-x86_64 -output "$APPEX/Contents/MacOS/NewFile"
rm build/pika-tools-arm64 build/pika-tools-x86_64 build/NewFile-arm64 build/NewFile-x86_64
cp Sources/pika-tools/Info.plist "$APP/Contents/Info.plist"
cp Extensions/NewFile/Info.plist "$APPEX/Contents/Info.plist"
for KEY in CFBundleShortVersionString CFBundleVersion; do
    /usr/libexec/PlistBuddy -c "Set :$KEY $(/usr/libexec/PlistBuddy -c "Print :$KEY" "$APP/Contents/Info.plist")" "$APPEX/Contents/Info.plist"
done
for LPROJ in Resources/*.lproj; do
    mkdir -p "$APPEX/Contents/Resources/$(basename "$LPROJ")"
    grep '^"New File" = ' "$LPROJ/Localizable.strings" > "$APPEX/Contents/Resources/$(basename "$LPROJ")/Localizable.strings"
done

RES="$APP/Contents/Resources"
mkdir -p "$RES"
cp -R Resources/*.lproj "$RES/"
cp Resources/github.svg "$RES/"
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
    /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.pesotchi.pika-tools.dev.new-file" "$APPEX/Contents/Info.plist"
    /usr/libexec/PlistBuddy -c "Set :PikaToolsURLScheme pika-tools-dev" "$APPEX/Contents/Info.plist"
fi
sign --entitlements Extensions/NewFile/NewFile.entitlements "$APPEX"
sign "$APP"

echo "Done: $APP ($(lipo -archs "$APP/Contents/MacOS/pika-tools"))"
