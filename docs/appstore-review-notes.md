pikapik - Mac Tools: information for App Review (Guideline 2.1)

1. Screen recording
Attached: a MacBook Pro with the latest macOS, from launch through the typical flow and each tool below.

2. Purpose and audience
pikapik is a free menu-bar app that fixes small everyday Mac annoyances, for Mac users who use a mouse, type in two languages, play games or want quick Finder actions. A small pet walks on the desktop.

3. Setup and main features
No account or sample files are needed (any photo or video works). Settings opens on first launch, later from the menu-bar icon; nothing is asked at launch; only the Pet is on.
- Keep Awake (Turn off the display now: IORequestIdle on IODisplayWrangler, allowed by the sandbox profile), Speed Test, Temperature (thermal state, battery), Battery (Macs with a battery), App Volume (macOS 14.2+: a slider and mute per app), Brightness (dims an external monitor's picture).
- Background Tasks: what starts in the background; view only. Animations, pointer acceleration, Other apps’ permissions: buttons only open System Settings.
- Hide desktop icons: a click-through window above the icons shows the wallpaper (NSWorkspace.desktopImageURL); no Screen Recording.
- Keyboard, with two input sources such as ABC and Russian. Switch language: hold Option, tap Shift. Fix Wrong Keyboard Layout: select "ghbdtn" (for "привет"), then Services > Fix Wrong Keyboard Layout, or turn on its shortcut and press ⌃⇧Space; or turn on Fix words as you type, type ghbdtn, Space. Home and End: an event tap sees only those keys and posts ⌘←/⌘→ (CGEvent); nothing is kept.
- Mouse: Scroll by lines, Scroll direction, Side buttons, Mouse button hides the current app.
- Protect quitting and closing: ⌘Q and ⌘W alone do nothing; ⇧⌘Q quits and ⇧⌘W closes.
- Finder: turn on New File, Smaller Copy or Convert, press Allow, switch the extension on in System Settings, then right-click in Finder; at first it asks for a save folder, the only place they write. Cut files: select files, press ⌘X, open another folder, press ⌘V: the files move.
- Game Mode: turn it on, press Add a Game… (e.g. Chess) and open it. While it is in front, system shortcuts and swipes don't pull the player out. It reads them with Carbon CopySymbolicHotKeys and /System's DefaultShortcutsTable.xml.
No private API. Entitlements: sandbox, network client, user-selected files, bookmarks, audio input (App Volume's taps; no microphone).
Permissions: a tool that needs one looks grey; a click shows the macOS prompt (App Volume: via Allow; Show FPS: a line under it) and opens Settings > Permissions. Accessibility (on macOS 27: Device Control and Data Access), to change or hold back a scroll, click, key, shortcut or swipe: the Mouse tools, Brightness keys, Protect quitting and closing, Cut files, Home and End, Fix Wrong Keyboard Layout and Game Mode. Input Monitoring: Switch language (its shortcut) and the Pet's jump. System Audio Recording: App Volume. Screen Recording: Show FPS. Folders: Background Tasks in the home folder. The Services command needs none. Events and sound stay in memory, never stored or sent. The app never pastes into other apps; it sends only ⌘Q, ⌘W, Finder's ⌘C, ⌘X and ⌥⌘V, ⌘←, ⌘→, ⌃⌥⇧⌘F19 (its own Services key), a back or forward swipe and Backspace plus the fixed word as you type.

4. External services
Only Speed Test: speed.cloudflare.com, when the user starts a check; no personal data. No accounts, analytics, ads, tracking, payment processors or AI services.

5. Regions
No regional differences; 23 languages.

6. Regulated industry or third-party material
None; no documents are needed.

Other: free, no in-app purchases; Open at Login is off by default; no data is collected (privacy manifest); Pet clothes unlock with awards, nothing is sold.

— конец текста для App Store Connect —

Everything above the line goes into the Notes field of App Review Information in App Store Connect as is; it must stay within 4000 characters. The details below are for answering App Review questions.

### Cut files in Finder
- Select files, press ⌘X, open another folder, press ⌘V: the files move. ⌘C cancels. The app only checks whether the clipboard holds files and never reads it.
- In Finder ⌘X becomes ⌘C, so Finder copies the files as usual. Then ⌘V in Finder becomes ⌥⌘V, Finder's own Move Item Here, so Finder itself moves the files and shows its own message if it can't.
- When the copied thing is text, for example while a file is being renamed, the app sends ⌘X again, so the text is cut as usual.
- ⌘V changes only in a Finder window and only while cut files wait: after anything else is copied or after ⌘C, ⌘V pastes as usual. The App Store version doesn't read Finder's window, so it can't tell that a name is being edited; pressing ⌘C there first cancels the cut, and then ⌘V pastes text.

### Permissions page
Until Accessibility and Input Monitoring are both on, Settings > Permissions is headed "Permissions for some tools" and says that only some tools need these permissions and everything else works without them. It lists Accessibility (on macOS 27 under its new name, Device Control and Data Access), Input Monitoring, Screen Recording (only while Show FPS is on and the permission is missing), System Audio Recording (once App Volume is turned on), Finder Extensions (while New File, Smaller Copy or Convert is on) and Folders, each with its state and one button, Allow or Turn Off. The app asks for a permission only here or from a grey tool that leads here, never at launch and never during a game. A grey tool that needs Accessibility, Input Monitoring or Screen Recording shows the macOS prompt when clicked; for System Audio Recording the prompt comes from Allow on this page. Turn Off opens the matching list in System Settings, where the user switches pikapik off: a Privacy & Security list, or the Finder extensions list for Finder Extensions; for Folders the app forgets the saved access right away. Below them, Left by deleted apps has one Open button for each Privacy & Security list.

### Buttons to System Settings
In the App Store version the app changes no system setting itself; these buttons only open a System Settings page:
- Turn off pointer acceleration (Settings > Mouse): Open goes to System Settings > Mouse, where the user clicks Advanced… and turns off Pointer acceleration. System Settings shows the Mouse page only while a mouse is connected.
- Animations (Settings > Animations): each Open button goes to System Settings > Desktop & Dock for one setting (minimize effect, bouncing icons, hiding the Dock); the link at the bottom opens Accessibility > Display for Reduce Motion.
- Other apps’ permissions (Settings > Permissions): each Open button opens one list in System Settings > Privacy & Security, where the user removes an app that was deleted. Next to it, the icons of apps in /Applications whose Info.plist has a usage description for that list (camera, microphone, Apple Events, folders, Bluetooth): the app reads those files only, says the apps can ask, and never claims they were allowed. Nothing leaves the Mac.
- Battery Settings… (Settings > Battery) opens System Settings > Battery.
- Turn On… and Turn Off… (Settings > Background Tasks) open Login Items in System Settings.

### Background Tasks
Settings > Background Tasks lists what starts in the background and which app added it: launch agents and daemons in /Library and in the user's Library, and helpers inside apps (Contents/Library/LaunchAgents, LaunchDaemons and LoginItems). It reads these property lists and SMAppService.statusForLegacyPlist, and runs /bin/launchctl print for the gui/<uid>, user/<uid> and system domains, read-only, to tell which tasks are loaded or running now.
- Tasks in the home folder appear only after the user allows it. The page says "To see the tasks in your home folder, allow access to it."; Allow shows the standard Open panel at the home folder with the button Allow Access. Turn Off on the Folders row of Settings > Permissions forgets that access.
- View only: in the App Store version pikapik loads, unloads, edits or deletes nothing. Turn On… and Turn Off… open Login Items in System Settings, where the user changes it; Show in Finder reveals the file.
- Left by deleted apps groups tasks whose app is gone, so the user can find them.

### Battery
Shown only on Macs with a battery. It reads the battery's condition, maximum capacity and cycle count, the power adapter, charging power and power use from IOKit: the power-source keys and the AppleSmartBattery entry in the I/O Registry. It launches no other program (no system_profiler) and changes nothing: Battery Settings… opens System Settings > Battery, and the row about Charge Limit and Optimized Battery Charging only explains the macOS setting. No permission.

### Temperature
In the App Store version Temperature shows the macOS thermal state (ProcessInfo.thermalState) and what it means for speed. On a Mac with a battery it also shows the battery temperature, read from the AppleSmartBattery entries in the I/O Registry, like the Battery page. It reads no other sensors.

### Speed Test
Settings > Speed Test measures download and upload speed with https://speed.cloudflare.com through an ephemeral URLSession, so no cookies or cache are kept. The caption says "Takes about 15 seconds. The check uses speed.cloudflare.com." A check starts only from Check Speed, from Check on the Speed Test card in the menu-bar menu (hidden until the user adds it) or from a pikapik-store://speed-test link the user opens. Only the last result is kept, in the app's preferences on this Mac.

### App Volume
Settings > Sound, macOS 14.2 and later (hidden on 14.0 and 14.1), off by default: a volume slider and a mute button for each app that plays sound. It needs System Audio Recording to change the volume of one app without touching the others. For an app whose slider is below 100% or that is muted, the app creates a private Core Audio process tap on that app only (AudioHardwareCreateProcessTap) and plays the same sound, scaled by the slider, to the output device the app was using; an app left at 100% gets no tap. The sound is processed on the fly in memory and is never recorded, stored, logged or sent anywhere. The entitlement com.apple.security.device.audio-input is there only so the sandboxed app can read other apps' sound through these system process taps. The microphone is never opened, and the app has no microphone usage description. The system prompt shows NSAudioCaptureUsageDescription: "pikapik passes each app’s sound through itself to change its volume. Nothing is recorded or saved."
- To try it: turn on App Volume. The row looks half-grey until System Audio Recording is allowed; clicking it opens the Permissions page on the System Audio Recording row, and Allow shows the system prompt (after a refusal it opens System Settings > Privacy & Security instead). Once it is allowed, play sound in any app: the app appears in the list with a slider and a mute button. Nothing is asked while App Volume is off.
- To learn whether the permission is given, the app briefly plays an inaudible test signal and taps only its own process.
- Add App… and the ✕ (Forget This App): the level, mute and name of each app the user set are kept in the app's own preferences, so a closed app stays in the list and gets its level back when it plays sound again; the ✕ deletes them and restores full volume. Nothing is sent anywhere.

### Monitor Brightness
Settings > Brightness: a slider for each external monitor that macOS can't adjust. This build only dims the picture, so no permission is needed.
- To try it: connect an external monitor, open Settings > Brightness and move its slider; the picture on that monitor gets darker, and moving the slider back restores it.
- Brightness keys (Settings > Brightness, optional) need Accessibility: they catch the brightness keys and change the monitor under the pointer.

### Fix Wrong Keyboard Layout
Settings > Keyboard. Add two input sources, for example ABC and Russian. In any app, select text typed in the wrong one (such as "ghbdtn" instead of "привет") and choose Services > Fix Wrong Keyboard Layout in the app menu or the right-click menu; this needs no permission. The standard macOS Services mechanism (NSServices in Info.plist) passes only the selected text to pikapik, only on that command, and the app the user is in puts the fixed text in place of the selection. This command does not type, paste or watch typing.
Optional shortcut, off by default: turn on Fix the selected text below it, then select the text and press ⌃⇧Space (the user can record other keys there). It needs Accessibility, asked for in Settings > Permissions. An event tap holds back only that key combination and sends ⌃⌥⇧⌘F19 instead, the Services command's own key (NSKeyEquivalent in Info.plist), so the app in front runs the same command on its selection. With Fix words as you type off, every other key passes untouched; nothing is read, logged or stored.
Fix words as you type, off by default: turn it on under the shortcut, type "ghbdtn" and press Space; it becomes "привет" and the input source switches. It needs Accessibility. The event tap keeps only the letters of the current word in memory and clears them on every click, arrow, ⌘ or ⌃ combination, app switch and input source switch; nothing is logged, stored or sent. On Space or Return after a word typed in the wrong layout (4 or more letters, unknown in the current language and likely in the other one) it posts one Backspace per letter, then the fixed word as Unicode key events (CGEvent). It never runs in password fields (Secure Event Input), in apps the user excludes, in terminals or while Game Mode is playing. Pressing the shortcut right after a fix undoes it, and that word is not fixed again.

### Mouse button hides the current app
Settings > Mouse. Turn it on, then press a mouse button over the Settings window to choose it, for example the middle one. That button then hides the front app with NSRunningApplication.hide(), the same as ⌘H; no keystroke is sent. Accessibility is needed because the chosen button's click is held back, so the app under the pointer doesn't get it too.

### Keep Awake: Turn off the display now
Settings > Keep Awake and the menu button. It darkens the display by setting the IORequestIdle property on IODisplayWrangler. The App Sandbox profile allows this property explicitly. Nothing runs outside the sandbox, and the Mac keeps working until the user moves the mouse.
- To try it: press Turn off the display now; the display goes dark; move the mouse and it comes back.

### Hide desktop icons
Settings > Finder. In the App Store version it doesn't change any system setting. It covers the desktop icons with a click-through window just above the icon layer that shows the user's wallpaper, read with the public NSWorkspace.desktopImageURL API. It uses no private API and doesn't need Screen Recording. With a moving (Aerial) wallpaper the window shows a plain fill colour.
- To try it: turn on Hide desktop icons; the icons disappear and clicks still reach the desktop; turn it off and they return.

### Home and End
Settings > Keyboard, off by default. When the user turns this on, the app uses a keyboard event tap, allowed in the Permissions tab (Input Monitoring / Accessibility), to catch only the Home and End keys. It posts ⌘← or ⌘→ through the public CGEvent API instead. It doesn't store, log or send any keystroke, and it lets every other key pass through unchanged. Browsers, Finder, Music and TV are left alone, because ⌘← and ⌘→ mean Back or change tracks there.
- To try it: turn it on, click in a text field, press End and then Home; the cursor goes to the end and start of the line.

### Game Mode
Settings > Games. It reads the user's system keyboard shortcuts with the public Carbon API CopySymbolicHotKeys and Apple's read-only DefaultShortcutsTable.xml in /System. It needs no new entitlement and calls no private API. It pauses those shortcuts and Dock swipes through a Quartz event tap that the user enables in Accessibility. In the App Store version it doesn't touch Dock preferences and doesn't move or hold the pointer. After the Mac wakes from sleep or the user switches back to their account, Game Mode checks the front app again and turns itself back on.

### Archives in Finder
Only in a package built with the Archive and Preview profiles; without them scripts/appstore.sh leaves both extensions out, Settings > Finder has no Archives row and the app opens no archives.
Settings > Finder. The Archive and Quick Look extensions only read and write files in folders the user picked; they use macOS's built-in /usr/bin/tar and ditto inside the app sandbox and download or run no other code. Only ZIP can have a password; it is passed on stdin, never on the command line. While a job runs, the app holds one ProcessInfo activity (idle system sleep disabled; the display may still sleep) and lets it go when the queue is empty or a prompt waits.
- To try it: right-click an archive in Finder and choose Extract; right-click files and choose Create Archive…; select an archive and press Space to look inside.

### New marks after an update
Settings shows a small dot on a tab and a New tag on a row that the latest update added. The app keeps only which marks were seen and the update date in its own preferences, sends nothing, and the marks end by themselves 21 days after the update.

### Pet
The pet needs no permission. It walks along the bottom of the screen; in the App Store version it doesn't look up where the Dock icons are. Settings > Pet shows "To make it jump when you press Space, allow Input Monitoring"; clicking it leads to the Permissions page. With that permission a listen-only event tap checks only whether Space was pressed.

### Pet wardrobe and awards
Settings > Pet has 53 things the pet can wear, 13 ready-made looks and 30 awards. Six things are free; the rest are unlocked by awards, which are earned only by using the pet. Network access unlocks nothing.

The app keeps plain totals of what the user and the pet do (steps, pick-ups, high throws, jumps, leaps, climbs, tumbles, catches, kicks, ball pushes, phrases, days together, whether the pet was out late at night, early in the morning or on a weekend, Settings pages opened, things tried on, visits to the Pet page, happy moments, blushes, gentle set-downs, mornings greeted, which of the pet's nine feelings were seen, whether five things were worn at once), the date of each award and the worn outfit. They are stored only in the app's preferences under five keys (pet-counts, pet-awards, pet-seen, pet-fresh, pet-outfit), are never sent anywhere and are not part of exported settings. The pet's feelings are worked out on the Mac from time of day, how long ago the keyboard or mouse was last used, the pointer, the ball and the battery level; the totals never record which keys were pressed or what was clicked. Erase Progress… in the Awards section of Settings > Pet deletes all five keys after a confirmation.

### Settings file
Settings > General has Import Settings… and Export Settings…; the user picks the file in the standard Open or Save panel. The file holds the app's settings only, not pet progress.

### Show FPS
Settings > Games: turn on Game Mode, then Show FPS. The line "Needs a permission. Click to allow it." appears under the switch. Its Allow button opens the Permissions page on the Screen Recording row, and the system Screen Recording prompt appears. Show FPS counts frames from a tiny low-resolution ScreenCaptureKit view of the game's display. Only the number of changed frames is kept; no picture is ever stored, logged or sent.

### Diagnostics
One line in the macOS system log at launch: the macOS version, whether Accessibility and Input Monitoring are allowed, and how many system shortcuts macOS reports. App Volume adds debug-level lines about its audio connections (process numbers, output device, sound levels), which macOS does not keep unless debug logging is turned on. No key, click, scroll or sound is ever logged, and nothing leaves the Mac.

### iCloud settings sync
The switch appears only in a build signed with a provisioning profile that includes iCloud key-value storage, and it is off by default. When such a build goes to review, replace the text under "4. External services" above with: "Speed Test connects to speed.cloudflare.com only when the user starts a check and sends no personal data. Sync settings with iCloud (General, off by default) uses the user's own iCloud. No accounts, analytics, ads, tracking, payment processors or AI services." The notes then stay within 4000 characters.

### Not in the App Store version
These features need to look inside other apps' windows, type into or control other apps, change system files or run with administrator rights, which the App Sandbox does not allow. They are only in the version distributed outside the App Store:
- Green button enlarges the window.
- Quit when the last window closes.
- Minimize or hide with a click in the Dock.
- Enter opens files and Delete removes files in Finder.
- Key repeat, pointer shortcuts, the Trash watcher, the Uninstaller, fan control and the built-in updater.
- Keeping the pointer on the game's display and away from hot corners, in Game Mode.
- Changing pointer acceleration, animations and leftover permissions directly. The App Store version has the buttons to System Settings instead.
- Ports, the list of which program holds which port: the App Sandbox doesn't show it.
- Turning background tasks off and on directly, from Background Tasks.
- Keep the Dock on one display.
- The media player and Middle click.
- Temperature readings of the processor, graphics, memory, storage and Wi-Fi.
- Keep Awake with the lid closed.
- The pet finding the Dock icons through Accessibility.
