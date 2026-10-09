# Changelog

Every update to pikapik, version by version. The same news, told simply with a picture, is in [What’s new](docs/whats-new/README.md), also in your language: [Русский](docs/whats-new/README.ru.md) · [Українська](docs/whats-new/README.uk.md) · [Deutsch](docs/whats-new/README.de.md) · [Français](docs/whats-new/README.fr.md) · [Español](docs/whats-new/README.es.md) · [Italiano](docs/whats-new/README.it.md) · [Português (Brasil)](docs/whats-new/README.pt-BR.md) · [日本語](docs/whats-new/README.ja.md) · [简体中文](docs/whats-new/README.zh-Hans.md) · [한국어](docs/whats-new/README.ko.md) · [Română](docs/whats-new/README.ro.md) · [Polski](docs/whats-new/README.pl.md) · [Türkçe](docs/whats-new/README.tr.md) · [Nederlands](docs/whats-new/README.nl.md) · [Svenska](docs/whats-new/README.sv.md) · [Čeština](docs/whats-new/README.cs.md) · [繁體中文](docs/whats-new/README.zh-Hant.md) · [العربية](docs/whats-new/README.ar.md) · [हिन्दी](docs/whats-new/README.hi.md) · [Bahasa Indonesia](docs/whats-new/README.id.md) · [Tiếng Việt](docs/whats-new/README.vi.md) · [ไทย](docs/whats-new/README.th.md).

## [1.27.1] - Unreleased

### Fixed
- Settings no longer keep your Mac busy. The little moving pictures used to redraw the whole page many times a second. Now each picture redraws only itself and only while it moves, no more than 30 times a second, and rests when it’s scrolled out of sight or the window is hidden. They look the same as before.
- New File, Compress and Convert To work in Finder right after the move to pikapik. Finder could keep looking for the old pika-tools app; now the app notices this and restarts Finder by itself when no Finder windows are open and nothing is copying. Otherwise the Finder page and the menu offer a Restart Finder button.
- The login item in System Settings now shows the new name, pikapik, and stays on.

## [1.27.0] - 2026-10-09

### Added
- A pet on the desktop. A little friend walks along the bottom of the screen, behind your windows and the Dock. Press Space and it jumps; put the pointer in its way and it hops over it. You can pick it up, carry it and throw it, and catch it again in the middle of a jump. Every now and then it sits down and says something short, and when a new version of the app really comes out, it tells you once. It has its own page in Settings, where you turn it on or off. To make it jump on Space, the app needs Input Monitoring.

### Changed
- The app is now called pikapik. Everything you set up stays: permissions, settings, the login item, and the Shortcuts links, both the new `pikapik://` and the old `pika-tools://`. The app moves itself to its new name on the first launch.
- If you installed it with Homebrew, run `brew update && brew upgrade --cask pikapik` once. Homebrew knows the new name and moves the app for you.

### Fixed
- The update check no longer says a new version is out when you already have the latest one. Versions are compared part by part, so 1.26.10 counts as newer than 1.26.9.
- The Permissions page no longer keeps your Mac busy. Its little picture used to redraw the whole page many times a second. Now the picture moves on its own, without redrawing anything, and rests while the window is hidden.

## [1.26.2] - 2026-10-08

### Changed
- What’s New in Settings › About now opens the What’s new page in the language of the app, with a picture for every update, instead of this list.
- This list is tidier: every version shows the day it came out and links to its release, and the top of the page leads to What’s new in every language.
- Homebrew updates come only from the dev-pikapik/pika-tools tap. If you added it long ago with the two-step `brew tap` command that pointed at this repository, run `brew tap --custom-remote dev-pikapik/pika-tools https://github.com/dev-pikapik/homebrew-pika-tools` once.

### Fixed
- Version links in this list that led nowhere now open the right release.

## [1.26.1] - 2026-10-08

### Changed
- The pictures on the Games page now play. Behind each Game Mode switch a little game runs: keys appear and get pressed, and what would pop up over the game shows, like Spotlight or Mission Control, while the game stops. With the switch on, the keys only glow softly and the game keeps going. Flipping a switch shows the difference at once. The game follows the look of your Mac: a sunny day in light mode, a calm night with the moon and stars in dark mode. The keys are the ones set on your Mac.
- In every picture in the app, the pointer moves like a hand: it takes longer over long distances, comes to rest, and only then clicks, and a picture that starts over glides back to the beginning instead of jumping. The pictures rest while the window is hidden, and with Reduce motion turned on they stand still.

