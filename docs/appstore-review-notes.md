# App Review notes

## What the app is
pikapik is a menu-bar utility suite for macOS. It has no Dock icon window of its own; everything lives in the menu bar and one Settings window. Every feature is off by default and is switched on by the user, one by one.

## Features in this build
- Keyboard: Switch language (input source shortcut), Command key shortcuts.
- Mouse: Scroll by lines (mouse wheel), Scroll direction for trackpad and mouse, Side buttons go back and forward.
- Finder: New File in Finder, Smaller Copy in Finder, Convert in Finder (Finder Sync and Action extensions).
- Extras: Game Mode, Pet (a small animated companion on the desktop that can wear clothes and earn awards), Keep Awake, Speed Test.

## Not in the App Store version
These features need to look inside other apps, which the App Sandbox does not allow. They are only in the version we distribute outside the App Store.
- Home and End go to the start and end of a line.
- Green button enlarges the window.
- Quit when the last window closes (also Protect quitting and closing).
- Minimize or hide with a click in the Dock.
- Enter opens files, Cut files and Delete removes files in Finder.
- Key repeat, pointer shortcuts, Archives in Finder, Animations, Trash watcher, fan control and the built-in updater.

## How to try it
No account or demo login is needed. Open pikapik from the menu bar, then Settings.

Tools that work with no permission:
- Keep Awake: Settings > Keep Awake, turn it on; the Mac will not sleep until it is turned off or the chosen duration ends.
- Speed Test: Settings > Speed Test, press Check Speed; download and upload speed appear in a few seconds.
- Settings file: Settings > General, press Export Settings…, then Import Settings… to load the file back.
- Finder extensions: see below.

Tools that need a permission (the prompt appears when the tool is switched on):
- Switch language (Input Monitoring): Settings > Keyboard, turn on, pick a shortcut, press it in any text field.
- Command key shortcuts (Input Monitoring): Settings > Keyboard, turn on, use the Command key shortcuts in any text field.
- Scroll by lines, Scroll direction, Side buttons (Input Monitoring): Settings > Mouse, turn on, then scroll or press a side button.
- Pet (Accessibility): Settings > Pet, turn on; the pet appears on the desktop.
- Game Mode > Show FPS (Screen Recording): Settings > Games, turn on Game Mode, then Show FPS.

## Finder extensions
They need no permission prompt, only a switch in System Settings > General > Login Items & Extensions > Finder. Settings > Permissions > Finder Extensions opens it.
- New File in Finder: right-click the empty space in a Finder window, choose New File, pick a type; the file is created in that folder.
- Smaller Copy in Finder: right-click an image, video or PDF, choose Make a Smaller Copy; a smaller copy is saved next to the original.
- Convert in Finder: right-click an image, audio or video file, choose Convert To and a format; the converted copy is saved next to the original.
The first time, the app asks the user to choose the folder it may save into (Settings > Permissions > Folders).

## Keep Awake and Speed Test
- Keep Awake only asks macOS not to sleep while it is on. It reads and sends nothing.
- Speed Test runs only when the user presses Check Speed. The only server contacted is speed.cloudflare.com, and no personal data is sent.

## Open at Login
Open at Login is off by default. It is a switch in Settings > General that the user turns on.

## Permissions
The app asks for up to three permissions, only when a feature that needs them is switched on. Nothing is requested at first launch.

- Accessibility: Pet uses it to read where the Dock is, so the pet can walk along it.
- Input Monitoring: Switch language, Command keys, Scroll by lines, Scroll direction and Side buttons use it to see the key or mouse event the user configured so the app can act on it.
- Screen Recording: Show FPS (Settings > Games, optional) uses it to count how many frames a game draws each second, from a tiny low-resolution ScreenCaptureKit view of the game's display. Only the number of changed frames is kept; no picture is ever stored, logged or sent anywhere.

To reproduce each prompt:
1. Open pikapik from the menu bar, then Settings.
2. Turn on any feature from the Keyboard or Mouse tab. The system Accessibility prompt appears first; the Input Monitoring prompt follows if the feature needs it.
3. In Settings > Games turn on Game Mode, then Show FPS. The line "Needs a permission. Click to allow it." appears under the switch; its Allow button opens the Permissions page on the Screen Recording row and the system Screen Recording prompt appears. Nothing is ever asked while a game is running.
4. The Permissions page in Settings lists Accessibility, Input Monitoring, Screen Recording (only while Show FPS is on and the permission is missing), Finder Extensions and Folders with their state and one button, Allow or Turn Off. Turn Off opens the matching list in System Settings > Privacy & Security; for Folders the app forgets the saved access right away. Tools that need a missing permission look half-grey and open this page when clicked.

Events are processed in memory to trigger the feature. They are never stored, logged or sent anywhere.

## Pet wardrobe and awards
Settings > Pet has a wardrobe of 38 things the pet can wear, 10 ready-made looks and 24 awards. Six things are free and the rest are unlocked by awards, which are earned only by using the pet. Nothing is sold, and network access unlocks nothing.

The app keeps plain totals of what the user and the pet do (steps, pick-ups, high throws, jumps, leaps, climbs, tumbles, catches, kicks, ball pushes, phrases, days together, Settings pages opened, things tried on, visits to the Pet page), the date of each award and the worn outfit. They are stored only in the app's preferences under five keys (pet-counts, pet-awards, pet-seen, pet-fresh, pet-outfit), are never sent anywhere and are not part of exported settings. The totals never record which keys were pressed or what was clicked. Erase Progress… in the Awards section of Settings > Pet deletes all five keys after a confirmation.

## In-app purchases
This version has no in-app purchases. The tip jar in Settings > About stays hidden while no tip products exist in App Store Connect.

## Privacy
- No login, no account.
- No data collection, no analytics, no advertising, no tracking. See the privacy manifest in the bundle.
- Pet progress (plain totals, award dates and the worn outfit) stays in the app's preferences on this Mac, is never sent anywhere and can be erased in Settings > Pet.
- The only network use is the Speed Test the user starts.

## Not in this build
Features that need private APIs or root rights are absent: key repeat tuning, pointer acceleration, Animations tweaks, Fan control, the automatic updater, the leftover-permissions cleaner and the Uninstaller. The sandbox is on.
