pikapik - Mac Tools: information for App Review (Guideline 2.1)

1. Screen recording
In App Review Information > Attachment, made on a physical Mac with the latest macOS and this build. It shows launching pikapik, Settings, turning tools on, allowing the macOS permissions and using each main tool. There are no accounts, user content or purchases to show.

2. Purpose and audience
pikapik is a free menu-bar app that fixes small everyday Mac annoyances in one place. It is for everyday Mac users, especially people who use a mouse, type in two languages, play games or want quick Finder actions. It solves: switching the keyboard language with one shortcut; mouse scrolling by lines, separate scroll directions and side buttons as Back and Forward; quitting or closing by accident with ⌘Q or ⌘W; cutting files and quick right-click actions in Finder; keeping the Mac awake; checking internet speed, battery health, busy ports and background tasks; system shortcuts pulling players out of games. A small pet walks on the desktop to make it friendly.

3. Setup and main features
No account, login or sample files are needed; any photo or video works for the Finder tools. Settings opens on first launch, later from the menu-bar icon. Nothing is asked at launch. The Pet is on by default; every other tool is off until the user turns it on.
- Keep Awake, Speed Test (press Check Speed), Temperature, Battery (on Macs with a battery), Keep the Dock on one display (Dock, two displays).
- Ports: which app holds which port; pikapik quits nothing itself.
- Background Tasks: what runs in the background and which app added it, view only; Turn Off… opens Login Items in System Settings.
- Animations, Turn off pointer acceleration (Mouse), Left by deleted apps (Permissions): Open goes to the matching System Settings page.
- Switch language (Keyboard): with two input sources, hold Option and tap Shift.
- Mouse: Scroll by lines, Scroll direction, Side buttons, Mouse button hides the current app (like ⌘H).
- Protect quitting and closing (Windows): ⌘Q and ⌘W alone do nothing; ⇧⌘Q quits and ⇧⌘W closes.
- Finder: turn on New File, Smaller Copy or Convert, press Allow and switch the extension on in System Settings; then right-click in Finder. The first time, the app asks which folder it may save into. Cut files in Finder: select files, press ⌘X, open another folder, choose Move Items Here in the menu-bar menu.
- Game Mode (Games): press Add a Game… (for example Chess) and open it. While it is in front, system shortcuts and swipes don't pull the player out.
Permissions: a tool that needs one looks grey; clicking it shows the macOS prompt and opens Settings > Permissions. Switch language needs Input Monitoring, only to see its shortcut. The Mouse tools, Protect quitting and closing, Cut files in Finder and Game Mode need Accessibility (on macOS 27: Device Control and Data Access), to change or hold back a scroll, click, shortcut or swipe. Optional: Screen Recording for Show FPS in Games; Folders (the user picks the home folder) for Background Tasks there; Input Monitoring for the Pet to jump on Space. Events are handled in memory and never stored or sent. The app never types or pastes text into other apps; it sends only ⌘Q or ⌘W, Finder's ⌘C, ⌘X and ⌥⌘V, and a back or forward swipe.

4. External services
Only one: Speed Test connects to speed.cloudflare.com, only when the user presses Check Speed, and sends no personal data. No accounts, analytics, ads, tracking, payment processors or AI services.

5. Regions
pikapik works the same in every region; it is localized into 23 languages.

6. Regulated industry or third-party material
Not applicable.

Other: free, no in-app purchases; the tip section in About stays hidden. Open at Login is off by default. No data is collected; see the privacy manifest. Pet clothes unlock with awards for using it; progress stays on this Mac.

— конец текста для App Store Connect —

Everything above the line goes into the Notes field of App Review Information in App Store Connect as is; it must stay within 4000 characters. The details below are for answering App Review questions.