## [1.26.0] - 2026-10-08

### Added
- A way to say thanks. At the bottom of About there is now a quiet line, “Made with care · Buy me a coffee”. It opens buymeacoffee.com/pikapik in your browser, and everything goes into developing and supporting the app. Nothing pops up or reminds you, ever. The README has the same link, and GitHub shows a Sponsor button.
- Clean up permissions left by deleted apps. When you delete an app, macOS keeps the permissions you gave it, and System Settings has no way to remove them. Now Permissions has a list called “Left by deleted apps”: each app with its icon, what it was allowed to do and when. Remove clears one app, Remove All clears them all, and an app you install again will simply ask again. To see the list, give pika-tools Full Disk Access; it only looks until you press Remove.

### Changed
- A new app icon: the pikapik mark in blue, violet and coral on a dark tile. The menu bar shows the same shape and follows a light or dark menu bar. When every tool is off, the shape turns pale.
- The pictures on the Animations and Games pages are drawn anew for their size, so they look sharp. A window shrinks into the Dock with round corners, like on a real Mac. The pointer clicks first, and only then a menu or a window opens. Spotlight, the app switcher and the emoji panel are see-through glass, as in macOS Tahoe.

### Fixed
- Clicking a system shortcut now takes you straight to its own list in System Settings, like Mission Control or Screenshots, not just to Keyboard. If pika-tools can’t pick the list for you, Keyboard Shortcuts still opens, and a short tip next to the keys says which list to click. The tip no longer disappears the moment System Settings opens.

## [1.25.2] - 2026-10-08

### Fixed
- Clicking a system shortcut in Settings opens the right place in System Settings. The Spotlight keys open right on Spotlight. For other shortcuts, System Settings opens on Keyboard, and a short tip next to the keys says where to click, like “Keyboard Shortcuts…”, then “Mission Control”. Cut files in Finder points to “App Shortcuts”. Before, every click ended up on Modifier Keys.

## [1.25.1] - 2026-10-08

### Changed
- Every picture on the Animations and Games pages is big now, the same size as the picture at the top of the page. The pictures still move at the speed you pick.
- Add a Game… shows what’s in your Dock: the apps you keep there and the ones open right now, in the same order. A check mark shows a game is already on the list, and a second click takes it off.
- The tip under the game list talks only about Finder. Picking a game in the list is easier than pulling it out of the Dock, so the Dock no longer offers to remove it.

### Fixed
- A game that sits in the Dock but is closed shows up in the list for adding, Minecraft too.
- The hearts in the small game scenes are no longer cut off at the edge.

## [1.25.0] - 2026-10-08

### Added
- Games: adding a game is easier. Press Add a Game… and pick it from the apps that are open right now, with big icons like in the Dock. One click adds it, or drag the icon into the list. You can also drop a game straight from Finder or the Dock, and the list lights up to show where it goes. Other… still lets you pick any app from a folder.
- Any app can be a game now, including Minecraft that runs on Java. Game Mode remembers the game itself, so other Java apps don’t turn it on. Games you added before carry over.
- Every Game Mode switch has a small picture of what it stops.
- Your own keys for quitting and closing. In Settings → Windows, click the keys next to Quit app or Close window and press new ones. Esc cancels, and ⌫ brings back ⇧⌘Q and ⇧⌘W. If your Mac or the other row already uses those keys, pika-tools tells you and asks first. Game Mode uses your keys too.

### Changed
- Game Mode switches are named in simple words, like “The game doesn’t close” or “Search doesn’t pop up”. The system name, such as Spotlight or Mission Control, sits next to them in gray.
- App names in lists show without “.app”.
- Every shortcut in Settings shows how it is really set up on your Mac. Shortcuts you changed in System Settings show your keys, and the ones you turned off say Off. Click one to open the keyboard shortcuts in System Settings.
- Cut files in Finder follows the Cut shortcut you set for Finder in System Settings.

## [1.24.1] - 2026-10-08

### Fixed
- Animations: the Faster preset never makes anything slower than what you already had. If parts of your Mac were already faster, for example after commands in Terminal, they stay as they are.
- Animations: Restore Defaults and uninstalling pika-tools bring back the values you had before, instead of erasing them.
- Animations: when the Dock doesn’t hide, the switch to hide it automatically sits right under the speed slider, because the Dock speeds up only when it hides. The Dock no longer restarts for nothing while it stays in place.
- Animations: after a change, a line at the bottom of the page says that apps show it once you open them again, with one Restart Finder button. Quick Look and columns now offer the button too, since Finder shows them only after a restart.

