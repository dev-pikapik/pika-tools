# Changelog

All notable changes to this project are documented here. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.18.2] - Unreleased

### Fixed
- Settings: keys in setting texts are now drawn as key pictures instead of symbols, and the texts are shorter.
- Scroll by lines: the distance slider no longer jumps while dragging and moves in clear steps of 20 px in pixels mode.

## [1.18.1] - Unreleased

### Fixed
- Settings: a single key picture no longer leaves an empty gap before the setting name.

## [1.18.0] - Unreleased

### Added
- Settings › Keyboard: “Block Control shortcuts” has a list of apps where Ctrl keeps working as usual, for example a remote desktop app. The list is saved, synced through iCloud Drive and cleared by Restore Defaults.
- New pictures that move with the switch: Switch language, Block Control shortcuts, Side buttons and New File in Finder.
- Settings › Mouse: “Distance per click” shows a small page that scrolls by the distance you pick, with a dot at the default. In pixel mode it also says how much of the screen height that is.

### Changed
- Shortcuts are shown as keys everywhere: ⌃, ⌥ ⇧, ⌘ Q, ⌘ W, ↩ F2, ⌘ X and the key repeat key.
- Every description in Settings is one short line, and the full sentence moved to the tooltip. The menu bar hints are shorter too.
- One “Distance per click” slider replaces the two wheel sliders, with Slower and Faster at the ends. The tracking speed slider marks the speed the Mac uses by itself.
- Clearer names: “Block Control shortcuts”, “Switch language”, “Cut files in Finder”. The ⌘Q and ⌘W group lost its heading and paragraph.

## [1.17.1] - Unreleased

### Fixed
- Finder: ⌘X and ⌘V now move files every time. Before, Finder sometimes did not notice the changed key, and Return, Enter and F2 sometimes did nothing for the same reason.
- Finder: ⌘X, ⌘V, Return, Enter and F2 now also work on the Desktop, not only in Finder windows.

## [1.17.0] - Unreleased

### Added
- Settings › Windows: “Green button enlarges the window”. Click the green button of a window, and it fills the screen without going full screen. Click again to bring back the previous size. Hold ⌥ and the button works as usual. Full screen stays in the button’s menu and on ⌃⌘F. A list of apps keeps the green button working as before. Off by default.
- Settings › Finder: “Enter opens files in Finder”. In a Finder window or on the Desktop, Return and Enter open the selected files, and F2 or fn F2 renames the selected file. In text fields, such as a name you are typing or the search field, the keys work as usual. Off by default.
- Settings › Finder: “⌘X cuts files in Finder”. ⌘X cuts the selected files, and ⌘V in the folder you choose moves them there instead of copying, like Cut and Paste on Windows. ⌘C cancels the cut. Off by default.

### Changed
- Settings pages follow System Settings: General, Keep Awake, Keyboard, Mouse, Windows, Dock and Finder, then Permissions and About set apart. Windows & Apps is split up. Windows has two sections, Size (green button) and Closing and Quitting (⌘Q and ⌘W, quit after the last window closes). Hide on Dock click moved to Dock, and New File, Enter opens files and ⌘X cuts files moved to Finder. Keyboard has the key repeat next to the Ctrl shortcuts and the language switch. The most used settings come first on each page, and the menu follows the same order. Dock and Finder have their own icons and colors, like in System Settings.
- About shows just the version number, without the build number in brackets.
- Settings: in rows with a title and a description, the switch, button or slider now sits in the middle of the row, like in System Settings, instead of next to the first line. The icon on the About page is the same size and in the same place as the icons at the top of the other pages.
- Settings: buttons have icons. Copy Link has a link, and for a second after you click it says “Copied” with a check mark. Open Shortcuts, Open Finder Extensions…, Import and Export, Restore Defaults…, Restart, Add App… and the buttons that open System Settings or check for updates have their own icons too. Shortcuts shows the icon of the Shortcuts app.
- Settings show pictures: Keep Awake, Appearance, Key Repeat, Scroll by lines or pixels, Pointer acceleration, Quit after the last window closes, Hide on Dock click, Green button enlarges the window, Enter opens files and ⌘X cuts files. A picture changes as you flip its switch. With Reduce Motion on in System Settings, the pictures stand still.
- Settings › Mouse: the description of “Lines per wheel click” said it works while scrolling by lines is on, which was wrong in Pixels mode. Both sliders now say they work while the switch above is on.
- Settings › Keep Awake no longer shows “Until …” twice while the timer is running.

