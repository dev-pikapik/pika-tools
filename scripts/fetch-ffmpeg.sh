#!/bin/bash
# Usage: scripts/fetch-ffmpeg.sh [--source DIR]
# Builds the LGPL parts of FFmpeg with dav1d inside as universal dylibs in Vendor/ffmpeg/{lib,include} for the media extensions (nothing happens if this script already built them).
# The same folder gets libass (a static library with FreeType and HarfBuzz inside) and FriBidi (a separate LGPL dylib) for the player's ASS subtitles.
# With --source DIR it also saves the matching source archives in DIR.
set -euo pipefail
cd "$(dirname "$0")/.."

FFMPEG=ffmpeg-8.1.3
FFMPEG_SHA=7138d28c96d9d3e3af4ee3d8cad72741f8ffb40da90c1112235dea3ecd3178a3
DAV1D=dav1d-1.5.4
DAV1D_SHA=686616b7c69eb88d44459391ab25cac13b6647a3b288835c5784e71c1514a5c5
LIBASS=libass-0.17.5
LIBASS_SHA=2dca25c0e0c837ddf00b52011b3f82cac1e4ddd3ad018227806b0c2288864acc
FREETYPE=freetype-2.15.0
FREETYPE_SHA=93cd47eb719c325107f2d3cf087d06299e944c3b48a40b55537302304dea1dd5
HARFBUZZ=harfbuzz-14.6.0
HARFBUZZ_SHA=d07a007327277708a2a73ae437887cdbaf282937f6d03ca5467723e9099af586
FRIBIDI=fribidi-1.0.17
FRIBIDI_SHA=6949dcde27d41cebad1fd741fcafc36d55a1020d2d872d4a6eb3914caabbada2
MIN_OS=14.0
LIBS="libavutil.60 libavcodec.62 libavformat.62 libfribidi.0"
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
    download "$LIBASS.tar.xz" "https://github.com/libass/libass/releases/download/${LIBASS#libass-}" "$LIBASS_SHA"
    download "$FREETYPE.tar.xz" https://download.savannah.gnu.org/releases/freetype "$FREETYPE_SHA"
    download "$HARFBUZZ.tar.xz" "https://github.com/harfbuzz/harfbuzz/releases/download/${HARFBUZZ#harfbuzz-}" "$HARFBUZZ_SHA"
    download "$FRIBIDI.tar.xz" "https://github.com/fribidi/fribidi/releases/download/v${FRIBIDI#fribidi-}" "$FRIBIDI_SHA"
}