## [1.24.0] - 2026-10-08

### Added
- Animations: a new page in Settings for how fast things move on your Mac. One slider speeds up the hidden Dock, new windows, Save dialogs, Quick Look and columns in Finder at once, from as in macOS to instant. Each effect can also be tuned on its own, along with the minimize effect, bouncing icons in the Dock and Finder animations. Every setting has a small live picture that moves at exactly the chosen speed. Restore Defaults and uninstalling pika-tools remove only what pika-tools changed, and values you set yourself in Terminal are shown as they are.

## [1.23.2] - 2026-10-08

### Changed
- Game Mode has a switch for each shortcut now. ⌘Q and ⌘W are separate, and so are Spotlight, Siri, ⌘Tab, Mission Control, App Exposé, switching desktops, ⌃F1–⌃F8, emoji, ⌃-click, swipes, the pointer and the screen. Each row shows exactly the keys it stops, and your earlier choices carry over.
- Key caps of one shortcut sit closer together, and different shortcuts have a little more room between them, so it’s easy to see where one ends and the next begins.

### Removed
- The keyboard language setting in Game Mode. ⌃Space and other ways to switch the language always work, even in a game.

## [1.23.1] - 2026-10-08

### Added
- Speed Test shows how fast your internet is right now: download, upload, ping and responsiveness, and in plain words whether it’s enough for 4K movies, video calls, online games and big downloads. It has its own page in Settings, a row for the menu bar panel and a link for Shortcuts. The check runs on Apple’s servers, and the last result stays until the next one.

### Changed
- Block Control shortcuts is now part of Game Mode: ⌃ works as a plain key only while you play, and as usual everywhere else. In a game, ⌃-click stays a click, and ⌃Space, ⌃ with arrows and other Mac shortcuts with ⌃ don’t fire. It’s on by default; if you had Block Control shortcuts on, it stays on.
- Game Mode recognizes Minecraft. Add the Minecraft Launcher or CurseForge to your games, and Game Mode turns on while Minecraft itself is in front, not while you’re in the launcher.

## [1.23.0] - 2026-10-07

### Added
- Game Mode keeps your Mac from pulling you out of a game. Add your games, and while you play one, Spotlight, Siri, ⌘Tab, Mission Control and swipes between desktops don’t open over it, ⌘Q and ⌘W don’t close it by accident, the pointer stays on the game’s screen, the keyboard language doesn’t change and the screen stays on. Each of these has its own switch, and pika-tools suggests games it finds on your Mac. To leave a game, press ⇧⌘Q; to close its window, press ⇧⌘W. ⌥⌘Esc always works. Off by default, on the Games page.
- Keep Awake has a "Turn off the screen now" button on its page and in the menu bar panel. The Mac keeps working, and the screen comes back when you move the mouse or press a key.

### Changed
- Keep Awake lets you choose what the screen does: stay on all the time, with no screen saver or lock screen, or turn off as usual while the Mac keeps working.
- On Macs without a lid, Keep Awake no longer shows the closed-lid options.

## [1.22.0] - 2026-10-07

### Added
- Home and End go to the start and end of a line while you type. With ⇧ they select up to there, with ⌘ they go to the start or end of the whole text. Terminals, virtual machines and remote desktop apps keep the keys as they are, and you can add your own exceptions. Off by default, on the Keyboard page.
- Delete removes files in Finder: ⌫ and ⌦ (fn ⌫ on a laptop) move the selected files to the Trash, like ⌘⌫. While you rename a file or search, the keys erase letters as usual. Off by default, on the Finder page.

### Changed
- Descriptions in the app and in the README now say what each tool does on its own, without comparing it to another system.

## [1.21.0] - 2026-10-07

### Added
- Convert To works both ways between pictures: any picture your Mac can open, JPEG included, can become JPEG, PNG, HEIC, GIF, TIFF or PDF. The format the file already has is left out of the list.
- Smaller Copy also shrinks BMP pictures and turns FLAC and AIFC sound into M4A.

