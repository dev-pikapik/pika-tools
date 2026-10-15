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

The direct build also bundles the official 7-Zip command line tool for archives. `build.sh` downloads it once into `Vendor/` (`scripts/fetch-7zip.sh` checks the download and the copy in `Vendor/` against pinned SHA-256 values and fetches it again when they differ), so the first build needs a network connection. The App Store build leaves it out. In the same way it builds LGPL FFmpeg and dav1d from source for the video player (`scripts/fetch-ffmpeg.sh`, needs `brew install meson ninja nasm pkg-config`).

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

Which apps count as games, which keys and clicks reach the game, and how the pointer is kept on the game's screen live in `GameRules`, which you can test without the app:

```bash
swiftc -parse-as-library $(find Sources -name '*.swift' ! -name main.swift ! -name App.swift) Extensions/Shared/*.swift Extensions/Convert/ConvertFormats.swift Extensions/Preview/ZipNames.swift scripts/test-game-mode.swift -o build/test-game-mode && build/test-game-mode
```

Which macOS shortcuts, gestures and hot corners Game Mode pauses for each rule is decided in `SystemShortcutCatalog` and `PointerShortcuts`:

```bash
swiftc -parse-as-library $(find Sources -name '*.swift' ! -name main.swift ! -name App.swift) Extensions/Shared/*.swift Extensions/Convert/ConvertFormats.swift Extensions/Preview/ZipNames.swift scripts/test-system-shortcuts.swift -o build/test-system-shortcuts && build/test-system-shortcuts
```

The ⌘Q and ⌘W guard is a `CGEventTap` on `keyDown`/`keyUp`. A bare ⌘Q or ⌘W, with Cmd and without Ctrl, Option or Shift, is dropped. The quit and close shortcuts, ⇧⌘Q and ⇧⌘W unless you record your own, are swallowed and replaced with a fresh ⌘Q or ⌘W, so the app sees a normal quit or close. During Game Mode, shortcuts with Control or without Command pass through as game input, even if they were assigned to quitting or closing elsewhere.

Shortcuts in Settings are read live. macOS shortcuts come from `AppleSymbolicHotKeys` in `com.apple.symbolichotkeys`, and a missing entry means the macOS default, which SkyLight reports. Finder's Cut comes from `NSUserKeyEquivalents` for Finder and then for all apps, matched by the menu title in Finder's language. They are read again when pikapik becomes active or a window comes forward. The recorder catches keys with a session event tap and pauses the Mac's own shortcuts while you type, the same way Game Mode does, so it can tell you what already uses them. Parsing and the conflict check live in `Shortcuts`, which you can test without the app:

```bash
swiftc -parse-as-library Sources/pika-tools/Common/Shortcuts.swift scripts/test-shortcuts.swift -o build/test-shortcuts && build/test-shortcuts
```

The FPS counter over a game (Settings > Games > Show FPS) is `Games/FrameRate.swift`, which has no AppKit, and `Games/FrameRateMeter.swift`, the overlay and the two counters. The direct build on macOS 27 and later asks `/usr/bin/metalperftrace listen --json --pid` for the presented frames per second of the largest layer that presented anything. The tool buffers its output unless it is a terminal, so it gets a pty, and a small shell reading from a pipe that pikapik holds open stops it when pikapik quits or crashes. Games it can't see (OpenGL, older macOS, the App Store build) are counted from a small ScreenCaptureKit stream of the display, which needs Screen Recording: a frame counts only when the changed area covers at least 30% of the game window, so the number can't go above the screen's refresh rate. The stream starts only after three seconds without a number from `metalperftrace`, only if the permission is already granted, and never for a game it has already measured. On macOS 27 a game that needs the stream while the permission is missing makes pikapik remember it (`game-mode-fps-recording`, never reset or exported), and only then does Settings show the Screen Recording row; older macOS and the App Store build show it whenever Show FPS is on. The row belongs to the Permissions page like every other permission: Settings > Games shows only the usual line under the switch ("Needs a permission. Click to allow it." with Allow), which opens that page on the row, and the switch itself never asks. The pill has room for two digits and grows to three, anchored in its corner, once a value of 100 or more arrives in a game. You can test the logic without the app:

```bash
swiftc -parse-as-library Sources/pika-tools/Tools/Games/FrameRate.swift scripts/test-frame-rate.swift -o build/test-frame-rate && build/test-frame-rate
```