### Fixed
- Some texts showed in English instead of your language.

## [1.16.0] - Unreleased

### Added
- Keep Awake: set the timer in days, hours, minutes and seconds. Click a number and type it, press ↑ and ↓ to change it by one, or move between numbers with ← and → or Tab. Ready-made buttons set 15 minutes, 30 minutes, 1 hour, 2 hours or 8 hours in one click.
- Settings › Keep Awake shows when the timer would end, for example “Until tomorrow, 14:07”.
- The links in Settings › About now have icons, like the sections in Settings. GitHub uses the GitHub logo.

### Changed
- The Keep Awake timer can be anything from 1 second to 365 days instead of a number with a unit. A timer you had already set is converted automatically.

## [1.15.2] - Unreleased

### Fixed
- The menu bar panel no longer turns grey when pika-tools was already the active app as you opened it.
- Finder no longer shows “New File” twice when a test build of pika-tools was also installed.

## [1.15.1] - Unreleased

### Changed
- The menu bar panel shows a short hint under each row again. The full description is still in the tooltip. Keep Awake always shows its status.
- “New File” in the Finder right-click menu no longer has an icon, like the system items.

### Fixed
- The menu bar panel sometimes opened with grey colors instead of your accent color.

## [1.15.0] - Unreleased

### Changed
- The menu bar panel is shorter and simpler. All rows sit in one card, each row is a single button without a switch, and descriptions show as a tooltip. Settings, Customize and Quit are now icon buttons.
- The panel now starts with four rows: Block ⌃ Control shortcuts, Switch language with ⌥⇧, Turn off pointer acceleration and Keep Awake. Click the pencil button to show the others. If you had already customized the panel, nothing changes.
- Keep Awake shows its timer in the panel only while it is on.
- Shorter descriptions for Repeat a held key, pointer acceleration, Scroll by lines and Side buttons. Settings › Mouse now says when to use Lines and when Pixels.
- Russian texts now address you politely and consistently.

## [1.14.1] - Unreleased

### Fixed
- The menu bar panel showed only its buttons in 1.14.0. All rows are back, and the panel scrolls only when it is taller than the screen.

## [1.14.0] - Unreleased

### Added
- Choose which rows the menu bar panel shows: click Customize…, untick what you don't need, click Done. Hidden rows keep working and stay in Settings.

### Fixed
- The menu bar panel no longer runs off the bottom of the screen. When it doesn't fit, it scrolls.

## [1.13.0] - Unreleased

### Added
- Scroll by pixels: on the Mouse page, choose Lines or Pixels. In Pixels mode every click of the wheel scrolls exactly 1 to 200 pixels, for apps and games that count scrolling in pixels.

## [1.12.0] - Unreleased

### Added
- Buttons for Keep Awake, the display and the lid-closed mode in Control Center, the menu bar or a desktop widget, through the Shortcuts app. Copy a link in Settings › Keep Awake and paste it into a shortcut with Open URLs.

## [1.11.0] - Unreleased

### Added
- **New File** in the Finder right-click menu, on the Desktop too: pick it, type a name and get an empty file. Plain text by default. Turn it on in Windows & Apps.
- Right-click the pika-tools icon in the menu bar for a quick menu: Keep Awake, Settings, updates, About, Open at Login and Quit.

### Fixed
- Quit when the last window closes now also reacts to the close button and ⌘W, and checks twice before quitting.

## [1.10.1] - Unreleased

