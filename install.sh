#!/bin/bash
set -euo pipefail

GITHUB_USER="dev-pikapik"

REPO="https://github.com/$GITHUB_USER/pika-tools"
APP_NAME="pika-tools.app"
DEST="/Applications/$APP_NAME"
BUNDLE_ID="com.pesotchi.pika-tools"

say() { printf '\033[1m→ %s\033[0m\n' "$1"; }
fail() { printf '\033[31m✗ %s\033[0m\n' "$1" >&2; exit 1; }

[ "$(uname)" = "Darwin" ] || fail "pika-tools работает только на macOS."
[ "$(sw_vers -productVersion | cut -d. -f1)" -ge 14 ] || fail "Нужна macOS 14 Sonoma или новее."

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

build_from_source() {
    if ! xcode-select -p >/dev/null 2>&1 || ! xcrun --find swiftc >/dev/null 2>&1; then
        say "Для сборки нужны Xcode Command Line Tools. Открываю установщик."
        xcode-select --install || true
        fail "Поставь Command Line Tools и запусти эту команду ещё раз."
    fi
    local src
    local here
    here="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
    if [ -n "$here" ] && [ -f "$here/scripts/build.sh" ]; then
        src="$here"
    else
        say "Скачиваю исходники"
        src="$WORK/src"
        git clone --depth 1 --quiet "$REPO.git" "$src"
    fi
    say "Собираю приложение (arm64 + x86_64)"
    "$src/scripts/build.sh" >/dev/null
    NEW_APP="$src/build/$APP_NAME"
}

if [ "${1:-}" = "--source" ]; then
    build_from_source
else
    say "Скачиваю последнюю версию"
    if curl -fsSL "$REPO/releases/latest/download/pika-tools.zip" -o "$WORK/pika-tools.zip" \
        && ditto -x -k "$WORK/pika-tools.zip" "$WORK/app" \
        && [ -d "$WORK/app/$APP_NAME" ]; then
        NEW_APP="$WORK/app/$APP_NAME"
    else
        say "Готовой сборки нет, соберу из исходников"
        build_from_source
    fi
fi

if pgrep -x pika-tools >/dev/null; then
    say "Закрываю старую версию"
    pkill -x pika-tools || true
    sleep 1
fi

say "Кладу в /Applications"
SUDO=""
[ -w /Applications ] || SUDO="sudo"
$SUDO rm -rf "$DEST"
$SUDO ditto "$NEW_APP" "$DEST"
$SUDO xattr -dr com.apple.quarantine "$DEST" 2>/dev/null || true

tccutil reset Accessibility "$BUNDLE_ID" >/dev/null 2>&1 || true
tccutil reset ListenEvent "$BUNDLE_ID" >/dev/null 2>&1 || true

say "Запускаю"
open "$DEST"

cat <<'EOF'

Готово. Иконка pika-tools уже в строке меню, рядом с часами.

Осталось дать два доступа — окно с подсказкой открыто:
  System Settings › Privacy & Security › Accessibility     → включи pika-tools
  System Settings › Privacy & Security › Input Monitoring  → включи pika-tools

Автозапуск при входе включён. Обновления приложение проверяет само.
EOF