The Mac App Store copy can't switch hot corners off, so the cursor fence of Game Mode (`GameRules.fenceCorners`) keeps the pointer 16 points from every corner instead, except corners you allow. There the screen lock is also tracked from the `com.apple.screenIsLocked` and `screenIsUnlocked` notifications (`GameModeTool.received`), and the game is left at once. The test compiles the App Store source set, so its exclusions repeat the list in `scripts/build.sh`.

```bash
swiftc -parse-as-library -D APPSTORE $(find Sources -name '*.swift' ! -name main.swift ! -name App.swift ! -name Updater.swift ! -name 'LeftoverPermissions*.swift' ! -name SMC.swift ! -name FanHelperProtocol.swift ! -name FanControl.swift ! -name FanSettings.swift ! -name PointerTool.swift ! -name 'DockDisplay*' ! -path '*/Tools/Animations/*' ! -path '*/Tools/KeyRepeat/*' ! -path '*/Tools/Uninstaller/*') Sources/pika-tools/Tools/Uninstaller/AppFootprint.swift Extensions/Convert/ConvertFormats.swift Extensions/Preview/ZipNames.swift scripts/test-game-appstore.swift -o build/test-game-appstore && build/test-game-appstore
```

Quit on last window uses an `AXObserver` per regular app: it tracks standard windows and, half a second after one is destroyed, quits the app if it has no windows left, including minimized ones and ones on other desktops (checked with `CGWindowListCopyWindowInfo`). Finder, pikapik and the apps in the exceptions list are skipped.

Hide with a Dock click is a `CGEventTap` on the left mouse button. On a plain click it asks the Dock for the element under the pointer with `AXUIElementCopyElementAtPosition`. If that is the icon of the frontmost app and the app has a visible window, the click is dropped and the app hides. Otherwise the click goes to the Dock as usual.

Keep the Dock on one display sets the Dock’s own `allow-display-switching` key in `com.apple.dock` to false, so the Dock stops following the pointer to another display. A missing key counts as true. The Dock reads the key only when it starts, so pikapik restarts the Dock, and only when the value really changes. pikapik remembers what the key was, so turning the switch off and `--uninstall` put back exactly that, or delete the key if there was none, and at launch the key is brought in line with the switch. The Mac App Store version can’t change the Dock’s settings and doesn’t have this switch. What to write and whether to restart is decided in `DockDisplaySwitch`, which you can test without the app:

```bash
swiftc -parse-as-library Sources/pika-tools/Tools/Windows/DockDisplaySwitch.swift scripts/test-dock-display.swift -o build/test-dock-display && build/test-dock-display
swiftc -parse-as-library Sources/pika-tools/Tools/Windows/DockHideMigration.swift scripts/test-dock-hide-migration.swift -o build/test-dock-hide-migration && build/test-dock-hide-migration
```

Only one copy of pikapik acts on the Mac. Copies of the same family (the website and App Store builds) pick the one that started last as the main copy: it is the only one that runs event taps and writes settings, and any other copy stays passive and shows a single screen with a button to take over. When the main copy quits or loses the lead, it puts back what it changed, and the previous copy takes over. Features that change a system switch keep the original in an `OriginalValue` entry that is written once and is put back only while the switch still holds our value.

```bash
swiftc -parse-as-library Sources/pika-tools/Common/MainCopyChoice.swift scripts/test-main-copy.swift -o build/test-main-copy && build/test-main-copy
```

Changing a hot corner from the Games page remembers the first action and puts it back on request, and a change to the same action writes nothing, so the Dock restarts only on a real change.

```bash
swiftc -parse-as-library Sources/pika-tools/Tools/Games/HotCorners.swift scripts/test-hot-corners.swift -o build/test-hot-corners && build/test-hot-corners
```

A `Toggle` inside a `Menu` needs `.toggleStyle(.automatic)`: the switch style that Settings pages apply makes each item draw three rows that do nothing when chosen. The test reads every Swift file in `Sources` and fails on a `Toggle` in a `Menu` without it.

```bash
swiftc -parse-as-library scripts/test-menu-items.swift -o build/test-menu-items && build/test-menu-items
```

