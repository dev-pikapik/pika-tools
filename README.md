# pika-tools

[Русский](README.ru.md)

[![Latest release](https://img.shields.io/github/v/release/dev-pikapik/pika-tools)](https://github.com/dev-pikapik/pika-tools/releases/latest)
![macOS 14+](https://img.shields.io/badge/macOS-14%2B-blue)
[![License: MIT](https://img.shields.io/github/license/dev-pikapik/pika-tools)](LICENSE)
[![Downloads](https://img.shields.io/github/downloads/dev-pikapik/pika-tools/total)](https://github.com/dev-pikapik/pika-tools/releases)

A small menu bar app for macOS with a few keyboard fixes: it blocks Ctrl shortcuts, ignores accidental double spaces and switches languages with Option+Shift, the way Alt+Shift works on Windows.

## Install

With Homebrew:

```bash
brew tap dev-pikapik/pika-tools https://github.com/dev-pikapik/pika-tools && brew trust dev-pikapik/pika-tools && brew install --cask pika-tools && open -a pika-tools
```

Or with a single command in Terminal:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/install.sh)"
```

Or download `pika-tools.dmg` from [Releases](https://github.com/dev-pikapik/pika-tools/releases/latest) and drag the app to Applications.

Homebrew and the script both put the app in `/Applications`, launch it, ask for permissions and turn on Open at Login.

## First launch

pika-tools needs two permissions. On first launch it opens Settings on the Permissions page, which walks you through them, and macOS shows its own prompts. Go to **System Settings › Privacy & Security** and turn on pika-tools in:

- **Accessibility**, so the app can change a key press or click before it reaches other apps.
- **Input Monitoring**, so the app can see key presses and clicks in the first place.

The app picks up the change within a couple of seconds, no restart needed.

pika-tools doesn't record, store or send anything you type or click. Events are handled in memory and passed on right away. The only network request is the update check, which asks GitHub for the latest release.

## Features

**Block Ctrl shortcuts.** Ctrl becomes a plain key. Apps still see it held down, but macOS no longer turns it into shortcuts: Ctrl+Space won't switch input sources, Ctrl+arrows won't switch desktops, and Ctrl-click is a regular click instead of a context menu. Right-click and two-finger tap work as usual. Handy in games and remote desktop sessions, where Ctrl has a job of its own.

**Double-space guard.** The first space always goes through. A second one pressed faster than the delay is ignored, so you don't get a period from double space or stray repeats. The delay is adjustable from 50 to 300 ms (120 ms by default). Holding space and space with modifiers always work.

**Switch language with Option+Shift.** Hold Option, press Shift and let go of both: macOS moves to the next input source. Shift first, then Option, goes back to the previous one. If you press another key, click, or add Cmd, Ctrl or Fn in between, nothing switches, so shortcuts like Option+Shift+arrow work as before. This tool is off by default.

Each tool has its own switch in the menu and in Settings. Need a normal Ctrl+C or the double-space period back? Turn that tool off.

The menu bar icon shows the state at a glance: an arrow with a click when the tools are working, a crossed-out arrow when everything is off, and a warning triangle when a tool is on but permissions are missing.

The app follows your system language or the one you pick in Settings: English, Russian, Ukrainian, German, French, Spanish, Italian, Portuguese (Brazil), Japanese, Chinese (Simplified) and Korean.

## Keep Awake

Stops your Mac from falling asleep while you're away from the keyboard: for 15 minutes up to 8 hours, or until you turn it off. Flip it on from the menu, pick the duration in Settings. The menu shows when it ends. **Keep the display on** stops the screen from dimming too. Quitting pika-tools ends Keep Awake.

On a MacBook you can also turn on **Work with the lid closed**. macOS has no switch for that, so pika-tools runs `pmset -a disablesleep 1` and asks for an administrator password: only an administrator can change how the Mac sleeps. The setting goes back to normal on its own when Keep Awake ends, when you quit the app, or if it crashes. If you don't enter the password, nothing changes. Keep the Mac ventilated with the lid closed. **Stop when battery is below 20%** ends the session before the battery runs out.

## Settings

Open Settings from the menu with **Settings…** or ⌘, or launch pika-tools again from Finder, Launchpad or Spotlight. While the window is open, the app shows up in the Dock and in ⌘Tab.

- **General**: open at login, appearance (System, Light or Dark), language and updates.
- **Keyboard & Mouse**: every tool and the double-space delay.
- **Keep Awake**: duration, display and lid options.
- **Permissions**: the status of both permissions with buttons that open the right place in System Settings.
- **About**: version, links to the changelog and to report a problem.

## Updates

pika-tools checks for new versions at launch and every 6 hours. You can turn that off in Settings › General. When one is out, an **Update to …** button appears in the menu: one click and the app downloads the update, installs it and restarts. You can also check by hand with **Check** at the bottom of the menu.

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
Remove pika-tools from both lists with the − button, then choose **Check Permissions** in the menu and turn them on again.

## Contributing

Building from source and releasing are covered in [CONTRIBUTING.md](CONTRIBUTING.md). Changes are listed in [CHANGELOG.md](CHANGELOG.md).

## License

MIT, © 2026 pikapik. See [LICENSE](LICENSE).
