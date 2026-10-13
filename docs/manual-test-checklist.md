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

## Keep Awake
- Start with a duration, check `pmset -g assertions`. Expected: assertion present, gone after stop or quit. No lid-closed or display-off rows.

## Battery
- On a Mac with a battery, open Settings > Battery. Expected: charge, status and cycle count match `pmset -g batt` and System Settings > Battery; Condition and Maximum Capacity match `system_profiler SPPowerDataType` a moment later. Plugged in: Power Adapter shows its name and watts, and Charging Power shows watts while charging. Unplugged: Power Use shows watts and the adapter row is gone.
- Click Battery Settings…. Expected: System Settings opens on Battery. Nothing on the page changes how the Mac charges. On a Mac without a battery the sidebar has no Battery row.

## Background Tasks
- Open Settings > Background Tasks before giving access to the home folder. Expected: a grey "Tasks in your home folder" row and a bar that asks for access. Click Allow, choose your home folder in the Open window. Expected: tasks from ~/Library/LaunchAgents appear with their app, a green dot when running and the file path; clicking the path shows the file in Finder.
- Click Turn Off… on any task. Expected: System Settings opens on Login Items, nothing on disk changes.

## Pet
- Turn on, switch an app to fullscreen on each display. Expected: pet hides on that display only and returns when fullscreen ends; works across Spaces and after sleep/wake.
- Open Settings > Pet. Expected: Wardrobe shows 38 things in seven groups with six unlocked, Looks shows 10 looks, Awards shows 24 awards and no "Open Source" award. Click an unlocked thing: the pet puts it on and takes it off again; Take Everything Off clears the outfit. Click a locked thing: its award opens and nothing is worn. Click a look with missing pieces: nothing is worn.
- Earn an award (pick the pet up and throw it high 10 times). Expected: the pet announces it, Pet in the sidebar shows a badge, the award and what it unlocks are marked "New" until you leave the page, and the unlocked things can be worn. Quit and relaunch: outfit, counts and awards are kept.
- Export Settings and open the file. Expected: no pet-counts, pet-awards, pet-seen, pet-fresh or pet-outfit. Restore Defaults keeps the awards and the outfit.
- Erase Progress... and confirm. Expected: awards, unlocked things and counts are gone, only the six free things can be worn, and `defaults read com.pikapik.tools` shows none of the five pet keys. Repeat the wardrobe and award steps with Wi-Fi off. Expected: same result, no error.

## Quit on close
- Turn on, close the last window of an app, then repeat with the app's windows on another Space and with a minimized window. Expected: app quits only when no windows remain anywhere.

## Keep the Dock on one display
- Needs two displays and "Displays have separate Spaces" on (System Settings > Desktop & Dock). Turn on Settings > Dock > Keep the Dock on one display, then push the pointer against the bottom edge of the other display. Expected: no permission prompt, the Dock stays on its display and hot corners still work. Hold ⌥ and push again: the Dock moves to that display and stays there. Settings > Dock has no "Bring the Dock back" row in this build.

## Tip jar (after products exist in App Store Connect)
- Settings > About shows three buttons with local prices. Buy one with a sandbox account. Expected: "Thank you!" appears and nothing unlocks. Cancel the purchase: no error. Offline: "Tips are not available right now" with Try Again that recovers. Search "tip" finds "Say thanks".

# Manual test checklist (GitHub build)

- Fan control: open Settings > Fans, turn on manual control. Expected: one admin prompt to install the helper; speed changes follow the slider; quitting or killing pikapik returns fans to automatic within seconds.
- Updates: About > Check Now finds a newer release, installs and relaunches.
- Pet awards: Settings > Pet shows 25 awards. Click the GitHub link in Settings > About. Expected: the "Open Source" award is earned. With iCloud sync on, a second Mac does not receive the awards or the outfit.
- Uninstaller: in Settings > Uninstaller drop a small test app on the picture and click Move to Trash. Expected: the app and its files are in the Trash, the removal is listed under Recently removed, and Put Back returns everything. An app that is open is asked to quit first, and an item that needs an administrator asks for the password once. Turn on "Offer to clean up when an app goes to the Trash" and drag an app to the Trash in Finder. Expected: Settings opens on this page with that app and the files it left behind, and nothing is removed until you choose.
- Background Tasks: make a test agent `~/Library/LaunchAgents/org.example.background-test.plist` that runs `/bin/sleep 3600` with RunAtLoad and load it with `launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/org.example.background-test.plist`. Open Settings > Background Tasks. Expected: it is listed with a green dot. Click Turn Off. Expected: the row dims, `launchctl print-disabled gui/$(id -u)` shows it as disabled, the sleep process is gone and the file is still there. Click Turn Back On. Expected: it runs again. Remove the test agent afterwards with `launchctl bootout gui/$(id -u)/org.example.background-test` and delete the file.
- Archives: turn on Settings > Archives in Finder. In a new test folder, right-click a folder of more than 20 MB > Create Archive…, choose 7Z, set a Password and Split into parts of 15 MB. Expected: numbered parts appear next to the folder, and right-click the first part > Extract asks for the password and unpacks a copy of the folder. Space on a ZIP shows the files inside. Turning the switch off removes the menu and the preview.
- Bring the Dock back: with Keep the Dock on one display on, turn on Settings > Dock > Bring the Dock back and allow Accessibility. Put the Mac to sleep and wake it, or unplug and replug a display, so that the Dock ends up on another display. Expected: within a few seconds the Dock is back on its display and the pointer is where it was.
