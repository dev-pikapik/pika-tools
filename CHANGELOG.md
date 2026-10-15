# Changelog

Every update to pikapik, version by version. The same news, told simply with a picture, is in [What’s new](docs/whats-new/README.md), also in your language: [Русский](docs/whats-new/README.ru.md) · [Українська](docs/whats-new/README.uk.md) · [Deutsch](docs/whats-new/README.de.md) · [Français](docs/whats-new/README.fr.md) · [Español](docs/whats-new/README.es.md) · [Italiano](docs/whats-new/README.it.md) · [Português (Brasil)](docs/whats-new/README.pt-BR.md) · [日本語](docs/whats-new/README.ja.md) · [简体中文](docs/whats-new/README.zh-Hans.md) · [한국어](docs/whats-new/README.ko.md) · [Română](docs/whats-new/README.ro.md) · [Polski](docs/whats-new/README.pl.md) · [Türkçe](docs/whats-new/README.tr.md) · [Nederlands](docs/whats-new/README.nl.md) · [Svenska](docs/whats-new/README.sv.md) · [Čeština](docs/whats-new/README.cs.md) · [繁體中文](docs/whats-new/README.zh-Hant.md) · [العربية](docs/whats-new/README.ar.md) · [हिन्दी](docs/whats-new/README.hi.md) · [Bahasa Indonesia](docs/whats-new/README.id.md) · [Tiếng Việt](docs/whats-new/README.vi.md) · [ไทย](docs/whats-new/README.th.md).

## [1.52.1] - Unreleased

### Added
- Player, website version: every format on the Player page is now a button that shows the app opening it. Click it to give that format to pikapik Player, click again to give it back to the app it had. **Open All in pikapik** does all formats one after another and becomes **Restore Previous Apps** once they are all the player’s. macOS asks about each format, both ways, and the next one is asked only after you answer; “Keep …” moves on to the next. What each button shows is read from the system, so an answer of Keep shows correctly, and no answer for 60 seconds stops the run. This replaces the single switch. The Archives switch shares the same code. The line under Open Video… saying it never changes your apps is gone, because the buttons can.
- Player, website version: the control panel is now frosted glass, Liquid Glass on macOS 26 and later and a blurred panel on macOS 14 and 15, and its buttons and times stay readable on a bright picture. While a video plays, the panel hides after 2.5 seconds without mouse movement, and in full screen the pointer hides with it. Any key or a move of the mouse brings them back, and the panel stays on screen while the video is paused or the pointer is over it.
- Player, website version: point at the time bar and a small picture of the video at that spot appears above it, with the time. The pictures are made in the background without interrupting the video and kept only while the window is open. For a sound-only file, or when a picture can’t be made, you see only the time.
- Player, website version: pictures open in the same app. JPEG, PNG, HEIC, AVIF, WebP, JPEG XL, camera RAW, PSD, TIFF, GIF, SVG, ICO, BMP and more show in a dark window like Preview: the picture fits the window, pinch or ⌘+ and ⌘− zoom, ⌘0 fits it again, ⌘9 or a double click shows it at 100 %, drag to move, ⌘R and ⌘L turn it, ← and → go to the next and previous picture, Space or ⇧⌘F starts a slideshow, F is full screen, and GIF, APNG and WebP move. The window has no grey title bar: the window buttons, the name with “3 of 12” and the glass panel at the bottom appear when you move the mouse and fade together, and you can drag the window by the picture. A big picture appears at screen size first and in full size only when you zoom in, so memory stays low; a broken file shows a message. A new **Pictures** group on the Player page works like the video one: every format is a button, **Open All in pikapik** gives them all to the player and **Restore Previous Apps** gives them back, to Preview if nothing was remembered. Open a single picture and press → or ←: after you allow access to its folder once, you page through the pictures next to it. A folder without pictures says so, and a tiny file that claims billions of pixels still opens without filling the memory.
- Player, website version: songs. MP3, AAC, M4A, FLAC, ALAC, WAV, AIFF, CAF, Ogg, Opus, WMA, APE and DSF play in the same window, with the cover (blurred behind it), the title, the artist and the album from the file, and the same keys, speed and panel. Open a folder, or drop it on the window, and it plays from the first song; **Next in Folder** and **Previous in Folder** (N and P) go through the songs by name, 2 before 10, and the next song starts by itself when one ends. The player can read a folder only after you allow it: the first time macOS shows an **Allow** sheet, and the choice is remembered. The Mac’s Now Playing and the media keys show the song and control play, pause, next, previous and the position. On the Player page the formats are now in two groups, Video and Music, each with its own buttons and **Open All in pikapik**. If the app a song type had before is gone, giving it back chooses Music.

### Changed
- Side buttons: the picture in Settings shows back and forward arrows instead of the numbers 4 and 5, and the rows say rear button and front button instead of button 4 and button 5.
- Clearer short subtitles: Quit app and Close window now say what the switch does when it is off, the retype row says that the keyboard switches to the right language, and the Mac App Store Show hidden files row says “Press in Finder to show or hide”.

### Fixed
- One main copy: if pikapik stopped unexpectedly while one of its settings was on, the next launch no longer takes pikapik’s value for yours. Animations, Hide the Dock automatically, hot corners, Repeat a held key, Keep the Dock on one display, Hide desktop icons and Show hidden files remember your own value before they change anything and put it back later. Hide the Dock automatically now also goes back as it was when pikapik quits. Only the main copy changes the brightness of external displays, the app that opens archives, Finder extensions and settings from your other Macs, and only the main copy checks for updates and offers them; a copy that is not the main one quits without turning off Keep Awake.
- Side buttons: the mouse Forward button no longer presses a menu item called Forward that has a letter shortcut, such as forwarding an email in Outlook or Mail. It also no longer goes back twice when an app is busy and answers late.
- Second copy of pikapik: Make This Copy the Main One now works once per press, so a fast double click can’t open two new copies. The note names the main copy as the website or Mac App Store version instead of a file path, and the window title is pikapik instead of the last page you looked at.
- Retype words you typed in the wrong language and Home/End, website version: if pikapik stopped unexpectedly, Chrome, Slack, VS Code and other apps built on Chromium stayed in the mode pikapik had switched on to see their text fields. pikapik now remembers each app it switched, and the next launch of the main copy puts it back in the apps that are still open.

### Changed
- Player, website version: the window no longer has the usual grey title bar. The video fills the whole window, and the three round buttons sit on top of it. They show and hide together with the control panel: they fade out after 2.5 seconds without mouse movement while a video plays, stay while it is paused, and over a video a thin dark shade under them keeps them readable on a bright picture; a song and a file that can’t be played keep the buttons without the shade. Hidden buttons ignore the mouse until it moves. Drag the window by any spot of the video, also with the very first click on a window that was not active; a double-click on the video still goes full screen, a double-click on the thin strip at the very top does what System Settings says for window title bars, and in full screen the Mac handles the menu bar and the buttons as before.

## [1.52.0] - 2026-10-15

### Added
- One main copy: when two copies of pikapik are open, such as the website one and the App Store one, only the one opened last changes anything on your Mac, so what Settings shows now matches what the Mac really has. The other copy puts back what it changed, hides its menu bar icon and shows a short note in Settings with a Make This Copy the Main One button, and it takes over when the main copy quits. Quitting or removing pikapik now also puts back Hide desktop icons, Show hidden files, hot corners, Animations and Repeat a held key, and the Animations page shows the real state of the Mac.
- Player, website version: it now behaves like QuickTime Player. On pause, ← and → step one frame; while playing they jump 5 seconds (⇧← and ⇧→ always do), J and L jump 10, K plays and pauses, , and . step a frame, ⌥← and ⌥→ go to the start and the end, M mutes, ↑ and ↓ change the volume. Scroll up or down for volume and sideways (or hold Shift and scroll) to skip; a light touch does nothing. Every key has the same menu item.
- Player, website version: a new Speed menu with 0.5×, 0.75×, 1×, 1.25×, 1.5× and 2×, with the pitch unchanged. ⌘← and ⌘→ (or [ and ]) change the speed, ⌫ goes back to 1×. The speed stays when you skip.
- Player, website version: Save Frame… (S) saves the picture on the screen as a PNG named after the video and the time. The player can write a file only where you choose in the Save panel.
- Player, website version: the Window menu has Float on Top (T) and, with more than one screen, Move to Display. The player remembers where you stopped in the last 200 videos and continues from there; Start Over begins again.
- Player, website version: the player now declares the MKV, WebM and Ogg video types itself, so Open With finds it even on a Mac with no other video app.
- Mouse: Middle click on the trackpad, in Settings › Mouse. Tap or click with three fingers, and the trackpad works like the middle mouse button: in most browsers that opens a link in a new tab or closes a tab. You can choose four fingers instead. Tapping needs Tap to click in System Settings › Trackpad. If Look up there is set to a three-finger tap, three fingers can only click, and if three-finger drag is on, choose four fingers. The Fingers row under the switch says what works on your Mac. It needs Accessibility and Input Monitoring. To have it in the menu, click the pencil at the bottom of the menu and select it. Not in the Mac App Store version.