# meson_build NAME SOURCE_DIR OPTION...: builds one meson project for $ARCH into $PREFIX; it finds the other libraries there and nowhere else
meson_build() {
    local NAME="$1" SRC="$2" LOG="$TMP/$1-$ARCH.log"
    shift 2
    { PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig" meson setup "$TMP/$NAME-$ARCH" "$TMP/src-$ARCH/$SRC" --cross-file "$TMP/$ARCH.meson" --prefix "$PREFIX" --libdir lib \
        --pkg-config-path "$PREFIX/lib/pkgconfig" --wrap-mode=nofallback --buildtype=release -Db_ndebug=true "$@" \
        && ninja -C "$TMP/$NAME-$ARCH" install; } >"$LOG" 2>&1 || { tail -20 "$LOG"; exit 1; }
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
        --enable-parser=aac,aac_latm,ac3,av1,flac,h263,h264,hevc,mpeg4video,mpegaudio,mpegvideo,opus,vc1,vorbis,vp3,vp8,vp9,dvdsub,dvbsub
        --enable-decoder=aac,vp8,vp9,libdav1d,mpeg4,msmpeg4v1,msmpeg4v2,msmpeg4v3,wmv1,wmv2,wmv3,vc1,theora,mpeg1video,mpeg2video,flv,h263,wmav1,wmav2,vorbis,ape,dsd_lsbf_planar,pgssub,dvdsub,dvbsub
        --enable-bsf=aac_adtstoasc,extract_extradata,mpeg4_unpack_bframes
        --enable-decoder=dca
        --enable-parser=dca
    )
    {
        echo "$FFMPEG (LGPL 2.1 or later) and $DAV1D (BSD 2-Clause), built by scripts/fetch-ffmpeg.sh"
        echo "dav1d: meson setup --default-library=static -Denable_tools=false -Denable_tests=false -Db_ndebug=true --buildtype=release"
        echo "$LIBASS (ISC), $FREETYPE (FreeType License), $HARFBUZZ (MIT) and $FRIBIDI (LGPL 2.1 or later): FreeType, HarfBuzz and libass are static and end up inside the player; FriBidi is the separate libfribidi.0.dylib, which you can replace with your own build of the same source."
        echo "FreeType: meson setup --default-library=static -Dharfbuzz=disabled -Dzlib=disabled -Dbzip2=disabled -Dpng=disabled -Dbrotli=disabled -Dtests=disabled -Dhvf=disabled"
        echo "HarfBuzz: meson setup --default-library=static, every optional part disabled (-Dfreetype=disabled -Dcoretext=disabled -Dglib=disabled -Dicu=disabled ...)"
        echo "FriBidi: meson setup --default-library=shared -Ddocs=false -Dbin=false -Dtests=false"
        echo "libass: meson setup --default-library=static -Dfontconfig=disabled -Dcoretext=enabled -Dlibunibreak=disabled -Dasm=enabled"
    } > "$TMP/configure.txt"
    for ARCH in arm64 x86_64; do
        echo "Building FFmpeg for $ARCH"
        CPU=$([ "$ARCH" = arm64 ] && echo aarch64 || echo x86_64)
        FLAGS="-arch $ARCH -mmacosx-version-min=$MIN_OS"
        PREFIX="$TMP/$ARCH"
        cat > "$TMP/$ARCH.meson" <<EOF
[binaries]
c = ['clang', '-arch', '$ARCH', '-mmacosx-version-min=$MIN_OS']
cpp = ['clang++', '-arch', '$ARCH', '-mmacosx-version-min=$MIN_OS']
ar = 'ar'
strip = 'strip'
nasm = 'nasm'
pkg-config = 'pkg-config'
[host_machine]
system = 'darwin'
cpu_family = '$CPU'
cpu = '$CPU'
endian = 'little'
EOF
        mkdir -p "$TMP/src-$ARCH"
        for SRC in $FFMPEG $DAV1D $LIBASS $FREETYPE $HARFBUZZ $FRIBIDI; do tar -xf "$TMP/$SRC.tar.xz" -C "$TMP/src-$ARCH"; done
        meson_build fribidi "$FRIBIDI" --default-library=shared -Ddocs=false -Dbin=false -Dtests=false
        meson_build freetype "$FREETYPE" --default-library=static -Dharfbuzz=disabled -Dzlib=disabled -Dbzip2=disabled -Dpng=disabled -Dbrotli=disabled -Dtests=disabled -Dhvf=disabled
        meson_build harfbuzz "$HARFBUZZ" --default-library=static -Dfreetype=disabled -Dglib=disabled -Dgobject=disabled -Dcairo=disabled -Dchafa=disabled -Dicu=disabled \
            -Dgraphite=disabled -Dgraphite2=disabled -Dfontations=disabled -Dharfrust=disabled -Dkbts=disabled -Dwasm=disabled -Dcoretext=disabled -Dgdi=disabled \
            -Ddirectwrite=disabled -Draster=disabled -Dvector=disabled -Dgpu=disabled -Dgpu_demo=disabled -Dsubset=disabled -Dtests=disabled -Dintrospection=disabled \
            -Ddocs=disabled -Dutilities=disabled -Dbenchmark=disabled -Dpng=disabled -Dzlib=disabled
        meson_build libass "$LIBASS" --default-library=static -Dfontconfig=disabled -Ddirectwrite=disabled -Dcoretext=enabled -Dlibunibreak=disabled -Dasm=enabled \
            -Dtest=disabled -Dcompare=disabled -Dprofile=disabled -Dfuzz=disabled -Dcheckasm=disabled
        libtool -static -o "$PREFIX/lib/libass-all.a" "$PREFIX/lib/libass.a" "$PREFIX/lib/libfreetype.a" "$PREFIX/lib/libharfbuzz.a" >"$TMP/libtool-$ARCH.log" 2>&1 || { tail -20 "$TMP/libtool-$ARCH.log"; exit 1; }
        meson_build dav1d "$DAV1D" --default-library=static -Denable_tools=false -Denable_tests=false
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
    rm -rf "$OUT/include/dav1d" "$OUT/include/freetype2" "$OUT/include/harfbuzz" "$OUT/include/fribidi"
    for LIB in $LIBS; do
        for ARCH in arm64 x86_64; do
            [ "$LIB" != libfribidi.0 ] || install_name_tool -id "@rpath/$LIB.dylib" "$TMP/$ARCH/lib/$LIB.dylib"
            strip -x "$TMP/$ARCH/lib/$LIB.dylib"
        done
        lipo -create "$TMP/arm64/lib/$LIB.dylib" "$TMP/x86_64/lib/$LIB.dylib" -output "$OUT/lib/$LIB.dylib"
    done
    lipo -create "$TMP/arm64/lib/libass-all.a" "$TMP/x86_64/lib/libass-all.a" -output "$OUT/lib/libass.a"
    mv "$TMP/configure.txt" "$OUT/configure.txt"
    {
        echo "$FFMPEG: GNU Lesser General Public License 2.1 or later"; echo; cat "$TMP/src-arm64/$FFMPEG/COPYING.LGPLv2.1"; echo
        echo "$DAV1D: BSD 2-Clause License"; echo; cat "$TMP/src-arm64/$DAV1D/COPYING"; echo
        echo "$LIBASS: ISC License"; echo; cat "$TMP/src-arm64/$LIBASS/COPYING"; echo
        echo "$FREETYPE: The FreeType Project License (used under this license, not the GPL)"; echo; cat "$TMP/src-arm64/$FREETYPE/docs/FTL.TXT"; echo
        echo "$HARFBUZZ: MIT License"; echo; cat "$TMP/src-arm64/$HARFBUZZ/COPYING"; echo
        echo "$FRIBIDI: GNU Lesser General Public License 2.1 or later. It is a separate library (libfribidi.0.dylib in the Frameworks folder of the app): you can replace it with your own build of the same source. The source is attached to the release this app came from."; echo; cat "$TMP/src-arm64/$FRIBIDI/COPYING"
    } > "$OUT/License.txt"
    echo "$STAMP" > "$OUT/stamp"
    echo "$FFMPEG, $DAV1D, $LIBASS, $FREETYPE, $HARFBUZZ and $FRIBIDI are in $OUT ($(du -ch "$OUT"/lib/* | tail -1 | cut -f1))"
fi

if [ -n "$SOURCE_DIR" ]; then
    fetch
    mkdir -p "$SOURCE_DIR"
    mv "$TMP/$FFMPEG.tar.xz" "$TMP/$DAV1D.tar.xz" "$TMP/$LIBASS.tar.xz" "$TMP/$FREETYPE.tar.xz" "$TMP/$HARFBUZZ.tar.xz" "$TMP/$FRIBIDI.tar.xz" "$SOURCE_DIR/"
    echo "$FFMPEG, $DAV1D, $LIBASS, $FREETYPE, $HARFBUZZ and $FRIBIDI source is in $SOURCE_DIR"
fi