### Cut files in Finder
- Select files, press ⌘X, open another folder, click the menu-bar icon and press Move Items Here: the files move. ⌘V still pastes a copy and ⌘C cancels. The app only checks whether the clipboard holds files and never reads it.
- In Finder ⌘X becomes ⌘C, so Finder copies the files as usual. Move Items Here is in the app's menu only while Finder is in front and files wait; it sends ⌥⌘V, Finder's own Move Item Here.
- When the copied thing is text, for example while a file is being renamed, the app sends ⌘X again, so the text is cut as usual.
- ⌘V is never changed in this version: it pastes as usual, a copy of files or text while a name is being edited.

### Permissions page
Settings > Permissions lists Accessibility (on macOS 27 under its new name, Device Control and Data Access), Input Monitoring, Screen Recording (only while Show FPS is on and the permission is missing), Finder Extensions and Folders with their state and one button, Allow or Turn Off. The app asks for a permission only here or from a grey tool that leads here, never at launch and never during a game. Turn Off opens the matching list in System Settings > Privacy & Security, where the user switches pikapik off; for Folders the app forgets the saved access right away. Below them, Left by deleted apps has one Open button for each Privacy & Security list.

### Buttons to System Settings
In this version the app changes no system setting itself; these buttons only open a System Settings page:
- Turn off pointer acceleration (Settings > Mouse): Open goes to System Settings > Mouse, where the user clicks Advanced… and turns off Pointer acceleration. System Settings shows the Mouse page only while a mouse is connected.
- Animations (Settings > Animations): each Open button goes to System Settings > Desktop & Dock for one setting (minimize effect, bouncing icons, hiding the Dock); the link at the bottom opens Accessibility > Display for Reduce Motion.
- Left by deleted apps (Settings > Permissions): each Open button opens one list in System Settings > Privacy & Security, where the user removes an app that was deleted.
- Battery Settings… (Settings > Battery) opens System Settings > Battery.
- Turn On… and Turn Off… (Settings > Background Tasks) open Login Items in System Settings.
- Change in System Settings (Settings > Ports) opens the Sharing or AirDrop & Handoff page for a port held by a macOS service, such as AirPlay Receiver.

### Ports
Settings > Ports lists the network ports open on this Mac and the program holding each one. It reads the kernel's list of sockets and processes with the public sysctl and libproc calls that work in the App Sandbox; it opens no connection and changes nothing.
- pikapik never quits or signals another process in this version. For the user's own program, Free Up only explains: "To free a port, quit the program that holds it: show the program and quit it there, or paste the command into Terminal." Its buttons are Show "name" (brings that app to the front), Copy Command (puts kill and the process number on the clipboard for the user to paste into Terminal) and Open Activity Monitor.
- A program of another user or of the system shows that pikapik doesn't touch it, with Open Activity Monitor.
- Show in Finder reveals the program's file.

### Background Tasks
Settings > Background Tasks lists what starts in the background and which app added it: launch agents and daemons in /Library and in the user's Library, helpers inside apps (Contents/Library/LaunchAgents, LaunchDaemons and LoginItems) and the user's login items. It reads these property lists, the login items list and SMAppService.statusForLegacyPlist, and runs /bin/launchctl print, read-only, to tell which tasks are loaded or running.
- Tasks in the home folder appear only after the user allows it. The page says "To see the tasks in your home folder, allow access to it."; Allow shows the standard Open panel at the home folder with the button Allow Access. Turn Off on the Folders row of Settings > Permissions forgets that access.
- View only: in this version pikapik loads, unloads, edits or deletes nothing. Turn On… and Turn Off… open Login Items in System Settings, where the user changes it; Show in Finder reveals the file.
- Left by deleted apps groups tasks whose app is gone, so the user can find them.

### Battery
Shown only on Macs with a battery. It reads the battery's condition, maximum capacity and cycle count, the power adapter, charging power and power use from IOKit's public power-source functions and the battery's entry in the I/O Registry. It changes nothing: Battery Settings… opens System Settings > Battery, and the row about Charge Limit and Optimized Battery Charging only explains the macOS setting. No permission.

### Temperature
In this version Temperature shows only the macOS thermal state (ProcessInfo.thermalState) and what it means for speed; it reads no sensors.