### Fixed
- Smaller Copy, Convert To and New File now show up on external drives and memory cards too, including ones you plug in later.
- Switching the keyboard language works while the New File name box or the Smaller Copy message is open.
- No more square corners around the list in the menu bar panel in the light theme.

## [1.20.0] - 2026-10-07

### Added
- Scroll direction for trackpad and mouse: pick Natural or Classic for the trackpad and for the mouse wheel separately. The trackpad choice also covers sideways scrolling, the glide after you lift your fingers and the Magic Mouse. When you turn it on, both start the way System Settings has them, so nothing changes until you pick something else.
- Smaller Copy also shrinks GIFs and turns uncompressed sound (WAV, AIFF, CAF) into a much lighter M4A.

### Changed
- Convert To is now its own tool with its own switch, so you can keep only the menu item you need. If Smaller Copy was on, Convert To stays on too.

### Fixed
- Slider labels on the Mouse page no longer break in the middle of a word when the window is narrow.

## [1.19.0] - 2026-10-07

### Added
- “Smaller Copy” in the Finder right-click menu makes a lighter copy of PNG, JPEG, HEIC, TIFF, PDF and video files next to the original. The original stays as it was.
- “Convert To” in the same menu turns pictures into JPEG, PNG, HEIC, TIFF or PDF, videos into MP4, MOV or M4A sound, and sound files into M4A, WAV or AIFF. The menu only lists formats that make sense for the files you picked.
- The mouse wheel can scroll its own way, separate from the trackpad. Handy with Universal Control: pick the same direction on each Mac and the mouse feels the same everywhere.

### Changed
- On macOS 26 and later the speed and scroll sliders are the standard system ones, with the Liquid Glass knob. The fill starts at the usual value, so you can see how far you moved from it.

### Fixed
- Keep Awake stays on through updates and restarts of pika-tools. A timer keeps counting from where it was, and with the lid closed you are not asked for the password again. Quitting pika-tools from its menu still turns Keep Awake off.
- The settings window has a sidebar button at the top again, so a sidebar you dragged shut can be opened back.
- Settings no longer spill over the window edge when the window is narrow and the sidebar is wide.
- The Appearance choice on the General page no longer breaks its labels into single letters in a narrow window.
- The Scroll by lines picture no longer covers the top of its little window.
- Keep Awake no longer starts its timer over when settings sync through iCloud or are imported with the same duration.

## [1.18.2] - 2026-10-07

### Fixed
- Settings: keys in setting texts are now drawn as key pictures instead of symbols, and the texts are shorter.
- Scroll by lines: the distance slider no longer jumps while dragging and moves in clear steps of 20 px in pixels mode.

## [1.18.1] - 2026-10-07

### Fixed
- Settings: a single key picture no longer leaves an empty gap before the setting name.

## [1.18.0] - 2026-10-07

### Added
- Settings › Keyboard: “Block Control shortcuts” has a list of apps where Ctrl keeps working as usual, for example a remote desktop app. The list is saved, synced through iCloud Drive and cleared by Restore Defaults.
- New pictures that move with the switch: Switch language, Block Control shortcuts, Side buttons and New File in Finder.
- Settings › Mouse: “Distance per click” shows a small page that scrolls by the distance you pick, with a dot at the default. In pixel mode it also says how much of the screen height that is.

### Changed
- Shortcuts are shown as keys everywhere: ⌃, ⌥ ⇧, ⌘ Q, ⌘ W, ↩ F2, ⌘ X and the key repeat key.
- Every description in Settings is one short line, and the full sentence moved to the tooltip. The menu bar hints are shorter too.
- One “Distance per click” slider replaces the two wheel sliders, with Slower and Faster at the ends. The tracking speed slider marks the speed the Mac uses by itself.
- Clearer names: “Block Control shortcuts”, “Switch language”, “Cut files in Finder”. The ⌘Q and ⌘W group lost its heading and paragraph.

## [1.17.1] - 2026-10-07

### Fixed
- Finder: ⌘X and ⌘V now move files every time. Before, Finder sometimes did not notice the changed key, and Return, Enter and F2 sometimes did nothing for the same reason.
- Finder: ⌘X, ⌘V, Return, Enter and F2 now also work on the Desktop, not only in Finder windows.

## [1.17.0] - 2026-10-07

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

## [1.16.0] - 2026-10-06

