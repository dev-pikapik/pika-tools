#!/bin/bash
# Usage: scripts/fetch-ffmpeg.sh [--source DIR]
# Builds the LGPL parts of FFmpeg with dav1d inside as universal dylibs in Vendor/ffmpeg/{lib,include} for the media extensions (nothing happens if this script already built them).
# With --source DIR it also saves the matching source archives in DIR.
set -euo pipefail
cd "$(dirname "$0")/.."

FFMPEG=ffmpeg-8.1.3
FFMPEG_SHA=7138d28c96d9d3e3af4ee3d8cad72741f8ffb40da90c1112235dea3ecd3178a3
DAV1D=dav1d-1.5.4
DAV1D_SHA=686616b7c69eb88d44459391ab25cac13b6647a3b288835c5784e71c1514a5c5
MIN_OS=14.0
LIBS="libavutil.60 libavcodec.62 libavformat.62"
OUT=Vendor/ffmpeg

SOURCE_DIR=
case "${1:-}" in
    "") ;;
    --source) SOURCE_DIR="${2:?Usage: scripts/fetch-ffmpeg.sh [--source DIR]}" ;;
    *) echo "Usage: scripts/fetch-ffmpeg.sh [--source DIR]" >&2; exit 1 ;;
esac

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

sha256() {
    shasum -a 256 "$1" | cut -d' ' -f1
}

download() {
    [ -f "$TMP/$1" ] || curl -fsSL --retry 3 -o "$TMP/$1" "$2/$1"
    [ "$(sha256 "$TMP/$1")" = "$3" ] || { echo "$1 does not match its checksum" >&2; exit 1; }
}

fetch() {
    download "$FFMPEG.tar.xz" https://ffmpeg.org/releases "$FFMPEG_SHA"
    download "$DAV1D.tar.xz" "https://downloads.videolan.org/pub/videolan/dav1d/${DAV1D#dav1d-}" "$DAV1D_SHA"
}

STAMP="$(sha256 "$0")"
if [ "$(cat "$OUT/stamp" 2>/dev/null)" != "$STAMP" ]; then
    for TOOL in meson ninja nasm pkg-config; do
        command -v "$TOOL" >/dev/null || { echo "$TOOL is missing: brew install meson ninja nasm pkg-config" >&2; exit 1; }
    done
    fetch
    JOBS="$(sysctl -n hw.ncpu)"
    COMPONENTS=(
        --enable-demuxer=matroska,mov,avi,flv,ogg,asf,mpegts,mpegps,mxf,mpegvideo,m4v,h264,hevc,ac3,eac3,aac,mp3,flac,wav,aiff,caf,ape,dsf
        --enable-parser=aac,aac_latm,ac3,av1,flac,h263,h264,hevc,mpeg4video,mpegaudio,mpegvideo,opus,vc1,vorbis,vp3,vp8,vp9
        --enable-decoder=aac,vp8,vp9,libdav1d,mpeg4,msmpeg4v1,msmpeg4v2,msmpeg4v3,wmv1,wmv2,wmv3,vc1,theora,mpeg1video,mpeg2video,flv,h263,wmav1,wmav2,vorbis,ape,dsd_lsbf_planar
        --enable-bsf=aac_adtstoasc,extract_extradata,mpeg4_unpack_bframes
    )
    {
        echo "$FFMPEG (LGPL 2.1 or later) and $DAV1D (BSD 2-Clause), built by scripts/fetch-ffmpeg.sh"
        echo "dav1d: meson setup --default-library=static -Denable_tools=false -Denable_tests=false -Db_ndebug=true --buildtype=release"
    } > "$TMP/configure.txt"
    for ARCH in arm64 x86_64; do
        echo "Building FFmpeg for $ARCH"
        CPU=$([ "$ARCH" = arm64 ] && echo aarch64 || echo x86_64)
        FLAGS="-arch $ARCH -mmacosx-version-min=$MIN_OS"
        PREFIX="$TMP/$ARCH"
        cat > "$TMP/$ARCH.meson" <<EOF
