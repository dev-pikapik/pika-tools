#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

VERSION="${1:-}"
[ -n "$VERSION" ] || { echo "Usage: ./scripts/release.sh 1.3.0" >&2; exit 1; }
[ -z "$(git status --porcelain)" ] || { echo "Commit your changes first." >&2; exit 1; }

PLIST="Sources/pika-tools/Info.plist"
BUILD=$(( $(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$PLIST") + 1 ))
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD" "$PLIST"

git add "$PLIST"
git commit -q -m "Version $VERSION"
git tag "v$VERSION"
git push -q origin HEAD "v$VERSION"

echo "Pushed v$VERSION. GitHub Actions will build, publish and update the cask:"
echo "https://github.com/dev-pikapik/pika-tools/actions"