### Added
- Keep Awake: set the timer in days, hours, minutes and seconds. Click a number and type it, press ↑ and ↓ to change it by one, or move between numbers with ← and → or Tab. Ready-made buttons set 15 minutes, 30 minutes, 1 hour, 2 hours or 8 hours in one click.
- Settings › Keep Awake shows when the timer would end, for example “Until tomorrow, 14:07”.
- The links in Settings › About now have icons, like the sections in Settings. GitHub uses the GitHub logo.

### Changed
- The Keep Awake timer can be anything from 1 second to 365 days instead of a number with a unit. A timer you had already set is converted automatically.

## [1.15.2] - 2026-10-06

### Fixed
- The menu bar panel no longer turns grey when pika-tools was already the active app as you opened it.
- Finder no longer shows “New File” twice when a test build of pika-tools was also installed.

## [1.15.1] - 2026-10-06

### Changed
- The menu bar panel shows a short hint under each row again. The full description is still in the tooltip. Keep Awake always shows its status.
- “New File” in the Finder right-click menu no longer has an icon, like the system items.

### Fixed
- The menu bar panel sometimes opened with grey colors instead of your accent color.

## [1.15.0] - 2026-10-06

### Changed
- The menu bar panel is shorter and simpler. All rows sit in one card, each row is a single button without a switch, and descriptions show as a tooltip. Settings, Customize and Quit are now icon buttons.
- The panel now starts with four rows: Block ⌃ Control shortcuts, Switch language with ⌥⇧, Turn off pointer acceleration and Keep Awake. Click the pencil button to show the others. If you had already customized the panel, nothing changes.
- Keep Awake shows its timer in the panel only while it is on.
- Shorter descriptions for Repeat a held key, pointer acceleration, Scroll by lines and Side buttons. Settings › Mouse now says when to use Lines and when Pixels.
- Russian texts now address you politely and consistently.

## [1.14.1] - 2026-10-06

### Fixed
- The menu bar panel showed only its buttons in 1.14.0. All rows are back, and the panel scrolls only when it is taller than the screen.

## [1.14.0] - 2026-10-06

### Added
- Choose which rows the menu bar panel shows: click Customize…, untick what you don't need, click Done. Hidden rows keep working and stay in Settings.

### Fixed
- The menu bar panel no longer runs off the bottom of the screen. When it doesn't fit, it scrolls.

## [1.13.0] - 2026-10-06

### Added
- Scroll by pixels: on the Mouse page, choose Lines or Pixels. In Pixels mode every click of the wheel scrolls exactly 1 to 200 pixels, for apps and games that count scrolling in pixels.

## [1.12.0] - 2026-10-06

### Added
- Buttons for Keep Awake, the display and the lid-closed mode in Control Center, the menu bar or a desktop widget, through the Shortcuts app. Copy a link in Settings › Keep Awake and paste it into a shortcut with Open URLs.

## [1.11.0] - 2026-10-06

### Added
- **New File** in the Finder right-click menu, on the Desktop too: pick it, type a name and get an empty file. Plain text by default. Turn it on in Windows & Apps.
- Right-click the pika-tools icon in the menu bar for a quick menu: Keep Awake, Settings, updates, About, Open at Login and Quit.

### Fixed
- Quit when the last window closes now also reacts to the close button and ⌘W, and checks twice before quitting.

## [1.10.1] - 2026-10-06

### Fixed
- Quit when the last window closes works in apps that keep a closed window in the background, such as Books. Windows on other desktops and in the Dock still keep the app open.

## [1.10.0] - 2026-10-06

### Added
- **Repeat a held key** on the Keyboard page: hold a key and the letter types again and again, like on Windows, instead of the accent menu. Handy in games. Open apps pick it up after a restart.

### Changed
- The Settings window has a minimum size, and every page fits down to it without overlapping.
- The Settings toolbar is translucent like in System Settings, content scrolls under it.

### Fixed
- ⇧⌘Q and ⇧⌘W quit and close again when ⌘Q and ⌘W are protected.

## [1.9.0] - 2026-10-06

### Added
- **Scroll by lines** on the Mouse page: every click of the wheel scrolls the same number of lines, 1 to 10, however fast you spin it, like on Windows. Mice only, natural scrolling is kept.
- Sliders show their value as a number you can type or change with arrows, with Slow and Fast at the ends.
- **Export Settings…** and **Import Settings…** on the General page save all settings to a file and load them back. Import asks first.
- **Sync settings with iCloud** keeps settings the same on all your Macs through iCloud Drive. Off by default.

