# Manual test checklist (App Store build)

Build: `APPSTORE=1 ./scripts/build.sh`, then run `build/pikapik.app`. Test on a fresh user or after `tccutil reset All com.pesotchi.pika-tools.appstore`.

## First run and permissions
- Launch. Expected: no permission prompt at launch except what the Permissions page asks for; menu bar icon appears.
- Turn on Window zoom (or any Keyboard/Mouse/Windows tool). Expected: Accessibility prompt, then Input Monitoring if needed. Status shows "Needs Access" until granted, then "Active".
- Revoke a permission in System Settings while the app runs. Expected: status returns to "Needs Access" without a crash; granting it again restores the tool without relaunch.
- A tool that needs a missing permission is half-grey and does nothing when toggled; clicking it opens the Permissions page on the row to allow. Turn Off on Accessibility and Input Monitoring opens the right System Settings list (this build cannot revoke them itself). The Folders row: Allow shows the home folder panel; Turn Off forgets the saved folders and the next file action asks again.
- Settings has no Fans, Animations, Key repeat, Pointer, Updates, iCloud sync, "Keep running after Quit" or "Turn off the display now" rows. Search for "fan" and "pointer" finds nothing.

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

## Speed Test
- Run a full test (about 20 s). Expected: ping, download, upload fill in, then a result. Cancel mid-way: returns to idle, next run works. Turn Wi-Fi off and run: "offline" message.

## Keep Awake
- Start with a duration, check `pmset -g assertions`. Expected: assertion present, gone after stop or quit. No lid-closed or display-off rows.

## Pet
- Turn on, switch an app to fullscreen on each display. Expected: pet hides on that display only and returns when fullscreen ends; works across Spaces and after sleep/wake.

## Quit on close
- Turn on, close the last window of an app, then repeat with the app's windows on another Space and with a minimized window. Expected: app quits only when no windows remain anywhere.

## Tip jar (after products exist in App Store Connect)
- Settings > About shows three buttons with local prices. Buy one with a sandbox account. Expected: "Thank you!" appears and nothing unlocks. Cancel the purchase: no error. Offline: "Tips are not available right now" with Try Again that recovers. Search "tip" finds "Say thanks".

# Manual test checklist (GitHub build)

- Fan control: open Settings > Fans, turn on manual control. Expected: one admin prompt to install the helper; speed changes follow the slider; quitting or killing pikapik returns fans to automatic within seconds.
- Updates: About > Check Now finds a newer release, installs and relaunches.