### Changed
- Quit app and Close window: each row now has a picture that shows what the keys do. With the switch on, ⌘Q or ⌘W alone is locked and the windows only shake; then the extra key appears, and the app or window goes only with all three keys, ⇧⌘Q or ⇧⌘W, or the keys you chose. With the switch off, the picture shows the usual ⌘Q or ⌘W closing right away.
- Show hidden files, website version: the keys ⇧⌘. now sit in the row itself, in front of the title, like on the other rows with a shortcut, and the line under the title is shorter so it stays on one line.
- Background and Ports, website version: tasks that run for the whole Mac now turn off right in pikapik too, with no trip to System Settings. Background daemons from the shared Library folder get the same Turn Off and Turn Back On buttons as agents, and Remote Login and Screen Sharing can be turned off and back on there. In Ports, “How to free it” for ports 22 and 5900 has a Turn Off button. pikapik remembers what it turned off and Turn Back On restores exactly that. This needs administrator access, which you allow once in Settings › Permissions; the row there was called Fan control and now also covers services. If it isn’t allowed yet, the page says so and points to Permissions. pikapik’s own helper, Apple’s system services and everything outside the shared Library folder stay out of reach. The Mac App Store version is unchanged.
- Settings: the groups in the sidebar now have names, like in System Settings: Mac, Enhancements, Apps and Info. General stays at the top without a name. The pages are the same and in the same order; the names only show what belongs together. Search still lists pages without group names.