### Fixed
- Side buttons no longer press ⌘[ and ⌘]. In Apple apps and many other apps they go back and forward like a swipe on the trackpad; apps that handle these buttons themselves get buttons 4 and 5 unchanged.

## [1.8.0] - 2026-10-06

### Added
- Mouse page in Settings. **Turn off pointer acceleration** makes the pointer move exactly as far as the mouse, with its own tracking speed slider. Mice only, the trackpad stays as it is, and macOS gets its own settings back when you turn it off or quit.
- **Side buttons go back and forward**: mouse buttons 4 and 5 work like ⌘[ and ⌘] in every app, with an option to swap them.
- **Restore Defaults…** at the bottom of every Settings page. It asks first, then turns off the tools on that page and puts their options back.

### Changed
- Keyboard and Mouse are now separate pages in Settings, like in System Settings.
- The Permissions page shows the same Accessibility and Input Monitoring icons as System Settings.

## [1.7.0] - 2026-10-06

### Added
- The app is now available in Romanian, Polish, Turkish, Dutch, Swedish, Czech, Traditional Chinese, Arabic, Hindi, Indonesian, Vietnamese and Thai.
- README in 23 languages.

## [1.6.0] - 2026-10-06

### Changed
- Language switching with Option+Shift works like on Windows: hold one key and tap the other to switch, as many times as you need, without letting go of both.

## [1.5.2] - 2026-10-06

### Fixed
- Accessibility and Input Monitoring stay allowed after updates. Test builds now use their own bundle ID, so they can no longer take over the permissions or the login item of the installed app.
- "Open at login" survives updates through Homebrew and always points to the installed app.

## [1.5.1] - 2026-10-06

### Changed
- The Settings window can be resized in width and height, from 700 × 500 to full screen. Rows move their controls below the title when space is tight, and long translations wrap instead of being cut off.
- The Settings window remembers its size and position between launches.
- The Settings sidebar is narrower and always stays visible.

## [1.5.0] - 2026-10-06

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

## [1.4.1] - 2026-10-06

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

## [1.4.0] - 2026-10-06

### Added
- Settings window in the style of System Settings: General, Keyboard & Mouse, Keep Awake, Permissions and About, with search in the sidebar. Opens with Settings… or ⌘, in the menu, or when you launch the app again.
- Keep Awake: keeps the Mac from sleeping for 15 minutes up to 8 hours or until you turn it off, optionally with the display on. On a MacBook it can also work with the lid closed (asks for an administrator password) and stop when the battery drops below 20%.
- Appearance: System, Light or Dark, applied right away to the menu and the Settings window.
- Language picker: any of the 11 languages or the system one, applied after a restart.
- Option to turn off automatic update checks.

### Changed
- The menu is simpler: tools, Keep Awake, Settings… and Quit. Open at Login moved to Settings › General.
- The permissions window became the Permissions page in Settings. The menu shows Permissions needed only when something is missing.

## [1.3.0] - 2026-10-06

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

[1.27.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.27.0
[1.26.2]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.26.2
[1.26.1]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.26.1
[1.26.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.26.0
[1.25.2]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.25.2
[1.25.1]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.25.1
[1.25.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.25.0
[1.24.1]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.24.1
[1.24.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.24.0
[1.23.2]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.23.2
[1.23.1]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.23.1
[1.23.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.23.0
[1.22.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.22.0
[1.21.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.21.0
[1.20.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.20.0
[1.19.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.19.0
[1.18.2]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.18.2
[1.18.1]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.18.1
[1.18.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.18.0
[1.17.1]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.17.1
[1.17.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.17.0
[1.16.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.16.0
[1.15.2]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.15.2
[1.15.1]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.15.1
[1.15.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.15.0
[1.14.1]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.14.1
[1.14.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.14.0
[1.13.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.13.0
[1.12.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.12.0
[1.11.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.11.0
[1.10.1]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.10.1
[1.10.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.10.0
[1.9.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.9.0
[1.8.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.8.0
[1.7.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.7.0
[1.6.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.6.0
[1.5.2]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.5.2
[1.5.1]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.5.1
[1.5.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.5.0
[1.4.1]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.4.1
[1.4.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.4.0
[1.3.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.3.0
[1.2.1]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.2.1
[1.2.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.2.0
[1.1.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.1.0
[1.0.2]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.0.2
[1.0.1]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.0.1
[1.0.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.0.0
