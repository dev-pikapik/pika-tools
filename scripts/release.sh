#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

VERSION="${1:-}"
[ -n "$VERSION" ] || { echo "Укажи версию: ./scripts/release.sh 1.0.2" >&2; exit 1; }
[ -z "$(git status --porcelain)" ] || { echo "Сначала закоммить изменения." >&2; exit 1; }

PLIST="Sources/pika-tools/Info.plist"
BUILD=$(( $(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$PLIST") + 1 ))
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD" "$PLIST"

git add "$PLIST"
git commit -q -m "Версия $VERSION"
git tag "v$VERSION"
git push -q origin HEAD "v$VERSION"

echo "Тег v$VERSION отправлен. Сборку, релиз и cask сделает GitHub Actions:"
echo "https://github.com/dev-pikapik/pika-tools/actions"