### Keep the Dock on one display
Settings > Dock; it matters only with two or more displays. macOS moves the Dock to another display when the pointer pushes against that display's bottom edge. While the tool is on, the app follows only the pointer position with an NSEvent mouse monitor, which needs no permission, and at that edge moves the pointer back a few points with CGWarpMouseCursorPosition, so the Dock stays. With ⌥ held the Dock moves as usual. No key or click is read or sent.

### Mouse button hides the current app
Settings > Mouse. Turn it on, then press a mouse button over the Settings window to choose it, for example the middle one. That button then hides the front app with NSRunningApplication.hide(), the same as ⌘H; no keystroke is sent. Accessibility is needed because the chosen button's click is held back, so the app under the pointer doesn't get it too.

### Pet
The pet needs no permission. It walks along the bottom of the screen; in this version it doesn't look up where the Dock icons are. Settings > Pet shows "To make it jump when you press Space, allow Input Monitoring"; clicking it leads to the Permissions page. With that permission a listen-only event tap checks only whether Space was pressed.

### Pet wardrobe and awards
Settings > Pet has 38 things the pet can wear, 10 ready-made looks and 24 awards. Six things are free; the rest are unlocked by awards, which are earned only by using the pet. Network access unlocks nothing.

The app keeps plain totals of what the user and the pet do (steps, pick-ups, high throws, jumps, leaps, climbs, tumbles, catches, kicks, ball pushes, phrases, days together, Settings pages opened, things tried on, visits to the Pet page), the date of each award and the worn outfit. They are stored only in the app's preferences under five keys (pet-counts, pet-awards, pet-seen, pet-fresh, pet-outfit), are never sent anywhere and are not part of exported settings. The totals never record which keys were pressed or what was clicked. Erase Progress… in the Awards section of Settings > Pet deletes all five keys after a confirmation.

### Settings file
Settings > General has Import Settings… and Export Settings…; the user picks the file in the standard Open or Save panel. The file holds the app's settings only, not pet progress.

### Show FPS
Settings > Games: turn on Game Mode, then Show FPS. The line "Needs a permission. Click to allow it." appears under the switch. Its Allow button opens the Permissions page on the Screen Recording row, and the system Screen Recording prompt appears. Show FPS counts frames from a tiny low-resolution ScreenCaptureKit view of the game's display. Only the number of changed frames is kept; no picture is ever stored, logged or sent.

### Diagnostics
One line in the macOS system log at launch: the macOS version, whether Accessibility and Input Monitoring are allowed, and how many system shortcuts macOS reports. No key, click or scroll is ever logged, and nothing leaves the Mac.

### iCloud settings sync
The switch appears only in a build signed with a provisioning profile that includes iCloud key-value storage, and it is off by default. When such a build goes to review, replace the text under "4. External services" above with: "Speed Test connects to speed.cloudflare.com only when the user presses Check Speed and sends no personal data. Sync settings with iCloud (General, off by default) uses the user's own iCloud. No accounts, analytics, ads, tracking, payment processors or AI services." The notes then stay within 4000 characters.

### Not in the App Store version
These features need to look inside other apps' windows, control other apps, change system files or run with administrator rights, which the App Sandbox does not allow. They are only in the version distributed outside the App Store:
- Home and End go to the start and end of a line.
- Green button enlarges the window.
- Quit when the last window closes.
- Minimize or hide with a click in the Dock.
- Enter opens files and Delete removes files in Finder.
- Key repeat, pointer shortcuts, Archives in Finder, the Trash watcher, the Uninstaller, fan control and the built-in updater.
- Changing pointer acceleration, animations and leftover permissions directly. The App Store version has the buttons to System Settings instead.
- Quitting the program that holds a port, from Ports.
- Turning background tasks off and on directly, from Background Tasks.
- Bring the Dock back, in Keep the Dock on one display.
- Temperature sensor readings.
- The pet finding the Dock icons through Accessibility.
