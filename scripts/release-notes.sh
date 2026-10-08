#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

VERSION="${1:?Usage: ./scripts/release-notes.sh 1.3.0}"
PAGE=docs/whats-new/README.md
REPO=https://github.com/dev-pikapik/pika-tools
grep -qF "id=\"v$VERSION\"" "$PAGE" || { echo "No What’s new post for $VERSION in $PAGE" >&2; exit 1; }

awk -v id="id=\"v$VERSION\"" 'index($0, id) { on = 1 } on && /^---$/ { exit } on' "$PAGE" \
  | sed -e 's|<a id="[^"]*"></a>||' -e "s|\.\./media/|$REPO/raw/v$VERSION/docs/media/|g"
grep -m1 'href="README\.' "$PAGE" \
  | sed -e 's|<b>[^<]*</b> · ||' -e "s|href=\"README\.\([^\"]*\)\.md\"|href=\"$REPO/blob/main/docs/whats-new/README.\1.md#v$VERSION\"|g"
