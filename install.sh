#!/bin/bash
set -euo pipefail

GITHUB_USER="dev-pikapik"

REPO="https://github.com/$GITHUB_USER/pika-tools"
APP_NAME="pika-tools.app"
DEST="/Applications/$APP_NAME"

say() { printf '\033[1m→ %s\033[0m\n' "$1"; }
fail() { printf '\033[31m✗ %s\033[0m\n' "$1" >&2; exit 1; }

[ "$(uname)" = "Darwin" ] || fail "pika-tools runs only on macOS."
[ "$(sw_vers -productVersion | cut -d. -f1)" -ge 14 ] || fail "pika-tools needs macOS 14 Sonoma or later."

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

build_from_source() {
    if ! xcode-select -p >/dev/null 2>&1 || ! xcrun --find swiftc >/dev/null 2>&1; then
        say "Building needs the Xcode Command Line Tools. Opening the installer."
        xcode-select --install || true
        fail "Install the Command Line Tools and run this command again."
    fi
    local src
    local here
    here="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
    if [ -n "$here" ] && [ -f "$here/scripts/build.sh" ]; then
        src="$here"
    else
        say "Downloading the source"
        src="$WORK/src"
        git clone --depth 1 --quiet "$REPO.git" "$src"
    fi
    say "Building the app"
    "$src/scripts/build.sh" >/dev/null
    NEW_APP="$src/build/$APP_NAME"
}

if [ "${1:-}" = "--source" ]; then
    build_from_source
else
    say "Downloading the latest version"
    if curl -fsSL "$REPO/releases/latest/download/pika-tools.zip" -o "$WORK/pika-tools.zip" \
        && ditto -x -k "$WORK/pika-tools.zip" "$WORK/app" \
        && [ -d "$WORK/app/$APP_NAME" ]; then
        NEW_APP="$WORK/app/$APP_NAME"
    else
        say "No ready build found, building from source"
        build_from_source
    fi
fi

if pgrep -x pika-tools >/dev/null; then
    say "Quitting the running copy"
    pkill -x pika-tools || true
    sleep 1
fi

say "Copying to /Applications"
SUDO=""
[ -w /Applications ] || SUDO="sudo"
$SUDO rm -rf "$DEST"
$SUDO ditto "$NEW_APP" "$DEST"
$SUDO xattr -dr com.apple.quarantine "$DEST" 2>/dev/null || true

say "Launching"
open "$DEST"

cat <<'EOF'

Done. pika-tools is in the menu bar, next to the clock.

One last step: turn on pika-tools in these two lists (a window with help is already open):
  System Settings › Privacy & Security › Accessibility
  System Settings › Privacy & Security › Input Monitoring

The app opens at login and checks for updates on its own.
EOF
