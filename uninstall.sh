#!/bin/bash
set -euo pipefail

DEST="/Applications/pika-tools.app"
BUNDLE_ID="com.pesotchi.pika-tools"

say() { printf '\033[1m→ %s\033[0m\n' "$1"; }

if [ -d "$DEST" ]; then
    say "Убираю из объектов входа"
    pkill -x pika-tools 2>/dev/null || true
    sleep 1
    open -W -n "$DEST" --args --uninstall 2>/dev/null || true
fi

pkill -x pika-tools 2>/dev/null || true

say "Удаляю приложение"
if [ -d "$DEST" ]; then
    SUDO=""
    [ -w /Applications ] || SUDO="sudo"
    $SUDO rm -rf "$DEST"
fi

say "Чищу доступы и настройки"
tccutil reset Accessibility "$BUNDLE_ID" >/dev/null 2>&1 || true
tccutil reset ListenEvent "$BUNDLE_ID" >/dev/null 2>&1 || true
defaults delete "$BUNDLE_ID" >/dev/null 2>&1 || true

echo "pika-tools удалён."