### Fixed
- Quit when the last window closes works in apps that keep a closed window in the background, such as Books. Windows on other desktops and in the Dock still keep the app open.

## [1.10.0] - Unreleased

### Added
- **Repeat a held key** on the Keyboard page: hold a key and the letter types again and again, like on Windows, instead of the accent menu. Handy in games. Open apps pick it up after a restart.

### Changed
- The Settings window has a minimum size, and every page fits down to it without overlapping.
- The Settings toolbar is translucent like in System Settings, content scrolls under it.

### Fixed
- ⇧⌘Q and ⇧⌘W quit and close again when ⌘Q and ⌘W are protected.

## [1.9.0] - Unreleased

### Added
- **Scroll by lines** on the Mouse page: every click of the wheel scrolls the same number of lines, 1 to 10, however fast you spin it, like on Windows. Mice only, natural scrolling is kept.
- Sliders show their value as a number you can type or change with arrows, with Slow and Fast at the ends.
- **Export Settings…** and **Import Settings…** on the General page save all settings to a file and load them back. Import asks first.
- **Sync settings with iCloud** keeps settings the same on all your Macs through iCloud Drive. Off by default.

### Fixed
- Side buttons no longer press ⌘[ and ⌘]. In Apple apps, Firefox, Opera and ForkLift they go back and forward like a swipe on the trackpad; every other app, such as JetBrains Rider, gets buttons 4 and 5 unchanged.

## [1.8.0] - Unreleased

### Added
- Mouse page in Settings. **Turn off pointer acceleration** makes the pointer move exactly as far as the mouse, with its own tracking speed slider. Mice only, the trackpad stays as it is, and macOS gets its own settings back when you turn it off or quit.
- **Side buttons go back and forward**: mouse buttons 4 and 5 work like ⌘[ and ⌘] in every app, with an option to swap them.
- **Restore Defaults…** at the bottom of every Settings page. It asks first, then turns off the tools on that page and puts their options back.

### Changed
- Keyboard and Mouse are now separate pages in Settings, like in System Settings.
- The Permissions page shows the same Accessibility and Input Monitoring icons as System Settings.

## [1.7.0] - Unreleased

### Added
- The app is now available in Romanian, Polish, Turkish, Dutch, Swedish, Czech, Traditional Chinese, Arabic, Hindi, Indonesian, Vietnamese and Thai.
- README in 23 languages.

## [1.6.0] - Unreleased

### Changed
- Language switching with Option+Shift works like on Windows: hold one key and tap the other to switch, as many times as you need, without letting go of both.

## [1.5.2] - Unreleased

### Fixed
- Accessibility and Input Monitoring stay allowed after updates. Test builds now use their own bundle ID, so they can no longer take over the permissions or the login item of the installed app.
- "Open at login" survives updates through Homebrew and always points to the installed app.

## [1.5.1] - Unreleased

### Changed
- The Settings window can be resized in width and height, from 700 × 500 to full screen. Rows move their controls below the title when space is tight, and long translations wrap instead of being cut off.
- The Settings window remembers its size and position between launches.
- The Settings sidebar is narrower and always stays visible.

## [1.5.0] - Unreleased

### Added
- Protect ⌘Q and ⌘W: ⌘Q and ⌘W alone do nothing in every app, ⇧⌘Q quits and ⇧⌘W closes a window. Each key has its own switch.
- A new Windows & Apps page with two tools, both off by default:
  - Quit when the last window closes, with a list of apps that never quit this way. Finder always stays open.
  - Hide with a click in the Dock: clicking the icon of the app you're in hides it.
- Keep Awake duration can be any number of minutes, hours, days, weeks or months, up to 12 months. The countdown shows days and the end date when it isn't today.

### Changed
- Installing is one command in Terminal, no Homebrew needed. The Homebrew command no longer needs `brew trust`.

### Removed
- Double-space guard. Its settings are cleaned up on the next launch.

## [1.4.1] - Unreleased

