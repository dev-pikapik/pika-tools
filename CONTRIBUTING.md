# Contributing

Bug reports and ideas are welcome in [Issues](https://github.com/dev-pikapik/pika-tools/issues). This page covers building, the code layout and how releases are made.

## Building from source

You need Xcode 26 or newer, the Command Line Tools alone are not enough. There is no Xcode project: `build.sh` calls `swiftc` directly. If `xcode-select -p` points to the Command Line Tools, run the scripts with `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`.

```bash
git clone https://github.com/dev-pikapik/pika-tools.git
cd pika-tools
./scripts/build.sh      # build/pikapik.app
./scripts/package.sh    # build/pikapik.dmg and build/pikapik.zip, plus build/pika-tools.zip for older versions
```

`install.sh` can also build from source: add `-- --source` after the install command from the README.

The direct build also bundles the official 7-Zip command line tool for archives. `build.sh` downloads it once into `Vendor/` (`scripts/fetch-7zip.sh` checks the download and the copy in `Vendor/` against pinned SHA-256 values and fetches it again when they differ), so the first build needs a network connection. The App Store build leaves it out.

Local builds are signed ad-hoc, which is fine for your own Mac. macOS treats every ad-hoc build as a new app, so after a rebuild you may need to remove pikapik from Accessibility and Input Monitoring with the − button and add it again.

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
  Tools/Pet/PetTool.swift, PetStage.swift, PetPhysics.swift, PetFigure.swift, PetPhrases.swift
  Common/                            shared UI, permissions, login item, updater
Resources/<lang>.lproj/              Localizable.strings
Resources/AppIcon.icon               app icon, AppIcon.icns is the fallback
scripts/                             build, package, release, icon, tests
```

Game Mode reads the complete symbolic shortcut catalogue on the current Mac, including Command combinations and user assignments. Automatic pauses actions that would interrupt the game. A short deliberate input-source shortcut selects the language directly without the system menu, while held game keys have priority. Per-action choices and previews are in More game settings. Keyboard events retain their keys and modifier flags. The separate Ctrl-click rule removes Control only from left mouse events so macOS does not turn them into context menu clicks. The catalogue, coverage limits and validation are described in [Game input and shortcut catalogue](docs/game-input-catalog.md).

The ⌘Q and ⌘W guard is a `CGEventTap` on `keyDown`/`keyUp`. A bare ⌘Q or ⌘W, with Cmd and without Ctrl, Option or Shift, is dropped. The quit and close shortcuts, ⇧⌘Q and ⇧⌘W unless you record your own, are swallowed and replaced with a fresh ⌘Q or ⌘W, so the app sees a normal quit or close. During Game Mode, shortcuts with Control or without Command pass through as game input, even if they were assigned to quitting or closing elsewhere.

Shortcuts in Settings are read live. macOS shortcuts come from `AppleSymbolicHotKeys` in `com.apple.symbolichotkeys`, and a missing entry means the macOS default, which SkyLight reports. Finder's Cut comes from `NSUserKeyEquivalents` for Finder and then for all apps, matched by the menu title in Finder's language. They are read again when pikapik becomes active or a window comes forward. The recorder catches keys with a session event tap and pauses the Mac's own shortcuts while you type, the same way Game Mode does, so it can tell you what already uses them. Parsing and the conflict check live in `Shortcuts`, which you can test without the app:

```bash
swiftc -parse-as-library Sources/pika-tools/Common/Shortcuts.swift scripts/test-shortcuts.swift -o build/test-shortcuts && build/test-shortcuts
```

The FPS counter over a game (Settings > Games > Show FPS) is `Games/FrameRate.swift`, which has no AppKit, and `Games/FrameRateMeter.swift`, the overlay and the two counters. The direct build on macOS 27 and later asks `/usr/bin/metalperftrace listen --json --pid` for the presented frames per second of the largest layer that presented anything. The tool buffers its output unless it is a terminal, so it gets a pty, and a small shell reading from a pipe that pikapik holds open stops it when pikapik quits or crashes. Games it can't see (OpenGL, older macOS, the App Store build) are counted from a small ScreenCaptureKit stream of the display, which needs Screen Recording: a frame counts only when the changed area covers at least 30% of the game window, so the number can't go above the screen's refresh rate. The stream starts only after three seconds without a number from `metalperftrace`, only if the permission is already granted, and never for a game it has already measured. On macOS 27 a game that needs the stream while the permission is missing makes pikapik remember it (`game-mode-fps-recording`, never reset or exported), and only then does Settings show the Screen Recording row; older macOS and the App Store build show it whenever Show FPS is on. The row belongs to the Permissions page like every other permission: Settings > Games shows only the usual line under the switch ("Needs a permission. Click to allow it." with Allow), which opens that page on the row, and the switch itself never asks. The pill has room for two digits and grows to three, anchored in its corner, once a value of 100 or more arrives in a game. You can test the logic without the app:

```bash
swiftc -parse-as-library Sources/pika-tools/Tools/Games/FrameRate.swift scripts/test-frame-rate.swift -o build/test-frame-rate && build/test-frame-rate
```

Quit on last window uses an `AXObserver` per regular app: it tracks standard windows and, half a second after one is destroyed, quits the app if it has no windows left, including minimized ones and ones on other desktops (checked with `CGWindowListCopyWindowInfo`). Finder, pikapik and the apps in the exceptions list are skipped.

Hide with a Dock click is a `CGEventTap` on the left mouse button. On a plain click it asks the Dock for the element under the pointer with `AXUIElementCopyElementAtPosition`. If that is the icon of the frontmost app and the app has a visible window, the click is dropped and the app hides. Otherwise the click goes to the Dock as usual.

The language switch uses a listen-only `CGEventTap`, so it never changes or delays events. It watches `flagsChanged` for Option and Shift, and any `keyDown` or mouse click in between cancels the gesture, as does Cmd, Ctrl or Fn. When both keys are released, the order they were pressed in picks the next or previous input source, which is then selected with `TISSelectInputSource`. Only keyboard layouts and input methods take part, not the emoji or character palettes. The decision is made in `InputSwitchGesture`, which you can test without the app:

```bash
swiftc -parse-as-library Sources/pika-tools/Tools/InputSwitch/InputSwitchGesture.swift scripts/test-input-switch.swift -o build/test-input-switch && build/test-input-switch
```

Animations writes hidden macOS preferences with `CFPreferencesSetAppValue`: the Dock keys go to `com.apple.dock`, the Finder key to `com.apple.finder` and the rest to the global domain. pikapik remembers which keys it wrote, so Restore Defaults and `--uninstall` delete exactly those; a value set in Terminal is shown as it is and stays until you move its slider. A change to a Dock key restarts the Dock once, 0.6 seconds after the last change, and Finder restarts only from its button. The slider math and what gets written live in `AnimationSetting`, which you can test without the app:

```bash
swiftc -parse-as-library Sources/pika-tools/Tools/Animations/AnimationSetting.swift scripts/test-animation-tweaks.swift -o build/test-animation-tweaks && build/test-animation-tweaks
```

Permissions left by deleted apps are read from the system TCC database (`/Library/Application Support/com.apple.TCC/TCC.db`), which needs Full Disk Access. A client counts as deleted when LaunchServices has no copy of it outside the Trash, no helper, launch agent or system extension with its id is left, and it is not on a disk that is unplugged; Apple apps and system paths are skipped. Remove calls `tccutil reset All <id>`. tccutil only accepts ids that LaunchServices knows, so pikapik registers a tiny placeholder app with that id in its Caches folder for a moment and deletes it right after. Path clients can’t be reset this way, so their row opens the list in System Settings instead. The parsing and the deleted check live in `LeftoverPermissions`, which you can test without the app:

```bash
swiftc -parse-as-library Sources/pika-tools/Common/LeftoverPermissions.swift scripts/test-leftover-permissions.swift -o build/test-leftover-permissions && build/test-leftover-permissions
```

The app used to be called pika-tools. A copy named `pika-tools.app` that wasn't installed with Homebrew renames itself to `pikapik.app` on launch and opens again; the updater does the same when it installs a new version. Homebrew copies stay where they are until `brew upgrade` moves them. If a `pikapik.app` that isn't this app already sits next to it (the App Store version, whose bundle id is `com.pikapik.tools`, or anything without a readable `Info.plist`), the copy keeps its old name and updates in place. Every release also carries `pika-tools.zip` with the app under its old name, because older versions download that file. The path logic lives in `Updater`:

```bash
swiftc -parse-as-library $(find Sources -name '*.swift' ! -name main.swift ! -name App.swift) Extensions/Shared/*.swift Extensions/Convert/ConvertFormats.swift Extensions/Preview/ZipNames.swift scripts/test-rename.swift -o build/test-rename && build/test-rename
```

The pet lives in a borderless window one level above the desktop icons, so every normal window and the Dock cover it. The window lets clicks through everywhere except the pet itself: on each frame it checks whether the pointer is over the pet’s hitbox, swept over the last frame so a fast pet can still be caught. While you hold or throw the pet, the window grows to the whole screen and rises above the Dock, and it drops back behind everything once the pet lands. It joins all Spaces, stays out of Mission Control and the app switcher, and hides during full-screen apps, Game Mode, screen sleep and the lock screen. It ticks at 30 frames per second only while it is on screen. Space comes from a listen-only `CGEventTap`, so the key is never changed or delayed. Walking, jumps, bumps, holding and throwing live in `PetPhysics`, which has no AppKit and steps in fixed slices of 1/120 s: the pet and the pointer are rectangles, their relative motion is swept every slice so nothing tunnels through, and the pet always stays inside the screen and on the ground. A throw takes the pointer speed over the last 80 ms, capped, bounces off the sides and never goes above the menu bar, and the pointer can’t knock the pet over for a second after it is let go. The phrases are one list in `PetPhrases`, each with an id, ready for partner lines. You can test the physics without the app:

```bash
swiftc -parse-as-library Sources/pika-tools/Tools/Pet/PetPhysics.swift Sources/pika-tools/Tools/Pet/BallPhysics.swift scripts/test-pet.swift -o build/test-pet && build/test-pet
```

Awards and wardrobe unlocks live in `PetProgress`. `PetPhysics` reports what the pet does (jumps, leaps over the pointer, climbs, tumbles, hard throws) and `PetStage` adds it up while no demo runs, together with steps, kicks, phrases and the days, nights and weekends you spend together. Everything stays on the Mac in five keys, `pet-counts`, `pet-awards`, `pet-seen`, `pet-fresh` and `pet-outfit`; they are not part of the settings file, so Restore Defaults leaves them alone. The rules run without the app too:

```bash
swiftc -parse-as-library Sources/pika-tools/Tools/Pet/PetWardrobe.swift Sources/pika-tools/Tools/Pet/PetAwards.swift scripts/test-awards.swift -o build/test-awards && build/test-awards
```

The app and the pet tell you about an update only when the latest release is newer than the running version, compared number by number, so `1.26.10` is newer than `1.26.9` and `v1.27.0` equals `1.27.0`. The comparison lives in `Version`:

```bash
swiftc -parse-as-library Sources/pika-tools/Common/Version.swift scripts/test-updater.swift -o build/test-updater && build/test-updater
```

Before Homebrew removes the app, it runs `pika-tools --uninstall`, which turns off launch at login and puts back the system settings the app changed, such as the Dock and key repeat. Homebrew runs the same step when it upgrades or reinstalls the app, so the app first looks for the `brew` command that started it and does nothing for `upgrade`, `reinstall` and `install`. The check lives in `Brew`:

```bash
swiftc -parse-as-library Sources/pika-tools/Common/Brew.swift scripts/test-brew.swift -o build/test-brew && build/test-brew
```

Fan control talks to a small helper that runs as root. You install it once, with the administrator password, from Settings › Permissions. On every connection the app and the helper check each other’s signature: the same developer, and the helper’s name is the app’s name plus `.fans`. The helper carries the app’s build number inside its signature. When pikapik updates, it hands the new helper from its own bundle to the one already installed, and the helper updates itself without a password: it copies the file into its own folder, which only root can write to, and checks that copy’s signature and that its build number isn’t lower than its own. It swaps the files in one step only when it quits, after the last app disconnects, and checks the copy once more first: macOS compares a running program with its file on disk, so a helper swapped while running would fail every signature check until it restarts. If anything fails, the copy is deleted, the old helper stays and the fans keep working. The new code starts the next time the helper is launched. The test signs tiny programs with the local `pikapik Dev` certificate, or the one named in `SIGN_IDENTITY`, and stages and swaps them in a temporary folder:

```bash
swiftc -parse-as-library Sources/pika-tools/Common/FanHelperProtocol.swift scripts/test-fan-helper.swift -o build/test-fan-helper && codesign -f -s "${SIGN_IDENTITY:-pikapik Dev}" build/test-fan-helper && build/test-fan-helper
```

iCloud sync keeps `settings.json` in the pikapik folder in iCloud Drive, or pikapik-dev for local builds. Earlier versions used a pika-tools folder. When sync starts, that folder is renamed. If both folders exist, the file with the later time saved inside it ends up in pikapik, and the old folder is deleted once nothing else is left in it. The move lives in `SettingsFile.moveFolder`, and the test works on temporary folders:

```bash
swiftc -parse-as-library Sources/pika-tools/Common/SettingsFile.swift Sources/pika-tools/Tools/Games/GameRules.swift scripts/test-settings-folder.swift -o build/test-settings-folder && build/test-settings-folder
```

Removing an app completely starts with `AppFootprint`, which finds everything an app keeps on the Mac and decides which app each file belongs to, without changing anything. The App Store build uses it only to list background tasks. The test builds a made-up home folder in a temporary directory, so nothing real is read or touched:

```bash
swiftc -parse-as-library Sources/pika-tools/Common/SettingsSearch.swift Sources/pika-tools/Tools/Uninstaller/AppFootprint.swift scripts/test-uninstaller.swift -o build/test-uninstaller && build/test-uninstaller
```

`AppRemover` moves what `AppFootprint` found to the Trash, asks for the administrator password once for the files only an administrator can move, and keeps a record so everything can be put back. Quitting apps, `launchctl`, the password prompt and Finder are all passed in as closures, so the test runs the real logic against a made-up home folder with fakes. Only a few tiny `pika-uninstall-test-*` files go through your real Trash, and the test puts them back. The Finder fallback needs the Automation permission, which the direct build declares in `Resources/Direct.entitlements`:

```bash
swiftc -parse-as-library Sources/pika-tools/Common/SettingsSearch.swift Sources/pika-tools/Tools/Uninstaller/AppFootprint.swift Sources/pika-tools/Tools/Uninstaller/AppRemover.swift scripts/test-app-remover.swift -o build/test-app-remover && build/test-app-remover
```

The Uninstaller page keeps its choices in `UninstallerLogic`: how the app list is sorted, what is ticked and what is not, the total on the **Move to Trash** button, how apps in the Trash and leftovers of removed apps are shown, and the wording of sizes and dates. The test gives it made-up apps and files, so nothing real is read or touched:

```bash
swiftc -parse-as-library Sources/pika-tools/Common/SettingsSearch.swift Sources/pika-tools/Tools/Uninstaller/AppFootprint.swift Sources/pika-tools/Tools/Uninstaller/UninstallerLogic.swift scripts/test-uninstaller-ui.swift -o build/test-uninstaller-ui && build/test-uninstaller-ui
```

The **Background Tasks** page shows everything that starts by itself: apps that open at login, launch agents and daemons, helpers inside apps, and tasks left behind by deleted apps. `BackgroundTasks` reads what `launchctl print` reports and uses `AppFootprint` to find the app that added each task, whether it runs now, how it starts and whether its program is gone. The test gives it made-up `launchctl` output and a made-up Mac in a temporary directory, so nothing real is read, turned off or touched:

```bash
swiftc -parse-as-library Sources/pika-tools/Common/SettingsSearch.swift Sources/pika-tools/Tools/Uninstaller/AppFootprint.swift Sources/pika-tools/Tools/Background/BackgroundTasks.swift scripts/test-background.swift -o build/test-background && build/test-background
```

`TrashWatcher` is what makes **Offer to clean up when an app goes to the Trash** work: it watches the Trash, ignores the apps that are already there when it starts, reports only the ones that arrive later, and stays quiet once stopped or when the folder cannot be read. The test watches a folder of its own in the temporary directory, never your real Trash, and takes about eight seconds. The folder stays in the temporary directory, which macOS clears itself:

```bash
swiftc -parse-as-library Sources/pika-tools/Tools/Uninstaller/TrashWatcher.swift scripts/test-trash-watcher.swift -o build/test-trash-watcher && build/test-trash-watcher
```

The archive engine in `Tools/Archive/` opens and creates ZIP, 7Z, TAR.GZ and TAR.XZ files and opens RAR and many more. It runs the bundled `7zz`, plus `ditto` and `bsdtar` for ZIP names in older encodings, as separate programs, and checks every result before it is shown: nothing lands outside the output folder, links that point out are removed, setuid bits are stripped, the archive's quarantine flag is copied onto everything extracted, and an unpacking that writes far more than the archive announced is stopped. The test makes its own archives, including broken and hostile ones, in a temporary folder, mounts a 16 MB scratch disk image to run out of space on purpose, and takes about ten seconds. Run it from the repository root: it uses `Vendor/7zip/7zz` (`scripts/fetch-7zip.sh` puts it there) or the tool named in `PIKA_7ZZ`. For RAR, set `PIKA_RAR_SAMPLES` to a folder of your own `.rar` files, otherwise that part is skipped:

```bash
swiftc -parse-as-library scripts/test-archive.swift Sources/pika-tools/Tools/Archive/Archive{,Create,Extract,Probe,Run,Sanitize}.swift Extensions/Preview/ZipNames.swift Sources/pika-tools/Common/UniqueURL.swift -o build/test-archive && build/test-archive
```

`Battery.swift` turns the readings from IOKit and `system_profiler` into a `BatteryState` and a `BatteryHealth`, and `BatterySettings.swift` shows them on the read-only Battery page. The test feeds them made-up readings, so it runs on a Mac without a battery:

```bash
swiftc -parse-as-library Sources/pika-tools/Common/Battery.swift scripts/test-battery.swift -o build/test-battery && build/test-battery
```

The **Ports** page learns which programs listen on which ports from the same kernel list `netstat` reads (`net.inet.tcp.pcblist_n` and `net.inet.udp.pcblist_n`), so it needs no extra tools and works in the App Store version too. macOS 27 shares that list only with programs signed with an identifier, so the command signs the test before running it. The test opens a few sockets of its own on ports the system picks, checks that the list finds each one with the right program, address and protocol and that a plain connection is not counted as listening, then groups made-up processes the way the page does. It only reads the list and never touches other programs:

```bash
swiftc -parse-as-library Sources/pika-tools/Tools/Ports/PortScanner.swift scripts/test-ports.swift -o build/test-ports && codesign -s - -f -i com.pesotchi.pika-tools.test-ports build/test-ports && build/test-ports
```

`KeyboardLayouts` is the engine behind **Fix words typed in the wrong layout**. It turns the keys that were pressed into text for every keyboard layout you have, and fixes a word only when what came out is not a word in any of your languages while another layout gives a common one, so names, slang and typos stay as typed. The test uses Apple's own layouts and the system spelling dictionaries: it checks pairs such as ghbdtn → привет, then runs every word of the app's texts in 18 languages and about 25,000 English dictionary words and names through the engine and fails on a single wrong fix.

```bash
swiftc -parse-as-library Sources/pika-tools/Tools/LayoutFix/KeyboardLayouts.swift scripts/test-layout.swift -o build/test-layout && build/test-layout
```

### Adding a tool

1. Create a file in `Sources/pika-tools/Tools/` with a class that conforms to `Tool`.
2. Add one line to `ToolRegistry.tools` in `Tools/Tool.swift`.

### Strings

English is the development language and the keys are the English text. Use `String(localized: "…")` when you need a `String`, and plain literals in SwiftUI (`Text("…")`, `Button("…")`). Every new key goes into all `Resources/*.lproj/Localizable.strings` files, and they all must have the same set of keys. Check with:

```bash
for f in Resources/*.lproj/Localizable.strings; do plutil -lint "$f"; done
```

## Releasing

```bash
./scripts/release.sh 1.3.0
```

The script bumps the version in `Info.plist`, commits, tags `v1.3.0` and pushes. GitHub Actions does the rest on a `macos-26` runner: builds the universal app, signs it, checks the signature, publishes the `.zip` and `.dmg` to Releases and updates the cask in the [Homebrew tap](https://github.com/dev-pikapik/homebrew-pika-tools). Installed copies pick up the new version on their own.

Before running the script, add the version to `CHANGELOG.md` under `## [1.3.0] - Unreleased` (the script fills in the date and the link) and add the version’s post to all 23 pages in `docs/whats-new/`: a short title, one sentence, a picture, a few short paragraphs and what to try. Pictures live in `docs/media/whats-new/<version>/`, and `scripts/render-media.sh <card>` draws them in light and dark. The script won’t start until every page has the post. The English post becomes the text of the GitHub release; `./scripts/release-notes.sh 1.3.0` shows it.

### Signing

Every release is signed with the same certificate, so macOS keeps the Accessibility and Input Monitoring permissions across updates and the fan helper accepts the next version without a password. The certificate lives in repository secrets:

- `DEVID_P12` and `DEVID_P12_PASSWORD`: the Developer ID Application certificate and private key exported as `.p12`, base64-encoded, and its password. When they are set, the release is signed with Developer ID and sent to Apple for notarization.
- `SIGN_P12` and `SIGN_P12_PASSWORD`: a permanent self-issued certificate, used only when there is no Developer ID. Its common name must be `pikapik`.

Without any of these secrets the release job fails on purpose: an ad-hoc signed release would reset everyone's permissions.

## Icon

The icon is `Resources/AppIcon.icon` in Icon Composer format, with light and dark variants. CI compiles it with `actool` on macOS 26. macOS 14 and 15 use the fallback `Resources/AppIcon.icns`, which `build.sh` also uses when `actool` isn't available. The menu bar shows the same `pikapik.svg` as a template image. After changing the icon, regenerate the fallback and the README icon:

```bash
swift scripts/make-icns.swift
```

## Third-party software

The direct build includes the 7-Zip command line tool (`7zz`) from [www.7-zip.org](https://www.7-zip.org), licensed under the GNU LGPL 2.1 with the unRAR restriction. It runs as a separate program, its license is in the app as `Contents/Resources/7-Zip License.txt`, and its source code is attached to every release as `7-Zip-26.04-source.tar.xz`.
