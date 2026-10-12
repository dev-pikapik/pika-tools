<p align="center"><a href="../../README.md"><img src="../media/icon.png" width="96" height="96" alt="pikapik"></a></p>
<h1 align="center">What’s new in pikapik</h1>
<p align="center">Every update in a few words and a picture, newest first.</p>
<p align="center"><sub><b>English</b> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.es.md">Español</a> · <a href="README.it.md">Italiano</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ja.md">日本語</a> · <a href="README.zh-Hans.md">简体中文</a> · <a href="README.ko.md">한국어</a> · <a href="README.ro.md">Română</a> · <a href="README.pl.md">Polski</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.nl.md">Nederlands</a> · <a href="README.sv.md">Svenska</a> · <a href="README.cs.md">Čeština</a> · <a href="README.zh-Hant.md">繁體中文</a> · <a href="README.ar.md">العربية</a> · <a href="README.hi.md">हिन्दी</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.th.md">ไทย</a></sub></p>

---

## <a id="v1.39.0"></a>New archive windows, and the password typed twice

<sub>1.39.0 · October 13, 2026</sub>

When you put a password on a new archive, you now type it twice, so a typo can’t lock you out of your own files.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.39.0/archive-password-dark.png"><img src="../media/whats-new/1.39.0/archive-password-light.png" width="340" alt=""></picture>

Under the fields, a green line appears when the passwords match, or a red one when they don’t, and Create waits until they match.

All archive windows have a new look: a large icon, one switch for the password, and a short line that tells you whether file names stay visible, as in ZIP, or are hidden too, as in 7Z. On macOS 26 the buttons are made of Liquid Glass.

Installing is simpler too: the command at the top of the pikapik page on GitHub needs nothing else on your Mac. It installs pikapik only if the download is signed by its developer and has passed Apple’s malware check.

---

## <a id="v1.38.2"></a>Safer updates next to the App Store version

<sub>1.38.2 · October 12, 2026</sub>

If pikapik from the App Store is also on your Mac, the GitHub version now updates in place and leaves the App Store copy alone.

Before, if the GitHub version still had its old name, pika-tools, and wasn’t installed with Homebrew, the update didn’t install, the App Store copy opened instead, and opening pikapik at login was switched off.

---

## <a id="v1.38.1"></a>A steadier Finder menu

<sub>1.38.1 · October 12, 2026</sub>

pikapik’s items in the Finder right-click menu no longer go missing when you connect a disk, open a disk image, wake your Mac or switch to Finder.

In rare cases, the helper that shows them used to quit at that moment.

---

## <a id="v1.38.0"></a>Open and make archives in Finder

<sub>1.38.0 · October 12, 2026</sub>

The new Archives in Finder opens RAR and other archives that macOS can’t, and makes ZIP and 7Z from the right-click menu.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/archive-dark.png"><img src="../media/archive-light.png" width="340" alt=""></picture>

Open Settings › Finder and turn on Archives in Finder. Right-click an archive and choose Extract, and its files appear next to it. Right-click any other file or folder and choose Create Archive… to make a ZIP, 7Z, TAR.GZ or TAR.XZ. ZIP and 7Z can have a password, and any archive can be split into parts, for example 15 MB ones for email. A ZIP made this way has no hidden service files and keeps names in any language readable.

pikapik also opens what macOS can’t: RAR, even split into several files, 7Z locked with a password, ZIPX, CAB, LZH, ARJ, ZST, WIM and more. Double-click opens them in pikapik. File names in old ZIPs, for example in Cyrillic, Japanese or Chinese, come out readable. A switch, Open archives with this app, also hands ZIP and 7Z to pikapik, while TAR and GZ stay with the built-in archive app, which already handles them well.

A window asks for the password, Stop cancels any job, and from a damaged archive pikapik takes out what can still be read. It asks before unpacking an archive that would swell to a huge size, and blocks archives that try to write outside their own folder. Not in the Mac App Store version. Press Space on an archive to preview what is inside.

---

## <a id="v1.37.3"></a>Show FPS now asks in the right place

<sub>1.37.3 · October 12, 2026</sub>

Screen Recording for the FPS counter is now allowed on the Permissions page, together with all the other permissions.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

To count the frames of a game, Show FPS may need Screen Recording. Before, pikapik asked for it right on the Games page. Now it sits with every other permission: when Show FPS needs it, a Screen Recording row appears in Settings › Permissions, and you click Allow there.

On the Games page you now only see the usual line under the switch, “Needs a permission. Click to allow it.” Its Allow button takes you straight to the Screen Recording row. Turning on Show FPS no longer pops up a question by itself, and pikapik still never asks while you play.

---

## <a id="v1.37.2"></a>Checked by Apple

<sub>1.37.2 · October 12, 2026</sub>

pikapik is now signed by a verified Apple developer and checked by Apple. That means macOS no longer warns you when you open it for the first time.

After this update macOS may ask again for the permissions you gave pikapik, such as Accessibility, Input Monitoring or Full Disk Access. Allow them once more in System Settings › Privacy & Security. If you use fan control, allow it again in pikapik’s settings, and macOS will ask for your password once.

---

## <a id="v1.37.1"></a>The FPS label keeps up with your game

<sub>1.37.1 · October 12, 2026</sub>

Move the game window, and the FPS label now moves right along with it.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

The label used to catch up with a moving window only about once a second, and trailed behind it. Now it checks the window on every frame of the screen and is never more than a few thousandths of a second behind. When the window stands still, it checks less often, so it puts almost no load on your Mac while you play. It also no longer jumps away when part of the window goes past the edge of the screen.

If a calm game like chess shows 0, nothing is wrong: games like that draw a new picture only when something moves. The number goes up while a piece slides and drops back to 0 when the board is still.

