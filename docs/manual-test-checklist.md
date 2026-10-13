# Manual test checklist (App Store build)

Build: `APPSTORE=1 ./scripts/build.sh`, then run `build/pikapik.app`. Test on a fresh user or after `tccutil reset All com.pikapik.tools`.

## First run and permissions
- Launch. Expected: no permission prompt at launch except what the Permissions page asks for; menu bar icon appears.
- Turn on Window zoom (or any Keyboard/Mouse/Windows tool). Expected: Accessibility prompt, then Input Monitoring if needed. Status shows "Needs Access" until granted, then "Active".
- Revoke a permission in System Settings while the app runs. Expected: status returns to "Needs Access" without a crash; granting it again restores the tool without relaunch.
- A tool that needs a missing permission is half-grey and does nothing when toggled; clicking it opens the Permissions page on the row to allow. Turn Off on Accessibility and Input Monitoring opens the right System Settings list (this build cannot revoke them itself). The Folders row: Allow shows the home folder panel; Turn Off forgets the saved folders and the next file action asks again.
- Settings has no Fans, Animations, Uninstaller, Key repeat, Pointer, Updates, iCloud sync, "Keep running after Quit" or "Turn off the display now" rows. Search for "fan", "pointer" and "uninstall" finds nothing.

## Settings
- Change Appearance and Language, press Restart in Settings. Expected: app relaunches with Settings open, choices kept.
- Quit with Cmd+Q. Expected: app really quits (no background mode in this build).
- Open at Login on and off. Expected: it appears and disappears in System Settings > Login Items.

## Finder
- Turn on New File, Smaller Copy, Convert. Expected: the three tools turn grey; clicking one opens the Permissions page on the Finder Extensions row. Allow opens System Settings > Login Items & Extensions > Finder; enable each extension; return to pikapik and the row shows a green check and the tools are no longer grey. Turn Off opens the same list.
- Right-click in a folder > New File. Expected: NSOpenPanel asks once for the home folder; after Allow Access the file is created and the panel does not return after relaunch.
- Smaller Copy and Convert on a file in Downloads and on an external volume. Expected: folder prompt when needed, output saved next to the original.
- Settings > Finder > Hide desktop icons > Open. Expected: System Settings opens on Desktop & Dock. In the menu the same row closes the menu and opens the same page.
- Settings > Finder. Expected: a Show hidden files row with the ⇧⌘. keys and no switch; typing “hidden” in the Settings search finds it.
- Known gap: turning a Finder tool off in pikapik does not hide the Finder menu item; disable the extension in System Settings.

