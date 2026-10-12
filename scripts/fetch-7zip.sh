#!/bin/bash
# Usage: scripts/fetch-7zip.sh [--source DIR]
# Puts the official 7-Zip command line tool and its license into Vendor/7zip/ (nothing happens if the tool is already there and matches its checksum).
# With --source DIR it also saves the matching source code as DIR/7-Zip-26.04-source.tar.xz.
set -euo pipefail
cd "$(dirname "$0")/.."

URL=https://github.com/ip7z/7zip/releases/download/26.04
TOOL_SHA=bee04358cbcbc7106273cee0e8d72916db2696c48067a3538c34d8cd6fd16578
BINARY_SHA=36ea959367d8f9ac51d47a56dc1f20bfb851f1cd22d6f206e85cb5cbc6ab4577
SOURCE_SHA=9691944c0fe0d01bb49373a704fb983fd33bc98b1738695179dfbf99ac1734f6

SOURCE_DIR=
case "${1:-}" in
    "") ;;
    --source) SOURCE_DIR="${2:?Usage: scripts/fetch-7zip.sh [--source DIR]}" ;;
    *) echo "Usage: scripts/fetch-7zip.sh [--source DIR]" >&2; exit 1 ;;
esac

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

sha256() {
    shasum -a 256 "$1" | cut -d' ' -f1
}

download() {
    curl -fsSL --retry 3 -o "$TMP/$1" "$URL/$1"
    [ "$(sha256 "$TMP/$1")" = "$2" ] || { echo "$1 does not match its checksum" >&2; exit 1; }
}

if [ ! -x Vendor/7zip/7zz ] || [ "$(sha256 Vendor/7zip/7zz)" != "$BINARY_SHA" ]; then
    download 7z2604-mac.tar.xz "$TOOL_SHA"
    mkdir "$TMP/tool"
    tar -xf "$TMP/7z2604-mac.tar.xz" -C "$TMP/tool" 7zz License.txt
    [ "$(sha256 "$TMP/tool/7zz")" = "$BINARY_SHA" ] || { echo "7zz does not match its checksum" >&2; exit 1; }
    ARCHS="$(lipo -archs "$TMP/tool/7zz")"
    [[ " $ARCHS " == *" arm64 "* && " $ARCHS " == *" x86_64 "* ]] || { echo "7zz is not universal: $ARCHS" >&2; exit 1; }
    mkdir -p Vendor/7zip
    mv -f "$TMP/tool/License.txt" Vendor/7zip/License.txt
    mv -f "$TMP/tool/7zz" Vendor/7zip/7zz
    echo "7-Zip 26.04 ($ARCHS) is in Vendor/7zip"
fi

if [ -n "$SOURCE_DIR" ]; then
    download 7z2604-src.tar.xz "$SOURCE_SHA"
    mkdir -p "$SOURCE_DIR"
    mv "$TMP/7z2604-src.tar.xz" "$SOURCE_DIR/7-Zip-26.04-source.tar.xz"
    echo "7-Zip 26.04 source is in $SOURCE_DIR"
fi