### Fixed
- Side buttons, mouse buttons 4 and 5: they now go back and forward in nearly every app, and again in pikapik’s own Settings, where they had stopped working in 1.9.0. Since then pikapik only acted in Apple apps, Firefox, Opera and ForkLift, so apps with a Back arrow in the toolbar or a Back item in a menu did nothing. In the website version pikapik now presses that Back or Forward menu item or toolbar button for you, in any language. Apps that already understand the buttons, such as Chrome and the JetBrains apps, still get them as they are. In the App Store version, which may not look into other apps, pikapik’s own windows and the Apple apps work, and every other app keeps handling the buttons itself. The Cmd+[ shortcut is not used blindly, because in code editors it moves the text.
- Retype words you typed in the wrong language, website version: in Chrome, Slack, VS Code, Discord and other apps built on Chromium, fixing as you type and the retype shortcut did nothing, because those apps keep their text fields hidden from other programs until they are asked. pikapik now asks once for each such app when you switch to it, so “ghbdtn” becomes “привет” there too. When you turn Layout fix and Home/End off, or quit pikapik, those apps are put back the way they were. Home and End use the same text-field check and now see text fields in these apps as well. If you start typing in the first second after an app launches, that first word may still be left as it was.
- Per-app volume: when you put an app’s slider back to 100%, the hand-back no longer ends with a tiny click and a few milliseconds of silence. The sound now fades out of pikapik’s path in a few milliseconds before the app plays on its own.
- Open With lists pikapik Player right after an update, before the player was opened once.
- Games: The pointer stays in the game now holds the pointer with macOS itself, in the website version. A fast flick no longer slips onto another display, and the pointer no longer jumps back from it: it simply stops at the edge of the game’s display, and hot corners you allowed in games stay in reach. In the website version pikapik no longer moves the pointer anywhere. The Mac App Store version is unchanged: it can’t use that part of macOS, so it still moves the pointer back and keeps it away from hot corners.

## [1.51.0] - 2026-10-15

### Added
- Player, website version: a new page, Settings › Player, for videos that QuickTime can’t open, such as MKV, WebM, AVI, WMV and FLV. Click Open Video…, or right-click a video and choose Open With › pikapik Player, and it plays in its own window: Space plays and pauses, ← and → jump 5 seconds, ↑ and ↓ change the volume, F goes full screen, and a video that is already open comes to the front instead of opening twice. The player is a small separate app with no network access that asks for no permissions, and it doesn’t change which app opens your videos. It uses FFmpeg and dav1d; their licenses and source code are linked on the same page. Subtitles aren’t supported yet. The Mac App Store version doesn’t have it.

## [1.50.3] - 2026-10-15

### Fixed
- Hot corners and Keep the Dock on one display, website version: the Change… menu on a hot-corner row and the Main display menu from 1.50.2 listed every choice three times, and picking one did nothing. Now each choice appears once, the current one has a check mark, and your pick takes effect at once. Put Back and turning the switch off still return everything as it was. The Mac App Store version is unchanged.

## [1.50.2] - 2026-10-15

### Changed
- Background, website version: tasks now turn off right in pikapik, with no trip to System Settings. This works for agents from the shared Library folder (for all users) and for old login items; the row changes at once, no password is needed, and the choice stays after a restart. Turn Back On puts the task back. If it doesn’t work, the row says so in plain words. Tasks for the whole Mac and helpers an app added itself still open System Settings, and a line under the row now says why. The Mac App Store version is unchanged.
- Keyboard layouts, website version: with only one layout, Fix Wrong Keyboard Layout now offers the layouts for your languages right in its note. Pick one under Add a Layout and it is ready at once, with no trip to System Settings and no password. If none fits, Keyboard Settings… is still there. The Mac App Store version is unchanged.
- Hot corners, website version: in Settings › Games, the Change… menu on a hot-corner row picks another action for that corner right there, with no trip to System Settings. The Dock restarts once for each change, the first action is remembered, and Put Back returns it. The Mac App Store version is unchanged.
- Keep the Dock on one display, website version: the Main display row now sits right under the switch as a menu. Pick a display there and it becomes the main one, with the Dock on it, with no trip to System Settings. Your first arrangement of displays is remembered, and turning the switch off puts the displays back exactly as they were. The Mac App Store version is unchanged.

### Fixed
- Keep Awake: with “Always on” saved and Keep Awake off, the menu said it would end on a date. It now says it stays on until you turn it off.
- Menu bar: when the Keep Awake options close, the rows no longer slide under the bottom buttons.
- Sound: the missing-permission note is now one clear sentence.
- Background: when two items have the same name, such as two copies of pikapik, each row shows its version.
- Game Mode: a game you already added, such as Minecraft, is no longer suggested again.
- Settings: tab descriptions all end the same way, without a full stop, in all 23 languages.
- New dots for per-app volume and Ports also show in the website version.
- Minimize or hide with a click in the Dock: if you turned it on while it was set to minimize the windows, it no longer switches itself to hiding the app after the next restart.
- Settings sync: when you open pikapik, it now checks for settings changed on your other Mac, so a Mac that missed the change catches up at once.

## [1.50.1] - Unreleased

### Added
- Mac App Store version, wrong keyboard layout: **Fix words as you type** is here too. Turn it on in Settings › Keyboard, and a word typed in the wrong layout, such as “ghbdtn”, becomes “привет” when you press Space or Return, and the layout switches. Press ⌃⇧Space right after a fix to undo it; that word is then left as you typed it. It needs Accessibility, which Settings › Permissions asks for, and it stays off in password fields, in apps you exclude and while a game is playing.

## [1.50.0] - 2026-10-15

### Added
- Mac App Store version, Archives in Finder: right-click an archive and choose Extract, or right-click files and folders and choose Create Archive… (ZIP, 7Z, TAR.GZ or TAR.XZ), and press Space on an archive to see the files inside, as in the version from the website. It works with the tools built into macOS instead of the bundled 7-Zip, so it has limits: only ZIP can have a password, an archive can’t be split into parts, split sets (.001, .part1.rar, .z01) and single .xz, .lzma and .zst files can’t be opened, password-protected 7Z and RAR can’t be opened, and there is no Open archives with this app switch. The first time, it asks for access to your home folder, the same as New File and Smaller Copy, and the Finder items need the extension turned on in System Settings › General › Login Items & Extensions. The progress bar now moves while an archive is unpacking and a wrong password is reported at once instead of after a pause (the version from the website gets this too), the switched-off password option for 7Z says why, and the “can’t be opened” message lists what this version can’t open. The hint in Settings now says which formats can have a password, and the Mac no longer falls asleep in the middle of unpacking or creating an archive (the version from the website gets this too).
- Mac App Store version, Keep Awake: **Turn off the display now** is here too, in the menu and in Settings › Keep Awake. The display goes dark at once while the Mac keeps working; move the mouse or press a key to bring it back.
- Mac App Store version: where macOS doesn’t let the app change a setting itself, a short animation now shows where to click in System Settings: Animations, Hide desktop icons, pointer acceleration, Permissions and Open at Login. The labels in the animation are taken from your Mac, in its language. Reduce Motion in both versions also gets the animation, and when Reduce Motion is on you see one still frame with the click marked.
- The animation that shows where to click in System Settings now also covers keyboard shortcuts you change in System Settings › Keyboard and turning on the Finder extensions in Login Items & Extensions. The Reduce Motion button now opens the Motion page itself, not Display.
- Mac App Store version, wrong keyboard layout: select the text and press ⌃⇧Space to fix it, no need to open the Services menu. Turn the shortcut on in Settings › Keyboard, where you can also change it. It needs Accessibility, which Settings › Permissions asks for; the Services menu still works without it.
- Mac App Store version, Permissions: Settings › Permissions now shows which installed apps can ask for Camera, Microphone, Automation, Files and Folders and Bluetooth, each with its icon. Who is allowed is still shown only in System Settings, because macOS hides it from this version.
- Settings › About › Report a Problem now opens the bug form with the edition and version of pikapik already chosen. The bug and feature forms also ask which feature the report is about and where you got pikapik: Mac App Store, Website, GitHub or Homebrew.
- Mac App Store version, Home and End: the keys go to the start and end of a line again. They work everywhere except browsers, Finder, Music and TV, because this version can’t see which field has focus.
- Mac App Store version, Hide desktop icons: it is now a real switch, in Settings › Finder and in the menu bar panel, and it needs no permission. pikapik covers the icons with your wallpaper on every display, or with a plain color if your wallpaper moves, and clicks still reach the desktop. The files stay in the Desktop folder in Finder. Below the switch, the animation and the Open button still lead to Desktop & Dock in System Settings, as a second way.
- After an update, Settings shows what is new: a small dot after the name of a tab that got something new, and a New tag beside the feature itself. The dot goes when you open the tab, the tag when you leave it, and everything goes by itself 21 days after the update. A fresh install shows none. The gear button in the menu bar panel gets the same dot until you open Settings once. A mark you have seen never comes back, not after a relaunch, a downgrade or a second copy of the app.
- App Volume: an app you set now stays in Settings › Sound with its slider, dimmed while it is closed, so you can set its volume before it starts. Its level and mute are applied again when it plays sound after you reopen pikapik or restart the Mac. Click Add App… or drag an app in from Finder to add one, and click the ✕ next to an app to forget it and return it to full volume. Apps with the same name show their folder. Before, a closed app was not in the list after pikapik was reopened, so its volume could only be set while it played sound.

### Changed
- Ports now explains itself: a line under the title says what a port is, a small animation shows that only one program fits at a door, the search box says “Type a number, like 3000”, and a note under the list says that the globe means other devices on your network can connect. The sections are called “Programs you started” and “Not yours: leave these alone”. Programs without an icon, such as console tools, get a plain terminal tile. Only programs that wait for connections are listed, so programs that merely send or receive UDP no longer appear. Its tile in the sidebar is blue.
- The top of Sound, Keyboard, Mouse, Dock, Finder and About now says what you get there, for example “Scrolling, side buttons and pointer speed” instead of “Fixes for the mouse”.
- “Keep running after Quit” is now “Stay in the background after Quit”, with the line “Shortcuts and Keep Awake keep working. Hold Option to quit completely” under it.
- Keyboard: the wrong-layout row is called “Retype words you typed in the wrong language”. Mouse: the hint under the speed graph says “The dot marks your Mac’s normal speed”. Games: “Not a Game” is now a quiet “Ignore” button. Speed Test: before the first test the page says “Press Check Speed to find out”.
- The sidebar in Settings now has gaps between its groups: General, then the Mac (Battery to Ports), then fixes (Sound to Animations), then apps (Uninstaller to Pet), then Permissions and About. The order of the tabs is the same as before.

### Fixed
- Mac App Store version, Finder: after ⌘X, ⌘V now moves the files, as in the version from the website. Before, ⌘V pasted a copy and the files stayed where they were, so cutting worked like copying. The Move Items Here button in the pikapik menu is gone, ⌘V does its job.
- Mac App Store version, Finder: the New File, Smaller Copy and Convert switches now each show whether their own item is turned on in System Settings. Before, turning on one of them made all three look on, so New File could stay missing from the right-click menu with its switch on, and Settings › Permissions didn’t ask to turn it on.
- Ports: on macOS 27 the page could call a port free while a part of macOS or another user held it, because macOS no longer shows their programs to apps. Now pikapik checks the port itself and says it’s taken by macOS or another user.
- Mac App Store version: Settings › Ports is gone. There macOS doesn’t let an app see which program holds a port, so the page stayed empty.
- Games: with two copies of pikapik open at once, for example the Mac App Store version and the version from the website, ⇧⌘Q and ⇧⌘W in a game did nothing. One copy turned them into ⌘Q and ⌘W, and the other copy stopped those as an accidental quit, so the game neither quit nor closed its window. Now the copies let each other’s ⌘Q and ⌘W through.
- With two copies of pikapik open at once, a setting turned on in both no longer undoes itself. Before, both copies did the same job one after the other: Swap the side buttons swapped them twice, so they stayed as they were; the scroll direction flipped twice; and the language switch and the language keys in games switched twice, back to the language you started from when you have two. Wrong keyboard layout could also fix the text the other copy had just retyped. Now one copy does the job and the other lets it through.
- Mac App Store version, Temperature: on a Mac with a battery, the page now shows the battery’s temperature in degrees, with a bar that turns green, yellow or orange, under the overall word. Before, the page showed only that word and a tip and no numbers, so it looked empty. A Mac without a battery still shows the overall level.
- Mac App Store version, Battery: on macOS 27 the page shows the battery’s Maximum Capacity again. macOS 27 moved that number to another place, so the page showed only the cycle count. The number may differ by 1% from System Settings, which smooths it over weeks.
- Mac App Store version, Game Mode: the list of Mac shortcuts that use ⌘, such as Spotlight on ⌘Space, was empty, so nothing was paused in a game. pikapik now reads them again and pauses them while a game is in front, as the version from the website does. Shortcuts without ⌘ and mouse shortcuts are still left out of the list here.
- Games: in the Mac App Store version, Game Mode now keeps the pointer a few points away from the screen corners while you play, so hot corners don’t go off. That version can’t switch hot corners off, so before, a brush against a corner could still set one off. Game Mode also turns back on by itself after the Mac wakes up or you switch back to your user account. Before, it came back only after you switched to another app.
- Make a Smaller Copy now makes videos about half the size. Before, almost every video got “Already compact” and no copy was made, because the copy came out bigger than the original. A video that is already very small still gets “Already compact”. Photos were not affected.
- Battery: the icons in the list now line up in one column. If the page is opened on a Mac without a battery, it says “This Mac has no battery” instead of staying empty.
- Keep Awake: the top of the page said “Your Mac stays awake until you quit pikapik” even when Keep Awake was off, and the time row said “Until …” as if it were running. The top now says what Keep Awake is for, and the row says “If turned on now, ends …”.
- Permissions: the top of the page said “All set” while some tools still lacked a permission. It now says “Both permissions are on” until every tool has what it needs. The bar over the grey tools now names the missing permission and what it is for, instead of “Grey tools need a permission”.
- Ports: in German and other long languages the Free Up button was cut off in a narrow window. It now keeps its full width, and the button that shows how to free a port is called “How to Free It”, so the two no longer look alike.
- The Permissions needed button in the menu bar panel and the right-click menu now appears only while a tool you switched on lacks a permission. Before, it showed whenever Accessibility or Input Monitoring was off, even if you had switched nothing on, and also in the Mac App Store version, where Settings says only some tools need these permissions.
- First launch no longer asks for permissions before you switch anything on. Before, the version from the website showed the Accessibility and Input Monitoring prompts at once and opened Permissions. Now it opens General Settings the first time and asks only when you click a grey tool that needs one. Permissions you already gave stay on.
- Menu bar panel: opening or closing a row, such as the display options under Keep Awake, no longer makes a scrollbar flash for a moment. The scrollbar now shows only when the rows really don’t fit on your screen. The arrow next to Keep Awake now says what it opens, Display settings, and VoiceOver tells whether it is open.

## [1.49.0] - 2026-10-13

### Added
- Brightness: a new page, Settings › Brightness, for monitors that macOS can’t adjust on its own. Each of them gets a slider, and the same sliders can be added to the menu bar panel as a Brightness row. pikapik changes the monitor’s own brightness, like its buttons do. If a monitor doesn’t respond, turn on Dim the picture instead: the picture gets darker, but never black. Some monitors restart when they get a brightness command: if a monitor disappears right after one, pikapik turns on Dim the picture instead for it by itself. pikapik remembers each monitor’s level and sets it again after sleep and when the monitor is connected again. In the Mac App Store version the slider dims the picture.
- Brightness keys: turn them on in Settings › Brightness, and the brightness keys on your keyboard adjust the monitor under the pointer, with a small indicator on that screen. Hold ⌥⇧ for finer steps. The keys need Accessibility from Settings › Permissions; the sliders work without it.

### Fixed
- Settings: VoiceOver can now turn the switches in Settings on and off. Before, it read each switch’s name twice, and pressing a switch did nothing.

## [1.48.0] - 2026-10-13

### Changed
- Dock: Keep the Dock on one display now turns off the Dock’s own move between displays, so the Dock stays on its display however fast you move the mouse. Before, pikapik pushed the pointer back from the bottom edge of the other display, and a quick flick could still move the Dock. pikapik no longer touches the pointer. To move the Dock on purpose, make another display the main one: Main display under the switch opens System Settings › Displays. The Dock reads this setting only when it starts, so turning the switch on or off restarts the Dock once, and if the switch was on, the Dock restarts once after the update.

### Removed
- Dock: Bring the Dock back. It also worked by pushing the pointer, and the Dock no longer follows the pointer.
- Mac App Store version: Keep the Dock on one display, because apps from the App Store can’t change the Dock’s settings.

## [1.47.0] - 2026-10-13

### Added
- Desktop icons and hidden files: two new switches on the Finder page in Settings. Hide desktop icons clears the files and folders off the desktop before a call, a screen recording or a screenshot, and brings them back to the same places when you turn it off. Nothing moves: the files stay in the Desktop folder, and the switch always matches Show items › On Desktop in System Settings › Desktop & Dock. Show hidden files shows the files and folders macOS hides, dimmed in Finder and on the desktop, the same as pressing ⇧⌘. in Finder. To apply it, Finder restarts for a moment and reopens its windows and tabs, and if Finder is copying or moving files, it waits until they are done. To have them in the menu, click the pencil at the bottom of the menu and select them. In the Mac App Store version, Hide desktop icons opens Desktop & Dock in System Settings, and the Finder page shows the ⇧⌘. keys instead.

## [1.46.1] - 2026-10-13

### Fixed
- Permissions: once both permissions at the top are on, the header no longer says every tool is working while a tool under For some features still needs its permission. It now says that some tools also need a permission from the list below.
- Mac App Store version: Say thanks on the About page appears only once the App Store has sent the tips. It no longer shows a spinning wheel while they load, and it no longer appears and then vanishes when the App Store doesn’t answer.
- Archives: if the disk fills up while an archive is being unpacked, Not enough space now shows how much space is really free once the half-unpacked files are removed. Before, it could say that almost nothing was free.

## [1.46.0] - 2026-10-13

### Added
- Mouse: Mouse button hides the current app, in Settings › Mouse. Turn it on and press the mouse button you want to use, such as the middle button or a side button; Change… picks another one later. From then on one press hides the app in front, like ⌘H. The app keeps running, and a click on its icon in the Dock brings it back. While you play with Game Mode on, the button does what it always did in the game. If Side buttons go back and forward is also on, the side button you picked hides apps instead. It needs Accessibility and is off by default.
- Mac App Store version: ⌘X cuts files in Finder. Select files and press ⌘X, open the folder you want them in, then click the pikapik icon in the menu bar and choose Move Items Here, or press ⌥⌘V. The button appears only while Finder is in front and files are waiting to be moved. ⌘V is not changed in this version: it still pastes a copy. ⌘C cancels the cut, and while you rename a file, ⌘X and ⌘V work on its name as usual.
- Mac App Store version: Settings › Permissions has a new section, Left by deleted apps. When you delete an app, macOS keeps the permissions you gave it. The section has a button for each list where that can happen, such as Accessibility, Screen Recording, Camera and Microphone, and each button opens that list in System Settings.
- Mac App Store version: Settings › Animations and the Turn off pointer acceleration row in Settings › Mouse are back. This version can't change these settings itself, so each row explains what to change and its Open button takes you to the right place in System Settings.

### Changed
- Mac App Store version: the pet walks across the whole width of the screen above the Dock and no longer stops short of the Dock’s ends.
- Mac App Store version: the Battery page reads the battery’s maximum capacity and condition straight from macOS and no longer starts another program to do it.
- Mac App Store version: Background Tasks no longer has the Open at Login group. These apps are listed in System Settings › General › Login Items.
- Mac App Store version: Free Up in Ports no longer copies a Terminal command. It shows the app that holds the port or opens Activity Monitor, where you can quit the program.
- Mac App Store version: the top of the Permissions page now says that only some tools need these permissions and everything else works without them.

### Fixed
- Mouse: the drawings on the Mouse page are sharp again.
- Permissions: on macOS 27, Accessibility appears under its new name, Device Control and Data Access, the same as in System Settings.
- Switch language: it now shows when it needs Input Monitoring, and a click on the row opens the Permissions page. Before, it stayed on without working.
- Permissions: keyboard and mouse features now ask only for the permission they really use. Most need only Accessibility; before, they also asked for Input Monitoring and stayed grey without it.
- Quit when the last window closes: it now waits until you allow Input Monitoring, instead of making macOS ask for it when pikapik starts.
- Speed Test: in the Mac App Store version, the caption says the check takes about 15 seconds and uses speed.cloudflare.com. Before, it said the check runs on Apple’s servers.
- Pet: with VoiceOver, you can pick the pet’s clothes and looks in Wardrobe and Looks and open its Awards. Before, those tiles didn’t respond.

## [1.45.0] - 2026-10-13

### Added
- App Volume: every app that plays sound gets its own volume slider and a mute button, in Settings › Sound and in the menu bar panel. Lower a loud video call, mute a noisy game and leave the music as it is: the volume of your Mac and of the other apps does not change. pikapik remembers the level of each app, and an app you leave at full volume is never touched. To change an app’s volume, pikapik passes its sound through itself, so it needs the System Audio Recording permission, which you allow on the Permissions page. The sound is not recorded, saved or sent anywhere, and the microphone is never used. It is off by default, it is in the Mac App Store version too, and it needs macOS 14.2 or later: on macOS 14.0 and 14.1 it is hidden.

## [1.44.3] - 2026-10-13

### Added
- Wrong keyboard layout: a word typed in the wrong layout, like ghbdtn instead of привет, is retyped in the right one as soon as you press Space or Return, and the layout switches so the next word comes out right. It works with every keyboard layout added on your Mac. A word changes only when it isn’t a word in any of your languages and the same keys in another layout give a common one, so names, typos, rare words, password fields, Terminal and the apps you choose stay as they are. ⌃⇧Space fixes the last word or the selected text, pressing it again tries your other layouts, and right after a fix the same keys undo it, after which pikapik leaves that word alone. Turn it on in Settings › Keyboard; it needs Accessibility and Input Monitoring, which the Permissions tab asks for. In the Mac App Store version, select the text and choose Fix Wrong Keyboard Layout in the Services menu.

## [1.44.2] - 2026-10-13

### Fixed
- Menu: on macOS 27, VoiceOver and other accessibility tools open the pikapik menu in the menu bar again. Pressing the icon opens the menu, and pressing it again closes it, just like a click. This fix is not in the App Store version.

## [1.44.0] - 2026-10-13

### Added
- Ports: a new Ports page in Settings shows every program that has taken a port on the Mac, with its icon, the TCP and UDP ports and whether other devices on the network can connect. Type a port number to find who holds it or to see that it is free. A row opens the addresses (web addresses open in the browser), the program's file with Show in Finder, the command, the folder, the process ID and when it started. Free Up asks before it quits the program politely and, if the port is still taken after a few seconds, asks again before force quitting it. Programs of macOS and of other users are never quit: for AirPlay Receiver, File Sharing, Screen Sharing, Remote Management and Remote Login the button says which switch in System Settings frees the port. The Mac App Store version lists the same ports; its Free Up menu shows the program, copies a command that quits it in Terminal, or opens Activity Monitor.

## [1.43.0] - 2026-10-13

### Added
- Background Tasks: a new page in Settings lists apps that open at login, background services, helpers inside apps and leftovers of deleted apps. Each task shows the app that added it, whether it runs now and where its file is, and one click shows the file in Finder. Your own tasks turn off and back on with one button, without being deleted. Tasks for all users and for the whole Mac open Login Items in System Settings. The Mac App Store version only shows the tasks, and its buttons open Login Items.

## [1.42.0] - 2026-10-13

### Added
- Temperature: a new page in Settings shows how warm the processor, graphics, memory, storage, battery and Wi‑Fi are. At the top, one word sums it up (Normal, Warm, Hot or Very hot) with a short tip, and each part has its own row with the temperature and a colored bar judged by what is normal for that part. To keep an eye on it, click the pencil at the bottom of the menu and select Temperature: the menu then shows the same word and the processor temperature. pikapik reads the sensors itself, so it needs no password and changes nothing, and it checks them every two seconds only while the page or the menu is open. The Mac App Store version shows the overall heat level that macOS reports.

### Fixed
- Menu: if you picked which rows the pikapik menu shows, Keep the Dock on one display no longer turns up there on its own. It starts hidden like every new row; to show it, click the pencil at the bottom of the menu and select it.
- Fans and Battery: when you close Settings, pikapik stops checking the fans and the battery right away. Before, it kept checking them in the background if Settings was closed on one of these pages.

## [1.41.1] - 2026-10-13

### Changed
- Fan control: the helper that sets the fan speed now updates itself together with pikapik, so new versions no longer ask for the administrator password. This update asks for it one last time: open Settings › Permissions and click Allow next to Fan control. pikapik accepts only a helper signed by its developer and never an older one, and if a check fails, the current helper stays and the fans keep working.

### Fixed
- Login Items: in System Settings › General › Login Items, the fan helper now shows up as pikapik, with the app’s icon.

## [1.41.0] - 2026-10-13

### Added
- Battery: a new Battery page in Settings, only on a Mac with a battery. It shows the charge with a drawn battery, how long until it is full or how long it will last, or that charging is on hold; the battery’s condition (Normal or Service Recommended, with a link to get service); its maximum capacity compared with when it was new; the cycle count, out of the 1,000 it is designed for; the power adapter and its watts; and the watts going into the battery while it charges, or what your Mac uses on battery. It also gives tips to make the battery last: Charge Limit on macOS 26.4 or newer with Apple silicon, or Optimized Battery Charging, each with a button that opens macOS Battery settings; keep the Mac between 10 and 35 °C; and store it at about 50% and shut it down. The page only shows information and never changes how your Mac charges. The charge limit stays in macOS Battery settings.

### Fixed
- Uninstall: `brew uninstall --cask pikapik` now also turns off launch at login and puts back the system settings pikapik changed, such as animations, key repeat and hot corners. Before, Homebrew ran this step in a sandbox that blocked it. Homebrew keeps the steps from the version it installed last, so if pikapik has been updating itself, run `brew upgrade --cask pikapik` once first.

## [1.40.2] - 2026-10-13

### Fixed
- Updates: updating or reinstalling pikapik with Homebrew no longer restarts the Dock, so it no longer disappears for a moment. The update to this version may still restart it one last time, because that step is still done by the version you had before.

## [1.40.1] - 2026-10-13

### Added
- Dock: a click on the Dock icon of the app you’re working in minimizes all its windows, and the next click brings them back in the same order, with the window you were working in on top. Holding an icon for its menu, dragging icons and clicks on other apps work as before. Under the switch you can choose to hide the whole app instead, as with ⌘H. It needs Accessibility, is off by default and is not in the App Store version.

### Changed
- Dock: Hide with a click in the Dock is now Minimize or hide with a click in the Dock. If it was on, it keeps hiding apps as before.

## [1.40.0] - 2026-10-13

### Added
- Dock: Keep the Dock on one display stops the Dock from jumping to another display when the pointer pushes against that display’s bottom edge, or its left or right edge if the Dock is at the side. The Dock stays on its display, hot corners keep working, and no permission is needed, also in the App Store version. To move it on purpose, hold ⌥ and push the pointer against the edge of the other display, and the Dock stays there. A second switch, Bring the Dock back, returns the Dock to its display on its own after sleep or when displays change. It needs Accessibility and is not in the App Store version. Both are off by default: switch them on in Settings › Dock.

## [1.39.4] - 2026-10-13

### Fixed
- Archives: closing the password window with the red button no longer stops pikapik from opening and creating archives until you restart it. The red button now works just like Cancel, in the window for a new archive too.
- Settings: VoiceOver reads the update button in About by its own name instead of the app version.

## [1.39.3] - 2026-10-13

### Added
- Pet: it now follows your rhythm. While you type, it perks up and walks faster, with more spring in its step. After about 40 seconds without the keyboard or mouse it slows down and its eyes grow heavy, and after a minute and a half it sits down and dozes off, with little z’s floating up. Press a key or move the mouse, and it wakes up and walks on. While it dozes, it doesn’t chat and redraws less often to save energy. pikapik only checks how long ago a key was pressed or the mouse moved, never what you type, so it needs no permissions, and it works the same in the Mac App Store version. Turn it off in Settings › Pet › Follows your rhythm.

## [1.39.2] - 2026-10-13

### Changed
- Settings sync: settings synced with iCloud now live in a folder called pikapik in iCloud Drive instead of pika-tools. pikapik moves them there by itself and keeps the newer copy if both folders exist. The old folder is removed only when nothing else is in it. A Mac with an older version keeps using the old folder until you update pikapik there.

### Fixed
- Uninstall: removing pikapik completely with `brew uninstall --zap` now also deletes the list of recently removed apps.
- What’s new: older posts now call the app pikapik.

## [1.39.1] - 2026-10-13

### Fixed
- Archives: the archive windows have the usual macOS title bar again. The window’s name is at the top, you drag the window by it, and the three buttons are on the left. In the window for a new archive and in the password window, the red button works like Cancel. Buttons that do nothing in these small windows are grey, as in other Mac apps.
- Smaller Copy and Convert To: the progress window has the three buttons in its title bar too. They are grey, because the window closes by itself and has its own Cancel button.
- Archives: from now on, the “Open archives with this app” switch remembers which app opened ZIP and 7Z files before and gives them back to it when you turn the switch off. If that app is gone, they go to Archive Utility.

## [1.39.0] - 2026-10-13

### Added
- Archives: when you protect a new archive with a password, you now type it twice. Create stays off until both match, and a line under the fields tells you whether they do, so a typo can’t lock you out of your own archive.

### Changed
- Install: the install command from the README now installs pikapik only if it is signed by its developer and has passed Apple’s malware check, and otherwise stops without changing anything. If the download fails, it says so instead of trying to build the app from source, which needed Apple’s developer tools. The README now starts with this command, since it needs nothing else installed; Homebrew and the dmg work as before.
- Archives: the three archive windows have a fresh look. The window for a new archive shows the icon of the format you pick, with a lock when it has a password, a wide format switch with a short hint under it, and the password and splitting options together in one card. The window that asks for a password shows the archive’s own icon and says right under the field when the password is wrong. The progress window got the same clean look.
- Updates: pikapik installs an update only if it is signed by its developer. A download signed by anyone else is refused, and the installed app stays as it is.

## [1.38.2] - 2026-10-12

### Fixed
- Updates: if pikapik from the App Store is also on your Mac, the GitHub version now updates in place and leaves the App Store copy alone. Before, when the GitHub version still had its old name, pika-tools, and wasn’t installed with Homebrew, the update didn’t install, the App Store copy opened instead, and opening pikapik at login was switched off. A pikapik.app that isn’t this app is now never touched; the GitHub version keeps its old name and updates where it is.
- Install and uninstall commands: they no longer delete a pikapik.app that isn’t the GitHub version. If pikapik from the App Store is on your Mac, the install command now stops before changing anything and asks you to move it to the Trash first, and the uninstall command leaves it in place, no longer quits it if it’s open, and says so. Before, both tried to delete it, which could succeed once they asked for your administrator password.

## [1.38.1] - 2026-10-12

### Fixed
- Finder: pikapik’s items in the Finder right-click menu no longer go missing for a while after you connect a disk, open a disk image, wake the Mac or switch to Finder. In rare cases the helper behind them stopped at that moment; now it keeps working.

## [1.38.0] - 2026-10-12

### Added
- Archives: Archives in Finder adds two items to the Finder right-click menu. On an archive, Extract puts its files next to it. On any other file or folder, Create Archive… makes a ZIP, 7Z, TAR.GZ or TAR.XZ. It is off by default: switch it on in Settings › Finder. It is not in the App Store version.
- Archives: ZIP and 7Z can have a password, and any archive can be split into parts, for example 15 MB ones for email or 4 GB ones for a USB drive. A ZIP made this way has no hidden service files (.DS_Store, __MACOSX and the like), keeps names in any language readable and handles files over 4 GB.
- Archives: pikapik also opens what macOS can’t: RAR, even split into parts, 7Z locked with a password, split sets such as .001, .z01, .r00 and .part1.rar, and ZIPX, CAB, LZH, ARJ, ZST, LZMA, WIM and more. Double-click opens them in pikapik. pikapik can unpack RAR but not make it: the RAR license allows only unpacking.
- Archives: file names in old ZIPs that were written in a local code page, for example Cyrillic, Greek, Hebrew, Arabic, Thai, Japanese, Korean or Chinese, come out readable. pikapik works out the code page from the names themselves and takes your system languages into account.
- Archives: a switch, Open archives with this app, in Settings › Finder also hands ZIP and 7Z to pikapik, while TAR and GZ stay with the built-in archive app, which already handles them well.
- Archives: a window asks for the password, Stop cancels any job, and from a damaged or unfinished archive pikapik takes out what can still be read. It asks before unpacking an archive that would swell to a huge size, stops in time if the disk would fill up, and blocks archives that try to write outside their own folder.
- Archives: press Space on an archive in Finder to see what is inside without unpacking it. The preview shows the unpacked size and notes when the archive has a password, comes in parts, is damaged, would swell to a huge size or contains a program. A big or slow archive is shown only in part, at most 5,000 items read within 1.5 seconds, and the preview says so. It is switched on and off together with Archives in Finder.

## [1.37.3] - 2026-10-12

### Fixed
- Games: Show FPS no longer asks for Screen Recording on its own page. Screen Recording is now allowed on the Permissions page, like every other permission: its row appears there when Show FPS needs it, and Settings › Games only shows the usual “Needs a permission. Click to allow it.” line with an Allow button that takes you to that row. Screen Recording can also be found in the Settings search.
- Games: switching Show FPS on no longer opens the macOS permission prompt by itself. The prompt appears only after you click Allow, and never during a game.

## [1.37.2] - 2026-10-12

### Changed
- Releases are now signed with a verified Apple Developer ID and checked by Apple (notarized), so macOS no longer warns when you open pikapik for the first time.
- Because the signature changes, macOS may ask again for the permissions you gave pikapik (Accessibility, Input Monitoring, Full Disk Access), and fan control has to be allowed once more in pikapik’s settings, which asks for your password once.

## [1.37.1] - 2026-10-12

### Fixed
- Games: the FPS label now moves together with the game window. It used to catch up with a moving window only once a second, so it trailed far behind while you dragged the window; now it checks the window on every frame of the screen and keeps up within a few thousandths of a second. Once the window has stood still for half a second, it checks 30 times a second, so it costs almost nothing while you play.
- Games: the FPS label no longer jumps to a corner of the main screen when more than half of the game window is past the edge of the screen. It stays with the window on the display that shows the largest part of it, and Game Mode now picks that same display when it keeps the pointer from slipping onto another screen.
- Games: the help for Show FPS now explains that calm games like chess draw a new picture only when something moves, so a 0 there is normal.

## [1.37.0] - 2026-10-12

### Added
- Games: Show FPS puts a small dark label with the frames per second in a corner of any game while Game Mode is on. FPS means frames per second: how many pictures the game draws each second. Switch it on in Settings › Games, and click a corner on the picture above the switch to choose where the label sits; the top right is the default. The label shows a dash while it waits for the first frames and a faded 0 when the game stops drawing, for example in a menu, while loading or on pause. The label ignores clicks, follows the game window, sits below the title bar in a window and below the notch in full screen, and fades in and out, without a fade when Reduce Motion is on. It is off by default, and the switch and the corner are part of exported settings and of Restore Defaults.
- Games: on macOS 27 most games are counted by macOS itself, and no permission is needed. Games it can’t count, mostly older ones, are counted through screen recording, and then the number can’t go above the screen’s refresh rate. The Screen Recording row, “Needed for some games”, appears in Settings only after such a game was played, and pikapik never asks for the permission during a game. On macOS 14 to 26 and in the App Store version every game is counted through screen recording, so switching Show FPS on asks for Screen Recording. pikapik looks at a tiny, low-resolution copy of the screen only to count how often the game’s window changes; no picture is ever kept or sent anywhere.

## [1.36.0] - 2026-10-12

### Added
- Uninstaller: a new page in Settings removes an app together with the files it keeps on your Mac. It is not in the App Store version. Pick an app from the list, which you can search and sort by name or by when you last used it, or drop an app on the picture at the top of the page. pikapik looks for everything the app keeps and shows it in groups: The app, Saved data, Private storage, Temporary files, Settings, Background helpers, Add-ons, Logs and Installer records. Every item says why it is listed, for example “Belongs to the app”, “Has the app’s name”, “Installed with Homebrew” or “Might be related”.
- Uninstaller: files that clearly belong to the app are ticked, files that are only maybe related are not, and files that other apps use too are marked “Also used by …” and left unticked. Select All and Deselect All change the whole list, a right click on a file offers Quick Look, Show in Finder and Copy Path, and the button shows the total size, like “Move to Trash · 1.2 GB”.
- Uninstaller: nothing is deleted for good, everything goes to the Trash. The app’s background helpers are stopped first. If the app is open, pikapik asks it to quit, and offers Force Quit only if it did not close. If some files need an administrator, your Mac asks for the password once. When macOS does not allow a move, the result says why and has a button that opens the right pane of System Settings: App Management, or Automation for Finder, which pikapik asks to move the app when macOS does not let it do that itself.
- Uninstaller: Put Back returns everything to where it was and starts the background helpers again, and whatever cannot be put back is listed with the reason. The last ten removals stay under Recently removed for as long as their files are in the Trash.
- Uninstaller: Reset App keeps the app and removes only its saved data, settings and temporary files, which can help when an app misbehaves.
- Uninstaller: In the Trash lists the apps you moved to the Trash yourself, with the files they left behind, and Leftovers of removed apps finds files of apps that are already gone.
- Uninstaller: a switch, Offer to clean up when an app goes to the Trash, opens this page on the app you just trashed. It is off by default, and nothing is removed until you choose.
- Uninstaller: Full Disk Access is needed to see everything an app keeps, and the page asks for it with a button.

## [1.35.0] - 2026-10-12

### Added
- Your pet now has a wardrobe. Settings › Pet shows 38 things to wear in seven groups: hats, face, neckwear, tops, bottoms, shoes and extras such as a cape, a balloon or wings. Each thing has a rank from Common to Legendary. Six are free from the start (a cap, sunglasses, a bow tie, a T-shirt, jeans and sneakers) and the rest are unlocked by awards. Click a thing to put it on your pet or take it off, or choose Take Everything Off. What your pet wears is kept between launches.
- Ten ready-made looks dress your pet from head to toe in one click: Wizard, Pirate, Astronaut, Superhero, Cowboy, Fairy, King, Gentleman, Scientist and Detective. A look can be worn once all its pieces are unlocked, and it replaces what your pet is wearing.
- 25 awards come from playing together (24 in the App Store version, which has no award for opening the pikapik page on GitHub). They are earned by opening Settings › Pet, walking 10,000, 100,000 and 1,000,000 steps, picking your pet up and throwing it high, catching it in the air, jumping, leaping over the pointer, climbing windows, tumbling, kicking and pushing the ball, talking, opening every page in Settings, trying on 10 things, being together early in the morning, after midnight and on both days of a weekend, 7, 30 and 100 days together, and finally every other award. Each award unlocks things to wear. Click an award to see when you earned it and what it unlocks. Your pet tells you when you earn one, new awards and things are marked “New”, and Pet in the Settings sidebar shows a badge with the number of new awards.
- Awards are counted only on this Mac and nothing is sent anywhere. pikapik keeps plain totals of what you and your pet do: steps, pick-ups, high throws, jumps, leaps, climbs, tumbles, catches, kicks, ball pushes, phrases said, days together, Settings pages opened, things tried on and visits to Settings › Pet, and in the download from GitHub also whether the GitHub link in Settings was opened. It never keeps which keys you pressed or what you clicked. The totals, the date of each award, which awards and things are still new and what your pet wears are stored in five settings entries (pet-counts, pet-awards, pet-seen, pet-fresh and pet-outfit). They are not part of exported settings or iCloud sync, and Restore Defaults leaves them alone. Erase Progress… in the Awards section of Settings › Pet removes all five after a confirmation.

## [1.34.0] - 2026-10-12

### Added
- Games: system mouse and trackpad shortcuts now have their own group, Mouse and trackpad, under More game settings. It lists only what is turned on in macOS on your Mac, with Apple’s own names and a small drawing for each: shortcuts on a mouse button, swiping between desktops and full-screen apps, Mission Control and App Exposé (also the two-finger double tap on a Magic Mouse), pinching for Apps and spreading for the Desktop, the swipe in from the right edge that opens Notification Centre, and every hot corner you have set, named after the action it runs. Each row has the same choice as a keyboard shortcut: follow the Game Mode rules, disable in games, or allow in games. The App Store version lists the gestures only, not mouse buttons or hot corners.
- Games: while a gesture is paused, all of it is dropped, from the first touch to the last, so a swipe can never start halfway and leave Mission Control or another desktop open. Paused hot corners stop reacting and come back exactly as they were when you leave the game; corners you allow keep working, and the pointer can still reach them while it stays in the game.

### Changed
- Games: the rule “Swipes don’t switch desktops” is now “Gestures don’t leave the game” and sits under Mouse and screen. It pauses the macOS gestures that can take you out of a game: swiping between desktops and full-screen apps, Mission Control and App Exposé, the pinch for Apps and the Desktop, and the swipe in from the right edge for Notification Centre, including ones missing from the list and swipes sent by other apps. Gestures inside the game, such as scrolling, keep working, and so does any gesture you allow in its own row.

### Fixed
- Games: if pikapik quits unexpectedly during a game, the next start no longer overwrites a hot corner or Dock delay you changed in System Settings meanwhile, and the Dock restarts only when something was put back.

## [1.33.2] - 2026-10-11

### Fixed
- Games: opening a long group of system keyboard shortcuts no longer pauses the settings window. Only the rows you can see, plus a few around them, are built, and their animated previews play only while they are on screen, so even the longest group opens at once.
- Games: the list of system keyboard shortcuts no longer shows puzzling rows called “System action” with a number. Dictation, Siri, Accessibility Reader, the keypad zoom shortcuts and the extra display brightness shortcuts now show their real names, and actions that macOS gives no name, or that no longer exist (such as Dashboard and Front Row), are hidden from the list. Game Mode still pauses the hidden ones in games exactly as before.
- Games: holding ⌥⇧⌘Esc, which force quits the front app, now always stays available in games, just like ⌥⌘Esc.

## [1.33.1] - 2026-10-11

### Fixed
- Games: opening a group of system keyboard shortcuts no longer freezes the settings window for up to three seconds. Each row with its preview is now laid out once instead of several times, so even long groups open almost at once.

## [1.33.0] - 2026-10-11

### Added
- Settings › Permissions is now the one place for every permission pikapik uses. Accessibility and Input Monitoring come first. Under For some features, Fan control, Finder Extensions, iCloud Drive and Full Disk Access appear when something needs them. Each row says what it is for, shows a green check or an orange cross, and has one button: Allow when it is missing, Turn Off when it is on. The App Store version lists only what it uses.
- Every permission can be taken back from inside pikapik. Accessibility and Input Monitoring ask first, then pikapik restarts without them; the App Store version opens the right System Settings list, because macOS lets you switch these off only there. Fan control removes the fan helper after the administrator password. Finder Extensions removes the Finder menu items. iCloud Drive stops syncing and removes the access. Full Disk Access is removed, or its list opens if macOS keeps it.
- A tool that needs a missing permission looks half-grey. Click it and Permissions opens with the right row highlighted. A bar at the bottom of the page says “Grey tools need a permission. Click one to allow it.” and has an Allow button.

### Changed
- Fans no longer asks for anything itself: the speed controls stay grey until Fan control is allowed in Permissions.
- The Open Finder Extensions… button on the Finder page and the Full Disk Access request in Left by deleted apps moved to Permissions.

## [1.32.2] - 2026-10-11

### Fixed
- Fans: the helper is installed from a file written by the administrator and its signature is checked before it starts. A fan that reports no speed range is ignored, and the forced test mode ends if setting a manual speed fails.
- Updates: if the new app can't be copied, the installed pikapik stays in place instead of being deleted. A download that comes back with an error is no longer saved as an update, and a failed re-check no longer hides an update that was already found.
- Uninstalling, including `brew zap`, removes the fan helper. Uninstalling also puts back the key repeat setting, the Dock corners and the system shortcuts that pikapik had changed.
- Repeat a held key: turning it off gives back your own accent-menu setting.
- Command keys, Home and End, and Finder keys: a remapped key you are holding is released when the tool restarts, so it no longer stays stuck.
- The pet skips its background checks while the screen is asleep or locked, so it uses less energy when idle.
- New file: copies of files with a double extension are numbered like `archive 2.tar.gz` instead of `archive.tar 2.gz`.

## [1.32.1] - 2026-10-11

### Fixed
- Fans: choosing Manual no longer bounces back to Auto with the safety warning on the first try. A fan gets a few seconds to report Manual before pikapik treats it as dropped, and a fan that really drops is now set back to Auto in the hardware too, so the screen always matches what the Mac does.

## [1.32.0] - 2026-10-11

### Added
- Fans: see the speed of each fan, then choose Auto or a manual speed after allowing it once with the administrator password. The fans go back to Auto when you quit pikapik, when the Mac sleeps, or if it gets hot.

## [1.31.4] - 2026-10-11

### Changed
- Game shortcut choices show an explanation beneath every option inside the dropdown. The settings page keeps only the selected name; redundant action descriptions and repeated guidance have been removed.
- Games uses the global settings search. It indexes each live macOS action, its topic, meaning and assigned keys, understands modifier symbols and names, and ranks exact key combinations first. Selecting a result opens its group and highlights that specific action, including actions with identical names.
- The shortcut catalogue refreshes when settings opens and when pikapik becomes active. Saved game protection rules and choices keep their behaviour.

## [1.31.3] - 2026-10-11

### Changed
- Every system shortcut now uses the same full-width animated preview as Game safeguards and the other settings pages, with its name, description and controls underneath.
- Game shortcut choices now say Follow Game Mode rules, Disable in games, Allow in games and, for language shortcuts, Switch language on every press. A visible explanation describes the selected choice and follows the current general protection rules. Saved choices keep their behaviour.
- The new explanations and choice names are available in all 23 languages.

## [1.31.2] - 2026-10-11

### Changed
- Game shortcuts are organised into eight clearly named topics. Every expandable heading has an icon, a short explanation and a count, and its whole row opens the section.
- Each action shows what it does beside its animated preview. The current key and the behaviour in games have their own row, and unassigned shortcuts have a visible link to System Settings. Descriptions stay readable when protection is off.
- The catalogue comes first in More game settings. General game safeguards are collected separately, with descriptions for every switch. Search includes explanations and topics, and settings search opens the relevant section.

### Fixed
- Empty macOS action names and category labels fall back to visible text. Nested actions include their parent topic, so names such as Left and Toggle visibility have context.

## [1.31.1] - 2026-10-11

### Fixed
- pikapik’s deliberate language gesture works in games even when the macOS input-source shortcuts are unassigned or turned off. Its intent check uses the incoming event, so releasing both modifiers works in either keyboard-observer order. Held game keys keep their priority.

## [1.31.0] - 2026-10-11

### Added
- Game Mode reads the full symbolic shortcut catalogue published by the current Mac, including current user assignments and actions without an assigned key. Each action has an animated preview, its own choice, and search in More game settings. Hidden action names keep their identifiers visible instead of guessed labels.
- Automatic pauses actions that open windows or move focus. A short deliberate language shortcut selects the input source directly without the system picker while its key still reaches the game. Held movement keys have priority. The advanced choices are Automatic, Pause, Run normally and, for supported language actions, Run without interrupting.
- Other applications observing or filtering keyboard input are shown separately. Their private shortcut definitions are outside the operating system's published catalogue.

### Changed
- The main Games page stays simple. Detailed controls are collected under More game settings, and individual choices are included in settings sync and backup. Force Quit remains available.

## [1.30.14] - 2026-10-11

### Fixed
- Clicking a shortcut marked Off on the Games page no longer crashes pikapik while it opens Keyboard Shortcuts in System Settings. The same fix covers other shortcut links: a row that changes while the window opens is read once and can disappear safely.

## [1.30.13] - 2026-10-10

### Fixed
- Holding Control while pressing Space in a game no longer switches the input language and takes the jump away from the game. The keyboard focus rule now pauses input-source shortcuts and other configured macOS shortcuts with Control or without Command, while keeping keyboard press, release and modifier events intact.
- The language gesture and custom quit or close shortcuts with game modifiers no longer interfere with game controls. On leaving the game, system shortcuts return to their original enabled or disabled state.

## [1.30.12] - 2026-10-10

### Fixed
- A game can now be added by dragging its process row from Activity Monitor onto Your games. Games running through Java, including Minecraft, work even without a normal app icon in the Dock. The process number and name must match a running process.

## [1.30.11] - 2026-10-10

### Changed
- Add a game straight from the apps open now, including games running through Java or other runtimes. Open games appear first; the Dock has its own foldout list. Minecraft is shown by its name instead of java.
- The game file picker and drag and drop now accept executable files as well as app bundles. Games added by their executable are recognized when you play them.

## [1.30.10] - 2026-10-10

### Fixed
- Your pet and its ball no longer disappear behind windows when they jump on a screen without the Dock, for example when the Dock is on another display or hides itself. Up in the air they show in front of your windows on every screen, and back on the ground they go behind them again.
- A window that only touches the edge of your pet or its ball no longer keeps them hidden when they jump. They stay behind a window only when it really covers them, like a video you’re watching.

## [1.30.9] - 2026-10-10

### Fixed
- A full-screen video no longer lets your pet slip out now and then. pikapik now asks macOS directly whether a screen is in full screen and checks once more when the switch is over.
- The ball no longer bounces off empty air above the Dock. It flies over it freely.
- The mouse hits the ball only when the pointer really touches it: a light touch rolls it, a quick flick sends it flying.
- When your pet or its ball hides behind a window, it stays behind it when it jumps next to the Dock, and the mouse over that window leaves them alone.
- Dragging a file across the desktop no longer builds a step for your pet. Only a selection frame does.

## [1.30.8] - 2026-10-10

### Fixed
- In Game Mode, moving the mouse to the edges and corners of the screen no longer sets off hot corners or pulls out a hidden Dock. They are switched off while you play and come back exactly as they were a few seconds after you leave the game, or when pikapik quits.
- The pointer no longer stutters at the edge of the game's screen.

## [1.30.7] - 2026-10-10

### Fixed
- When your pet or its ball is behind a window, such as a video or a game, it stays behind it when it jumps or flies, instead of popping up over what you're watching.
- Pressing Space to pause a video no longer brings your pet out.
- A full-screen video in Firefox now hides your pet and its ball right away.

## [1.30.6] - 2026-10-10

### Fixed
- When any app is in full screen, such as a video or a game, your pet and its ball now hide on every display instead of moving to another screen and playing there. They come back as soon as you leave full screen.

## [1.30.5] - 2026-10-10

### Fixed
- Your pet and its ball now hide while an app is in full screen, such as when you watch a video or play a game, on Macs with a notch too. The ball no longer pops up over a full-screen app on another display. As before, they still slip behind ordinary windows.

## [1.30.4] - 2026-10-10

### Fixed
- Your pet and its ball no longer disappear behind windows when they jump over the pointer or ride a selection box up. While they are higher than the Dock, they show in front of your windows, and back on the ground they go behind them again.

### Changed
- Your pet can walk behind the Dock again, and the ball rolls there too, just like before 1.30.3.

## [1.30.3] - 2026-10-09

### Fixed
- Your pet and its ball no longer go under the Dock, where nobody can see them. They turn back or bounce off its edges and stay in sight next to it, even when a window fills the whole screen.

## [1.30.2] - 2026-10-09

### Fixed
- Your pet no longer freezes in mid-air when windows cover the whole strip it lives on. Your pet and its ball keep living behind the window, and only the drawing pauses, so the pet falls to the ground as soon as you let go of a selection box.
- A selection box no longer lifts your pet higher than its strip.

## [1.30.1] - 2026-10-09

### Fixed
- Selection boxes on the desktop work again when the Dock or a remote desktop app covers the whole screen, so your pet and its ball jump onto them as before.
- App lists in Settings light up only when you drag an app over them. Other files are ignored, and if you drop an app together with other files, only the app is added.
- The frame around an app list turns off right after you drop an app on it.

## [1.30.0] - 2026-10-09

### Added
- Quit no longer switches pikapik off. Choosing Quit, pressing ⌘Q or quitting from the Dock closes its windows and hides the menu bar icon, while shortcuts, Keep Awake and your pet keep working. Open pikapik again to bring the icon back. To quit completely, hold Option and choose Quit, or press ⌥⌘Q. The first time, pikapik explains what happened. You can turn this off with Keep running after Quit in Settings › General.
- Updates, changing the language, logging out, restarting, shutting down and quitting from Homebrew or a script always quit pikapik completely, so they never wait for it.

## [1.29.1] - 2026-10-09

### Added
- Your pet and its ball walk across all your screens. When they reach the edge of one screen, they step over to the next. You can also carry the pet or the ball to any screen with the mouse. If an app goes full screen, they move to another screen, and if you unplug a monitor, they come back to the main one.

### Fixed
- Your pet no longer disappears. Every two seconds it checks that it’s still on screen and comes back on its own if it got lost, for example after sleep, locking the Mac, switching desktops or full screen.
- A thrown pet no longer lands on a selection box that sits higher than it can reach, and no longer vanishes because of it.
- The ball no longer gets stuck in a corner. Your pet scoops it back over its head and keeps playing.

## [1.29.0] - 2026-10-09

### Added
- Your pet has a ball. A little football rolls and bounces along the bottom of the screen, and your pet kicks it and chases it. Flick the pointer quickly into the ball to kick it yourself, or pick it up, carry it and throw it, just like the pet. You can turn it off with Ball in Settings › Pet.
- A selection box on the desktop becomes a shelf. Click an empty spot on the desktop and drag, with or without Shift: while you hold the mouse button, your pet can jump onto the box and the ball can land on it.

### Fixed
- Next to the Dock, the pet jumps as high as it likes again. It stays low only while it’s right over the Dock, so it never peeks out above it.

## [1.28.0] - 2026-10-09

### Added
- Adding apps to a list is now a click or a drag. Add App… opens a shelf with the apps in your Dock and the apps that are open right now: click one to add it, click it again to take it back, or choose Other… for anything else. You can also drag an app from Finder straight onto a list, and the list lights up to show where it lands. This works for every list of apps in Settings: Home and End, Never quit these apps, the green button and your games.
- The bug report form on GitHub lets you pick your pikapik version and macOS from a list.

### Fixed
- Scroll direction no longer turns scrolling around a second time when you control another Mac through AnyDesk or another remote desktop app. pikapik now flips only scrolling that comes from a real mouse or trackpad. If an app makes its own smooth scrolling, like Mos, set the direction in that app.
- The pet stays behind the Dock when it jumps or tumbles, just like when it walks, and no longer pops out in front of it. After you leave a full-screen app or a game, it comes back by itself.
- The thin frames around the little pictures in Settings no longer disappear on regular, non-Retina displays.

## [1.27.3] - 2026-10-09

### Fixed
- The pet no longer vanishes behind other apps’ windows when it jumps over the pointer or tumbles. It now stays in front for the whole jump and goes back behind your windows when it lands.
- pikapik windows open ready to use, even when the app started quietly in the background: at login, after an update, or from a `pikapik://` link. Settings, the New File box, the message after Make a Smaller Copy and the list where you pick an app to add no longer open gray and inactive behind other windows.

## [1.27.2] - 2026-10-09

### Fixed
- New File is back in Finder’s right-click menu. After the last update, Finder could restart New File in the background and forget which folders it works in. Now New File, Compress and Convert To remind Finder of their folders every time they start, and the app checks a little after launch that Finder got the message.
- After an update, the app re-adds its Finder items only when it really moved, so Finder doesn’t have to reload them every time.

### Changed
- Settings ask even less of your Mac. A moving picture plays only while at least half of it is on screen, and in the game pictures the hills and ground behind the hero move 15 times a second while the hero keeps 30. Everything looks the same.

## [1.27.1] - 2026-10-09

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
- Clean up permissions left by deleted apps. When you delete an app, macOS keeps the permissions you gave it, and System Settings has no way to remove them. Now Permissions has a list called “Left by deleted apps”: each app with its icon, what it was allowed to do and when. Remove clears one app, Remove All clears them all, and an app you install again will simply ask again. To see the list, give pikapik Full Disk Access; it only looks until you press Remove.

### Changed
- A new app icon: the pikapik mark in blue, violet and coral on a dark tile. The menu bar shows the same shape and follows a light or dark menu bar. When every tool is off, the shape turns pale.
- The pictures on the Animations and Games pages are drawn anew for their size, so they look sharp. A window shrinks into the Dock with round corners, like on a real Mac. The pointer clicks first, and only then a menu or a window opens. Spotlight, the app switcher and the emoji panel are see-through glass, as in macOS Tahoe.

### Fixed
- Clicking a system shortcut now takes you straight to its own list in System Settings, like Mission Control or Screenshots, not just to Keyboard. If pikapik can’t pick the list for you, Keyboard Shortcuts still opens, and a short tip next to the keys says which list to click. The tip no longer disappears the moment System Settings opens.

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
- Your own keys for quitting and closing. In Settings → Windows, click the keys next to Quit app or Close window and press new ones. Esc cancels, and ⌫ brings back ⇧⌘Q and ⇧⌘W. If your Mac or the other row already uses those keys, pikapik tells you and asks first. Game Mode uses your keys too.

### Changed
- Game Mode switches are named in simple words, like “The game doesn’t close” or “Search doesn’t pop up”. The system name, such as Spotlight or Mission Control, sits next to them in gray.
- App names in lists show without “.app”.
- Every shortcut in Settings shows how it is really set up on your Mac. Shortcuts you changed in System Settings show your keys, and the ones you turned off say Off. Click one to open the keyboard shortcuts in System Settings.
- Cut files in Finder follows the Cut shortcut you set for Finder in System Settings.

## [1.24.1] - 2026-10-08

### Fixed
- Animations: the Faster preset never makes anything slower than what you already had. If parts of your Mac were already faster, for example after commands in Terminal, they stay as they are.
- Animations: Restore Defaults and uninstalling pikapik bring back the values you had before, instead of erasing them.
- Animations: when the Dock doesn’t hide, the switch to hide it automatically sits right under the speed slider, because the Dock speeds up only when it hides. The Dock no longer restarts for nothing while it stays in place.
- Animations: after a change, a line at the bottom of the page says that apps show it once you open them again, with one Restart Finder button. Quick Look and columns now offer the button too, since Finder shows them only after a restart.

## [1.24.0] - 2026-10-08

### Added
- Animations: a new page in Settings for how fast things move on your Mac. One slider speeds up the hidden Dock, new windows, Save dialogs, Quick Look and columns in Finder at once, from as in macOS to instant. Each effect can also be tuned on its own, along with the minimize effect, bouncing icons in the Dock and Finder animations. Every setting has a small live picture that moves at exactly the chosen speed. Restore Defaults and uninstalling pikapik remove only what pikapik changed, and values you set yourself in Terminal are shown as they are.

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
- Game Mode keeps your Mac from pulling you out of a game. Add your games, and while you play one, Spotlight, Siri, ⌘Tab, Mission Control and swipes between desktops don’t open over it, ⌘Q and ⌘W don’t close it by accident, the pointer stays on the game’s screen, the keyboard language doesn’t change and the screen stays on. Each of these has its own switch, and pikapik suggests games it finds on your Mac. To leave a game, press ⇧⌘Q; to close its window, press ⇧⌘W. ⌥⌘Esc always works. Off by default, on the Games page.
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
- Keep Awake stays on through updates and restarts of pikapik. A timer keeps counting from where it was, and with the lid closed you are not asked for the password again. Quitting pikapik from its menu still turns Keep Awake off.
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
- The menu bar panel no longer turns grey when pikapik was already the active app as you opened it.
- Finder no longer shows “New File” twice when a test build of pikapik was also installed.

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
- Right-click the pikapik icon in the menu bar for a quick menu: Keep Awake, Settings, updates, About, Open at Login and Quit.

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

[1.52.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.52.0
[1.51.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.51.0
[1.50.3]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.50.3
[1.50.2]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.50.2
[1.50.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.50.0
[1.49.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.49.0
[1.48.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.48.0
[1.47.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.47.0
[1.46.1]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.46.1
[1.46.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.46.0
[1.45.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.45.0
[1.44.3]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.44.3
[1.44.2]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.44.2
[1.44.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.44.0
[1.43.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.43.0
[1.42.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.42.0
[1.41.1]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.41.1
[1.41.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.41.0
[1.40.2]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.40.2
[1.40.1]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.40.1
[1.40.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.40.0
[1.39.4]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.39.4
[1.39.3]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.39.3
[1.39.2]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.39.2
[1.39.1]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.39.1
[1.39.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.39.0
[1.38.2]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.38.2
[1.38.1]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.38.1
[1.38.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.38.0
[1.37.3]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.37.3
[1.37.2]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.37.2
[1.37.1]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.37.1
[1.37.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.37.0
[1.36.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.36.0
[1.35.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.35.0
[1.34.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.34.0
[1.33.2]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.33.2
[1.33.1]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.33.1
[1.33.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.33.0
[1.32.2]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.32.2
[1.32.1]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.32.1
[1.32.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.32.0
[1.31.4]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.31.4
[1.31.3]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.31.3
[1.31.2]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.31.2
[1.31.1]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.31.1
[1.31.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.31.0
[1.30.14]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.30.14
[1.30.13]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.30.13
[1.30.12]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.30.12
[1.30.11]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.30.11
[1.30.10]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.30.10
[1.30.9]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.30.9
[1.30.8]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.30.8
[1.30.7]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.30.7
[1.30.6]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.30.6
[1.30.5]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.30.5
[1.30.4]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.30.4
[1.30.3]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.30.3
[1.30.2]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.30.2
[1.30.1]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.30.1
[1.30.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.30.0
[1.29.1]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.29.1
[1.29.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.29.0
[1.28.0]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.28.0
[1.27.3]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.27.3
[1.27.2]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.27.2
[1.27.1]: https://github.com/dev-pikapik/pika-tools/releases/tag/v1.27.1
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
