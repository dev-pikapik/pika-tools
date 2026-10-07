#!/bin/bash
# Usage: scripts/check-strings.sh [dir with .stringsdata from swiftc -emit-localized-strings]
# Without an argument it compiles the sources into a temporary dir first.
set -euo pipefail
cd "$(dirname "$0")/.."

DIR="${1:-}"
if [ -z "$DIR" ]; then
    DIR="$(mktemp -d)"
    trap 'rm -rf "$DIR"' EXIT
    SOURCES=()
    while IFS= read -r -d '' f; do SOURCES+=("$f"); done < <(find Sources -name '*.swift' -print0)
    FLAGS=()
    if [ -d Private/Sources ] && [ -n "$(find Private/Sources -name '*.swift' -print -quit)" ]; then
        while IFS= read -r -d '' f; do SOURCES+=("$f"); done < <(find Private/Sources -name '*.swift' -print0)
        FLAGS+=(-D PIKA_PRIVATE)
    fi
    echo "Extracting strings"
    swiftc -wmo -c -module-name PikaTools -target arm64-apple-macos14.0 \
        ${FLAGS[@]+"${FLAGS[@]}"} \
        -Xfrontend -emit-localized-strings -Xfrontend -emit-localized-strings-path -Xfrontend "$DIR" \
        "${SOURCES[@]}" -o "$DIR/app.o"
    for EXT in NewFile Compress; do
        swiftc -wmo -c -module-name "$EXT" -target arm64-apple-macos14.0 -application-extension \
            -Xfrontend -emit-localized-strings -Xfrontend -emit-localized-strings-path -Xfrontend "$DIR" \
            Extensions/"$EXT"/*.swift -o "$DIR/$EXT.o"
    done
fi

python3 - "$DIR" <<'PY'
import glob, json, os, re, subprocess, sys
from collections import Counter

problems = []

def fail(text):
    problems.append(text)

def escape(s):
    return s.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n')

def unescape(s):
    return re.sub(r'\\(.)', lambda m: {'n': '\n', 't': '\t'}.get(m.group(1), m.group(1)), s)

SPEC = re.compile(r'%(?:\d+\$)?[-+ 0#]*(?:\d+|\*)?(?:\.\d+)?(?:hh|h|ll|l|q|L|z|t|j)?[@dDiuUxXoOfFeEgGcCsSpaA]')

def specs(s):
    return Counter(re.sub(r'(?<=%)\d+\$', '', m) for m in SPEC.findall(s.replace('%%', '')))

def load(path):
    r = subprocess.run(['plutil', '-convert', 'json', '-o', '-', path], capture_output=True, text=True)
    if r.returncode:
        fail(f'{path}: {r.stderr.strip()}')
        return {}
    table = json.loads(r.stdout)
    written = len(re.findall(r'^"(?:[^"\\]|\\.)*"\s*=', open(path, encoding='utf-8').read(), re.M))
    if written != len(table):
        fail(f'{path}: {written - len(table)} duplicate key(s)')
    return table

code = {}
for path in sorted(glob.glob(sys.argv[1] + '/**/*.stringsdata', recursive=True)):
    data = json.load(open(path))
    for table, items in data.get('tables', {}).items():
        for item in items:
            where = f"{os.path.relpath(data['source'])}:{item.get('location', {}).get('startingLine', '?')}"
            if table != 'Localizable':
                fail(f'{where}: table "{table}" is not Localizable')
            code.setdefault(item['key'], where)
if not code:
    fail(f'no strings found in {sys.argv[1]}')

swift = {}
for root in ('Sources', 'Extensions', 'Private/Sources'):
    for path in glob.glob(root + '/**/*.swift', recursive=True):
        swift[path] = open(path, encoding='utf-8').read()

# The compiler does not see texts picked through a ternary or looked up by name at run time.
named = {}
for path, text in swift.items():
    for n, line in enumerate(text.split('\n'), 1):
        for m in re.finditer(r'(?:synonyms:|LocalizedStringKey\(|NSLocalizedString\()\s*"((?:[^"\\]|\\.)*)"', line):
            if '\\(' not in m.group(1):
                named.setdefault(unescape(m.group(1)), f'{path}:{n}')
needed = {**named, **code}

langs = sorted(os.path.basename(p)[:-len('.lproj')] for p in glob.glob('Resources/*.lproj'))
tables = {lang: load(f'Resources/{lang}.lproj/Localizable.strings') for lang in langs}
english = tables.get('en', {})
all_text = '\n'.join(swift.values())

for key, where in sorted(needed.items(), key=lambda kv: kv[1]):
    for lang in langs:
        if key not in tables[lang]:
            fail(f'{where}: "{key[:60]}" is missing in {lang}')
for key in sorted(english):
    if key not in needed and f'"{escape(key)}"' not in all_text:
        fail(f'en.lproj: "{key[:60]}" is not used in the code')
for lang in langs:
    for key, value in tables[lang].items():
        if key not in english:
            fail(f'{lang}.lproj: "{key[:60]}" is not in en.lproj')
        elif not value.strip():
            fail(f'{lang}.lproj: "{key[:60]}" is empty')
        elif specs(key) != specs(value):
            fail(f'{lang}.lproj: "{key[:60]}" has different placeholders: {dict(specs(value))}')

LITERAL = re.compile(r'(?:NSMenuItem\(title:|addItem\(withTitle:|addButton\(withTitle:|\bitem\(menu,|'
                     r'\.(?:messageText|informativeText|prompt|toolTip|placeholderString)\s*=|setAccessibilityLabel\()\s*"[^"]*[A-Za-z]')
for path, text in swift.items():
    for n, line in enumerate(text.split('\n'), 1):
        if LITERAL.search(line):
            fail(f'{path}:{n}: this text is not translated, wrap it in String(localized:)')

declared = set(json.loads(subprocess.run(['plutil', '-extract', 'CFBundleLocalizations', 'json', '-o', '-',
                                          'Sources/pika-tools/Info.plist'], capture_output=True, text=True).stdout or '[]'))
picker = re.search(r'static let codes = \[([^\]]*)\]', all_text)
picker = set(re.findall(r'"([^"]+)"', picker.group(1))) if picker else set()
for name, found in (('CFBundleLocalizations in Info.plist', declared), ('Language.codes', picker)):
    if found != set(langs):
        fail(f'{name} differs from Resources/*.lproj: {sorted(found ^ set(langs))}')
for lang in langs:
    readme = 'README.md' if lang == 'en' else f'docs/readme/README.{lang}.md'
    if not os.path.exists(readme):
        fail(f'{readme} is missing')

if problems:
    print('\n'.join(problems[:60]))
    if len(problems) > 60:
        print(f'... and {len(problems) - 60} more')
    sys.exit(f'Strings check failed: {len(problems)} problem(s)')
print(f'Strings OK: {len(english)} texts in {len(langs)} languages')
PY