---

## <a id="v1.37.0"></a>See how smoothly your game runs

<sub>1.37.0 · October 12, 2026</sub>

The new Show FPS puts a small counter in a corner of your game, so you can see how smoothly it runs.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-fps-dark.png"><img src="../media/game-fps-light.png" width="340" alt=""></picture>

Open Settings › Games and turn on Show FPS. While Game Mode is on, a small dark label with a number appears in a corner of any game. FPS means frames per second: how many pictures the game draws each second, so a higher number means a smoother game. Click a corner of the picture above the switch to choose where the label sits.

Clicks go straight through the label, and it follows the game window. A dash means the first frames haven’t arrived yet, and a faded 0 means the game has stopped drawing. Show FPS is off until you turn it on.

On macOS 27, macOS counts most games itself, so no permission is needed. A few games, mostly older ones, can only be counted through screen recording, and then the number can’t go above your screen’s refresh rate. On macOS 14 to 26 and in the Mac App Store version, every game is counted that way, so Show FPS asks for Screen Recording. No picture is ever saved or sent.

---

## <a id="v1.36.0"></a>Remove apps without worry

<sub>1.36.0 · October 12, 2026</sub>

The new Uninstaller removes an app with all its files, and puts it all back if you change your mind.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/uninstaller-dark.png"><img src="../media/uninstaller-light.png" width="340" alt=""></picture>

Open Settings › Uninstaller and pick an app, or drop one on the picture. pikapik shows everything the app keeps on your Mac, with the reason for each file. Files that clearly belong to the app are ticked, and the ones that are only maybe related are not. Click Move to Trash, and everything goes to the Trash, so nothing is deleted for good.

Changed your mind? Click Put Back and it all returns where it was. The last ten removals wait under Recently removed while their files are still in the Trash. Reset App keeps the app and removes only its saved data, settings and temporary files, in case it misbehaves.

Moved an app to the Trash yourself? The page lists those apps and the files they left behind, and you can turn on a switch that offers to clean up each time an app goes to the Trash. Nothing is removed until you choose. The page needs Full Disk Access to see everything.

---

## <a id="v1.35.0"></a>Dress up your pet

<sub>1.35.0 · October 12, 2026</sub>

Your pet has a wardrobe now, and you earn new things to wear as you play together.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.35.0/wardrobe-dark.png"><img src="../media/whats-new/1.35.0/wardrobe-light.png" width="340" alt=""></picture>

Open Settings › Pet and pick what your pet wears: hats, glasses, scarves, shirts, shoes, capes and even wings. Your pet puts it on right away. A few things are free, and the rest are awards that come as you play together: pick your pet up and toss it, kick the ball around, watch it climb windows and chat, or simply keep it company day after day. When you earn one, your pet tells you.

Ready-made looks dress your pet from head to toe in one click: a wizard, a pirate, an astronaut, a superhero, a king and more. A look is ready once you have earned all its pieces.

Only simple counts are kept, like steps, throws and days together. They stay on your Mac, nothing is sent anywhere, and you can erase them any time in Settings › Pet.

---

## <a id="v1.34.0"></a>Mouse and trackpad shortcuts in games

<sub>1.34.0 · October 12, 2026</sub>

Swipes, pinches and hot corners now stay out of your game, just like keyboard shortcuts.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.34.0/pointer-shortcuts-dark.png"><img src="../media/whats-new/1.34.0/pointer-shortcuts-light.png" width="340" alt=""></picture>

Settings › Games › More game settings has a group called Mouse and trackpad. It lists only what is turned on in macOS on your Mac, with Apple’s own names and a small drawing for each: shortcuts on a mouse button, swiping between desktops and full-screen apps, Mission Control and App Exposé, pinching for Apps and spreading for the Desktop, the swipe in from the right edge for Notification Centre, and every hot corner with the action it runs. While a game is in front they are paused, so a stray swipe or a brush against a screen corner can’t pull you out of it. Gestures inside the game keep working. Each one can be set to work as usual.

---

## <a id="v1.33.2"></a>Shortcut groups open instantly

<sub>1.33.2 · October 11, 2026</sub>

Even the longest group of system shortcuts opens at once, and every row has a clear name.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

A group with dozens of rows used to freeze the settings window for a moment, because every row and its animated preview was built at once. Now only the rows you can see, plus a few around them, are built. Rows called “System action” with a number are gone too: Dictation, Siri and the brightness and zoom keys show their real names, and actions macOS gives no name to are hidden but still paused in games as before.

---

## <a id="v1.33.1"></a>Shortcut groups open without a freeze

<sub>1.33.1 · October 11, 2026</sub>

The Games page stays smooth when a long list of previews opens.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

Opening a group of system keyboard shortcuts used to freeze the settings window for up to three seconds, because every row with its preview was laid out several times. Now each row is laid out once, so groups open almost at once.

---

## <a id="v1.33.0"></a>Every permission in one place

<sub>1.33.0 · October 11, 2026</sub>

Settings › Permissions now lists everything pikapik uses, and lets you take back any of it.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.33.0/permissions-dark.png"><img src="../media/whats-new/1.33.0/permissions-light.png" width="340" alt=""></picture>

Settings › Permissions now lists every permission pikapik uses, from Accessibility and Input Monitoring to Fan control, Finder Extensions, iCloud Drive and Full Disk Access. Each row says in one line what it is for, with a green check when it’s on and an orange cross when it’s missing.

Every row has one button: Allow when it’s missing, Turn Off when it’s on. So you can take any permission back right there, without digging through System Settings. For Accessibility and Input Monitoring, pikapik asks first and then restarts without them.

A tool that needs a permission you haven’t given looks half-grey. Click it, and Permissions opens with the right row highlighted, ready for one click on Allow.