## Game Mode
- Turn on, start a game. Expected: Cmd+Space and Cmd+` are swallowed while playing; the rules list shows only shortcuts that exist on this Mac.
- Quit the game, lock the screen mid-game. Expected: shortcuts work again at once; Dock corners and hiding are untouched in this build.
- Settings > Games > Show FPS, turn on without Screen Recording on macOS 26 or the App Store build. Expected: no prompt yet; the line "Needs a permission. Click to allow it." shows under the switch and the Permissions page lists Screen Recording with "Needed to count frames". Click Allow in the line: the Screen Recording prompt appears and the Permissions page opens on the row. Both go away once it is allowed (if macOS asks to reopen pikapik, do that), and they update when you come back from System Settings. Deny it: the pill shows a dimmed "—", with no crash and no further prompts.
- Same on macOS 27 (direct build). Expected: no prompt and no Screen Recording row while games are counted by the system. Play a game the system can't count (an OpenGL one): after about three seconds the line "Needs a permission. Click to allow it." appears in Settings > Games and the row "Needed for some games" under Permissions, still without any prompt during the game, and both stay on later launches until the permission is allowed.
- Start a game with Show FPS on. Expected: a small pill with a dash appears in the chosen corner of the game window (top corners sit below its title bar), then shows the frame rate; a game drawing 30 frames a second shows about 30, a frozen picture shows a dimmed 0, and no number goes above the screen's refresh rate. From 100 on the pill gets one digit wider and stays in its corner, with the small FPS on the same baseline as the number. Quit the game: the pill fades out at once.
- Click each corner of the picture under Show FPS, then turn the switch off and on again while the game runs. Expected: the pill in the picture and the one over the game move to the corner at once, hovering a corner shows its name, off fades the pill out and on brings it back without restarting the game. With Reduce Motion on, the pill appears and goes without fading. Repeat with a native fullscreen game and a game on a second display: the pill shows in the chosen corner of that display.

## Speed Test
- Run a full test (about 20 s). Expected: ping, download, upload fill in, then a result. Cancel mid-way: returns to idle, next run works. Turn Wi-Fi off and run: "offline" message.

## App Volume (macOS 14.2 or later)
- On macOS 14.0 or 14.1. Expected: no Sound page in Settings and no App Volume row in the menu bar panel.
- Settings > Sound > App Volume on, without the permission. Expected: no prompt yet; the row is half-grey and clicking it opens the Permissions page on the System Audio Recording row. Allow shows the system prompt (after a refusal it opens System Settings > Privacy & Security instead); Turn Off also opens System Settings in this build. Once allowed, the row has a green check and the list says "No apps are playing sound".
- Start a stub app that plays a quiet tone (never a program you use) and keep another app playing sound. Expected: both appear in the list with their icon, a slider at 100% and a mute button.
- Drag the stub's slider down. Expected: only the stub gets quieter, smoothly and without clicks, and it is silent at the left end; the other app, the Mac's volume and the output device do not change. Back at 100% the stub plays as before.
- Press the stub's mute button. Expected: it falls silent at once, its slider greys out and the button shows a crossed speaker with the tip "Unmute"; press again and the sound returns at the old level. Relaunch pikapik: the level and the mute are kept.
- Quit the stub. Expected: its row dims and goes after about 30 seconds, unless the stub is muted or below 100%, then it stays dimmed.
- Quit pikapik with Cmd+Q while the stub is below 100%, then repeat and force quit it. Expected: the stub is back at full volume at once both times, and neither while it ran nor after that does Audio MIDI Setup or System Settings > Sound show an extra device (the helper aggregate is private and is gone with the app).

## Keep Awake
- Start with a duration, check `pmset -g assertions`. Expected: assertion present, gone after stop or quit. No lid-closed or display-off rows.

## Battery
- On a Mac with a battery, open Settings > Battery. Expected: charge, status and cycle count match `pmset -g batt` and System Settings > Battery; Maximum Capacity is within two points of System Settings > Battery > Battery Health, and the Condition row appears only when the battery needs service; Activity Monitor shows no system_profiler started by pikapik. Plugged in: Power Adapter shows its name and watts, and Charging Power shows watts while charging. Unplugged: Power Use shows watts and the adapter row is gone.
- Click Battery Settings…. Expected: System Settings opens on Battery. Nothing on the page changes how the Mac charges. On a Mac without a battery the sidebar has no Battery row.

## Background Tasks
- Open Settings > Background Tasks before giving access to the home folder. Expected: a grey "Tasks in your home folder" row and a bar that asks for access. Click Allow, choose your home folder in the Open window. Expected: tasks from ~/Library/LaunchAgents appear with their app, a green dot when running and the file path; clicking the path shows the file in Finder.
- Click Turn Off… on any task. Expected: System Settings opens on Login Items, nothing on disk changes.

## Ports
- In Terminal run `python3 -m http.server 47123 --bind 127.0.0.1`, then open Settings > Ports. Expected: Python with port 47123 under Your programs, its folder under the name; `lsof -nP -iTCP:47123 -sTCP:LISTEN` shows the same process ID as the row.
- Type 47123 in the search field. Expected: only that row. Type 47199. Expected: "Port 47199 is free".
- Click the row. Expected: localhost:47123 opens the page in the browser, "Only this Mac can connect.", Protocol TCP, the path of Python, the command, the folder, the process ID and when it started.
- Click Free Up. Expected: only Open Activity Monitor (and Show for an app), no Copy Command. Quit Python in Activity Monitor. Expected: the row disappears within two seconds.
- Turn on AirPlay Receiver in System Settings > General > AirDrop & Handoff. Expected: Control Center appears under macOS and other users with 5000 and 7000; Free Up explains which switch frees the port, and Change in System Settings opens AirDrop & Handoff.

## Pet
- Turn on, switch an app to fullscreen on each display. Expected: pet hides on that display only and returns when fullscreen ends; works across Spaces and after sleep/wake.
- Open Settings > Pet. Expected: Wardrobe shows 38 things in seven groups with six unlocked, Looks shows 10 looks, Awards shows 24 awards and no "Open Source" award. Click an unlocked thing: the pet puts it on and takes it off again; Take Everything Off clears the outfit. Click a locked thing: its award opens and nothing is worn. Click a look with missing pieces: nothing is worn.
- Earn an award (pick the pet up and throw it high 10 times). Expected: the pet announces it, Pet in the sidebar shows a badge, the award and what it unlocks are marked "New" until you leave the page, and the unlocked things can be worn. Quit and relaunch: outfit, counts and awards are kept.
- Export Settings and open the file. Expected: no pet-counts, pet-awards, pet-seen, pet-fresh or pet-outfit. Restore Defaults keeps the awards and the outfit.
- Erase Progress... and confirm. Expected: awards, unlocked things and counts are gone, only the six free things can be worn, and `defaults read com.pikapik.tools` shows none of the five pet keys. Repeat the wardrobe and award steps with Wi-Fi off. Expected: same result, no error.

## Quit on close
- Turn on, close the last window of an app, then repeat with the app's windows on another Space and with a minimized window. Expected: app quits only when no windows remain anywhere.

## Tip jar (after products exist in App Store Connect)
- Settings > About shows three buttons with local prices. Buy one with a sandbox account. Expected: "Thank you!" appears and nothing unlocks. Cancel the purchase: no error. Offline: "Tips are not available right now" with Try Again that recovers. Search "tip" finds "Say thanks".

# Manual test checklist (GitHub build)

- Fan control: open Settings > Fans, turn on manual control. Expected: one admin prompt to install the helper; speed changes follow the slider; quitting or killing pikapik returns fans to automatic within seconds.
- Updates: About > Check Now finds a newer release, installs and relaunches.
- Pet awards: Settings > Pet shows 25 awards. Click the GitHub link in Settings > About. Expected: the "Open Source" award is earned. With iCloud sync on, a second Mac does not receive the awards or the outfit.
- Uninstaller: in Settings > Uninstaller drop a small test app on the picture and click Move to Trash. Expected: the app and its files are in the Trash, the removal is listed under Recently removed, and Put Back returns everything. An app that is open is asked to quit first, and an item that needs an administrator asks for the password once. Turn on "Offer to clean up when an app goes to the Trash" and drag an app to the Trash in Finder. Expected: Settings opens on this page with that app and the files it left behind, and nothing is removed until you choose.
- Background Tasks: make a test agent `~/Library/LaunchAgents/org.example.background-test.plist` that runs `/bin/sleep 3600` with RunAtLoad and load it with `launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/org.example.background-test.plist`. Open Settings > Background Tasks. Expected: it is listed with a green dot. Click Turn Off. Expected: the row dims, `launchctl print-disabled gui/$(id -u)` shows it as disabled, the sleep process is gone and the file is still there. Click Turn Back On. Expected: it runs again. Remove the test agent afterwards with `launchctl bootout gui/$(id -u)/org.example.background-test` and delete the file.
- Ports: run `python3 -m http.server 47123 --bind 127.0.0.1` in Terminal, open Settings > Ports and click Free Up on its row. Expected: "Quit “Python”?"; Cancel changes nothing; Quit stops the server and the row disappears. Then run `python3 -c "import signal,socket,time; signal.signal(signal.SIGTERM, signal.SIG_IGN); s=socket.socket(); s.bind(('127.0.0.1', 47124)); s.listen(); time.sleep(600)"` and click Free Up > Quit. Expected: after about five seconds "Force quit “Python”?"; Force Quit frees port 47124. Rows under macOS and other users never quit anything.
- Archives: turn on Settings > Archives in Finder. In a new test folder, right-click a folder of more than 20 MB > Create Archive…, choose 7Z, set a Password and Split into parts of 15 MB. Expected: numbered parts appear next to the folder, and right-click the first part > Extract asks for the password and unpacks a copy of the folder. Space on a ZIP shows the files inside. Turning the switch off removes the menu and the preview.
- Keep the Dock on one display: needs two displays and "Displays have separate Spaces" on (System Settings > Desktop & Dock). Run `defaults read com.apple.dock allow-display-switching` and note the answer. Turn on Settings > Dock > Keep the Dock on one display. Expected: no permission prompt, the Dock restarts once, pushing the pointer against the bottom edge of the other display no longer moves it, and the command prints 0. Quit and reopen pikapik: the Dock does not restart. Turn the switch off. Expected: the Dock restarts once, moves between displays again, and the command prints what it printed before (or says the key does not exist). Turn it on again and run `build/pikapik.app/Contents/MacOS/pika-tools --uninstall`: the same result as turning it off.
- Desktop icons and hidden files: first write down `defaults read com.apple.WindowManager StandardHideDesktopIcons` and `defaults read com.apple.finder AppleShowAllFiles` to put them back after the test. Turn on Settings > Finder > Hide desktop icons. Expected: the icons leave the desktop without Finder restarting, the files stay in the Desktop folder, and System Settings > Desktop & Dock > Show items > On Desktop turns off. Turn it off. Expected: the icons come back to the same places. Change On Desktop in System Settings and open the menu. Expected: the switch follows. Repeat with Stage Manager on. Turn on Show hidden files. Expected: Finder restarts for a moment, its open windows and tabs come back, and hidden files and folders appear dimmed in Finder and on the desktop, the same as ⇧⌘.; turning it off restarts Finder the same way and hides them again. Restore Defaults on the Finder page leaves both as they are.
- Show hidden files while copying: start copying a large folder (several GB) in Finder, then turn Settings > Finder > Show hidden files on or off. Expected: the row says “Waiting for Finder to finish copying”, the copy is not interrupted, and Finder restarts only after the copy is done. Turning the switch back before the copy ends leaves Finder alone.
