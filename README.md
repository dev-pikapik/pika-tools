# pika-tools

**English** · [Русский](docs/readme/README.ru.md) · [Українська](docs/readme/README.uk.md) · [Deutsch](docs/readme/README.de.md) · [Français](docs/readme/README.fr.md) · [Español](docs/readme/README.es.md) · [Italiano](docs/readme/README.it.md) · [Português (Brasil)](docs/readme/README.pt-BR.md) · [日本語](docs/readme/README.ja.md) · [简体中文](docs/readme/README.zh-Hans.md) · [한국어](docs/readme/README.ko.md) · [Română](docs/readme/README.ro.md) · [Polski](docs/readme/README.pl.md) · [Türkçe](docs/readme/README.tr.md) · [Nederlands](docs/readme/README.nl.md) · [Svenska](docs/readme/README.sv.md) · [Čeština](docs/readme/README.cs.md) · [繁體中文](docs/readme/README.zh-Hant.md) · [العربية](docs/readme/README.ar.md) · [हिन्दी](docs/readme/README.hi.md) · [Bahasa Indonesia](docs/readme/README.id.md) · [Tiếng Việt](docs/readme/README.vi.md) · [ไทย](docs/readme/README.th.md)

[![Latest release](https://img.shields.io/github/v/release/dev-pikapik/pika-tools)](https://github.com/dev-pikapik/pika-tools/releases/latest)
![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue)
[![License: MIT](https://img.shields.io/github/license/dev-pikapik/pika-tools)](LICENSE)
[![Downloads](https://img.shields.io/github/downloads/dev-pikapik/pika-tools/total)](https://github.com/dev-pikapik/pika-tools/releases)

A small menu bar app for macOS with fixes for keys, windows and the Dock: it guards ⌘Q and ⌘W, switches languages with Option+Shift, repeats a held key, turns off mouse acceleration, scrolls the mouse wheel by lines, makes the side mouse buttons go back and forward, quits apps when you close their last window, hides an app with a click in the Dock and keeps your Mac awake.

## Install

With [Homebrew](https://brew.sh):

```bash
brew install --cask dev-pikapik/pika-tools/pika-tools && open -a pika-tools
```

Without Homebrew, open Terminal, paste this line and press Return:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/install.sh)"
```

Or download [pika-tools.dmg](https://github.com/dev-pikapik/pika-tools/releases/latest/download/pika-tools.dmg), open it and drag the app to Applications.

Homebrew and the script both put the app in `/Applications`, launch it, ask for permissions and turn on Open at Login. After that the app updates itself, see [Updates](#updates). To remove it, see [Uninstall](#uninstall).

## First launch

pika-tools needs two permissions. On first launch it opens Settings on the Permissions page, which walks you through them, and macOS shows its own prompts. Go to **System Settings › Privacy & Security** and turn on pika-tools in:

- **Accessibility**, so the app can change a key press or click before it reaches other apps.
- **Input Monitoring**, so the app can see key presses and clicks in the first place.

The app picks up the change within a couple of seconds, no restart needed.

pika-tools doesn't record, store or send anything you type or click. Events are handled in memory and passed on right away. The only network request is the update check, which asks GitHub for the latest release.

## Features

**Protect ⌘Q and ⌘W.** ⌘Q and ⌘W alone do nothing, so you don't quit an app or close a window by accident. Add Shift to do it on purpose: ⇧⌘Q quits, ⇧⌘W closes. Works in every app. Each key has its own switch. Off by default.

**Switch language with Option+Shift.** Hold Option and tap Shift: macOS moves to the next input source. Keep holding Option and tap Shift again to go further. Hold Shift and tap Option to go back. If you press another key, click, or add Cmd, Ctrl or Fn in between, nothing switches, so shortcuts like Option+Shift+arrow work as before. Off by default.

**Repeat a held key.** Hold a key and it types the letter again and again instead of showing the accent menu. Handy in games and when you type fast. Apps that are already open pick it up after a restart. Turn it off and macOS works as usual again. Off by default.

**Home and End go to the start and end of a line.** While you type, Home moves the cursor to the start of the line and End to its end, instead of scrolling the page. Add ⇧ to select up to there, or ⌘ to jump to the start or end of the whole text. Outside text fields, and in terminals, virtual machines and remote desktop apps, the keys work as before. You can list other apps where they should work as usual. Off by default.

**Turn off pointer acceleration.** The pointer moves exactly as far as the mouse does, however fast you move it, like LinearMouse. A **Tracking speed** slider sets how fast it goes. Works for mice only, the trackpad stays as it is. Turn it off or quit pika-tools, and macOS gets its own settings back. Off by default.

**Scroll by lines.** Every click of the mouse wheel scrolls the same number of lines, however fast you spin it. Pick from 1 to 10 lines per click, 3 by default. Natural scrolling stays as you set it in System Settings. Works for mice only, the trackpad stays as it is. Off by default. Beside the **Distance per click** slider, a small page scrolls by the distance you pick, and a dot marks the default.

Some apps and games count scrolling in exact pixels: for them, switch the same setting to pixels and pick from 1 to 200 pixels per click, 40 by default. The slider also says how much of the screen height that is.

**Scroll direction for trackpad and mouse.** macOS has one natural scrolling switch for both the trackpad and the mouse. Turn this on and pick a direction for each one: **Natural**, where the page follows your fingers like on iPhone, or **Classic**, where the page moves the other way. The trackpad choice also covers sideways scrolling and the glide after you lift your fingers. The Magic Mouse scrolls by touch, so it follows the trackpad choice. Pick the same on each of your Macs, and scrolling feels the same on all of them, even when you move the mouse to another Mac with Universal Control. Off by default. When you turn it on, both start the way System Settings has them, so nothing changes until you pick something else.

**Side buttons go back and forward.** Mouse buttons 4 and 5 go back and forward in Safari, Finder and other Apple apps, Firefox, Opera and ForkLift, just like a swipe on the trackpad. Other apps, such as JetBrains IDEs, get the buttons as they are and handle them their own way. If your mouse has them the other way round, turn on **Swap the side buttons**. Off by default.

**Quit when the last window closes.** Close the last window of an app, and the app quits. Finder stays open, and so do apps with windows on other desktops or in the Dock. You can list apps that should never quit this way. Off by default.

**Hide with a click in the Dock.** Click the Dock icon of the app you're in, and it hides. Click again to bring it back. Off by default.

**Green button enlarges the window.** Click the green button of a window, and it grows to fill the screen without going full screen. Click again to bring back the previous size. Hold ⌥ and the button works as it always did. Full screen stays in the button's menu and on ⌃⌘F. You can list apps where the green button should work as usual. Off by default.

**New File in Finder.** Right-click in a Finder window or on the Desktop, choose **New File**, type a name, and an empty file appears. It’s a .txt by default. Off by default.

**Enter opens files in Finder.** Select files in a Finder window or on the Desktop and press Return or Enter, and they open. F2 or fn F2 renames the selected file. In text fields, for example while you type a name, the keys work as usual. Off by default.

**⌘X cuts files in Finder.** Select files and press ⌘X, open the folder you want and press ⌘V, and the files move there instead of being copied. ⌘C cancels the cut. Off by default.

**Delete removes files in Finder.** Select files and press ⌫ or ⌦ (fn ⌫ on a laptop), and they go to the Trash, just like with ⌘⌫. While you rename a file, search or type in any other field, the keys erase letters as usual. Off by default.

**Smaller Copy in Finder.** Right-click a file in Finder and choose **Make a Smaller Copy**. A lighter version of a photo, GIF, PDF or video appears right next to it, often several times smaller. Uncompressed sound like WAV or AIFF becomes a compact M4A. If a file can’t get any smaller, no copy is made and pika-tools tells you so. The original stays as it is, and nothing leaves your Mac. Off by default.

**Convert in Finder.** Right-click a file in Finder and choose **Convert To** to save it in another format: a picture as JPEG, PNG, HEIC, GIF, TIFF or PDF, a video as MP4, MOV or just its sound, music as M4A, WAV or AIFF. The original stays as it is, and nothing leaves your Mac. Turns on separately from Smaller Copy. Off by default.

**Game Mode.** Add your games, and while you play one, your Mac doesn’t pull you out of it. Spotlight, Siri, ⌘Tab, Mission Control and swipes between desktops don’t open over the game, ⌘Q and ⌘W don’t close it by accident, the pointer doesn’t slip onto the Dock, the menu bar or another screen, the keyboard language doesn’t change, and the screen stays on. Each of these has its own switch on the Games page, and pika-tools suggests games it finds on your Mac. In a game, Ctrl is a plain key: Ctrl-click stays a click, and Ctrl+Space or Ctrl+arrows don’t switch the language or the desktop. Minecraft is recognized too: add the Minecraft Launcher or CurseForge, and Game Mode turns on inside Minecraft itself. To leave a game, press ⇧⌘Q; to close its window, press ⇧⌘W. ⌥⌘Esc always works. As soon as you leave the game, everything works as usual. Off by default.

Each tool has its own switch in the menu and in Settings.

The menu bar icon shows the state at a glance: an arrow with a click when the tools are working, a crossed-out arrow when everything is off, and a warning triangle when a tool is on but permissions are missing.

The menu bar panel starts with just a few rows. You choose which ones it shows: click the pencil button at the bottom, tick what you want to see and click **Done**. Hidden rows keep working and stay in Settings. If the panel doesn't fit the screen, it scrolls.

The app follows your system language or the one you pick in Settings. It is available in all 23 languages listed at the top of this page.

## Keep Awake

Stops your Mac from falling asleep while you're away from the keyboard: for any time from 1 second to 365 days, or until you turn it off. Flip it on from the menu, set the duration in Settings: type days, hours, minutes and seconds, use ↑ and ↓, or click a preset from 15 minutes to 8 hours. The menu shows how much time is left and when it ends. **Display** has two choices. **Always on**: it doesn't go dark, with no screen saver or lock screen. **Turns off as usual**: it goes dark on its own timer while the Mac keeps working. **Turn off the display now** (also in the menu) darkens it at once while the Mac keeps working: move the mouse or press a key to bring it back. Quitting pika-tools ends Keep Awake.

On a MacBook you can also turn on **Work with the lid closed**. macOS has no switch for that, so pika-tools runs `pmset -a disablesleep 1` and asks for an administrator password: only an administrator can change how the Mac sleeps. The setting goes back to normal on its own when Keep Awake ends, when you quit the app, or if it crashes. If you don't enter the password, nothing changes. Keep the Mac ventilated with the lid closed. **Stop when battery is below 20%** ends the session before the battery runs out.

Keep Awake, the display and lid-closed modes can be put on a button in Control Center, the menu bar or a desktop widget through the Shortcuts app, with links you copy from Settings › Keep Awake.

## Settings

Open Settings from the menu with **Settings…** or ⌘, or launch pika-tools again from Finder, Launchpad or Spotlight. While the window is open, the app shows up in the Dock and in ⌘Tab.

- **General**: open at login, appearance (System, Light or Dark), language, updates, and backup: export and import settings as a file, or sync them through iCloud Drive.
- **Keep Awake**: duration, display and lid options.
- **Keyboard**: language switch, key repeat, Home and End.
- **Mouse**: pointer acceleration and tracking speed, scrolling by lines, scroll direction, side buttons.
- **Windows**: enlarge with the green button (with a list of exceptions), ⌘Q and ⌘W protection, quit on last window (with a list of exceptions).
- **Dock**: hide with a click in the Dock.
- **Finder**: new file, smaller copy and conversion, Enter to open, ⌘X to cut, Delete to move to the Trash.
- **Permissions**: the status of both permissions, and of iCloud Drive when sync is on, with buttons that open the right place in System Settings.
- **About**: version, links to the changelog and to report a problem.

Many settings come with a small picture of what they do, such as a Mac staying awake or a window hiding behind the Dock. The picture changes together with the switch and stands still when Reduce Motion is on in System Settings.

Every page has a **Restore Defaults…** button at the bottom. It asks first, then turns off the tools on that page and puts their options back, as if pika-tools never touched them.

**Sync settings with iCloud** keeps pika-tools the same on all your Macs. The settings live in the pika-tools folder in iCloud Drive, and the most recent change wins. It's off by default and needs iCloud Drive turned on. Permissions aren't synced: every Mac asks for them on its own.

## Updates

pika-tools checks for new versions at launch and every 6 hours. You can turn that off in Settings › General. When one is out, an **Update to …** button appears in the menu: one click and the app downloads the update, installs it and restarts. You can also check by hand with **Check Now** in Settings › General.

With Homebrew you can also run `brew upgrade --cask pika-tools`.

Starting with 1.3, permissions stay in place after updates.

## Uninstall

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/uninstall.sh)"
```

If you installed with Homebrew: `brew uninstall --cask --zap pika-tools`.

Both quit the app, remove it from login items and delete it. The script also resets its permissions.

## FAQ

**Why does it need two permissions?**
macOS splits keyboard and mouse access in two. Input Monitoring lets the app see events, Accessibility lets it change them. Blocking a shortcut needs both.

**macOS says the app is from an unidentified developer.**
pika-tools is signed, but not notarized by Apple. Homebrew and the install script take care of this for you. If you used the dmg, open **System Settings › Privacy & Security** and click **Open Anyway**, or run:

```bash
xattr -dr com.apple.quarantine /Applications/pika-tools.app
```

**Does it work on Intel Macs?**
Yes. It's a universal app for Apple Silicon and Intel, macOS 14 Sonoma or later.

**The permission is on, but nothing works.**
In **System Settings › Privacy & Security**, remove pika-tools from both lists with the − button, then add it again. The Permissions page in pika-tools Settings has buttons that open the right place.

## Contributing

Building from source and releasing are covered in [CONTRIBUTING.md](CONTRIBUTING.md). Changes are listed in [CHANGELOG.md](CHANGELOG.md).

## License

MIT, © 2026 pikapik. See [LICENSE](LICENSE).