**Try it:** Open Settings › Permissions and look at each row. Click a grey tool to jump to the permission it needs.

---

## <a id="v1.32.2"></a>Safer installs, and updates that never lose the app

<sub>1.32.2 · October 11, 2026</sub>

A round of fixes that make installing, updating and uninstalling safer.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

The fan helper is now installed more carefully and checked before it starts. If an update can’t be copied, your current pikapik stays in place. Uninstalling now also removes the fan helper and puts back your key repeat setting, Dock corners and system shortcuts.

Keys you hold no longer get stuck when a tool restarts, and turning off Repeat a held key gives you back your own accent-menu setting. The pet rests while your screen is asleep or locked, and a copy of archive.tar.gz is now called archive 2.tar.gz.

---

## <a id="v1.32.1"></a>Manual fan speed now sticks on the first try

<sub>1.32.1 · October 11, 2026</sub>

Choosing Manual in Fans no longer bounces back to Auto.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

Sometimes the first tap on Manual sent the fans back to Auto with a safety warning, and only the second tap worked. Manual now holds from the first try.

If a fan ever does leave Manual by itself, pikapik now puts it back to Auto for real, so what you see always matches what your Mac is doing.

You don’t need to allow anything again. Update, and it just works.

**Try it:** Open Settings › Fans and pick Manual.

---

## <a id="v1.32.0"></a>See how fast your fans spin

<sub>1.32.0 · October 11, 2026</sub>

A new Fans tab shows every fan live, and lets you pick its speed.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/fans-dark.png"><img src="../media/fans-light.png" width="340" alt=""></picture>

Fans now has its own tab in Settings and a row in the menu. You see how fast each fan is spinning right now, in real time, next to a little fan that spins along with it.

Leave it on Auto and your Mac decides, like always. Or choose Manual and drag one slider to set the speed you want. The first time, you allow it once with your administrator password, and that’s all.

It’s built to be safe. The fans go back to Auto when you quit pikapik, when your Mac goes to sleep, if pikapik crashes, or when your Mac gets hot.

**Try it:** Open Settings › Fans and watch the speed. Pick Manual to try the slider.

---

## <a id="v1.31.4"></a>Details when you need them

<sub>1.31.4 · October 11, 2026</sub>

A calmer Games page and one search.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.4/game-choices-dark.png"><img src="../media/whats-new/1.31.4/game-choices-light.png" width="340" alt=""></picture>

Every mode explains what it does inside the dropdown. When closed, only its name stays on the page.

Descriptions that repeat the action name are removed. Useful extra information stays.

Global search finds system actions by name, meaning and keys. Selecting a result opens and highlights that exact setting.

**Try it:** Find an action in global search and open its mode list.

---

## <a id="v1.31.3"></a>One style for game settings

<sub>1.31.3 · October 11, 2026</sub>

Matching previews and clearer shortcut choices.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.3/game-preview-dark.png"><img src="../media/whats-new/1.31.3/game-preview-light.png" width="340" alt=""></picture>

Every shortcut now has the same wide preview as Game safeguards and the other settings pages. Its description and controls sit underneath, with an explanation of the selected choice.

«Follow Game Mode rules». A quick shortcut switches language without a menu. Holding game keys prevents accidental switching.

«Disable in games». This macOS action is disabled while the game is in front. When you leave, it works as before. «Allow in games». macOS runs the action normally, even if it opens a window or takes focus from the game.

**Try it:** Open More game settings, expand System controls and choose how an action behaves while you play.

---

## <a id="v1.31.2"></a>Game settings with a clear purpose

<sub>1.31.2 · October 11, 2026</sub>

Fine-tune protection and explore your Mac’s shortcuts.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.2/game-settings-dark.png"><img src="../media/whats-new/1.31.2/game-settings-light.png" width="340" alt=""></picture>

Eight clear topics replace the repeated folders. Every heading has a name, an explanation, an icon and a count. Click anywhere on its row to open it.

Each action shows what it does beside its animated preview. Its current keys and behaviour in games have their own row. Search also understands descriptions.

Unassigned keys have a clear link to System Settings. General game safeguards are collected separately, and your choices are preserved.

**Try it:** Open More game settings, expand a topic and compare an action’s description with its preview.

---

## <a id="v1.31.1"></a>Language gestures in games

<sub>1.31.1 · October 11, 2026</sub>

Simple by default, with the full system catalogue when you need it.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/input-switch-dark.png"><img src="../media/input-switch-light.png" width="340" alt=""></picture>

pikapik’s language gesture works in games even when macOS language shortcuts are unassigned or turned off.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Automatic pauses actions that open windows or move focus. A quick deliberate language shortcut switches the input source silently. Held movement keys keep their priority, so running and jumping don’t change the language by accident.

Each action can be adjusted in the searchable catalogue. Language actions can run in the background; other actions can be paused or allowed normally. Choices sync with your settings. Other apps watching the keyboard appear separately, and Force Quit stays available.

**Try it:** Hold ⌥ and tap ⇧: next language. Hold ⇧ and tap ⌥: previous

---

## <a id="v1.31.0"></a>Game Mode knows your Mac’s shortcuts

<sub>1.31.0 · October 11, 2026</sub>

Simple by default, with the full system catalogue when you need it.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.31.0/system-shortcuts-dark.png"><img src="../media/whats-new/1.31.0/system-shortcuts-light.png" width="340" alt=""></picture>

Turn on Game Mode and play. More game settings holds the catalogue published by your Mac, with current key assignments and an animated preview for every action.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Automatic pauses actions that open windows or move focus. A quick deliberate language shortcut switches the input source silently. Held movement keys keep their priority, so running and jumping don’t change the language by accident.