The language switch uses a listen-only `CGEventTap`, so it never changes or delays events. It watches `flagsChanged` for Option and Shift, and any `keyDown` or mouse click in between cancels the gesture, as does Cmd, Ctrl or Fn. When both keys are released, the order they were pressed in picks the next or previous input source, which is then selected with `TISSelectInputSource`. Only keyboard layouts and input methods take part, not the emoji or character palettes. The decision is made in `InputSwitchGesture`, which you can test without the app:

```bash
swiftc -parse-as-library Sources/pika-tools/Tools/InputSwitch/InputSwitchGesture.swift scripts/test-input-switch.swift -o build/test-input-switch && build/test-input-switch
```

Middle click on the trackpad uses two `CGEventTap`s. A listen-only one reads the fingers from gesture events with `NSEvent.allTouches()`, leaving out resting thumbs, and `MiddleClickGesture` decides when a quick tap with the chosen number of fingers ends; pikapik then posts a middle button click at the pointer. The other one turns a left or right press made while that many fingers are down into the middle button: down, drag and up. Both read the trackpad settings each time, so a three-finger tap stays with Look up and a three-finger press with three-finger drag. The tap decision can be tested without the app:

```bash
swiftc -parse-as-library Sources/pika-tools/Tools/Mouse/MiddleClickGesture.swift scripts/test-middle-click.swift -o build/test-middle-click && build/test-middle-click
```

Animations writes hidden macOS preferences with `CFPreferencesSetAppValue`: the Dock keys go to `com.apple.dock`, the Finder key to `com.apple.finder` and the rest to the global domain. pikapik remembers which keys it wrote, so Restore Defaults and `--uninstall` delete exactly those; a value set in Terminal is shown as it is and stays until you move its slider. A change to a Dock key restarts the Dock once, 0.6 seconds after the last change, and Finder restarts only from its button. The slider math and what gets written live in `AnimationSetting`, which you can test without the app:

```bash
swiftc -parse-as-library Sources/pika-tools/Tools/Animations/AnimationSetting.swift scripts/test-animation-tweaks.swift -o build/test-animation-tweaks && build/test-animation-tweaks
```

Permissions left by deleted apps are read from the system TCC database (`/Library/Application Support/com.apple.TCC/TCC.db`), which needs Full Disk Access. A client counts as deleted when LaunchServices has no copy of it outside the Trash, no helper, launch agent or system extension with its id is left, and it is not on a disk that is unplugged; Apple apps and system paths are skipped. Remove calls `tccutil reset All <id>`. tccutil only accepts ids that LaunchServices knows, so pikapik registers a tiny placeholder app with that id in its Caches folder for a moment and deletes it right after. Path clients can’t be reset this way, so their row opens the list in System Settings instead. The parsing and the deleted check live in `LeftoverPermissions`, which you can test without the app:

```bash
swiftc -parse-as-library Sources/pika-tools/Common/LeftoverPermissions.swift scripts/test-leftover-permissions.swift -o build/test-leftover-permissions && build/test-leftover-permissions
```

In the App Store version the sandbox and macOS hide who was allowed, so Settings › Permissions reads the usage keys in the `Info.plist` of the apps in `/Applications` (and one folder level below it) and says “can ask”, never “has”: Camera (`NSCameraUsageDescription`), Microphone, Automation (`NSAppleEventsUsageDescription`), Files and Folders (the folder and volume keys) and Bluetooth. Accessibility, Screen Recording, Input Monitoring, Full Disk Access, App Management and Developer Tools have no such key, so those rows only open System Settings. The scan lives in `PrivacyAsks`, which you can test without the app:

```bash
swiftc -parse-as-library Sources/pika-tools/Common/PrivacyAsks.swift scripts/test-privacy-asks.swift -o build/test-privacy-asks && build/test-privacy-asks
```

App Volume (macOS 14.2 and later) changes one app’s volume without a driver. For every app whose slider is below 100% or that is muted, pikapik creates a Core Audio process tap (`CATapDescription`) that mutes the app’s own output, read through a private aggregate device that holds only the tap. A HAL output unit with its input off, set to the output the app plays to (the current output if it uses several), takes the sound from a ring buffer, multiplies it by the app’s gain and plays it there, so the microphone is never opened; an app at 100% gets no tap and is never touched. Helper processes, such as a browser’s audio service, are listed under the app that contains or started them; system daemons are left out. The gain follows the slider squared and moves through a 30 ms ramp so nothing clicks. macOS has no call that says whether System Audio Recording is allowed, so pikapik plays a tone too quiet to hear through a tap on itself and takes any sound that comes back as “allowed”; it asks again when a running tap delivers only silence. The gain, the ramp, the mixing, the ring buffer, the grouping, the saved levels (`AppVolumeMemory`, kept under the app’s bundle ID) and the merge of running and remembered apps into the list live in `AppVolumeMath`, which you can test without the app:

