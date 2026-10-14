#!/bin/bash
# Fills the “Which feature?” dropdown of the issue forms from docs/FEATURES.md:
# every “## Group” and “### Feature” heading there becomes “Group › Feature”.
# --check changes nothing and fails when a form is out of date.
set -euo pipefail
cd "$(dirname "$0")/.."

CATALOG="docs/FEATURES.md"
FORMS=".github/ISSUE_TEMPLATE/bug_report.yml .github/ISSUE_TEMPLATE/feature_request.yml"

LIST=$(awk '/^## / { group = substr($0, 4) } /^### / { print group " › " substr($0, 5) }' "$CATALOG")
[ -n "$LIST" ] || { echo "No “### Feature” headings in $CATALOG." >&2; exit 1; }
DUP=$(sort <<< "$LIST" | uniq -d)
[ -z "$DUP" ] || { echo "Listed twice in $CATALOG:" >&2; echo "$DUP" >&2; exit 1; }
! grep -q '["\\]' <<< "$LIST" || { echo "Use “curly quotes” in $CATALOG headings, not \" or \\." >&2; exit 1; }
export LIST

STALE=0
for FORM in $FORMS; do
    NEW=$(awk '
        /# features:end/ { skip = 0 }
        !skip { print }
        /# features:start/ {
            n = split(ENVIRON["LIST"], items, "\n")
            for (i = 1; i <= n; i++) print "        - \"" items[i] "\""
            skip = 1
        }
    ' "$FORM")
    [ "$(grep -cE '# features:(start|end)' <<< "$NEW")" == 2 ] || { echo "$FORM needs “# features:start” and “# features:end” lines." >&2; exit 1; }
    [ "$NEW" == "$(cat "$FORM")" ] && continue
    if [ "${1:-}" == "--check" ]; then
        echo "$FORM does not match $CATALOG. Run ./scripts/feature-form.sh and commit the result:" >&2
        diff <(cat "$FORM") <(echo "$NEW") >&2 || true
        STALE=1
    else
        echo "$NEW" > "$FORM"
        echo "Updated $FORM"
    fi
done
exit $STALE