Each action can be adjusted in the searchable catalogue. Language actions can run in the background; other actions can be paused or allowed normally. Choices sync with your settings. Other apps watching the keyboard appear separately, and Force Quit stays available.

**Try it:** Open More game settings, search for a screenshot or language shortcut, and compare its preview with the protection on and off.

---

## <a id="v1.30.14"></a>Shortcut links open without a crash

<sub>1.30.14 · October 11, 2026</sub>

Clicking a shortcut marked Off no longer quits pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

On the Games page, you can click a shortcut even when no keys are assigned. System Settings opens safely.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Before, pikapik could read the same changing row twice while the settings window opened. If the text disappeared between those reads, the app crashed.

Each row is now read once. Missing text is skipped, and the same fix covers shortcut links on other pages.

**Try it:** Click a shortcut marked Off on the Games page.

---

## <a id="v1.30.13"></a>Hold Control and keep playing

<sub>1.30.13 · October 10, 2026</sub>

Control no longer lets language switching take Space away from your game.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Hold Control to run and press Space to jump. In Game Mode, switching input languages with Control+Space or Control+Option+Space is paused.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Other macOS shortcuts using Control, or Shift and Option without Command, are paused too, including your own assignments. Key presses, releases and held modifiers keep reaching the game together.

pikapik’s language gesture and quit shortcuts with game modifiers also stay out of the way. When you leave the game, your system shortcuts return exactly as they were.

**Try it:** Hold Control, move and press Space several times. Then leave the game and switch languages as usual.

---

## <a id="v1.30.12"></a>Drag your game from Activity Monitor

<sub>1.30.12 · October 10, 2026</sub>

Game Mode now accepts processes dragged from Activity Monitor.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Find the game’s process and drag its row onto Your games in Settings → Games.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Java games work too, even without a normal app icon in the Dock. Before, these rows were ignored because they contain a process number and name instead of a file.

The game stays saved for future launches. Minecraft appears under its own name. The number and name must match a running process.

**Try it:** Drag the java row for your running Minecraft onto Your games.

---

## <a id="v1.30.11"></a>Add your game while it’s running

<sub>1.30.11 · October 10, 2026</sub>

Your open games are now the first thing you see when you add a game.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Open Settings → Games → Add a Game and click your running game. Games through Java and other runtimes appear here too, even without an app bundle. Minecraft appears as Minecraft instead of java.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

The apps in your Dock now have their own foldout list, so you can reach the game you’re playing right away.

Other… and drag and drop also accept the game’s executable file, as well as app bundles. Once added, Game Mode turns on when you switch to the game.

**Try it:** Leave your game open, choose Add a Game, and click its icon. No hunting through folders.

---

## <a id="v1.30.10"></a>Your pet stays in sight when it jumps

<sub>1.30.10 · October 10, 2026</sub>

Your pet no longer disappears behind windows when it jumps on a screen without the Dock.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Before, if the Dock was on another display or hidden, your pet jumped behind your windows and vanished until it landed. Now, as soon as it leaves the ground, it shows in front of your windows on every screen, with or without the Dock. The ball does the same.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

A window that only touches the edge of your pet no longer keeps it hidden when it jumps. Your pet stays behind a window only when the window really covers it, like a video you’re watching.

Back on the ground, your pet and its ball walk behind your windows again, just like before.

**Try it:** Let the Dock hide or move it to another display, then press Space next to a window. Your pet jumps in front of it.

---

## <a id="v1.30.9"></a>Full screen stays yours, and the ball plays fair

<sub>1.30.9 · October 10, 2026</sub>

Your pet no longer slips into a full-screen video, and the ball stops bumping into things that aren’t there.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Before, while you watched a full-screen video, your pet could pop up now and then. Now pikapik asks macOS directly whether a screen is in full screen and checks once more when the switch is over. Your pet and its ball stay hidden until you leave full screen.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

The ball no longer bounces off empty air. It flies over the Dock instead of hitting an invisible wall above it. The mouse now hits the ball only when the pointer really touches it. A light touch rolls it, a quick flick sends it flying. And if your pet or its ball is hiding behind a window, moving the mouse over that window leaves them alone.

Dragging a file across the desktop no longer builds a step for your pet. Only a selection frame does.

**Try it:** Watch a video in full screen and pause it with Space a few times. Your pet stays out of sight. Then flick the mouse at the ball.

---

## <a id="v1.30.8"></a>Screen corners stay quiet while you play

<sub>1.30.8 · October 10, 2026</sub>

In Game Mode, the mouse at the edges and corners of the screen no longer sets off hot corners or pulls out a hidden Dock.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

Before, while you played, moving the mouse into a corner or to the edge of the screen could set off a hot corner or pull out a hidden Dock right in the middle of a game.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Now Game Mode switches hot corners and the hidden Dock off while you play. A few seconds after you leave the game, or when you quit pikapik, they come back exactly as they were.

And the pointer no longer stutters at the edge of the game’s screen.

**Try it:** Turn on Game Mode, start a game, and move the mouse into a corner of the screen. Nothing pops up.

---

## <a id="v1.30.7"></a>Your pet stays out of your video

<sub>1.30.7 · October 10, 2026</sub>

When your pet or its ball is behind a window, it stays there even when it jumps or flies.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Before, if your pet or its ball was hiding behind a video or a game, a jump or a flight could pop it up right over what you were watching. Pressing Space to pause a video could bring it out too.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Now they stay behind the window that covers them, whatever they do. And a full-screen video in Firefox hides them right away.

Behind ordinary windows they still slip in and out, just like before.

**Try it:** Play a video in a big window that covers the bottom of the screen and press Space to pause it. Your pet stays behind the video.

---

## <a id="v1.30.6"></a>Full screen means your pet takes a break everywhere

<sub>1.30.6 · October 10, 2026</sub>

