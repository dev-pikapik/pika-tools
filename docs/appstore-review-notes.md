# App Review notes

## What the app is
pikapik is a menu-bar utility suite for macOS. It has no Dock icon window of its own; everything lives in the menu bar and one Settings window. Every feature is off by default and is switched on by the user, one by one.

## Features in this build
- Keyboard: Switch language (input source shortcut), Home and End go to the start and end of a line, Command key shortcuts.
- Mouse: Scroll by lines (mouse wheel), Scroll direction for trackpad and mouse, Side buttons go back and forward.
- Windows: Green button enlarges the window, Quit when the last window closes, Protect quitting and closing.
- Dock: Hide with a click in the Dock.
- Finder: New File in Finder, Smaller Copy in Finder, Convert in Finder (Finder Sync and Action extensions), Enter opens files, Cut files, Delete removes files.
- Extras: Game Mode, Pet (a small animated companion on the desktop), Keep Awake, Speed Test.

## Permissions
The app asks for two permissions, only when a feature that needs them is switched on. Nothing is requested at first launch.

- Accessibility: Window zoom, Quit on close, Protect quitting, Hide with a click in the Dock, Enter/Cut/Delete in Finder, and Pet use it to read window and Dock element positions and to send the requested shortcut to the frontmost app.
- Input Monitoring: Switch language, Home and End, Command keys, Scroll by lines, Scroll direction, Side buttons, and the Finder keys use it to see the key or mouse event the user configured so the app can act on it.

To reproduce each prompt:
1. Open pikapik from the menu bar, then Settings.
2. Turn on any feature from the Keyboard, Mouse or Windows tab. The system Accessibility prompt appears first; the Input Monitoring prompt follows if the feature needs it.
3. The Permissions page in Settings shows both states and opens System Settings > Privacy & Security.

Events are processed in memory to trigger the feature. They are never stored, logged or sent anywhere.

## Tips (in-app purchase)
Settings > About has an optional tip jar with three consumable in-app purchases:
- com.pesotchi.pika-tools.appstore.tip.small
- com.pesotchi.pika-tools.appstore.tip.medium
- com.pesotchi.pika-tools.appstore.tip.large

Tips unlock nothing. All features work the same without them. If the products cannot be loaded, the page shows a short message and a Try Again button.

## Privacy
- No login, no account.
- No data collection, no analytics, no advertising, no tracking. See the privacy manifest in the bundle.
- The only network use is the Speed Test the user starts, and the App Store tip purchase.

## Not in this build
Features that need private APIs or root rights are absent: key repeat tuning, pointer acceleration, Animations tweaks, Fan control, the automatic updater and the leftover-permissions cleaner. The sandbox is on.