```bash
swiftc -parse-as-library Sources/pika-tools/Tools/AppVolume/AppVolumeMath.swift scripts/test-app-volume.swift -o build/test-app-volume && build/test-app-volume
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

After an update the app points at what is new: a dot after the tab’s name until the tab is opened, a New tag beside the row until the tab is left, nothing on a fresh install and nothing 21 days after the update. `NewMarks` holds the table of what is new and the version logic, and the test checks fresh installs, upgrades from 1.49.x, seen items that stay seen after a relaunch, a downgrade or a second running copy, expiry and that every tab in the table exists:

```bash
swiftc -parse-as-library Sources/pika-tools/Common/Version.swift Sources/pika-tools/Common/NewMarks.swift scripts/test-new-marks.swift -o build/test-new-marks && build/test-new-marks
```

Before Homebrew removes the app, it runs `pika-tools --uninstall`, which turns off launch at login and puts back the system settings the app changed, such as the Dock and key repeat. Homebrew runs the same step when it upgrades or reinstalls the app, so the app first looks for the `brew` command that started it and does nothing for `upgrade`, `reinstall` and `install`. The check lives in `Brew`:

```bash
swiftc -parse-as-library Sources/pika-tools/Common/Brew.swift scripts/test-brew.swift -o build/test-brew && build/test-brew
```

The helper that runs as root sets the fan speed and, in the website version, turns background services off and on. You install it once, with the administrator password, from Settings › Permissions (Administrator access). On every connection the app and the helper check each other’s signature: the same developer, and the helper’s name is the app’s name plus `.fans`. The helper carries the app’s build number inside its signature. When pikapik updates, it hands the new helper from its own bundle to the one already installed, and the helper updates itself without a password: it copies the file into its own folder, which only root can write to, and checks that copy’s signature and that its build number isn’t lower than its own. It swaps the files in one step only when it quits, after the last app disconnects, and checks the copy once more first: macOS compares a running program with its file on disk, so a helper swapped while running would fail every signature check until it restarts. If anything fails, the copy is deleted, the old helper stays and the fans keep working. The new code starts the next time the helper is launched. The test signs tiny programs with the local `pikapik Dev` certificate, or the one named in `SIGN_IDENTITY`, and stages and swaps them in a temporary folder:

```bash
swiftc -parse-as-library Sources/pika-tools/Common/FanHelperProtocol.swift scripts/test-fan-helper.swift -o build/test-fan-helper && codesign -f -s "${SIGN_IDENTITY:-pikapik Dev}" build/test-fan-helper && build/test-fan-helper
```

The same helper switches launch daemons off and on with `launchctl disable` and `bootout`, or `enable` and `bootstrap`, for `system/<label>`. It takes only a label and finds the file itself, so the app never hands it a path. A label must use letters, digits, dots, hyphens and underscores, must not start with `com.apple.` or be pikapik’s own, and must be the `Label` of a regular file (not a link) directly inside `/Library/LaunchDaemons`. The only exceptions are Remote Login (`com.openssh.sshd`) and Screen Sharing (`com.apple.screensharing`), which have fixed files in `/System/Library/LaunchDaemons`. File Sharing (`com.apple.smbd`) is left out: macOS 27 has no launchd on/off entry for it (the other two have one), so System Settings stays the way to change it. Change the allow-list only together with this test:

```bash
swiftc -parse-as-library Sources/pika-tools/Common/FanHelperProtocol.swift scripts/test-service-guard.swift -o build/test-service-guard && build/test-service-guard
```

iCloud sync keeps `settings.json` in the pikapik folder in iCloud Drive, or pikapik-dev for local builds. Earlier versions used a pika-tools folder. When sync starts, that folder is renamed. If both folders exist, the file with the later time saved inside it ends up in pikapik, and the old folder is deleted once nothing else is left in it. The move lives in `SettingsFile.moveFolder`, and the test works on temporary folders:

```bash
swiftc -parse-as-library Sources/pika-tools/Common/SettingsFile.swift Sources/pika-tools/Tools/Games/GameRules.swift scripts/test-settings-folder.swift -o build/test-settings-folder && build/test-settings-folder
```

The app also reads the file whenever it comes to the front, so a change that arrived while it sat in the background is picked up. This check writes newer settings from "another Mac" into the local build's folder and waits for them to be applied. It needs `./scripts/build.sh` first and switches between apps, so it refuses to run unless the keyboard and mouse have been idle for two minutes:

```bash
./scripts/check-settings-sync.sh
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
swiftc -parse-as-library Sources/pika-tools/Common/SettingsSearch.swift Sources/pika-tools/Common/FanHelperProtocol.swift Sources/pika-tools/Tools/Uninstaller/AppFootprint.swift Sources/pika-tools/Tools/Background/BackgroundTasks.swift scripts/test-background.swift -o build/test-background && build/test-background
```

`TrashWatcher` is what makes **Offer to clean up when an app goes to the Trash** work: it watches the Trash, ignores the apps that are already there when it starts, reports only the ones that arrive later, and stays quiet once stopped or when the folder cannot be read. The test watches a folder of its own in the temporary directory, never your real Trash, and takes about eight seconds. The folder stays in the temporary directory, which macOS clears itself:

```bash
swiftc -parse-as-library Sources/pika-tools/Tools/Uninstaller/TrashWatcher.swift scripts/test-trash-watcher.swift -o build/test-trash-watcher && build/test-trash-watcher
```

The archive engine in `Tools/Archive/` opens and creates ZIP, 7Z, TAR.GZ and TAR.XZ files and opens RAR and many more. It runs the bundled `7zz`, plus `ditto` and `bsdtar` for ZIP names in older encodings, as separate programs, and checks every result before it is shown: nothing lands outside the output folder, links that point out are removed, setuid bits are stripped, the archive's quarantine flag is copied onto everything extracted, and an unpacking that writes far more than the archive announced is stopped. The test makes its own archives, including broken and hostile ones, in a temporary folder, mounts a 16 MB scratch disk image to run out of space on purpose, and takes about ten seconds. Run it from the repository root: it uses `Vendor/7zip/7zz` (`scripts/fetch-7zip.sh` puts it there) or the tool named in `PIKA_7ZZ`. For RAR, set `PIKA_RAR_SAMPLES` to a folder of your own `.rar` files, otherwise that part is skipped:

```bash
swiftc -parse-as-library scripts/test-archive.swift Sources/pika-tools/Tools/Archive/Archive{,Create,Extract,Probe,Run,Sanitize}.swift Extensions/Preview/ZipNames.swift Sources/pika-tools/Common/UniqueURL.swift -o build/test-archive && build/test-archive
```

`Battery.swift` turns the readings from IOKit into a `BatteryState` and a `BatteryHealth`, and `BatterySettings.swift` shows them on the read-only Battery page. The battery condition comes from `system_profiler` in the direct version and straight from IOKit in the App Store version, which starts no other program. The test feeds them made-up readings, so it runs on a Mac without a battery; the second line checks the App Store version:

```bash
swiftc -parse-as-library Sources/pika-tools/Common/Battery.swift scripts/test-battery.swift -o build/test-battery && build/test-battery
swiftc -parse-as-library -D APPSTORE Sources/pika-tools/Common/Battery.swift scripts/test-battery.swift -o build/test-battery-appstore && build/test-battery-appstore
```

The **Ports** page learns which programs listen on which ports from the same kernel list `netstat` reads (`net.inet.tcp.pcblist_n` and `net.inet.udp.pcblist_n`), so it needs no extra tools. macOS 27 gives the whole list only to programs signed without a team, like local builds and this test, so the command signs the test before running it. A signed release sees only its own sockets: it finds the user's programs through libproc, and a port it can't see is checked with a test bind, so the page never calls a taken port free. In the App Store version the sandbox blocks libproc too, so the page is hidden there. The test opens a few sockets of its own on ports the system picks, checks that the list finds each one with the right program, address and protocol and that a plain connection is not counted as listening, that a taken port is never called free, then groups made-up processes the way the page does. It only reads the list and never touches other programs:

```bash
swiftc -parse-as-library Sources/pika-tools/Tools/Ports/PortScanner.swift scripts/test-ports.swift -o build/test-ports && codesign -s - -f -i com.pesotchi.pika-tools.test-ports build/test-ports && build/test-ports
```

The **Brightness** page changes the brightness of monitors macOS can’t adjust on its own: it asks the monitor itself through its cable or, if the monitor doesn’t listen, dims the picture. `BrightnessMath.swift` holds the parts that need no monitor: the messages that set and read the brightness with their checksums, reading the monitor’s answer even when HDMI repeats a byte or two, the maker, model and serial number from the monitor’s EDID, how dark the picture gets and the steps of the brightness keys. The test feeds it made-up bytes and never talks to a monitor:

```bash
swiftc -parse-as-library Sources/pika-tools/Common/BrightnessMath.swift scripts/test-brightness.swift -o build/test-brightness && build/test-brightness
```

`KeyboardLayouts` is the engine behind **Fix words typed in the wrong layout**. It turns the keys that were pressed into text for every keyboard layout you have, and fixes a word only when what came out is not a word in any of your languages while another layout gives a common one, so names, slang and typos stay as typed. The test uses Apple's own layouts and the system spelling dictionaries: it checks pairs such as ghbdtn → привет, then runs every word of the app's texts in 18 languages and about 25,000 English dictionary words and names through the engine and fails on a single wrong fix.

```bash
swiftc -parse-as-library Sources/pika-tools/Tools/LayoutFix/KeyboardLayouts.swift scripts/test-layout.swift -o build/test-layout && build/test-layout
```

The **Player** page opens videos in `pikapik Player.app`, a small sandboxed app inside `Contents/Helpers/` with no network access that reads only the files you open. It plays every file through one pipeline: the `Demuxer` from `Extensions/MediaReader/` reads the packets with FFmpeg, H.264, HEVC and AV1 go straight to `AVSampleBufferDisplayLayer`, which decodes them in hardware, other video is decoded by FFmpeg, and the sound goes to `AVSampleBufferAudioRenderer`, both kept in step by one `AVSampleBufferRenderSynchronizer`. It is an alternate app for every type until a format button, or **Open All in pikapik**, turns it into the default one: `Common/DefaultApps.swift` (shared with the archives switch) remembers each type’s previous app and assigns the helper with `NSWorkspace.setDefaultApplication`, one type at a time, waiting for each answer (macOS reports “Keep” as a cancel error, which only moves on to the next type; no answer for 60 s stops the run). On the way back it restores that app, or the next one that can open the type, never the helper. What the buttons show is read from `urlForApplication(toOpen:)`, not from our own settings. Time, seeking, keys and the format list live in `PlayerLogic.swift`, and the chapter jumps, the chapter marks and the A–B loop in `PlayerMarks.swift`:

```bash
swiftc -parse-as-library Sources/pika-tools/Common/DefaultApps.swift Sources/pika-tools/Tools/Player/PlayerLogic.swift Sources/pika-tools/Tools/Player/PlayerMarks.swift Sources/pika-tools/Tools/Player/PlayerOutput.swift scripts/test-player.swift -o build/test-player && build/test-player
```

The Picture in Picture window (`Helper/Player/PictureInPicture.swift`) has a check too: after it is closed it must not keep the video it showed alive, which AVKit does for as long as its content source holds the delegate. It does nothing on a Mac that cannot show Picture in Picture.

```bash
swiftc -parse-as-library Helper/Player/PictureInPicture.swift scripts/test-pip.swift -o build/test-pip && build/test-pip
```

The preview over the time bar (`Helper/Player/Thumbnails.swift`) has its own test. It makes short videos with ffmpeg (set `FFMPEG=/path/to/ffmpeg` if it is not in Homebrew’s folder), checks the picture at 50 % for H.264, MPEG-4 and VP9, the background filling, that the chapters of an MKV and an MP4 are read with their titles and times, and that closing the window frees everything. It needs the bundled FFmpeg, so CI skips it; build FFmpeg first with `./scripts/build.sh`:

```bash
swiftc -O -parse-as-library -target arm64-apple-macos14.0 -import-objc-header Extensions/MediaReader/FFmpeg.h -I Vendor/ffmpeg/include Vendor/ffmpeg/lib/*.dylib -Xlinker -rpath -Xlinker "$PWD/Vendor/ffmpeg/lib" Helper/Player/Thumbnails.swift Helper/Player/Engine.swift Extensions/MediaReader/{Demuxer,Formats,Codecs,AudioDecoder}.swift Sources/pika-tools/Tools/Player/PlayerLogic.swift scripts/test-thumbnails.swift -o build/test-thumbnails && build/test-thumbnails
```

Songs have a test too (`scripts/test-music.swift`). It makes a short song in MP3, AAC, M4A, ALAC, FLAC, WAV, AIFF, CAF, Ogg, Opus and WMA with ffmpeg, with a title, artist, album and cover, checks that each one plays, that the tags and the cover are read, and that about seventy cut, empty, random and damaged copies are refused or played without a crash. Same ffmpeg and same build as above:

```bash
swiftc -O -parse-as-library -target arm64-apple-macos14.0 -import-objc-header Extensions/MediaReader/FFmpeg.h -I Vendor/ffmpeg/include Vendor/ffmpeg/lib/*.dylib -Xlinker -rpath -Xlinker "$PWD/Vendor/ffmpeg/lib" Helper/Player/Engine.swift Extensions/MediaReader/{Demuxer,Formats,Codecs,AudioDecoder}.swift Sources/pika-tools/Tools/Player/PlayerLogic.swift scripts/test-music.swift -o build/test-music && build/test-music
```

The folder, the next-song logic and Now Playing have one too (`scripts/test-folder.swift`). It opens a folder of three songs in a real player window with the volume at zero, and checks the first song, the automatic move to the next one, Next and Previous, and what macOS would show in Control Center after opening, pausing, moving on and closing. It needs the same ffmpeg:

```bash
swiftc -O -parse-as-library -target arm64-apple-macos14.0 -import-objc-header Extensions/MediaReader/FFmpeg.h -I Vendor/ffmpeg/include Vendor/ffmpeg/lib/*.dylib -Xlinker -rpath -Xlinker "$PWD/Vendor/ffmpeg/lib" Helper/Player/{Engine,FolderAccess,MusicView,NowPlaying,PlayerWindow,Thumbnails}.swift Extensions/MediaReader/{Demuxer,Formats,Codecs,AudioDecoder}.swift Sources/pika-tools/Tools/Player/PlayerLogic.swift scripts/test-folder.swift -o build/test-folder && build/test-folder
```

### Adding a tool

1. Create a file in `Sources/pika-tools/Tools/` with a class that conforms to `Tool`.
2. Add one line to `ToolRegistry.tools` in `Tools/Tool.swift`.
3. Describe it in [`docs/FEATURES.md`](docs/FEATURES.md) under its Settings tab: what it does, how it works, its limits, which edition has it and how to test it by hand. Then run `./scripts/feature-form.sh` so the bug and feature forms list it. CI and `release.sh` fail while the forms and the catalog disagree. A changed tool gets the same update.
4. If users should notice it after the update, add one line to `NewMarks.items` in `Common/NewMarks.swift`: the version that ships it, the tab, the tool’s `id` as the row, and the edition. The tab gets a dot until it is opened and the row a New tag until the tab is left.

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

## Icons in Settings

Settings use three kinds of icons, the same way System Settings does:
- a colored tile (`SectionIcon` in `Common/IconStyle.swift`) marks a place: the sidebar and page headers;
- an app's own icon means the row is that program: Ports, Background, Games, Uninstaller;
- a plain symbol in a 24 pt column marks a fact: Battery, Temperature.

A program without its own icon, such as a command-line tool, gets a gray tile with the `terminal` symbol.

## Third-party software

The direct build includes the 7-Zip command line tool (`7zz`) from [www.7-zip.org](https://www.7-zip.org), licensed under the GNU LGPL 2.1 with the unRAR restriction. It runs as a separate program, its license is in the app as `Contents/Resources/7-Zip License.txt`, and its source code is attached to every release as `7-Zip-26.04-source.tar.xz`.

The video player uses [FFmpeg](https://ffmpeg.org) under the GNU LGPL 2.1 or later and [dav1d](https://code.videolan.org/videolan/dav1d) under the BSD 2-Clause license, built as shared libraries in `Contents/Frameworks/` with only LGPL parts enabled. Both licenses are in the app as `Contents/Resources/FFmpeg License.txt`, the Player page opens them, and the exact sources are attached to every release.