While any app is in full screen, your pet and its ball now hide on every display.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Before, when you opened a video or a game in full screen, your pet and its ball sometimes ran off to another screen and kept playing there.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Now, while any app is in full screen, they hide on all your displays. Leave full screen, and they come right back.

Behind ordinary windows they still slip in and out, just like before.

**Try it:** If you have two displays, open a video in full screen on one of them. Your pet and its ball disappear from both and come back when you leave full screen.

---

## <a id="v1.30.5"></a>Your pet steps aside while you watch or play

<sub>1.30.5 · October 10, 2026</sub>

Your pet and its ball now hide while an app is in full screen, on Macs with a notch too.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Before, on a Mac with a notch, your pet could stay on top of a full-screen video or game, and the ball sometimes popped up over a full-screen app on another display.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Now, while an app fills the whole screen, your pet and its ball wait out of sight. Leave full screen, and they come right back.

Behind ordinary windows they still slip in and out, just like before.

**Try it:** Open a video in full screen or start a game. Your pet and its ball stay out of the way until you’re done.

---

## <a id="v1.30.4"></a>Your pet stays in sight when it jumps or rides a selection

<sub>1.30.4 · October 10, 2026</sub>

Your pet and its ball no longer vanish behind windows while they are up in the air.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Before, when your pet jumped over the pointer or rode a selection box up, a full-size window covered it, and it looked as if your pet was gone.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Now, while your pet or its ball is higher than the Dock, they show in front of your windows. Back on the ground, they go behind them again.

And your pet can walk behind the Dock again, just like before.

**Try it:** Make a window full size, start a selection box on the desktop next to the Dock so your pet climbs on, and slowly drag it up. Your pet rides it in front of the window.

---

## <a id="v1.30.3"></a>Your pet and its ball stay out from under the Dock

<sub>1.30.3 · October 9, 2026</sub>

Your pet no longer walks or naps under the Dock, so you can always see it.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Before, your pet and its ball often walked and rested right under the Dock, where nobody could see them. With a full-size window it looked as if your pet was gone for good.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

Now the Dock is like a wall for them. Your pet turns around at its edge, and the ball bounces off it.

So your pet always stays in sight next to the Dock, even when a window fills the whole screen.

**Try it:** Make a window full size and watch for a couple of minutes. Your pet is always visible to the left or right of the Dock.

---

## <a id="v1.30.2"></a>Your pet no longer disappears behind windows

<sub>1.30.2 · October 9, 2026</sub>

Even when a window covers your pet, it keeps living and falls to the ground when you let go of the selection.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

When windows covered the whole strip your pet lives on, pikapik paused it, and it could freeze in mid-air. Now your pet and its ball keep living behind the window: they walk, fall and play. Only the drawing takes a break.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

If a selection box lifts your pet up behind a window, it falls back down as soon as you let go, and you see it by the Dock again.

And a selection box no longer lifts your pet higher than its strip.

**Try it:** Make a window full size, lift your pet with a selection box behind it, then let go. Your pet falls and shows up by the Dock.

---

## <a id="v1.30.1"></a>Selections on the desktop work again

<sub>1.30.1 · October 9, 2026</sub>

Your pet and its ball jump onto selection boxes again, and app lists light up only for apps.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

When the Dock or a remote desktop app covered the whole screen, pikapik didn’t notice the selection box you drew on the desktop. Now it does again, and your pet and its ball jump onto it just like before.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

App lists in Settings light up only when you drag an app over them. Other files are ignored: no frame appears and nothing extra gets added. If you drag an app together with other files, only the app is added.

And the frame goes out as soon as you drop the app or move the pointer away.

**Try it:** Draw a selection box on the desktop and watch your pet jump onto it.

---

## <a id="v1.30.0"></a>Quit no longer switches pikapik off

<sub>1.30.0 · October 9, 2026</sub>

Pressed Quit out of habit? Your shortcuts, Keep Awake and your pet keep working anyway.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/keep-awake-dark.png"><img src="../media/keep-awake-light.png" width="340" alt=""></picture>

When you choose Quit, press ⌘Q or quit pikapik from the Dock, it closes its windows and hides its menu bar icon, but quietly keeps working in the background: shortcuts, Keep Awake and your pet stay on. To bring the icon back, just open pikapik again.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Want to quit for real? Hold Option and choose Quit, or press ⌥⌘Q. The first time pikapik goes into the background, it explains what happened and lets you quit completely right there.

Prefer the old way? Turn off “Keep running after Quit” in Settings › General. Updates, changing the language, logging out, restarting and shutting down always quit pikapik completely, so they never have to wait for it.

**Try it:** Press ⌘Q, then open pikapik again to bring its icon back.

---

## <a id="v1.29.1"></a>Your pet walks across all your screens

<sub>1.29.1 · October 9, 2026</sub>

Got more than one monitor? Your pet and its ball now go wherever you look, and they never get lost.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

When your pet reaches the edge of one screen, it simply steps over to the next one, and the ball rolls after it. You can also pick up the pet or the ball and carry it to any screen. If an app goes full screen, they move to another screen so they don’t get in the way, and if you unplug a monitor, they come back to the main one.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

The ball no longer gets stuck in a corner. Your pet runs up, scoops it back over its head and keeps playing.

And your pet never vanishes anymore. Every two seconds it checks that it’s still on screen, and if something went wrong, after sleep, locking the Mac, switching desktops or full screen, it comes right back on its own.

**Try it:** Carry your pet to another screen, or roll the ball into a corner.

**Fixed**

- A thrown pet no longer lands on a selection box that sits higher than it can reach, and no longer disappears because of it.

---

## <a id="v1.29.0"></a>Your pet has a ball

<sub>1.29.0 · October 9, 2026</sub>

