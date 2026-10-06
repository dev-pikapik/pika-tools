# Changelog

All notable changes to this project are documented here. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
