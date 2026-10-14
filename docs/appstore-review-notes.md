pikapik - Mac Tools: information for App Review (Guideline 2.1)

1. Screen recording
Attached in App Review Information; made on a physical Mac with the latest macOS and this build, it shows each main tool and permission prompt.

2. Purpose and audience
pikapik is a free menu-bar app that fixes small everyday Mac annoyances. It is for Mac users, especially those who use a mouse, type in two languages, play games or want quick Finder actions. It solves: switching the keyboard language and fixing text typed in the wrong one; a separate volume for each app; mouse scrolling, scroll directions and side buttons; accidental ⌘Q and ⌘W; cutting files and right-click actions in Finder; keeping the Mac awake; checking internet speed, battery, ports and background tasks; system shortcuts pulling players out of games. A small pet walks on the desktop to make it friendly.

3. Setup and main features
No account or sample files are needed; any photo or video works for Finder tools. Settings opens on first launch, later from the menu-bar icon; nothing is asked at launch. Only the Pet is on by default.
- Keep Awake, Speed Test, Temperature (thermal state and battery temperature), Battery (Macs with a battery), App Volume (Sound, macOS 14.2+: a slider and mute button per app), Brightness (an external monitor's slider dims its picture).
- Background Tasks: what starts in the background; view only.
- Animations, pointer acceleration, Left by deleted apps: buttons only open System Settings.
- Keyboard, with two input sources such as ABC and Russian. Switch language: hold Option, tap Shift. Fix Wrong Keyboard Layout: select "ghbdtn" (meant as "привет"), then Services > Fix Wrong Keyboard Layout, or turn on its shortcut and press ⌃⇧Space.
- Mouse: Scroll by lines, Scroll direction, Side buttons, Mouse button hides the current app (like ⌘H).
- Protect quitting and closing (Windows): ⌘Q and ⌘W alone do nothing; ⇧⌘Q quits and ⇧⌘W closes.
- Finder: turn on New File, Smaller Copy or Convert, press Allow, switch the extension on in System Settings, then right-click in Finder; the first time, it asks which folder to save into. Cut files: select files, press ⌘X, open another folder, press ⌘V: the files move.
- Game Mode (Games): turn it on, press Add a Game… (for example Chess) and open the game. While it is in front, system shortcuts and swipes don't pull the player out.
Permissions: a tool that needs one looks grey; a click shows the macOS prompt (for App Volume, via Allow) and opens Settings > Permissions. Input Monitoring: Switch language, only to see its shortcut. Accessibility (on macOS 27: Device Control and Data Access): the Mouse tools, Brightness keys, Protect quitting and closing, Cut files in Finder, the Fix Wrong Keyboard Layout shortcut and Game Mode, to change or hold back a scroll, click, shortcut or swipe. System Audio Recording: App Volume, to change an app's volume. The Services command alone needs none. Optional: Screen Recording for Show FPS in Games; Folders (the user picks the home folder) for Background Tasks there; Input Monitoring for the Pet to jump on Space. Events and sound are handled in memory, never stored or sent. The app never types or pastes text into other apps; it sends only ⌘Q or ⌘W, Finder's ⌘C, ⌘X and ⌥⌘V, ⌃⌥⇧⌘F19 (its own Services key) and a back or forward swipe.

4. External services
Only one: Speed Test connects to speed.cloudflare.com, only when the user starts a check, and sends no personal data. No accounts, analytics, ads, tracking, payment processors or AI services.

5. Regions
pikapik works the same in every region; it is localized into 23 languages.

6. Regulated industry or third-party material
Not applicable.

Other: free, no in-app purchases; the tip section in About stays hidden while no tip products exist. Open at Login is off by default. No data is collected; see the privacy manifest. Pet clothes unlock with awards; nothing is sold.

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
- Left by deleted apps (Settings > Permissions): each Open button opens one list in System Settings > Privacy & Security, where the user removes an app that was deleted.
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
Settings > Speed Test measures download and upload speed with https://speed.cloudflare.com through an ephemeral URLSession, so no cookies or cache are kept. The caption says "Takes about 15 seconds. The check uses speed.cloudflare.com." A check starts only from Check Speed, from Check on the Speed Test card in the menu-bar menu (hidden until the user adds it) or from a pikapik://speed-test link the user opens. Only the last result is kept, in the app's preferences on this Mac.

### App Volume
Settings > Sound, macOS 14.2 and later (hidden on 14.0 and 14.1), off by default: a volume slider and a mute button for each app that plays sound. It needs System Audio Recording to change the volume of one app without touching the others. For an app whose slider is below 100% or that is muted, the app creates a private Core Audio process tap on that app only (AudioHardwareCreateProcessTap) and plays the same sound, scaled by the slider, to the output device the app was using; an app left at 100% gets no tap. The sound is processed on the fly in memory and is never recorded, stored, logged or sent anywhere. The entitlement com.apple.security.device.audio-input is there only so the sandboxed app can read other apps' sound through these system process taps. The microphone is never opened, and the app has no microphone usage description. The system prompt shows NSAudioCaptureUsageDescription: "pikapik passes each app’s sound through itself to change its volume. Nothing is recorded or saved."
- To try it: turn on App Volume. The row looks half-grey until System Audio Recording is allowed; clicking it opens the Permissions page on the System Audio Recording row, and Allow shows the system prompt (after a refusal it opens System Settings > Privacy & Security instead). Once it is allowed, play sound in any app: the app appears in the list with a slider and a mute button. Nothing is asked while App Volume is off.
- To learn whether the permission is given, the app briefly plays an inaudible test signal and taps only its own process.

### Monitor Brightness
Settings > Brightness: a slider for each external monitor that macOS can't adjust. This build only dims the picture, so no permission is needed.
- To try it: connect an external monitor, open Settings > Brightness and move its slider; the picture on that monitor gets darker, and moving the slider back restores it.
- Brightness keys (Settings > Brightness, optional) need Accessibility: they catch the brightness keys and change the monitor under the pointer.

### Fix Wrong Keyboard Layout
Settings > Keyboard. Add two input sources, for example ABC and Russian. In any app, select text typed in the wrong one (such as "ghbdtn" instead of "привет") and choose Services > Fix Wrong Keyboard Layout in the app menu or the right-click menu; this needs no permission. The standard macOS Services mechanism (NSServices in Info.plist) passes only the selected text to pikapik, only on that command, and the app the user is in puts the fixed text in place of the selection. pikapik does not type, paste or watch typing.
Optional shortcut, off by default: turn on Fix the selected text below it, then select the text and press ⌃⇧Space (the user can record other keys there). It needs Accessibility, asked for in Settings > Permissions. An event tap holds back only that key combination and sends ⌃⌥⇧⌘F19 instead, the Services command's own key (NSKeyEquivalent in Info.plist), so the app in front runs the same command on its selection. Every other key passes untouched; nothing is read, logged or stored.

### Mouse button hides the current app
Settings > Mouse. Turn it on, then press a mouse button over the Settings window to choose it, for example the middle one. That button then hides the front app with NSRunningApplication.hide(), the same as ⌘H; no keystroke is sent. Accessibility is needed because the chosen button's click is held back, so the app under the pointer doesn't get it too.

### Pet
The pet needs no permission. It walks along the bottom of the screen; in the App Store version it doesn't look up where the Dock icons are. Settings > Pet shows "To make it jump when you press Space, allow Input Monitoring"; clicking it leads to the Permissions page. With that permission a listen-only event tap checks only whether Space was pressed.

### Pet wardrobe and awards
Settings > Pet has 38 things the pet can wear, 10 ready-made looks and 24 awards. Six things are free; the rest are unlocked by awards, which are earned only by using the pet. Network access unlocks nothing.

The app keeps plain totals of what the user and the pet do (steps, pick-ups, high throws, jumps, leaps, climbs, tumbles, catches, kicks, ball pushes, phrases, days together, whether the pet was out late at night, early in the morning or on a weekend, Settings pages opened, things tried on, visits to the Pet page), the date of each award and the worn outfit. They are stored only in the app's preferences under five keys (pet-counts, pet-awards, pet-seen, pet-fresh, pet-outfit), are never sent anywhere and are not part of exported settings. The totals never record which keys were pressed or what was clicked. Erase Progress… in the Awards section of Settings > Pet deletes all five keys after a confirmation.

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
- Home and End go to the start and end of a line.
- Green button enlarges the window.
- Quit when the last window closes.
- Minimize or hide with a click in the Dock.
- Enter opens files and Delete removes files in Finder.
- Fixing words as you type. The App Store version fixes only selected text, through the Services command Fix Wrong Keyboard Layout or its shortcut.
- Key repeat, pointer shortcuts, Archives in Finder, the Trash watcher, the Uninstaller, fan control and the built-in updater.
- Changing pointer acceleration, animations and leftover permissions directly. The App Store version has the buttons to System Settings instead.
- Ports, the list of which program holds which port: the App Sandbox doesn't show it.
- Turning background tasks off and on directly, from Background Tasks.
- Keep the Dock on one display.
- Temperature readings of the processor, graphics, memory, storage and Wi-Fi.
- Keep Awake with the lid closed, and Turn off the display now.
- The pet finding the Dock icons through Accessibility.