A little football now rolls along the bottom of your screen. Your pet plays with it, and so can you.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.29.0/pet-ball-dark.png"><img src="../media/whats-new/1.29.0/pet-ball-light.png" width="340" alt=""></picture>

The ball rolls and bounces like a real one. Your pet runs after it, kicks it and chases it again. Flick the pointer quickly into the ball to kick it yourself, or pick it up, carry it and throw it, just like the pet.

Here’s a little trick. Click an empty spot on the desktop and drag to draw a selection box, with or without Shift. While you hold the mouse button, the box turns into a shelf: your pet jumps up onto it, and the ball can land there too. Let go, and the shelf is gone.

Rather keep the desktop calm? Turn off Ball in the pet settings, and your pet goes back to walking on its own.

**Try it:** Settings › Pet › Ball

**Fixed**

- Next to the Dock, the pet jumps as high as it likes again. It stays low only while it’s right over the Dock, so it never peeks out above it.

---

## <a id="v1.28.0"></a>Add apps with a click or a drag

<sub>1.28.0 · October 9, 2026</sub>

Every list of apps in Settings now shows what’s in your Dock and open right now, and you can drag apps onto it from Finder.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.28.0/app-shelf-dark.png"><img src="../media/whats-new/1.28.0/app-shelf-light.png" width="340" alt=""></picture>

Some features let you choose apps where they step aside, like the green button or Home and End. Before, Add App… only opened a long folder of everything you have. Now it shows a shelf with the apps in your Dock and the ones open right now. Click an app to add it, click it again to take it back. For anything else, pick Other…

You can also drag an app from Finder straight onto a list. The list lights up to show where the app will land. Your games work the same way, with the same shelf.

And if something goes wrong, the bug report form on GitHub now lets you pick your pikapik version and macOS from a list, so telling us about it takes less time.

**Try it:** Settings › Windows, then Add App…

**Fixed**

- Scrolling through AnyDesk or another remote desktop app is no longer turned around twice when you use the classic direction on both Macs. pikapik now flips only scrolling from a real mouse or trackpad. If an app makes its own smooth scrolling, like Mos, set the direction in that app.
- The pet stays behind the Dock when it jumps, just like when it walks, and comes back by itself after you leave a full-screen app or a game.
- The thin frames around the little pictures in Settings no longer disappear on regular, non-Retina displays.

---

## <a id="v1.27.3"></a>The pet stays in sight, and windows open ready

<sub>1.27.3 · October 9, 2026</sub>

The pet no longer hides behind windows in the middle of a jump, and pikapik’s windows open ready to use.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

When the pet hopped over the pointer or took a tumble, it could slip behind the windows of other apps and vanish in mid-air. Now it stays in front for the whole jump and goes back behind your windows once it lands.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

When pikapik started quietly in the background, at login, after an update or from a pikapik:// link, its windows could open gray and stay behind other windows until you clicked them. Now Settings and the New File box come to the front, ready for you to type.

The same goes for the message after Make a Smaller Copy and for the list where you pick an app to add. You don’t need to do anything.

**Try it:** Settings › Pet

---

## <a id="v1.27.2"></a>New File is back, and Settings are even lighter

<sub>1.27.2 · October 9, 2026</sub>

New File is back in Finder’s right-click menu for everyone, and Settings ask even less of your Mac.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

After the last update, Finder could restart New File in the background and forget which folders it works in, so the item quietly vanished from the right-click menu. Now New File reminds Finder of its folders every time it starts, and pikapik checks a little after launch that Finder got the message. You don’t need to do anything.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

The moving pictures in Settings now play only while at least half of a picture is on screen. In the game pictures the little hero still moves 30 times a second, and the hills and ground behind it 15 times, so the Games page asks much less of your Mac. Everything looks the same.

After an update, pikapik no longer re-adds its Finder items unless the app really moved, so Finder doesn’t have to reload them every time.

**Try it:** Settings › Games

---

## <a id="v1.27.1"></a>Quieter, lighter, and Finder ready right away

<sub>1.27.1 · October 9, 2026</sub>

Settings now barely use your Mac, and Finder’s right-click items work right after the move to pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/wheel-lines-dark.png"><img src="../media/wheel-lines-light.png" width="340" alt=""></picture>

The little moving pictures in Settings used to redraw the whole page many times a second, so an open window kept your Mac busy. Now each picture redraws only itself, no more than 30 times a second, and rests when you scroll past it or hide the window. They look just the same.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

After the move from pika-tools to pikapik, Finder could keep looking for the old app, so New File, Convert To and the other right-click items did nothing. pikapik now notices this on the first launch and restarts Finder by itself when no Finder windows are open and nothing is copying. Otherwise a short line on the Finder page offers a Restart Finder button.

In System Settings, among the apps that open at login, the app now shows its new name, pikapik, and stays turned on.

**Try it:** Settings › Finder

---

## <a id="v1.27.0"></a>Meet your desktop pet

<sub>1.27.0 · October 9, 2026</sub>

A little friend now lives at the bottom of your screen, and the app has a new name: pikapik.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/pet-dark.png"><img src="../media/pet-light.png" width="340" alt=""></picture>

Turn it on in Settings › Pet. It strolls behind your windows and the Dock, hops over the pointer when it’s in the way, and jumps when you press Space. Pick it up, carry it, toss it, and catch it again in the middle of a jump.

Every now and then it sits down and says something short. When a new version really comes out, it tells you once, and a click on it opens Settings, where the update is waiting.

pika-tools is now called pikapik. Your permissions, settings and Shortcuts links all stay as they were. If you installed it with Homebrew, run `brew update && brew upgrade --cask pikapik` once.

**Try it:** Settings › Pet

**Fixed**

- The update check said a new version was out even when you already had the latest one.
- The Permissions page kept your Mac busy while it was open.

