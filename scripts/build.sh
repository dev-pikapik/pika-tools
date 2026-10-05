#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

APP="build/pika-tools.app"
MIN_OS="14.0"
SIGN_IDENTITY="${SIGN_IDENTITY:--}"

rm -rf build
mkdir -p "$APP/Contents/MacOS"

SOURCES=()
while IFS= read -r -d '' f; do SOURCES+=("$f"); done < <(find Sources -name '*.swift' -print0)

FLAGS=()
if [ -d Private/Sources ] && [ -n "$(find Private/Sources -name '*.swift' -print -quit)" ]; then
    while IFS= read -r -d '' f; do SOURCES+=("$f"); done < <(find Private/Sources -name '*.swift' -print0)
    FLAGS+=(-D PIKA_PRIVATE)
    echo "Подключаю Private/Sources"
fi

for ARCH in arm64 x86_64; do
    echo "Собираю $ARCH"
    swiftc -O -whole-module-optimization \
        -module-name PikaTools \
        -target "$ARCH-apple-macos$MIN_OS" \
        ${FLAGS[@]+"${FLAGS[@]}"} \
        "${SOURCES[@]}" \
        -o "build/pika-tools-$ARCH"
done

lipo -create build/pika-tools-arm64 build/pika-tools-x86_64 -output "$APP/Contents/MacOS/pika-tools"
rm build/pika-tools-arm64 build/pika-tools-x86_64
cp Sources/pika-tools/Info.plist "$APP/Contents/Info.plist"

RES="$APP/Contents/Resources"
mkdir -p "$RES"
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
    echo "Иконка: Assets.car из AppIcon.icon"
else
    [ -s build/actool.log ] && tail -5 build/actool.log
    rm -f "$RES/Assets.car"
    cp Resources/AppIcon.icns "$RES/AppIcon.icns"
    echo "Иконка: готовый AppIcon.icns"
fi
rm -f build/icon-info.plist build/actool.log

if [ "$SIGN_IDENTITY" = "-" ]; then
    codesign --force --sign - "$APP"
else
    codesign --force --options runtime --timestamp --sign "$SIGN_IDENTITY" "$APP"
fi

echo "Готово: $APP ($(lipo -archs "$APP/Contents/MacOS/pika-tools"))"
