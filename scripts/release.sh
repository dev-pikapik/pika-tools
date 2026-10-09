#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

VERSION="${1:-}"
[ -n "$VERSION" ] || { echo "Usage: ./scripts/release.sh 1.3.0" >&2; exit 1; }
[ -z "$(git status --porcelain)" ] || { echo "Commit your changes first." >&2; exit 1; }
MISSING=$(grep -LF "id=\"v$VERSION\"" docs/whats-new/README*.md || true)
[ -z "$MISSING" ] || { echo "Write the What’s new post for $VERSION first. It’s missing in:" >&2; echo "$MISSING" >&2; exit 1; }
grep -qxF "## [$VERSION] - Unreleased" CHANGELOG.md || { echo "Add “## [$VERSION] - Unreleased” to CHANGELOG.md first." >&2; exit 1; }
FORM=".github/ISSUE_TEMPLATE/bug_report.yml"
grep -qxF "        - Latest version" "$FORM" || { echo "“- Latest version” is missing in $FORM." >&2; exit 1; }

PLIST="Sources/pika-tools/Info.plist"
BUILD=$(( $(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$PLIST") + 1 ))
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD" "$PLIST"

sed -i '' "s/^## \[${VERSION//./\\.}\] - Unreleased$/## [$VERSION] - $(date +%F)/" CHANGELOG.md
REF="[$VERSION]: https://github.com/dev-pikapik/pika-tools/releases/tag/v$VERSION"
grep -qxF "$REF" CHANGELOG.md || { awk -v ref="$REF" '!done && /^\[[0-9]/ { print ref; done = 1 } 1' CHANGELOG.md > CHANGELOG.md.new && mv CHANGELOG.md.new CHANGELOG.md; }

grep -qxF "        - \"$VERSION\"" "$FORM" || { awk -v v="        - \"$VERSION\"" '{ print } $0 == "        - Latest version" { print v }' "$FORM" > "$FORM.new" && mv "$FORM.new" "$FORM"; }

git add "$PLIST" CHANGELOG.md "$FORM"
git commit -q -m "Version $VERSION"
git tag "v$VERSION"
git push -q origin HEAD "v$VERSION"

echo "Pushed v$VERSION. GitHub Actions will build, publish and update the Homebrew tap:"
echo "https://github.com/dev-pikapik/pika-tools/actions"