---

## <a id="v1.26.2"></a>What’s New, in your language

<sub>1.26.2 · October 8, 2026</sub>

What’s New in Settings now opens the What’s new page, in the same language as the app.

<img src="../media/icon.png" width="128" height="128" alt="">

Open Settings › About and click What’s New. You get the What’s new page, with a picture for every update, in the language pika-tools speaks.

The full list of changes is tidier too. Every version shows the day it came out, and every version number opens its download page.

Nothing changes in how pika-tools works. Updates arrive as before, on their own or through Homebrew.

**Try it:** Settings › About › What’s New

**Fixed**

- What’s New opened a long technical list in English instead of the What’s new page.
- Links in the list of changes that led nowhere now open the right page.

---

## <a id="v1.26.1"></a>The game pictures come to life

<sub>1.26.1 · October 8, 2026</sub>

The pictures on the Games page now play, so you see what each switch stops.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.26.1/game-previews-dark.png"><img src="../media/whats-new/1.26.1/game-previews-light.png" width="340" alt=""></picture>

Behind every switch on the Games page, a little game is now running. Keys appear and get pressed, and you see what would pop up over your game, like Spotlight or Mission Control, while the game stops. When the switch is on, the keys only glow softly and the game keeps going. Flip a switch, and the picture shows the difference right away.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

The little game follows the look of your Mac: a sunny day in light mode and a calm night with the moon and stars in dark mode.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/new-file-dark.png"><img src="../media/new-file-light.png" width="340" alt=""></picture>

In every picture in the app, the pointer now moves like a hand: it takes a bit longer over long distances, comes to rest, and only then clicks. When a picture starts over, it glides back to the beginning instead of jumping. The pictures rest while the window is hidden, and with Reduce motion turned on they stand still.

**Try it:** Settings › Games

---

## <a id="v1.26.0"></a>A new icon, and a clean slate for old permissions

<sub>1.26.0 · October 8, 2026</sub>

pika-tools has a new face, and it can now clear the permissions that deleted apps leave behind.

<img src="../media/icon.png" width="128" height="128" alt="">

The new icon is the pikapik mark in blue, violet and coral on a dark tile. The menu bar shows the same shape and follows a light or dark menu bar. When every tool is off, the shape turns pale.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/leftover-permissions-dark.png"><img src="../media/leftover-permissions-light.png" width="340" alt=""></picture>

When you delete an app, macOS keeps the permissions you gave it, and System Settings has no way to remove them. Now the Permissions page has a list called “Left by deleted apps”: each app with its icon, what it was allowed to do and when. “Remove” clears one app, “Remove All” clears them all, and an app you install again simply asks again. To see the list, give pika-tools Full Disk Access: it only looks and changes nothing until you press “Remove”.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/animations-dark.png"><img src="../media/animations-light.png" width="340" alt=""></picture>

The pictures on the Animations and Games pages are drawn anew for their real size, so they look sharp. A window shrinks into the Dock with round corners, and the pointer clicks first, and only then a menu opens. And at the bottom of About there is now a quiet line, “Made with care · Buy me a coffee”. Nothing pops up or reminds you, ever.

**Try it:** Settings › Permissions, then “Left by deleted apps”

**Fixed**

- Clicking a system shortcut takes you straight to its own section in System Settings, like Mission Control, not just to “Keyboard”.
- The tip next to the keys no longer disappears the moment System Settings opens.

---

## <a id="v1.25.2"></a>Shortcuts open where you change them

<sub>1.25.2 · October 8, 2026</sub>

Click a shortcut in Settings, and System Settings opens in the right place.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

Before, clicking a shortcut, like the one for Spotlight, always took you to “Modifier Keys”. Now the Spotlight keys open right on Spotlight.

For the other shortcuts, System Settings opens on “Keyboard”, and a short tip next to the keys tells you where to click: “Keyboard Shortcuts…”, then “Mission Control” or another section.

It works the same on the Games page and for “Cut files in Finder”. For cutting files, the tip leads you to “App Shortcuts”.

**Try it:** Settings › Games, then click the keys next to “Search doesn’t pop up”

**Fixed**

- Clicking a shortcut no longer opens “Modifier Keys”.

---

## <a id="v1.25.1"></a>Big pictures, and games right from your Dock

<sub>1.25.1 · October 8, 2026</sub>

Every switch now has a big picture, and Add a Game… shows what’s in your Dock.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.25.1/dock-games-dark.png"><img src="../media/whats-new/1.25.1/dock-games-light.png" width="340" alt=""></picture>

On the Animations and Games pages, every picture is now big, just like the one at the top of the page. It’s easier to see what each switch does, and the pictures still move at the speed you pick.

Press Add a Game… and you see your Dock: the apps you keep there and the ones open right now, in the same order. A game you keep in the Dock shows up even when it’s closed, Minecraft too. One click adds it, and a check mark shows it’s on the list. Click again to take it off.

You can still drag a game here from Finder. There’s no need to pull it out of the Dock anymore, so the Dock won’t offer to remove it.

**Try it:** Settings › Games, then Add a Game…

**Fixed**

- A game that sits in the Dock but is closed now shows up in the list for adding.

---

## <a id="v1.25.0"></a>Add a game in one click, and choose your own keys

<sub>1.25.0 · October 8, 2026</sub>

Adding a game is now as easy as picking it from what’s open, and the keys for quitting and closing can be your own.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.25.0/game-pictures-dark.png"><img src="../media/whats-new/1.25.0/game-pictures-light.png" width="340" alt=""></picture>

Press Add a Game…, and the apps that are open right now appear with big icons, like in the Dock. One click adds a game, or drag its icon into the list. You can also drop a game straight from Finder or the Dock. Any app can be a game, even Minecraft that runs on Java, and your earlier games carry over.

