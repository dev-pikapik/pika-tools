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

if [ "$SIGN_IDENTITY" = "-" ]; then
    codesign --force --sign - "$APP"
else
    codesign --force --options runtime --timestamp --sign "$SIGN_IDENTITY" "$APP"
fi

echo "Готово: $APP ($(lipo -archs "$APP/Contents/MacOS/pika-tools"))"