### Added
- Back and Forward buttons in the Settings toolbar, with ⌘[ and ⌘].
- Search finds settings, not just pages: matches show under their page, and clicking one opens it and highlights the setting. Synonyms work too, like "sleep" or "autostart".
- Keep Awake shows a live countdown and the end time, in Settings and in the menu.

### Changed
- The Settings window has the size and layout of System Settings: the sidebar sits at the left edge, the window only grows in height.
- Sidebar icons follow the Icon & widget style on macOS 26: Default, Dark, Clear and Tinted.
- The app icon is amber again, with a white arrow.
- Name, version and updates live only in About. The menu shows just an Update button when a new version is out.
- Modifier keys use their symbols: ⌃ Control, ⌥ Option, ⇧ Shift.
- Work with the lid closed is shown on desktop Macs too, but turned off with a note that it works only on Mac laptops.

### Fixed
- An empty area next to the Settings content when the window got wider.
- Work with the lid closed stayed on after a canceled password prompt.

## [1.4.0] - Unreleased

### Added
- Settings window in the style of System Settings: General, Keyboard & Mouse, Keep Awake, Permissions and About, with search in the sidebar. Opens with Settings… or ⌘, in the menu, or when you launch the app again.
- Keep Awake: keeps the Mac from sleeping for 15 minutes up to 8 hours or until you turn it off, optionally with the display on. On a MacBook it can also work with the lid closed (asks for an administrator password) and stop when the battery drops below 20%.
- Appearance: System, Light or Dark, applied right away to the menu and the Settings window.
- Language picker: any of the 11 languages or the system one, applied after a restart.
- Option to turn off automatic update checks.

### Changed
- The menu is simpler: tools, Keep Awake, Settings… and Quit. Open at Login moved to Settings › General.
- The permissions window became the Permissions page in Settings. The menu shows Permissions needed only when something is missing.

## [1.3.0] - Unreleased

### Added
- Switch language with Option+Shift: Option then Shift selects the next input source, Shift then Option the previous one. Off by default.
- The app speaks 11 languages: English, Russian, Ukrainian, German, French, Spanish, Italian, Portuguese (Brazil), Japanese, Chinese (Simplified) and Korean.
- VoiceOver support: toggles, the delay slider and permission status are read out properly.

### Changed
- Ctrl-click and Ctrl shortcuts are merged into one tool, Block Ctrl shortcuts.
- New adaptive app icon with light and dark variants.
- Releases are signed with a permanent certificate, so permissions are kept between updates.

## [1.2.1] - 2026-10-06

### Fixed
- Menu titles wrap instead of being cut off, subtitles are shorter, and the repeat delay is easier to understand.

## [1.2.0] - 2026-10-05

### Added
- Double-space guard: the first space goes through, a repeat faster than the delay is ignored. The delay is adjustable.

## [1.1.0] - 2026-10-05

### Added
- Block Ctrl shortcuts: apps still see Ctrl held down, but macOS no longer reacts to Ctrl shortcuts.

## [1.0.2] - 2026-10-05

### Added
- App icon.
- Releases are built and published by GitHub Actions.

## [1.0.1] - 2026-10-05

### Changed
- The Homebrew cask uses the current Homebrew syntax.

### Fixed
- Stale permissions left from an older build are reset from within the app.

## [1.0.0] - 2026-10-05

### Added
- First release: Ctrl-click works as a regular click instead of opening a context menu.
- Menu bar menu with a status icon, Open at Login and a permissions window.
- Built-in updates from GitHub Releases.
- Install with Homebrew, an install script or a dmg.

[1.4.0]: https://github.com/dev-pikapik/pika-tools/compare/v1.3.0...HEAD
[1.3.0]: https://github.com/dev-pikapik/pika-tools/compare/v1.2.1...v1.3.0
[1.2.1]: https://github.com/dev-pikapik/pika-tools/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/dev-pikapik/pika-tools/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/dev-pikapik/pika-tools/compare/v1.0.2...v1.1.0
[1.0.2]: https://github.com/dev-pikapik/pika-tools/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/dev-pikapik/pika-tools/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.0.0