Game Mode switches now speak plainly, like “The game doesn’t close” or “Search doesn’t pop up”, and each has a small picture of what it stops. The system name, such as Spotlight, sits next to it in gray.

In Settings › Windows, click the keys next to Quit app or Close window and press new ones. ⌫ brings back ⇧⌘Q and ⇧⌘W, and if the keys are already taken, pika-tools asks first. Game Mode uses your keys too. And every shortcut in Settings now shows how it’s really set up on your Mac: your keys, or Off.

**Try it:** Settings › Games, then Add a Game…

**Fixed**

- Cutting files in Finder follows the Cut shortcut you set for Finder in System Settings.
- App names in lists show without “.app”.

---

## <a id="v1.24.1"></a>Speed changes you can see right away

<sub>1.24.1 · October 8, 2026</sub>

The Animations page now tells you where a change shows up, and it keeps your own values safe.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/dock-hide-dark.png"><img src="../media/dock-hide-light.png" width="340" alt=""></picture>

The Dock can slide out faster only if it hides. If yours always stays in place, the switch to hide it automatically now sits right under the speed slider.

After a change, a line at the bottom of the page says that apps pick it up once you open them again. Finder shows new Quick Look and column speeds only after a restart, so the line has a Restart Finder button.

The slider never slows down what you had already sped up, for example with commands in Terminal. And Restore Defaults or uninstalling pika-tools brings back the values you had before, instead of erasing them.

**Try it:** Settings › Animations

**Fixed**

- The Dock no longer restarts for nothing when it doesn’t hide.

---

## <a id="v1.24.0"></a>Choose how fast your Mac moves

<sub>1.24.0 · October 8, 2026</sub>

A new Animations page sets how quickly things open, slide and appear on your Mac.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/animations-dark.png"><img src="../media/animations-light.png" width="340" alt=""></picture>

One slider does it all. Move it, and the hidden Dock, new windows, Save dialogs, Quick Look and columns in Finder speed up together, from as in macOS to instant.

Want to tune just one thing? Each effect has its own setting, and so do the minimize effect, bouncing icons in the Dock and Finder animations. Next to every setting, a small picture moves at exactly the speed you chose.

Restore Defaults puts back only what pika-tools changed, and so does uninstalling it. If you once set one of these values yourself in Terminal, pika-tools shows it as it is.

**Try it:** Settings › Animations

---

## <a id="v1.23.2"></a>A switch for every shortcut in Game Mode

<sub>1.23.2 · October 8, 2026</sub>

Now you decide, one shortcut at a time, what Game Mode keeps quiet while you play.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/whats-new/1.23.2/game-shortcuts-dark.png"><img src="../media/whats-new/1.23.2/game-shortcuts-light.png" width="340" alt=""></picture>

⌘Q and ⌘W have separate switches now, and so do Spotlight, Siri, ⌘Tab, Mission Control, swipes, the pointer, the screen and the rest. Your earlier choices carry over.

Each row shows exactly the keys it stops, so you always know what a switch does.

The keyboard language setting has left Game Mode. ⌃Space and other ways to switch the language always work, even in a game.

**Try it:** Settings › Games

**Fixed**

- Keys of one shortcut sit closer together, with a little more room between different shortcuts, so it’s easy to see where one ends and the next begins.

---

## <a id="v1.23.1"></a>How fast your internet is, in plain words

<sub>1.23.1 · October 8, 2026</sub>

Speed Test checks your connection and tells you simply what it’s good for.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/speed-test-dark.png"><img src="../media/speed-test-light.png" width="340" alt=""></picture>

Press Check Speed, and in about half a minute you’ll see download, upload, ping and responsiveness. Below the numbers, plain words say whether it’s enough for 4K movies, video calls, online games and big downloads.

The check runs on Apple’s servers, and the last result stays until the next one. Speed Test has its own page in Settings, a row in the menu bar panel and a link for the Shortcuts app: `pika-tools://speed-test`.

Game Mode learned two things. Blocking Control shortcuts is now part of it: in a game, ⌃-click stays a click and ⌃ shortcuts don’t fire, and everywhere else ⌃ works as usual. And it recognizes Minecraft: add the Minecraft Launcher or CurseForge to your games, and Game Mode turns on while Minecraft itself is in front.

**Try it:** Settings › Speed Test, then Check Speed

**Fixed**

- Test versions of pika-tools that people build themselves keep their settings apart in iCloud Drive and no longer touch yours.

---

## <a id="v1.23.0"></a>Game Mode: play without interruptions

<sub>1.23.0 · October 7, 2026</sub>

Add your games, and your Mac stops pulling you out of them.

<picture><source media="(prefers-color-scheme: dark)" srcset="../media/game-mode-dark.png"><img src="../media/game-mode-light.png" width="340" alt=""></picture>

While you play, Spotlight, Siri, ⌘Tab, Mission Control and swipes between desktops don’t open over the game. ⌘Q and ⌘W don’t close it by accident, the pointer stays on the game’s screen, and the screen stays on.

To leave a game, press ⇧⌘Q; to close its window, press ⇧⌘W. ⌥⌘Esc always works. pika-tools suggests games it finds on your Mac. Game Mode is off until you turn it on.

Keep Awake lets you choose what the screen does: stay on, with no screen saver or lock screen, or turn off as usual while your Mac keeps working. The new Turn off the display now button darkens it at once; move the mouse or press a key to bring it back.

**Try it:** Settings › Games, then Add a Game…

**Fixed**

- On Macs without a lid, Keep Awake no longer shows the closed-lid options.

---

<p align="center"><sub>Earlier versions are in the <a href="../../CHANGELOG.md">changelog</a>.</sub></p>
