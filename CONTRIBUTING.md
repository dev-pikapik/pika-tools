# Contributing

Bug reports and ideas are welcome in [Issues](https://github.com/dev-pikapik/pika-tools/issues). This page covers building, the code layout and how releases are made.

## Building from source

All you need is the Xcode Command Line Tools. Xcode itself isn't required: the app is built with plain `swiftc`.

```bash
git clone https://github.com/dev-pikapik/pika-tools.git
cd pika-tools
./scripts/build.sh      # build/pika-tools.app
./scripts/package.sh    # build/pika-tools.dmg and build/pika-tools.zip
```

`install.sh` can also build from source: add `-- --source` after the install command from the README.

Local builds are signed ad-hoc, which is fine for your own Mac. macOS treats every ad-hoc build as a new app, so after a rebuild you may need to remove pika-tools from Accessibility and Input Monitoring with the − button and add it again.

To sign with a Developer ID and notarize:

```bash
xcrun notarytool store-credentials pika-notary --apple-id you@example.com --team-id TEAMID
SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)" NOTARY_PROFILE=pika-notary ./scripts/package.sh
```

## Layout

```
Sources/pika-tools/
  main.swift, App.swift, MenuView.swift
  Tools/Tool.swift                   Tool protocol and ToolRegistry
  Tools/CtrlKeys/CtrlKeysTool.swift
  Tools/CommandKeys/CommandKeysTool.swift
  Tools/InputSwitch/InputSwitchTool.swift, InputSwitchGesture.swift
  Tools/Windows/QuitOnCloseTool.swift, DockHideTool.swift
  Common/                            shared UI, permissions, login item, updater
Resources/<lang>.lproj/              Localizable.strings
Resources/AppIcon.icon               app icon, AppIcon.icns is the fallback
Casks/pika-tools.rb                  Homebrew cask
scripts/                             build, package, release, icon, tests
```

Ctrl shortcuts are caught with a `CGEventTap` before events reach other apps, for `keyDown`/`keyUp` and the left mouse button (`leftMouseDown`/`leftMouseUp`/`leftMouseDragged`). Events that arrive with Ctrl held lose the Ctrl flag, and the Cmd flag too if Cmd is also held, so Ctrl+Cmd+Space doesn't turn into Cmd+Space (Spotlight) and Ctrl+Cmd-click doesn't become Cmd-click. The `flagsChanged` event for Ctrl itself is left alone, so apps still see Ctrl held while macOS sees no shortcut. Right-click is never touched.

The ⌘Q and ⌘W guard is a `CGEventTap` on `keyDown`/`keyUp`. A bare ⌘Q or ⌘W, with Cmd and without Ctrl, Option or Shift, is dropped. The quit and close shortcuts, ⇧⌘Q and ⇧⌘W unless you record your own, are swallowed and replaced with a fresh ⌘Q or ⌘W, so the app sees a normal quit or close. Ctrl+Cmd combinations are left to the Ctrl tool.

Shortcuts in Settings are read live. macOS shortcuts come from `AppleSymbolicHotKeys` in `com.apple.symbolichotkeys`, and a missing entry means the macOS default, which SkyLight reports. Finder's Cut comes from `NSUserKeyEquivalents` for Finder and then for all apps, matched by the menu title in Finder's language. They are read again when pika-tools becomes active or a window comes forward. The recorder catches keys with a session event tap and pauses the Mac's own shortcuts while you type, the same way Game Mode does, so it can tell you what already uses them. Parsing and the conflict check live in `Shortcuts`, which you can test without the app:

```bash
swiftc -parse-as-library Sources/pika-tools/Common/Shortcuts.swift scripts/test-shortcuts.swift -o build/test-shortcuts && build/test-shortcuts
```

Quit on last window uses an `AXObserver` per regular app: it tracks standard windows and, half a second after one is destroyed, quits the app if it has no windows left, including minimized ones and ones on other desktops (checked with `CGWindowListCopyWindowInfo`). Finder, pika-tools and the apps in the exceptions list are skipped.

Hide with a Dock click is a `CGEventTap` on the left mouse button. On a plain click it asks the Dock for the element under the pointer with `AXUIElementCopyElementAtPosition`. If that is the icon of the frontmost app and the app has a visible window, the click is dropped and the app hides. Otherwise the click goes to the Dock as usual.

The language switch uses a listen-only `CGEventTap`, so it never changes or delays events. It watches `flagsChanged` for Option and Shift, and any `keyDown` or mouse click in between cancels the gesture, as does Cmd, Ctrl or Fn. When both keys are released, the order they were pressed in picks the next or previous input source, which is then selected with `TISSelectInputSource`. Only keyboard layouts and input methods take part, not the emoji or character palettes. The decision is made in `InputSwitchGesture`, which you can test without the app:

```bash
swiftc -parse-as-library Sources/pika-tools/Tools/InputSwitch/InputSwitchGesture.swift scripts/test-input-switch.swift -o build/test-input-switch && build/test-input-switch
```

Animations writes hidden macOS preferences with `CFPreferencesSetAppValue`: the Dock keys go to `com.apple.dock`, the Finder key to `com.apple.finder` and the rest to the global domain. pika-tools remembers which keys it wrote, so Restore Defaults and `--uninstall` delete exactly those; a value set in Terminal is shown as it is and stays until you move its slider. A change to a Dock key restarts the Dock once, 0.6 seconds after the last change, and Finder restarts only from its button. The slider math and what gets written live in `AnimationSetting`, which you can test without the app:

```bash
swiftc -parse-as-library Sources/pika-tools/Tools/Animations/AnimationSetting.swift scripts/test-animation-tweaks.swift -o build/test-animation-tweaks && build/test-animation-tweaks
```

Permissions left by deleted apps are read from the system TCC database (`/Library/Application Support/com.apple.TCC/TCC.db`), which needs Full Disk Access. A client counts as deleted when LaunchServices has no copy of it outside the Trash, no helper, launch agent or system extension with its id is left, and it is not on a disk that is unplugged; Apple apps and system paths are skipped. Remove calls `tccutil reset All <id>`. tccutil only accepts ids that LaunchServices knows, so pika-tools registers a tiny placeholder app with that id in its Caches folder for a moment and deletes it right after. Path clients can’t be reset this way, so their row opens the list in System Settings instead. The parsing and the deleted check live in `LeftoverPermissions`, which you can test without the app:

```bash
swiftc -parse-as-library Sources/pika-tools/Common/LeftoverPermissions.swift scripts/test-leftover-permissions.swift -o build/test-leftover-permissions && build/test-leftover-permissions
```

### Adding a tool

1. Create a file in `Sources/pika-tools/Tools/` with a class that conforms to `Tool`.
2. Add one line to `ToolRegistry.tools` in `Tools/Tool.swift`.

### Strings

English is the development language and the keys are the English text. Use `String(localized: "…")` when you need a `String`, and plain literals in SwiftUI (`Text("…")`, `Button("…")`). Every new key goes into all `Resources/*.lproj/Localizable.strings` files, and they all must have the same set of keys. Check with:

```bash
for f in Resources/*.lproj/Localizable.strings; do plutil -lint "$f"; done
```

## Private tools

`Private/` is a private submodule with drafts and tools that aren’t public yet. The public build doesn’t depend on it: a regular clone leaves the folder empty, and everything builds as usual.

## Releasing

```bash
./scripts/release.sh 1.3.0
```

The script bumps the version in `Info.plist`, commits, tags `v1.3.0` and pushes. GitHub Actions does the rest on a `macos-26` runner: builds the universal app, signs it, checks the signature, publishes the `.zip` and `.dmg` to Releases and updates `Casks/pika-tools.rb` on `main`. Installed copies pick up the new version on their own.

Before running the script, update `CHANGELOG.md` and add the version’s post to all 23 pages in `docs/whats-new/`: a short title, one sentence, a picture, a few short paragraphs and what to try. Pictures live in `docs/media/whats-new/<version>/`, and `scripts/render-media.sh <card>` draws them in light and dark. The script won’t start until every page has the post. The English post becomes the text of the GitHub release; `./scripts/release-notes.sh 1.3.0` shows it.

### Signing

Releases are signed with a permanent self-issued certificate, so macOS keeps the Accessibility and Input Monitoring permissions across updates. The certificate lives in two repository secrets:

- `SIGN_P12`: the certificate and private key exported as `.p12`, base64-encoded.
- `SIGN_P12_PASSWORD`: the password for that `.p12`.

The certificate's common name must be `pikapik`. Without these secrets the release job fails on purpose: an ad-hoc signed release would reset everyone's permissions.

## Icon

The icon is `Resources/AppIcon.icon` in Icon Composer format, with light and dark variants. CI compiles it with `actool` on macOS 26. macOS 14 and 15 use the fallback `Resources/AppIcon.icns`, which `build.sh` also uses when `actool` isn't available. The menu bar shows the same `pikapik.svg` as a template image. After changing the icon, regenerate the fallback and the README icon:

```bash
swift scripts/make-icns.swift
```
