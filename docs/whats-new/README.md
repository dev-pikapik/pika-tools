<p align="center"><a href="../../README.md"><img src="../media/icon.png" width="96" height="96" alt="pika-tools"></a></p>
<h1 align="center">What’s new in pika-tools</h1>
<p align="center">Every update in a few words and a picture, newest first.</p>
<p align="center"><sub><b>English</b> · <a href="README.ru.md">Русский</a> · <a href="README.uk.md">Українська</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.es.md">Español</a> · <a href="README.it.md">Italiano</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ja.md">日本語</a> · <a href="README.zh-Hans.md">简体中文</a> · <a href="README.ko.md">한국어</a> · <a href="README.ro.md">Română</a> · <a href="README.pl.md">Polski</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.nl.md">Nederlands</a> · <a href="README.sv.md">Svenska</a> · <a href="README.cs.md">Čeština</a> · <a href="README.zh-Hant.md">繁體中文</a> · <a href="README.ar.md">العربية</a> · <a href="README.hi.md">हिन्दी</a> · <a href="README.id.md">Bahasa Indonesia</a> · <a href="README.vi.md">Tiếng Việt</a> · <a href="README.th.md">ไทย</a></sub></p>

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