[binaries]
c = ['clang', '-arch', '$ARCH', '-mmacosx-version-min=$MIN_OS']
ar = 'ar'
strip = 'strip'
nasm = 'nasm'
[host_machine]
system = 'darwin'
cpu_family = '$CPU'
cpu = '$CPU'
endian = 'little'
EOF
        mkdir -p "$TMP/src-$ARCH"
        tar -xf "$TMP/$DAV1D.tar.xz" -C "$TMP/src-$ARCH"
        tar -xf "$TMP/$FFMPEG.tar.xz" -C "$TMP/src-$ARCH"
        meson setup "$TMP/dav1d-$ARCH" "$TMP/src-$ARCH/$DAV1D" --cross-file "$TMP/$ARCH.meson" --prefix "$PREFIX" --libdir lib \
            --default-library=static -Denable_tools=false -Denable_tests=false -Db_ndebug=true --buildtype=release >"$TMP/dav1d-$ARCH.log" 2>&1 \
            || { tail -20 "$TMP/dav1d-$ARCH.log"; exit 1; }
        ninja -C "$TMP/dav1d-$ARCH" install >>"$TMP/dav1d-$ARCH.log" 2>&1 || { tail -20 "$TMP/dav1d-$ARCH.log"; exit 1; }
        CONFIGURE=(
            --prefix="$PREFIX" --install-name-dir=@rpath
            --arch="$ARCH" --target-os=darwin --enable-cross-compile --cc=clang
            --extra-cflags="$FLAGS" --extra-ldflags="$FLAGS"
            --pkg-config=pkg-config --pkg-config-flags=--static
            --enable-shared --disable-static --enable-pic --disable-debug
            --disable-everything --disable-programs --disable-doc --disable-network --disable-autodetect
            --disable-avdevice --disable-avfilter --disable-swscale --disable-swresample
            --enable-zlib --enable-libdav1d
            "${COMPONENTS[@]}"
        )
        (cd "$TMP/src-$ARCH/$FFMPEG" && PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig" PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig" ./configure "${CONFIGURE[@]}" >"$TMP/ffmpeg-$ARCH.log" 2>&1) \
            || { tail -20 "$TMP/src-$ARCH/$FFMPEG/ffbuild/config.log"; exit 1; }
        CONFIG="$TMP/src-$ARCH/$FFMPEG/config.h"
        grep -q '^#define FFMPEG_LICENSE "LGPL version 2.1 or later"$' "$CONFIG" || { echo "FFmpeg license is not LGPL 2.1 or later: $(grep FFMPEG_LICENSE "$CONFIG")" >&2; exit 1; }
        for FLAG in GPL NONFREE VERSION3; do
            ! grep -q "^#define CONFIG_$FLAG 1$" "$CONFIG" || { echo "FFmpeg is configured with CONFIG_$FLAG" >&2; exit 1; }
        done
        make -C "$TMP/src-$ARCH/$FFMPEG" -j"$JOBS" install >>"$TMP/ffmpeg-$ARCH.log" 2>&1 || { tail -20 "$TMP/ffmpeg-$ARCH.log"; exit 1; }
        echo "$ARCH: ./configure $(printf '%q ' "${CONFIGURE[@]}" | sed "s|$TMP/$ARCH|PREFIX|g")" >> "$TMP/configure.txt"
    done
    diff -r "$TMP/arm64/include" "$TMP/x86_64/include" >/dev/null || { echo "FFmpeg headers differ between arm64 and x86_64" >&2; exit 1; }
    rm -rf "$OUT"
    mkdir -p "$OUT/lib"
    cp -R "$TMP/arm64/include" "$OUT/include"
    rm -rf "$OUT/include/dav1d"
    for LIB in $LIBS; do
        for ARCH in arm64 x86_64; do strip -x "$TMP/$ARCH/lib/$LIB.dylib"; done
        lipo -create "$TMP/arm64/lib/$LIB.dylib" "$TMP/x86_64/lib/$LIB.dylib" -output "$OUT/lib/$LIB.dylib"
    done
    mv "$TMP/configure.txt" "$OUT/configure.txt"
    { echo "$FFMPEG: GNU Lesser General Public License 2.1 or later"; echo; cat "$TMP/src-arm64/$FFMPEG/COPYING.LGPLv2.1"; echo; echo "$DAV1D: BSD 2-Clause License"; echo; cat "$TMP/src-arm64/$DAV1D/COPYING"; } > "$OUT/License.txt"
    echo "$STAMP" > "$OUT/stamp"
    echo "$FFMPEG and $DAV1D are in $OUT ($(du -ch "$OUT"/lib/*.dylib | tail -1 | cut -f1))"
fi

if [ -n "$SOURCE_DIR" ]; then
    fetch
    mkdir -p "$SOURCE_DIR"
    mv "$TMP/$FFMPEG.tar.xz" "$TMP/$DAV1D.tar.xz" "$SOURCE_DIR/"
    echo "$FFMPEG and $DAV1D source is in $SOURCE_DIR"
fi
