# Features

This is the catalog of everything pikapik does, grouped like the Settings sidebar. It is the one place to walk through and test the whole app, and every `###` heading is one feature: `./scripts/feature-form.sh` lists them in the “Which feature?” dropdown of the bug and feature forms. When you add, change, rename or remove a feature, update its entry here and run that script (CI fails otherwise).

**Editions.** “Website” is the build from the website, GitHub Releases and Homebrew (bundle `com.pesotchi.pika-tools`, Developer ID, not sandboxed). “App Store” is the Mac App Store build (`APPSTORE=1 ./scripts/build.sh`, code under `#if APPSTORE`, bundle `com.pikapik.tools`, sandboxed). The App Store build has no bundled 7-Zip (Archives in Finder uses the tools built into macOS and has limits), no fan helper, no updater and no Buy me a coffee link. Its Fans, Ports, Dock and Uninstaller tabs are hidden. It cannot change system settings itself (pointer acceleration, Animations, Hide desktop icons, Show hidden files, Background Tasks switches, Left by deleted apps), so there it shows a guide or an Open System Settings button. It has no Green button, Quit when the last window closes, Minimize or hide with a click in the Dock, Enter or Delete in Finder, Key repeat, Trash watcher, lid-closed Keep Awake, sensor temperatures (only the battery temperature), real monitor brightness (it only dims the picture), Fix words as you type and Stay in the background after Quit. It adds the Folders permission, the Say thanks tip section and a Services-based wrong-layout fix.

## Before you test

- **Build the Website edition:** `./scripts/build.sh` (Xcode 26 or newer; set `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer` if `xcode-select -p` points to the Command Line Tools). The app is `build/pikapik.app`. Local builds are signed ad hoc, so after every rebuild remove pikapik from Accessibility and Input Monitoring with the − button and add it again.
- **Build the App Store edition:** `APPSTORE=1 ./scripts/build.sh`, then open `build/pikapik.app`. If it does not launch locally (the sandbox needs a provisioning profile), test the TestFlight build instead.
- **One edition at a time.** The two editions can be installed together. Their synthetic keys and clicks are tagged (`Sources/pika-tools/Common/EventTag.swift`), so the copies no longer undo each other, but test one copy at a time, and quit it before starting the other, unless a step names two copies.
- **Reset permissions before a permission test:** Website `tccutil reset All com.pesotchi.pika-tools`, App Store `tccutil reset All com.pikapik.tools`. Reset settings with `defaults delete <bundle id>`. Both need a relaunch of pikapik afterwards.
- **Full Disk Access checks (Uninstaller Trash watcher, Left by deleted apps, Ports on other users) need the released Website app** in `/Applications` (the notarized one). A local development build does not hold Full Disk Access.
- **Test only on dummy apps.** Whenever a step says “stub app”, use a throwaway app whose name starts with `PikaE2E` (an empty app bundle with its own bundle id such as `org.example.pikae2e.test`, or a tiny app that plays a quiet tone). Never select, quit, uninstall, remove permissions of or change one of your real programs. Create test files only in a new test folder.
- **Write down system state before you change it:** `defaults read com.apple.dock`, `defaults read com.apple.WindowManager StandardHideDesktopIcons`, `defaults read com.apple.finder AppleShowAllFiles`. Put them back after the test.
- **Hardware some steps need:** a second display (Dock, Game Mode pointer, Show FPS), an external monitor not made by Apple (Brightness), a Mac with a battery (Battery) and one with fans (Fans), a trackpad and a mouse with side buttons and a wheel (Mouse), two input sources such as ABC and Russian (Keyboard), macOS 14.2 or later (Sound), a game or Chess (Games), Wi-Fi you can switch off (Speed Test).
- **Do not flip these casually:** Open archives with this app (changes the Mac’s default app for ZIP and 7Z), Fan speed Manual, Keep the Dock on one display (restarts the Dock).
- **Run synthetic-input tools yourself:** all clicks and keys in the steps are meant to be done by you at the Mac with the test app in front.

## General

### Settings search

**Does:** Finds any setting in the Settings window and jumps to it.

**How it works:** SwiftUI `.searchable` over `SettingsItem.allItems` (`Sources/pika-tools/Common/SettingsWindow.swift:103-283`), titles plus synonyms. The App Store build drops the items of hidden tabs and of rows that do not exist there and adds one item for each Privacy & Security list, marked “Other apps’ permissions” (`SettingsWindow.swift:119-143`). Empty result shows **No Results**.

**Nuances:** The index lists every shortcut of Games › System keyboard shortcuts too. A search hit scrolls to the row and flashes it.

**Edition:** Both; App Store differs: it hides the titles of the website-only rows.

**Test:**
1. Open Settings (menu bar icon › Settings…, or ⌘,). Click the search field and type “hidden” → Show hidden files appears (Website: with its switch; App Store: with the ⇧⌘. hint).
2. Click the result → the Finder tab opens, scrolled to that row.
3. Type “zzzz” → No Results.
4. (App Store) Type “fan” and “uninstall” → nothing found. Type “pointer” → only Turn off pointer acceleration (Open button) and game rules appear. Type “port” → nothing about ports.
5. (Website) Type “fan” → Fan speed under Fans.
6. (App Store) Type “camera” → Camera marked “Other apps’ permissions”; click it → the Permissions tab opens on that row.

### Sidebar and navigation

**Does:** Switches between tabs, shows or hides the sidebar, moves back and forward through visited tabs.

**How it works:** `SettingsWindow.swift` (`SettingsTab` enum :4-32, availability :80-88, sidebar rows :417-422, detail routing :516-562). The sidebar has two sections: tools, then Permissions and About.

**Options:**
- Sidebar — button that hides or shows the sidebar.
- Back / Forward — buttons, keys `[` and `]`.

**Nuances:** The Battery row appears only on Macs with a battery. The Sound row appears only on macOS 14.2 or later. The Pet row shows a badge with the number of new awards. Website sidebar: General, Battery, Keep Awake, Brightness, Fans, Temperature, Speed Test, Ports, Sound, Keyboard, Mouse, Windows, Dock, Finder, Animations, Uninstaller, Background Tasks, Games, Pet, then Permissions, About. App Store: the same without Fans, Ports, Dock and Uninstaller.

**Edition:** Both; App Store differs: Fans, Ports, Dock and Uninstaller tabs are hidden.

**Test:**
1. Click through every tab → each opens; the list matches the edition (count: Website 19 + 2, App Store 15 + 2, minus Battery on a desktop Mac, minus Sound before macOS 14.2).
2. Press Sidebar → the sidebar hides; press again → it returns.
3. Open General, then Mouse, then press Back (or `[`) → General; Forward (`]`) → Mouse.
4. (App Store) Confirm there is no Fans, Ports, Dock or Uninstaller row and no “Stay in the background after Quit”, Updates or iCloud sync row anywhere.

### Open at Login

**Does:** Starts pikapik when you log in.

**How it works:** `SMAppService.mainApp` through `LoginItem` (`Sources/pika-tools/Common/LoginItem.swift`); toggle at `SettingsWindow.swift:778`. When macOS needs approval the row says “Allow it in System Settings › General › Login Items”, gets an Open button (`BackgroundTasks.openLoginItems`) and shows an animated guide (`SettingsGuide.loginItems`, `Sources/pika-tools/Common/SettingsGuide.swift`) of where to click: Login Items & Extensions, then the pikapik switch. The labels in the guide come from your Mac, in its language; with Reduce Motion on it is one still frame with the click marked. App Store: `LoginItem.swift:26` also keeps the wanted state in a default.

**Nuances:** Off by default in the App Store build; the Website build turns it on after installing with the one-line command or Homebrew. `--uninstall` turns it off.

**Edition:** Both.

**Test:**
1. Turn Open at Login on → pikapik appears in System Settings › General › Login Items & Extensions; turn it off → it disappears.
2. If approval is pending, the row shows the Login Items hint, the Open button and the animated guide; press Open, approve it in System Settings and come back → hint, button and guide are gone. (With Reduce Motion on, the guide shows one still frame.)
3. (Website) Turn it on, log out and in → pikapik starts and shows its menu bar icon.

### Stay in the background after Quit

**Does:** Lets Quit close the windows while shortcuts and Keep Awake keep working in the background.

**How it works:** Stored under `Background.key`; `Sources/pika-tools/Common/Background.swift`, toggle at `SettingsWindow.swift:790` (`#if !APPSTORE`). Open pikapik again to bring the menu bar icon back; ⌥⌘Q (Quit Completely) really quits.

**Nuances:** In the App Store build `Background.isOn` is always false, so Quit always quits.

**Edition:** Website only (App Store: cut — an App Store app has to quit when asked).

**Test:**
1. (Website) Turn Stay in the background after Quit on, choose Quit in the menu → the menu bar icon disappears but a Keep Awake started earlier keeps the Mac awake (`pmset -g assertions`).
2. Open pikapik again → the icon is back. Hold ⌥ and choose Quit Completely (or press ⌥⌘Q) → the process ends.
3. (App Store) Press ⌘Q → the app really quits; there is no such switch.

### Appearance

**Does:** Sets the look of pikapik: System, Light or Dark.

**How it works:** `AppearancePicker` (`SettingsWindow.swift:891`, picker :789) sets `NSApp.appearance`.

**Edition:** Both.

**Test:**
1. Choose Light, then Dark, then System → Settings and the menu bar panel follow at once.
2. Quit and reopen pikapik → the choice is kept.

### Language

**Does:** Sets the language of the app. 23 languages plus “System”.

**How it works:** `Language.codes` (`SettingsWindow.swift:728`) writes `AppleLanguages` for the app. Languages: en ru uk de fr es it pt-BR nl sv pl cs ro tr ja zh-Hans zh-Hant ko ar hi th vi id.

**Options:**
- Restart pikapik to apply — row with a Restart button after a change; relaunches the app and reopens Settings.

**Edition:** Both.

**Test:**
1. Pick another language (for example Deutsch) → the row “Restart pikapik to apply” appears.
2. Press Restart → the app relaunches with Settings open, in the new language; Appearance and the other choices are kept.
3. Switch back to System.

### Settings file

**Does:** Saves all your settings to a file and loads them back, for example on a new Mac.

**How it works:** `SettingsBackup` (`Sources/pika-tools/Common/SettingsFile.swift`), buttons at `SettingsWindow.swift:769-770`, standard open and save panels.

**Options:**
- Export Settings… — save panel; writes the file.
- Import Settings… — open panel, then the alert “Replace your settings?” with Replace and Cancel (`SettingsWindow.swift:862`).

**Nuances:** The file holds settings only. Pet progress (pet-counts, pet-awards, pet-seen, pet-fresh, pet-outfit) is never exported or imported.

**Edition:** Both.

**Test:**
1. Change a few settings (for example Appearance and a Mouse switch). Press Export Settings…, save the file, open it in a text editor → your settings are there and no pet-* keys.
2. Change the settings again, press Import Settings…, choose the file, press Cancel in the alert → nothing changes; repeat and press Replace → the exported values return.

### Sync settings with iCloud

**Does:** Keeps your settings the same on all your Macs through iCloud.

**How it works:** `SettingsSync` (`Sources/pika-tools/Common/SettingsSync.swift`); the row appears only when `SettingsSync.isAvailable`. Website: iCloud Drive files, needs the iCloud Drive permission (`SettingsSync.swift:172`). App Store: `NSUbiquitousKeyValueStore` (`SettingsSync.swift:93,152,226,243`).

**Options:**
- Turn on iCloud Drive in System Settings — row with an Open button, Website only, when iCloud Drive is off.
- Needs a permission. Click to allow it. — row with an Allow button, Website only, when access is missing (asks the iCloud Drive permission).

**Nuances:** The switch appears only in a build signed with a provisioning profile that has the iCloud capability, so local builds usually do not show it. Pet awards and the outfit are never synced. Off by default.

**Edition:** Both; App Store differs: it uses iCloud key-value storage and never shows the iCloud Drive rows.

**Test:**
1. (signed build with iCloud) Turn the switch on → no error; with iCloud Drive off in System Settings the Open row appears (Website).
2. Change a setting on this Mac → the same setting appears on a second Mac signed in to the same iCloud account; the pet awards and outfit do not.

### Restore Defaults…

**Does:** Puts the settings of the open tab (and of General or About) back to their defaults.

**How it works:** `RestoreDefaultsSection` (`SettingsWindow.swift:639-650`) at the bottom of every tool tab and General; alert “Restore default settings?” with Restore Defaults and Cancel. The message differs per edition (`SettingsWindow.swift:871`).

**Options:**
- About › Restore Defaults… — Website only: turns “Check for updates automatically” back on (`SettingsWindow.swift:1153`).

**Nuances:** Keeps pet awards and the outfit. On the Finder tab it leaves Hide desktop icons and Show hidden files as they are. On About (Website) it only turns “Check for updates automatically” back on.

**Edition:** Both; App Store differs: the text of the alert and the About button (Website only).

**Test:**
1. Change a switch on a tab, scroll down, press Restore Defaults…, press Cancel → nothing changes. Press it again and Restore Defaults → the tab’s switches return to defaults.
2. On Finder, with Hide desktop icons and Show hidden files on (Website), restore → both stay on.
3. (Website) Turn the update switch off, press Restore Defaults… and confirm → it is on again.

## Battery

*The tab appears only on Macs with a battery.*

### Battery

**Does:** Shows the charge, whether the Mac is charging, and a picture of the battery.

**How it works:** IOKit power-source APIs (`Sources/pika-tools/Common/Battery.swift`, `BatterySettings.swift`). No permission.

**Options:**
- Battery Settings… — opens System Settings › Battery (`x-apple.systempreferences:com.apple.Battery-Settings.extension`, `BatterySettings.swift:134`). The row is named Charge Limit on macOS 26.4 or later with Apple silicon and Optimized Battery Charging otherwise; it only explains the macOS setting, nothing in pikapik changes how the Mac charges.
- Keep It Cool — advice row on how to keep the battery cool (static text, `BatterySettings.swift:139`).
- Storing Your Mac — advice row on how to leave the Mac for a long time (static text, `BatterySettings.swift:142`).

**Edition:** Both.

**Test:**
1. On a Mac with a battery open Settings › Battery → the charge and state match `pmset -g batt` and System Settings › Battery.
2. On a Mac without a battery → the sidebar has no Battery row.
3. Click Battery Settings… → System Settings opens on Battery.
4. Check the row title matches your macOS (Charge Limit or Optimized Battery Charging).
5. Open the Battery tab → the Keep It Cool row is there and readable.
6. Open the Battery tab → the Storing Your Mac row is there and readable.

### Battery Health

**Does:** Shows the battery’s condition, maximum capacity and cycle count.

**How it works:** Website: `/usr/sbin/system_profiler SPPowerDataType -json`. App Store: the AppleSmartBattery entry of the I/O Registry (`Battery.swift:47,116`), no other program is started. `BatterySettings.swift:84`.

**Options:**
- Condition — Normal or Service Recommended (`BatterySettings.swift:59`).
- Get Service… — link to Apple’s repair page, shown only when service is recommended (`:56`).
- Maximum Capacity — percent of the design capacity (`:68`).
- Cycle Count — compared with the rated count (`:79`).

**Nuances:** The Condition row appears only when the battery needs service. On macOS 27 the capacity values live only in the BatteryData of AppleSmartBatteryPack; the App Store build reads it there after the AppleSmartBattery root (`Battery.swift`, test `scripts/test-battery.swift`). The percent may differ by 1% from System Settings, which smooths it over weeks.

**Edition:** Both; App Store differs: reads the registry instead of running system_profiler.

**Test:**
1. Open the tab → Maximum Capacity is within two points of System Settings › Battery › Battery Health; Cycle Count matches System Information.
2. Open Activity Monitor → no `system_profiler` started by pikapik (App Store build and after the page loads).
3. (battery needing service) Condition shows Service Recommended and Get Service… opens Apple’s repair page.

### Power Adapter

**Does:** Shows the connected power adapter and its watts.

**How it works:** IOKit adapter details (`BatterySettings.swift:102`).

**Nuances:** Hidden on battery power.

**Edition:** Both.

**Test:**
1. Plugged in → Power Adapter shows its name and watts.
2. Unplug → the row disappears.

### Charging Power

**Does:** Shows the live watts going into the battery; on battery it is called Power Use and shows what the Mac draws.

**How it works:** IOKit battery voltage and amperage (`BatterySettings.swift:115`).

**Edition:** Both.

**Test:**
1. Plugged in and charging → Charging Power shows watts.
2. Unplug → the label becomes Power Use with watts.

## Keep Awake

### Keep your Mac awake

**Does:** Stops the Mac from sleeping for a while, or until you turn it off.

**How it works:** IOPMAssertion `PreventUserIdleSystemSleep` (`Sources/pika-tools/Common/KeepAwake.swift:230`), settings at `KeepAwake.swift:341-470`. Website also starts `/usr/bin/caffeinate -di|-i -t N` in `handOff()` (`:189-220`) so it survives quitting.

**Options:**
- Keep your Mac awake — Off / For a while / Indefinitely.
- Duration — appears for “For a while”; while Keep Awake is off it also shows “If turned on now, ends …” (`DurationPicker`, `KeepAwake.swift:353`).
- Display — Always on / Turns off as usual: whether the screen also stays on while the Mac is kept awake (`KeepAwake.swift:390`); Always on adds `PreventUserIdleDisplaySleep` (`:231`).

**Nuances:** The App Store build skips the caffeinate handoff.

**Edition:** Both; App Store differs: no handoff after Quit (Quit always quits there).

**Test:**
1. Choose For a while, set 5 minutes, then run `pmset -g assertions` → a PreventUserIdleSystemSleep assertion from pikapik is listed.
2. Choose Off → the assertion is gone. Choose Indefinitely → assertion present; quit pikapik (App Store) → gone.
3. (Website) Start a duration, quit with Stay in the background after Quit off → the Mac stays awake until the time ends.
4. Turn Keep Awake on with Display = Always on → `pmset -g assertions` also lists PreventUserIdleDisplaySleep.
5. Choose Turns off as usual → only the system-sleep assertion remains.

### Turn off the display now

**Does:** Switches the screen off right away without sleeping the Mac.

**How it works:** Website: `/usr/bin/pmset displaysleepnow`. App Store: sets `IORequestIdle` to true on `IOService:/IOResources/IODisplayWrangler`, which the app sandbox allows (`KeepAwake.turnOffDisplay` :202; row `KeepAwake.swift:403-408`). Also in the menu bar panel under Keep Awake (`MenuView.swift:234`).

**Nuances:** macOS 27’s own `pmset` no longer goes through `IORequestIdle`, so the App Store path has not yet been seen to darken an Apple Silicon display; check it on a TestFlight or App Store install.

**Edition:** Both; App Store differs: IODisplayWrangler instead of `pmset`.

**Test:**
1. Press Turn Off in Settings, then Turn off the display now in the menu, once with Display = Always on and once with Turns off as usual → every display goes dark within a second with no prompt; moving the mouse wakes it; `pmset -g assertions` still lists pikapik’s assertion.

### Work with the lid closed

**Does:** Keeps the Mac running with the lid shut (for example with an external display).

**How it works:** `pmset -a disablesleep 1` through `KeepAwake.runAsAdmin` (asks for the administrator password) and a watcher; shows an error label when it fails (`KeepAwake.swift:411`). The row is hidden on Macs without a lid.

**Options:**
- Stop when battery is below %@ — shown as “Stop when battery is below 20%”; turns lid-closed mode off at that charge (`KeepAwake.swift:416`).

**Nuances:** `hasLid` is false in the App Store build, so the row never shows there (`KeepAwake.swift:20,253`).

**Edition:** Website only (App Store: cut — needs administrator rights; the sandbox-reachable IOPMrootDomain clamshell switch has no App Store precedent and stays on if the app crashes).

**Test:**
1. (Website, MacBook) Turn it on → one administrator prompt; close the lid with an external display connected → the Mac keeps running; open the lid, turn it off → `pmset -g | grep SleepDisabled` shows 0.
2. Turn on Stop when battery is below 20% and unplug the charger → at 20% lid-closed mode switches off by itself.

### Buttons in Control Center and widgets

**Does:** Gives links you can add to Shortcuts, Control Center and widgets to start Keep Awake in one click.

**How it works:** `pikapik://keep-awake`, `pikapik://display`, `pikapik://lid-closed` handled by `KeepAwake.handle(_:)` (`KeepAwake.swift:473`). The App Store build uses the scheme `pikapik-store` (`scripts/build.sh:181`). Add the Open URLs action in Shortcuts with the link.

**Options:**
- Keep Awake — row with Copy Link (`KeepAwake.swift:433`).
- Keep the display on — row with Copy Link (`:434`).
- Work with the lid closed — row with Copy Link, Website only in effect (`:436`).
- Open Shortcuts — opens the Shortcuts app (`:439`).

**Edition:** Both; App Store differs: link scheme `pikapik-store`; no lid-closed link.

**Test:**
1. Press Copy Link on Keep Awake, paste it into Safari’s address bar and press Return → pikapik turns Keep Awake on (a second time turns it off).
2. Press Open Shortcuts → the Shortcuts app opens.

## Brightness

### Brightness

**Does:** Gives every external monitor that macOS cannot adjust its own brightness slider. The built-in screen and Apple displays are not listed, because macOS adjusts them itself.

**How it works:** `Sources/pika-tools/Common/BrightnessSettings.swift:61` (`BrightnessSlider`), `Brightness.swift`, `BrightnessMath.swift`. Website: real brightness over DDC/CI through the private IOAVService link (`MonitorLink`, `Brightness.swift:265`), with a gamma fallback and a poll timer; the level is re-applied after sleep, wake and re-plug. App Store: gamma-only dimming; monitors that macOS adjusts itself are left out (`Brightness.swift:164`); the subtitle reads “Dims the picture.” (`BrightnessSettings.swift:45`). No permission.

**Nuances:** With no such monitor the page says “No monitor needs pikapik right now. macOS adjusts the built-in screen and Apple displays itself, with the brightness keys and in Control Center. Connect another monitor and it will appear here.” Some monitors restart when they get a brightness command; if one disappears right after, pikapik turns Dim the picture instead on for it. A Brightness row can be added to the menu bar panel (Customize…); it shows only while a monitor is listed.

**Edition:** Both; App Store differs: the slider only dims the picture and never changes the monitor’s own brightness.

**Test:**
1. Connect an external monitor that is not made by Apple, open Settings › Brightness → the monitor is listed with its name and a slider; the built-in screen and Apple displays are not.
2. Disconnect every such monitor → the list is replaced by the “No monitor needs pikapik right now…” message.
3. (Website) Move the slider of a monitor that supports it → the monitor’s own brightness changes, the same as with its buttons (its on-screen menu shows the new value), and the colors stay the same.
4. Set a level, put the Mac to sleep and wake it, then unplug the monitor and plug it back → both times it comes back at the level you set.
5. Open the menu bar panel → no Brightness row. Press Customize…, turn on Brightness, press Done → a Brightness row with a slider per listed monitor. Unplug the monitor → the row disappears from the panel and from Customize…; plug it back → it returns.
6. (App Store) Each slider only dims the picture and its subtitle reads “Dims the picture.”; the monitor’s own brightness never changes.

### Dim the picture instead

**Does:** Switches a monitor that supports real brightness to software dimming, for monitors that do not respond to the slider.

**How it works:** `BrightnessSettings.swift:75` (anchor :23), `#if !APPSTORE`; sets `monitor.hasControl` off and dims with gamma.

**Nuances:** The picture gets darker but never black, and text stays readable. Turning the switch off brings the colors back at once.

**Edition:** Website only (App Store: dimming is the only mode, so there is nothing to switch).

**Test:**
1. (Website) On a monitor that does not respond to the slider, turn on Dim the picture instead and drag the slider to the left end → darker but not black, text readable.
2. Turn the switch off → the colors are back to normal at once.
3. (App Store) There is no such switch.

### Brightness keys

**Does:** Makes the brightness keys of your keyboard adjust the monitor under the pointer, with a small sun-and-bar indicator on that screen.

**How it works:** `Sources/pika-tools/Tools/Brightness/BrightnessKeysTool.swift:237`; a `.cgSessionEventTap` on system-defined keys, needs Accessibility. 16 steps; hold ⌥⇧ for finer steps (64).

**Nuances:** Off by default. With the pointer on the built-in screen the keys work as usual. Without Accessibility the toggle looks half-grey, asks for the permission when clicked and does nothing until it is allowed; the sliders, Dim the picture instead and the menu row keep working.

**Edition:** Both.

**Test:**
1. Look at Brightness keys → off by default.
2. Turn it on, allow Accessibility, put the pointer on the external monitor and press the brightness keys → only that monitor changes, in 16 steps, and a small indicator with a sun and a level bar shows on it. Hold ⌥⇧ while pressing → finer steps (64 instead of 16).
3. Put the pointer on the built-in screen → the keys work as usual.
4. Without Accessibility (never allowed, or turned off for pikapik in System Settings) → Brightness keys asks for the permission like the other tools and does nothing until it is allowed; the sliders still work.

## Fans

*Hidden in the App Store build.*

### Fan speed

**Does:** Lets you set each fan to Auto or to a fixed speed.

**How it works:** `Sources/pika-tools/Common/FanSettings.swift:66-73`, `FanControl.swift`, `SMC.swift`, helper `Helper/FanHelper/main.swift`. Writes the SMC through a privileged helper installed with the administrator password (`/Library/PrivilegedHelperTools` plus a LaunchDaemon), talking over NSXPC. One card per fan (“Fan 1”, “Fan 2” when there are several).

**Options:**
- Fan speed (Auto / Manual) — picker per fan.
- Fan speed (slider) — shown for Manual; from the fan’s minimum to its maximum in steps of 50 rpm.
- This Mac has no fans — what the page says on a Mac without fans (fanless MacBook Air; empty state, `FanSettings.swift:22`).

**Nuances:** Quitting or killing pikapik returns the fans to automatic within seconds (handoff on terminate, `App.swift:182`). The helper is installed and removed through the Fan control permission row. Needs a Mac with fans.

**Edition:** Website only (App Store: hidden — needs administrator rights and SMC access).

**Test:**
1. (Website) Open Settings › Fans, turn on manual control → one administrator prompt to install the helper; the speed follows the slider (watch rpm with a monitoring tool).
2. Quit pikapik, and in another run kill it (`pkill -9 pika-tools`) → the fans return to automatic within seconds.
3. Turn Manual back to Auto → the fans return to automatic at once.
4. (Website, fanless Mac) Open Settings › Fans → “This Mac has no fans”.

## Temperature

### Temperature

**Does:** Says in plain words how warm the Mac is inside (Normal, Warm, Hot, Very hot) with a short tip.

**How it works:** `ProcessInfo.thermalState` (`Sources/pika-tools/Common/TemperatureSettings.swift`, `Temperatures.swift`); `ThermalScene` picture. Website adds the processor degrees to the summary (`TemperatureSettings.swift:134`). App Store: the page also shows a Battery row on Macs with a battery (see Processor, Graphics, Memory, Storage, Battery and Wi-Fi).

**Nuances:** The App Store sandbox refuses the SMC (`IOServiceOpen` on AppleSMC is not permitted), so the other part temperatures are not available there. A desktop Mac in the App Store build shows only the thermal state. Not yet live-checked in the installed App Store app. New in 1.49.1.

**Edition:** Both; App Store differs: thermal state plus the battery temperature only.

**Test:**
1. Open Settings › Temperature → a verdict word and a tip show.
2. (App Store, Mac with a battery) a Battery row with degrees and a colored bar shows; (App Store, desktop Mac) only the thermal state.
3. Run a heavy task (for example a long video export) and come back → the verdict can move to Warm or Hot.

### Processor, Graphics, Memory, Storage, Battery and Wi-Fi

**Does:** Shows the temperature of each part of the Mac with a gauge.

**How it works:** Website: SMC readings (`Sources/pika-tools/Common/SMC.swift`, read in `Temperatures.refresh`, `Temperatures.swift:60-66`, `#if !APPSTORE`). App Store: only the Battery row, from `Battery.temperature()` (`Battery.swift:141`), the public `kIOPMPSBatteryTemperatureKey` read from the I/O Registry (the sandbox refuses the SMC); shown on Macs with a battery, and a reading outside 1–125 °C is dropped. The rows are listed in `TemperatureSettings.swift:29-34` for `ThermalPart` (`Temperatures.swift:86`). Bars and colors follow the normal range for each part. Parts a Mac does not report are not listed.

**Options:**
- Processor — chip temperature (`TemperatureSettings.swift:32`).
- Graphics — graphics chip.
- Memory — memory.
- Storage — SSD.
- Battery — battery.
- Wi-Fi — Wi-Fi chip.

**Edition:** Both; App Store differs: only the Battery row (a Mac with a battery), the other parts need the SMC, which the sandbox blocks.

**Test:**
1. (Website) Open Settings › Temperature → rows with degrees and colored bars for the parts your Mac reports; the degrees are in your region’s unit.
2. Compare Processor with a monitoring tool → close.
3. (App Store, Mac with a battery) One row, Battery, with degrees and a bar that is green, yellow or orange. (App Store, desktop Mac) No rows, only the word and the tip above.

## Speed Test

### Check Speed

**Does:** Measures your internet download and upload speed, responsiveness and ping.

**How it works:** `Sources/pika-tools/Tools/SpeedTest/SpeedTest.swift:208`, `SpeedMeasure.swift`, `SpeedResult.swift`. Website: `/usr/bin/networkQuality` (“Takes about half a minute. The check runs on Apple’s servers.”). App Store: an ephemeral URLSession against speed.cloudflare.com (“Takes about 15 seconds. The check uses speed.cloudflare.com.”). Only the last result is kept, in the app’s preferences. The button turns into Cancel while running.

**Options:**
- Download — Mbit/s.
- Upload — Mbit/s.
- Responsiveness — how quickly things react while the internet is busy (`SpeedTest.swift:236`).
- Ping — how long a signal takes to get there and back.
- What it’s good for — after a result, a list from the last result (`SpeedTest.swift:249`): Movies and shows in 4K, Video calls, Online games and Big downloads (“A 10 GB game takes about …”), each with a verdict.
- Speed Test — row with Copy Link under Buttons in Control Center and widgets (`SpeedTest.swift:256`, `SpeedTest.handle(_:)`): a link you can add to Shortcuts, Control Center or a widget to run the check in one click. App Store: scheme `pikapik-store`.

**Nuances:** A check starts only from Check Speed, from the Speed Test card in the menu bar panel (hidden until added in Customize…) or from a `pikapik://speed-test` link (App Store: `pikapik-store://`). With no connection the page says “No internet connection”.

**Edition:** Both; App Store differs: measures against speed.cloudflare.com, about 15 seconds.

**Test:**
1. Run a full test → Download, Upload, Responsiveness and Ping fill in, then a result with a time (“Checked …”).
2. Press Cancel in the middle → it returns to idle; the next run works.
3. Turn Wi-Fi off and run → “No internet connection”.
4. After a successful test → four lines with a verdict each, and the 10 GB estimate.
5. Press Copy Link, paste it in Safari and press Return → pikapik starts a check.

## Ports

*Hidden in the App Store build.*

### Port or program

**Does:** Shows which program holds a network port, or whether a port is free.

**How it works:** Search field with the hint “Type a number, like 3000” (`Sources/pika-tools/Tools/Ports/PortsPage.swift:22`) over `PortScanner` (libproc: `proc_listallpids`, `PROC_PIDLISTFDS`, `PROC_PIDFDSOCKETINFO`; `PortScanner.isFree` test-binds 127.0.0.1 for TCP and UDP). Messages “Port N is free” and “Port N is taken by macOS or another user”.

**Nuances:** On macOS 27 the kernel socket list is filtered for Team-signed code, so the Website build cannot list programs of root or other users (sshd, smbd, screen sharing). That is why a port held by them is reported as “taken by macOS or another user” and the System Settings hints for File Sharing, Screen Sharing and Remote Login may not appear. Local ad-hoc builds see everything, so test with the released app.

**Edition:** Website only (App Store: hidden — the sandbox hides other programs’ ports).

**Test:**
1. (Website) Type 47999 → “Port 47999 is free”.
2. Run `python3 -m http.server 47123 --bind 127.0.0.1` in Terminal, type 47123 or “python” → the Python row shows.
3. Turn on Remote Login in System Settings › General › Sharing and type 22 → “Port 22 is taken by macOS or another user”, not “is free”. Turn Remote Login off again.
4. (App Store) Settings has no Ports page, and searching Settings for “port” finds nothing about ports.

### Doors picture

**Does:** A small looping picture under the page title shows what a port is: numbered doors (3000, 5432, 8080) where only one program fits. A program takes door 3000, a second one is refused with a red cross, and takes the door when the first has left. The line under it says “Only one program fits at a door”.

**How it works:** `PortsArt` (`PortsPage.swift:112`) inside `IllustrationRow`. With Reduce Motion on, the picture stays on its first frame.

**Edition:** Website only (App Store: hidden).

**Test:**
1. (Website) Open Settings › Ports → three doors and two small program tiles loop without flicker; the second tile is refused once (red cross), then takes the door.
2. Turn on Reduce Motion in System Settings › Accessibility › Display → the picture stays still.

### Programs you started

**Does:** Lists the programs of your user that hold ports, with expandable rows. A program without an app icon, such as a console tool, shows a grey terminal tile. Only programs that wait for connections (TCP) are listed.

**How it works:** Section at `PortsPage.swift:56`; each row expands to addresses (links) and the Process ID. Context menu: Show in Finder. For AirPlay and sharing ports the row has a “How to Free It” button; its hint offers “Change in System Settings”.

**Edition:** Website only (App Store: hidden).

**Test:**
1. (Website) With the Python server from above running, expand its row → address 127.0.0.1:47123 and the Process ID show; right-click › Show in Finder reveals Python.

### Not yours: leave these alone

**Does:** Lists ports held by macOS or other users. Nothing here can be quit.

**How it works:** Section at `PortsPage.swift:72`; rows have no Free Up button.

**Edition:** Website only (App Store: hidden).

**Test:**
1. (Website, released app) Rows under Not yours: leave these alone never offer to quit anything.

### What the globe means

**Does:** A note under the lists explains the port chips: a chip with a globe means other devices on your network can connect, a chip without one means only this Mac can.

**How it works:** `PortLegend` (`PortsPage.swift:328`), shown while at least one program is listed; the same two sentences are the tooltips of the chips.

**Edition:** Website only (App Store: hidden).

**Test:**
1. (Website) With the Python server from above running, the note under the list shows a chip with a globe and a chip without one, each with its sentence. Searching for a port that no program holds hides the note.

### Free Up

**Does:** Quits the program that holds a port.

**How it works:** Button on a program row (`PortsPage.swift:239`) → alert “Quit “Python”?” with Quit, Force Quit and Cancel; SIGTERM, then SIGKILL after about five seconds if the program ignores it (`PortsModel.swift:175`). An App Store-only page variant with an Open Activity Monitor button (`PortsPage.swift:226`) exists in code but is unreachable because the tab is hidden.

**Edition:** Website only (App Store: hidden).

**Test:**
1. (Website) Click Free Up on the Python row (port 47123) → “Quit “Python”?”. Cancel changes nothing. Quit stops the server and the row disappears.
2. Run `python3 -c "import signal,socket,time; signal.signal(signal.SIGTERM, signal.SIG_IGN); s=socket.socket(); s.bind(('127.0.0.1', 47124)); s.listen(); time.sleep(600)"`, click Free Up › Quit → after about five seconds “Force quit “Python”?”; Force Quit frees port 47124.

## Sound

*Appears on macOS 14.2 or later only.*

### App Volume

**Does:** Gives every app that plays sound its own volume slider and mute button.

**How it works:** `Sources/pika-tools/Tools/AppVolume/AppVolumeTool.swift:111`. A Core Audio process tap (`CATapDescription`, `AudioHardwareCreateProcessTap`) feeds a private tap-only aggregate device, played back through an output-only HAL unit on the app’s output device. Only apps whose slider is below 100% or that are muted get a tap. Sound is processed in memory, never recorded or saved. Needs the System Audio Recording permission. The microphone is never opened.

**Options:**
- Slider and Mute — one row per playing app with its icon, a slider (`AppVolumeTool.swift:166`) and a Mute / Unmute button; it changes or silences one app without touching the others, the Mac’s volume or the output device. Gain = slider squared with 30 ms smoothing so there are no clicks. Level and mute are remembered by app and kept after relaunch. A row of an app that stopped dims and goes after about 30 seconds, unless the app is muted or below 100%, then it stays dimmed.
- No apps are playing sound — what the list says when nothing plays and App Volume is on and allowed (`AppVolumeTool.swift:131`).

**Nuances:** Off by default. Hidden on macOS 14.0 and 14.1 (no Sound page and no App Volume row in the menu). Without the permission the row is half-grey and clicking it opens Permissions on the System Audio Recording row; nothing is asked while App Volume is off. The tap aggregate is private, so Audio MIDI Setup and System Settings › Sound show no extra device. Never test with a program you use: start a stub app that plays a quiet tone and keep another app playing sound.

**Edition:** Both.

**Test:**
1. (macOS 14.0 or 14.1) No Sound page in Settings and no App Volume row in the menu bar panel.
2. Turn App Volume on without the permission → no prompt yet; the row is half-grey and clicking it opens the Permissions page on the System Audio Recording row. Allow shows the system prompt (after a refusal it opens System Settings › Privacy & Security instead); Turn Off also opens System Settings in the App Store build. Once allowed, the row has a green check and the list says “No apps are playing sound”.
3. Quit pikapik with ⌘Q while a stub app is below 100%, then repeat and force quit it → the stub is back at full volume at once both times, and neither while it ran nor after does Audio MIDI Setup or System Settings › Sound show an extra device.
4. Start a stub app that plays a quiet tone and keep another app playing sound → both appear with their icon, a slider at 100% and a mute button.
5. Drag the stub’s slider down → only the stub gets quieter, smoothly and without clicks, silent at the left end; the other app, the Mac’s volume and the output device do not change. Back at 100% the stub plays as before.
6. Press the stub’s mute button → it falls silent at once, its slider greys out and the button shows a crossed speaker with the tip “Unmute”; press again → the sound returns at the old level. Relaunch pikapik → the level and the mute are kept.
7. Quit the stub → its row dims and goes after about 30 seconds (stays dimmed if muted or below 100%).
8. With App Volume on and allowed and nothing playing → “No apps are playing sound”.

## Keyboard

### Switch language

**Does:** Changes the input language with a quick Option and Shift gesture, without the system menu.

**How it works:** `Sources/pika-tools/Tools/InputSwitch/InputSwitchTool.swift:176`, `InputSwitchGesture.swift`. Hold ⌥ and tap ⇧ for the next language; ⇧ then ⌥ for the previous. A listen-only `CGEventTap`; needs Input Monitoring. Game Mode can switch the language on every press of the shortcut (see Games › System keyboard shortcuts).

**Nuances:** The App Store build uses the permission only to see the shortcut. Needs at least two input sources. With two copies of pikapik running, both step from the source that was selected when the gesture began (`InputSources.select(_:from:)`, `InputSources.swift`), so they pick the same language instead of switching twice.

**Edition:** Both.

**Test:**
1. Add two input sources (for example ABC and Russian), turn Switch language on, allow Input Monitoring.
2. Hold ⌥ and tap ⇧ in TextEdit → the input source changes to the next one; ⇧ then ⌥ → the previous one.
3. (two copies, App Store and Website, both with the switch on) Repeat step 2 → the language changes once, not back to where it was.

### Repeat a held key

**Does:** Makes a held key repeat the letter instead of showing the accent popup.

**How it works:** Writes the global default `ApplePressAndHoldEnabled` with CFPreferences (`Sources/pika-tools/Tools/KeyRepeat/KeyRepeatTool.swift:136`); no permission. `--uninstall` puts it back.

**Edition:** Website only (App Store: cut — an App Store app cannot change global defaults).

**Test:**
1. (Website) Turn it on, open a new app (TextEdit) and hold a key → the letter repeats, no accent popup. Turn it off and reopen the app → the popup is back.

### Home and End go to the start and end of a line

**Does:** Makes Home and End move to the start and end of the line in every app, like on Windows.

**How it works:** `.defaultTap` `CGEventTap` (`Sources/pika-tools/Tools/HomeEnd/HomeEndTool.swift:97`), needs Accessibility. Website: switches only when a text field has focus (`TextFocus`, :145). App Store: the sandbox cannot see focus, so it switches in every app except browsers (Safari, Chrome, Firefox, Edge, Arc, Brave, Opera, Vivaldi, Zen, Orion, Chromium, DuckDuckGo, Yandex), Finder and Music (`storeExcluded`, :26). Terminals, virtual machines and remote desktop apps are skipped in both (`alwaysExcluded`, :18).

**Options:**
- Home and End work as usual in these apps — list of apps to leave alone: Add App… / Done, app shelf of open apps, Remove (`HomeEndTool.swift:224`).

**Nuances:** The Home and End it sends are tagged (`Sources/pika-tools/Common/EventTag.swift`), so another copy of pikapik does not handle them again.

**Edition:** Both; App Store differs: no text-focus check, so it also works outside text fields, except in browsers, Finder and Music.

**Test:**
1. Turn it on, type a long line in TextEdit and press Home and End → the caret goes to the start and end of the line.
2. Add TextEdit under “Home and End work as usual in these apps” → Home and End behave as macOS does by default there.
3. (Website) With no text field focused, for example on the desktop, press Home → it does what macOS does by default.
4. (App Store) Press Home and End in Safari and Music and in a Finder window → they behave as macOS does by default there. In another app, for example Notes → the caret jumps to the start and end of the line.

### Retype words you typed in the wrong language

**Does:** Fixes text typed in the wrong keyboard layout (“ghbdtn” becomes “привет”).

**How it works:** Website: event tap with Accessibility (`Sources/pika-tools/Tools/LayoutFix/LayoutFixTool.swift:566`). App Store: Services-based (`LayoutFixTool.swift:5`, `LayoutFixServiceSettings` :142-199) because the sandbox cannot read selected text; the toggle row asks Accessibility itself.

**Options:**
- Fix words as you type — fixes on Space or Return (`LayoutFixTool.swift:576`). Website only.
- Fix the last word or selected text — shortcut recorder, default ⌃⇧Space (`:580`). Website only.
- Words left as you typed them — list with a Clear button, shown only when not empty (`:587-590`). Website only.
- Keyboard Settings… — button with a note, shown when fewer than two layouts exist (`:595-597`). Website only.
- Don’t fix text in these apps — app exclusion list (`:602`). Website only.

**Nuances:** Needs at least two input sources. Website App Exclusions: Add App… / Done, app shelf, Remove. The retyped text and the keys it sends are tagged (`EventTag.swift`), so with two copies of pikapik one copy does not fix the text the other has just retyped.

**Edition:** Both; App Store differs: only the selected text is fixed, through the Services item or the shortcut (see Fix the selected text); the options above are Website only.

**Test:**
1. Add two input sources (ABC and Russian). (Website) Turn on Retype words you typed in the wrong language and Fix words as you type, type “ghbdtn ” in TextEdit with the ABC layout → it becomes “привет ”.
2. Select a mistyped word and press ⌃⇧Space → it is fixed.
3. Undo a fix → the word appears under Words left as you typed them; Clear empties the list.
4. With only one input source → Keyboard Settings… with its note shows.
5. Add TextEdit to Don’t fix text in these apps → no fixing there.

### Fix the selected text

**Does:** (App Store) Fixes the selected mistyped text with a shortcut, no need to open the Services menu.

**How it works:** `LayoutFixTool.swift` (`LayoutFixServiceSettings`). The event tap (Accessibility, asked on the Permissions tab) holds back your recorded shortcut (default ⌃⇧Space) and posts the hidden Services key ⌃⌥⇧⌘F19 (`NSKeyEquivalent` of the Fix Wrong Keyboard Layout service, PR #78). No clipboard, no Accessibility reading of text.

**Options:**
- Fix the selected text — shortcut recorder, “Select the text, then press these keys”.

**Nuances:** If you reassign the Services shortcut in System Settings the in-app shortcut stops working (it presses the original hidden key). The app in front needs a Services menu (every normal Cocoa app has one). Not live-checked in the real App Store build. New in 1.49.1.

**Edition:** App Store only.

**Test:**
1. (App Store) Turn it on and allow Accessibility when asked. In TextEdit type “ghbdtn” in the ABC layout, select it, press ⌃⇧Space → it becomes “привет”.
2. Record another shortcut → the new one works and the old one does not.

### Fix Wrong Keyboard Layout

**Does:** A Services command in every app’s Services menu and right-click menu that fixes the selected text.

**How it works:** `NSServices` in the Info.plist, `Sources/pika-tools/Common/LayoutFixService.swift` (`fixLayout` pasteboard service; title in `Resources/en.lproj/ServicesMenu.strings`). Receives only the selected text, only on that command; the app in front puts the fixed text back. Needs no permission.

**Edition:** Both.

**Test:**
1. In TextEdit type “ghbdtn” (ABC layout), select it, choose TextEdit › Services › Fix Wrong Keyboard Layout (or right-click › Services) → “привет”.
2. Nothing needs a permission for this path.

## Mouse

### Turn off pointer acceleration

**Does:** Makes the pointer move the same distance for the same hand movement, with no speed-up.

**How it works:** Website: the private `IOHIDEventSystemClient` (`HIDPointerAccelerationType`), no permission; restored when pikapik quits (`Sources/pika-tools/App.swift:185`) and by `--uninstall` (`Sources/pika-tools/Tools/Mouse/PointerTool.swift:216`). App Store: replaced by an animated guide and a row with an Open button to System Settings › Mouse (`SettingsWindow.swift:978-987`, `com.apple.Mouse-Settings.extension`) because an App Store app cannot change it. The guide (`SettingsGuide`, `Sources/pika-tools/Common/SettingsGuide.swift`) shows where to click: Advanced…, then “Pointer acceleration” off; its labels come from your Mac, in its language. System Settings shows the Mouse page only while a mouse is connected.

**Options:**
- Tracking speed — slider, disabled while the switch is off (`PointerTool.swift:226`). Website only; in the App Store guide it is the system’s own slider.

**Edition:** Both; App Store differs: shows the animated guide and an Open button instead of the switch.

**Test:**
1. (Website) Turn it on, move the mouse slowly and quickly → the distance per hand movement is the same; move Tracking speed → the pointer speed changes. Turn it off → acceleration returns.
2. Quit pikapik → acceleration is restored.
3. (App Store) The row shows an animation (click Advanced…, turn off Pointer acceleration) above Open; press Open → System Settings opens on Mouse. With Reduce Motion on, the animation is one still frame with the click marked. Search for “Tracking speed” in Settings → nothing.

### Scroll by lines

**Does:** Makes a mouse wheel scroll a fixed distance per click instead of macOS’s smooth, accelerated scroll.

**How it works:** `.defaultTap` `CGEventTap` (`Sources/pika-tools/Tools/Mouse/WheelTool.swift:313`), needs Accessibility.

**Options:**
- Scroll by — two tiles, Lines or Pixels (`WheelTool.swift:323-341`).
- Distance per click — slider (`:344`).

**Edition:** Both.

**Test:**
1. Turn it on and allow Accessibility. Scroll one wheel click in a long web page → it moves by a fixed amount; change Distance per click → the amount changes; switch Scroll by between Lines and Pixels → it still scrolls.
2. Turn it off → macOS’s usual scrolling returns.

### Scroll direction for trackpad and mouse

**Does:** Sets the scroll direction of the trackpad and of the mouse wheel separately.

**How it works:** Reads the system’s Natural scrolling (`com.apple.swipescrolldirection`) and flips each scroll event that does not match your choice in the shared scroll tap (`ScrollTap`, `Sources/pika-tools/Tools/Mouse/WheelTool.swift:102`; `ScrollDirection.rewrite`, `WheelStep.swift:77`); needs Accessibility. It does not change the System Settings switch (`Sources/pika-tools/Tools/Mouse/ScrollDirectionTool.swift:106`). Flipped events are tagged, so a second copy of pikapik does not flip them back.

**Options:**
- Trackpad direction — Natural / Classic (`:133-146`).
- Mouse wheel direction — Natural / Classic (`:135`).

**Edition:** Both.

**Test:**
1. Turn it on, set Trackpad Natural and Mouse wheel Classic → the trackpad scrolls like a phone, the wheel scrolls the classic way.
2. Swap the two → the directions swap. System Settings › Trackpad › Scroll & Zoom keeps its own “Natural scrolling” setting.
3. (two copies, App Store and Website, both with the switch on) Scroll → the direction is flipped once, not twice.

### Side buttons go back and forward

**Does:** Makes the mouse’s side buttons act as Back and Forward in browsers and Finder.

**How it works:** Accessibility event tap (`Sources/pika-tools/Tools/Mouse/SideButtonsTool.swift:211`); sends a back or forward swipe tagged (`Sources/pika-tools/Common/EventTag.swift`) and ignores tagged presses, so with two copies of pikapik the buttons are not swapped twice.

**Options:**
- Swap the side buttons — exchanges Back and Forward (`:221`).

**Edition:** Both.

**Test:**
1. Open two pages in Safari, press the lower side button → Back; the upper → Forward.
2. Turn on Swap the side buttons → the buttons swap roles. (two copies, both with the switch on) They are still swapped once.

### Mouse button hides the current app

**Does:** Hides the front app with a mouse button, like ⌘H.

**How it works:** Accessibility event tap holds back the chosen button’s click (`Sources/pika-tools/Tools/Mouse/HideAppTool.swift:179`) and calls `NSRunningApplication.hide()`; no keystroke is sent. It ignores events another pikapik copy has sent.

**Options:**
- Change… — records a mouse button: press Change…, then press a mouse button over the Settings window; the label reads “Middle button” or “Button N”; Cancel stops recording (`HideAppTool.swift:196-203`).

**Edition:** Both.

**Test:**
1. Turn it on, press Change…, press the middle button → the label says “Middle button”.
2. With a stub app in front press the middle button → the app hides; the click does not reach the app under the pointer.

### Middle click on the trackpad

**Does:** A tap or click with three (or four) fingers works like the middle mouse button: open a link in a new tab, close a tab.

**How it works:** A listen-only event tap reads the fingers from gesture events; `MiddleClickGesture` decides when a quick tap ends and posts a middle click at the pointer; a second tap turns a left or right press made with that many fingers into the middle button (down, drag, up). Starts only when Accessibility and Input Monitoring are already allowed.

**Options:**
- Fingers — Three fingers or Four fingers; the row says what works with the current trackpad settings (Tap to click off, Look up on a three-finger tap, three-finger drag on).

**Nuances:** Off by default and hidden from the menu. Excluded from the App Store build by `scripts/build.sh`. Needs a real trackpad to test.

**Edition:** Website only (App Store: cut — needs to read gestures).

**Status:** Pending — PR #70: new switch Middle click on the trackpad with the Fingers row; not merged yet.

**Test:**
1. (once PR #70 is merged, Website) Turn it on; on a link in Safari tap with three fingers → opens in a new tab; on a tab tap with three fingers → closes it. Pick Four fingers and repeat.
2. Open the Fingers row with three-finger drag on, with Look up on a three-finger tap on, and with Tap to click off → the row says what works.
3. Scrolling, pinch, swipes between pages and Mission Control work as before.
4. With Input Monitoring off → no system dialog by itself; the rows look half-grey and a click asks for the permission and opens Permissions.

## Windows

### Green button enlarges the window

**Does:** Makes the green window button fill the screen area (like Windows maximize) instead of entering full screen.

**How it works:** AXUIElement hit-test on the zoom button, sets AXSize and AXPosition (`Sources/pika-tools/Tools/Windows/WindowZoomTool.swift:284`), needs Accessibility.

**Options:**
- Green button works as usual in these apps — app exclusion list (Add App… / Done, Remove) (`WindowZoomTool.swift:292`).

**Edition:** Website only (App Store: cut — needs to move other apps’ windows).

**Test:**
1. (Website) Turn it on and allow Accessibility. Click the green button of a small stub or TextEdit window → it fills the screen area and does not go full screen.
2. Add that app to the exclusions → the green button works as macOS does.

### Protect quitting and closing

**Does:** Stops accidental ⌘Q and ⌘W: they do nothing alone; ⇧⌘Q quits and ⇧⌘W closes (or your own keys).

**How it works:** `.defaultTap` `CGEventTap` on key down and up (`Sources/pika-tools/Tools/CommandKeys/CommandKeysTool.swift:201`, Settings rows :198-230), needs Accessibility. A bare ⌘Q or ⌘W is dropped; the quit and close keys are swallowed and replaced by a fresh ⌘Q or ⌘W tagged (`Sources/pika-tools/Common/EventTag.swift`, `eventSourceUserData` 0x70696B61) so a second copy of pikapik lets it through.

**Options:**
- Quit app — toggle with a shortcut recorder, default ⇧⌘Q (key `command-keys-quit-shortcut`).
- Close window — toggle with a shortcut recorder, default ⇧⌘W (key `command-keys-close-shortcut`).

**Nuances:** The Games tab footer lists these keys under “To leave a game, press …”; ⌥⌘Esc always works. With two copies of pikapik running (App Store and Website) quitting a game with these keys used to fail; fixed in 1.49.1.

**Edition:** Both.

**Test:**
1. Turn it on and allow Accessibility. In a stub app press ⌘Q alone → nothing; ⇧⌘Q → the app quits. Open a window, press ⌘W → nothing; ⇧⌘W → the window closes.
2. Record other keys in the Quit app recorder → the new keys work.
3. (App Store) Press ⌘Q while pikapik is in front with the switch off → the app really quits.

### Quit when the last window closes

**Does:** Quits an app when you close its last window, like on Windows.

**How it works:** `Sources/pika-tools/Tools/Windows/QuitOnCloseTool.swift:320`; needs Accessibility and Input Monitoring (`:11`); private CGS APIs for windows on other Spaces (`:237`). App Store branches (`:213,226`) are dead code.

**Options:**
- Never quit these apps — app exclusion list (`QuitOnCloseTool.swift:328`).

**Nuances:** The app quits only when no window remains anywhere: other Spaces and minimized windows count.

**Edition:** Website only (App Store: cut — private APIs).

**Test:**
1. (Website) Turn it on. Close the last window of a stub app → it quits. Repeat with the app’s windows on another Space and with a minimized window → it quits only when no windows remain anywhere.
2. Add the stub to Never quit these apps → it stays open.

## Dock

*Hidden in the App Store build.*

### Minimize or hide with a click in the Dock

**Does:** Clicking the icon of the front app in the Dock minimizes its windows or hides the app.

**How it works:** `.defaultTap` event tap plus Accessibility (`Sources/pika-tools/Tools/Windows/DockHideTool.swift:376`).

**Options:**
- A click on the icon — Minimizes the windows / Hides the app (`DockHideTool.swift:388`).

**Nuances:** The click it replays is tagged (`EventTag.swift`), so another copy of pikapik does not act on it twice.

**Edition:** Website only (App Store: cut — needs to look inside the Dock).

**Test:**
1. (Website) Turn it on and allow Accessibility. Click the Dock icon of the front stub app → windows minimize (or the app hides, per the picker); click again → it returns.

### Keep the Dock on one display

**Does:** Keeps the Dock on its display, however fast you move the mouse to the bottom of the other one.

**How it works:** Writes the hidden key `com.apple.dock allow-display-switching` = false and restarts the Dock once (`Sources/pika-tools/Tools/Windows/DockDisplayTool.swift:95`, `DockDisplaySwitch.swift`). No permission. The Dock reads it only at start. Turning off (and `--uninstall`) puts back the previous value.

**Options:**
- Main display — row with an Open button to System Settings › Displays; make another display the main one to move the Dock on purpose (`DockDisplayTool.swift:103`).

**Nuances:** Needs two displays and “Displays have separate Spaces” on (System Settings › Desktop & Dock).

**Edition:** Website only (App Store: cut — an App Store app cannot change the Dock’s settings).

**Test:**
1. (Website, two displays) Run `defaults read com.apple.dock allow-display-switching` and note the answer. Turn on Keep the Dock on one display → no permission prompt, the Dock restarts once, pushing the pointer against the bottom edge of the other display no longer moves it, and the command prints 0.
2. Quit and reopen pikapik → the Dock does not restart.
3. Turn the switch off → the Dock restarts once, moves between displays again, and the command prints what it printed before (or says the key does not exist).
4. Turn it on again and run `build/pikapik.app/Contents/MacOS/pika-tools --uninstall` → same result as turning it off.
5. Press Open next to Main display → System Settings › Displays opens.

## Finder

*Header “Create, convert and compress files right in Finder”. The Finder extension switches are New File in Finder, Smaller Copy in Finder, Convert in Finder and Archives in Finder; the right-click items they add are described in the same entries.*

### New File in Finder

**Does:** Adds New File to Finder’s right-click menu, in a folder or on its background, to make a text file (or other kinds) in place.

**How it works:** Finder Sync extension `Extensions/NewFile/NewFileExtension.swift:13`, switch at `Sources/pika-tools/Tools/NewFile/NewFileTool.swift:20-25` through `FinderExtension.swift:257`. Website: `pluginkit -a`, `-e use`, `-e ignore`, `-m` (`FinderExtension.swift:60-66,103-120`). App Store: stores the wanted state in UserDefaults and opens `FIFinderSyncController.showExtensionManagementInterface()` so you turn the extension on in System Settings; the switch checks that this extension’s own process is running (PR #72). Needs the Finder Extensions permission item. Saving into a folder asks once for access to the home folder (App Store: `FolderAccess`, security-scoped bookmark).

**Nuances:** Before 1.49.1 the App Store New File switch looked on while only another extension was enabled, so the menu item could be missing; now each switch shows its own extension’s state. Known gap (App Store): turning a Finder tool off in pikapik does not hide its menu item; disable the extension in System Settings. Not yet live-checked in the App Store branch.

**Edition:** Both; App Store differs: the switch turns grey until you enable the extension in System Settings (Login Items & Extensions › Finder) and the first file asks for the home folder.

**Test:**
1. (App Store) Turn on New File, Smaller Copy, Convert → the three tools turn grey; clicking one opens the Permissions page on the Finder Extensions row. Allow opens System Settings › Login Items & Extensions › Finder; enable each extension; return to pikapik → the row shows a green check and the tools are no longer grey. Turn Off opens the same list.
2. Right-click in a folder › New File → (App Store) an Open panel asks once for the home folder; after Allow Access the file is created and the panel does not return after relaunch. (Website) the file is created at once.
3. (Website) Turn the switch off → the item leaves Finder’s menu.

### Smaller Copy in Finder

**Does:** Adds Make a Smaller Copy to Finder’s right-click menu for photos and videos; the copy is saved next to the original.

**How it works:** Extension `Extensions/Compress/CompressExtension.swift:17`, switch `Sources/pika-tools/Tools/Compress/CompressTool.swift:20-25`, engine `Sources/pika-tools/Tools/Windows/Compressor.swift`. Videos are exported with a file-length limit of half the source (about 47–52 percent, same frames, audio kept); photos are re-encoded. If the result would not be smaller than 95 percent the message “Already compact” shows and no copy is made. `FolderAccess.ensure` asks for folder access in the App Store build (`Extensions/Shared/Folders.swift`, `FolderAccess.swift:6`).

**Nuances:** AVFoundation will not go below about 1.5 Mbit/s at 1080p30, so a very small video still reports “Already compact”. Before 1.49.1 most videos ended with “Already compact”.

**Edition:** Both; App Store differs: needs the extension enabled in System Settings and asks for folder access.

**Test:**
1. Right-click a photo and a screen recording in Downloads › Make a Smaller Copy → a smaller copy appears next to the original (video about half the size).
2. Do the same on a file on an external volume → a folder prompt when needed; output next to the original.
3. Try a tiny already-compressed video → “Already compact”, no copy.

### Convert in Finder

**Does:** Adds Convert To to Finder’s right-click menu: change a file’s format (for example PNG to JPEG or HEIC, or video to “M4A (Audio Only)”).

**How it works:** Extension `Extensions/Convert/ConvertExtension.swift:22`, formats in `ConvertFormats.swift`, switch `Sources/pika-tools/Tools/Convert/ConvertTool.swift:26-31`. Same enabling flow and folder access as Smaller Copy. For a PNG the targets are JPEG, HEIC, GIF, TIFF, PDF. There is no size check.

**Nuances:** Like New File, it showed on while only another extension was enabled before 1.49.1; now it asks for permission until its own extension runs.

**Edition:** Both; App Store differs: needs the extension enabled in System Settings and asks for folder access.

**Test:**
1. Right-click a PNG › Convert To › JPEG → a JPEG appears next to it. Right-click a video › Convert To › M4A (Audio Only) → an audio file appears.
2. On an external volume or in Downloads → a folder prompt when needed (App Store), output next to the original.

### Archives in Finder

**Does:** Adds Extract and Create Archive… to Finder, a preview of archives on Space, and (Website) the option to open ZIP and 7Z with pikapik.

**How it works:** Switch `Sources/pika-tools/Tools/Archive/ArchiveTool.swift:40-45`; one `archive` key turns both the Finder extension and the preview on or off (off runs `pluginkit -e ignore`). Bundled 7-Zip 26.04 `7zz` (LGPL; the license file and source ship with releases). Website engine routing: `ditto` for zips with `__MACOSX`, `bsdtar` for legacy code-page zips, `7zz` for the rest. App Store: no `7zz`; `ditto`, `bsdtar`, `gzip` and `bzip2` from macOS do the work (`ArchiveProbe.swift`, `ArchiveCreate.swift`, `ArchiveExtract.swift` under `#if APPSTORE`), and the preview reads headers with the system libarchive.

**Options:**
- Open archives with this app — toggle labelled “ZIP · 7Z”; sets the default app for `public.zip-archive` and `org.7-zip.7-zip-archive` (`ArchiveTool.swift:48-51`). Changes the Mac’s default apps; do not flip it in tests you do not want to keep. Website only: the App Store row is not shown.

**Nuances:** Never create RAR (license). Zips with legacy names and a password may come out garbled. Create Archive… is hidden when the selection spans several folders. Dev builds register the preview only after `pluginkit -a <appex>`. App Store limits: a password only for ZIP (not 7Z); no splitting into parts, and multi-part archives (.001, .part1.rar, .z01 …) cannot be opened; single .xz, .lzma and .zst files cannot be opened (single .gz and .bz2 can); password-protected 7Z and RAR cannot be opened. The first use asks for access to the home folder (the same folder access New File and Smaller Copy use), and the Finder items need the extension turned on in System Settings › General › Login Items & Extensions (the animated guide in Permissions shows where). The App Store package carries the Archive and Preview extensions only when their provisioning profiles are set (`scripts/appstore.sh`); without them the Archives row is absent.

**Edition:** Both; App Store differs: built-in macOS tools instead of 7-Zip, the limits above, no Open archives with this app, needs the extension enabled and asks for folder access.

**Test:**
1. (Website) Turn on Archives in Finder. In a new test folder right-click a folder of more than 20 MB › Create Archive…, choose 7Z, set a Password and Split into parts of 15 MB → numbered parts appear next to the folder; right-click the first part › Extract asks for the password and unpacks a copy of the folder.
2. Select a ZIP and press Space → the files inside show.
3. Turn the switch off → the menu items and the preview are gone.
4. (App Store) Turn on Archives in Finder and enable the extension in System Settings › General › Login Items & Extensions → right-click a folder › Create Archive… → a folder prompt the first time, then the dialog; ZIP can have a Password, with 7Z the Password switch is disabled, and there is no Split archive row. Right-click the archive › Extract → the files appear next to it. Select it and press Space → the files inside show. A password-protected 7Z or a .part1.rar › Extract → the message “… can’t be opened”. There is no Open archives with this app switch.

### Extract

**Does:** Unpacks an archive (ZIP, 7Z, TAR, RAR, and more) next to it from Finder’s right-click menu.

**How it works:** Finder item in `Extensions/Archive/ArchiveExtension.swift:16`, bundled `7zz`, a progress window (`ArchiveQueue.swift`, `ArchiveRun.swift`). Asks for a password with Extract and Cancel when the archive is protected.

**Edition:** Both; App Store differs: unpacks with the tools built into macOS, so password-protected 7Z and RAR, multi-part archives and single .xz, .lzma and .zst files are refused with a message; asks for folder access the first time.

**Test:**
1. (Website) Right-click an archive › Extract → a progress window, then the unpacked files next to it. With a password-protected archive → a password prompt (Extract / Cancel); a wrong password fails clearly, the right one works.
2. (App Store) The same with a ZIP, a password-protected ZIP and a .tar.gz → they unpack. A password-protected 7Z or a .xz → the message “… can’t be opened”.

### Create Archive…

**Does:** Packs files or a folder into an archive from Finder’s right-click menu.

**How it works:** Finder item `Extensions/Archive/ArchiveExtension.swift:18`; dialog `Sources/pika-tools/Tools/Archive/ArchivePrompts.swift`.

**Options:**
- Name — archive name.
- Format — ZIP, 7Z, TAR.GZ, TAR.XZ.
- Password — toggle; typed twice, Create waits for a match; one eye button shows both.
- Split archive — Don’t split, 15 MB (for email), 100 MB, 1 GB, 4 GB (for USB drives). Website only.
- Cancel / Create.

**Edition:** Both; App Store differs: built-in macOS tools, a password only for ZIP (not 7Z), no splitting; asks for folder access the first time.

**Test:**
1. (Website) Right-click a test folder › Create Archive… → the dialog shows Name, Format, Password, Split archive. Choose ZIP with no password → Create makes a .zip next to the folder.
2. Turn on Password and type two different passwords → Create stays disabled until they match.
3. (App Store) The dialog has no Split archive row; with 7Z the Password switch is disabled.

### Archive preview

**Does:** Shows what is inside an archive in Quick Look (Space) without unpacking.

**How it works:** Sandboxed Quick Look extension `Extensions/Preview/ArchivePage.swift`, `ArchiveListing.swift`, `ZipNames.swift`; reads headers with libarchive, stops at 5,000 items or 1.5 s. Notes such as “Protected with a password”, “Part of a multi-part archive”, “Damaged. Showing what could be read.”, “Only the first items are shown.” and “Contains a program…”. ARJ and WIM are not supported.

**Nuances:** Check with Space in Finder, not `qlmanage -p` (it crashes for extension previews). A preview of a RAR with encrypted headers is unverified.

**Edition:** Both; App Store differs: needs the extension enabled in System Settings.

**Test:**
1. Select a ZIP and 7Z in Finder and press Space → a list of files and sizes. A password-protected one shows “Protected with a password”.

### Enter opens files in Finder

**Does:** Makes Return and Enter open the selected files, and F2 (fn F2 on a laptop) rename the selected file, like Windows Explorer.

**How it works:** Accessibility event tap (`Sources/pika-tools/Tools/Windows/FinderKeysTool.swift:399`), keys ↩, ⌤ and F2; while you type a name or search, the keys act as usual.

**Edition:** Website only (App Store: cut — without Accessibility it cannot tell renaming a file from browsing, because a click or a menu can start a rename).

**Test:**
1. (Website) Turn it on. Select a test file in Finder and press Return → it opens; press F2 → the name becomes editable. While renaming, press Return → it only confirms the name and does not open the file.

### Cut files in Finder

**Does:** ⌘X cuts files and ⌘V in another folder moves them.

**How it works:** Accessibility event tap (`FinderKeysTool.swift:419`). ⌘X becomes ⌘C so Finder copies the files; ⌘V in a Finder window becomes Finder’s own ⌥⌘V (Move Item Here) while cut files wait; the app only checks whether the clipboard holds files, never reads it. ⌘C cancels. When the copied thing is text (for example a name being edited) it sends ⌘X again. Shortcut text from `SystemShortcuts.finderCutText`.

**Nuances:** The App Store build cannot tell rename mode (`FinderKeysTool.swift:147`, `isBrowsing` is always true), so with cut files waiting ⌘V in a name field sends ⌥⌘V; press ⌘C first to cancel. Before 1.49.1 the App Store build only copied. The keys it sends are tagged (`Sources/pika-tools/Common/EventTag.swift`), so another copy of pikapik does not turn them again.

**Edition:** Both; App Store differs: no text-focus check.

**Test:**
1. Select files in a test folder, press ⌘X, open another folder, press ⌘V → the files move (they leave the first folder).
2. Cut, then press ⌘C on something else, then ⌘V → pastes normally.
3. (App Store) Rename a file after cutting → press ⌘C first, then ⌘V pastes the text.

### Delete removes files in Finder

**Does:** Makes ⌫ and ⌦ (fn ⌫ on a laptop) move the selected files to the Trash, like ⌘⌫. While you type a name or search, they erase letters as usual.

**How it works:** Accessibility event tap (`FinderKeysTool.swift:438`).

**Edition:** Website only (App Store: cut).

**Test:**
1. (Website) Turn it on, select a test file in Finder and press ⌫ → it goes to the Trash. Put it back from the Trash. Start renaming the file and press ⌫ → it erases a letter and nothing is trashed.

### Hide desktop icons

**Does:** Clears the desktop of files and folders before a call or a screen recording, and brings them back to the same places.

**How it works:** Website: `StandardHideDesktopIcons` in `com.apple.WindowManager` (`Sources/pika-tools/Tools/Windows/DesktopTools.swift:139`); no Finder restart; the switch always follows System Settings › Desktop & Dock › Show items › On Desktop; works with Stage Manager. App Store: an animated guide (`SettingsGuide`: Show items › On Desktop turned off) above an Open button to System Settings › Desktop & Dock (`DesktopIconsLink`, `DesktopTools.swift:170`, guide at :182).

**Edition:** Both; App Store differs: guide and Open button to System Settings instead of the switch.

**Test:**
1. (Website) Write down `defaults read com.apple.WindowManager StandardHideDesktopIcons`. Turn on Hide desktop icons → the icons leave the desktop without Finder restarting, the files stay in the Desktop folder, and System Settings › Desktop & Dock › Show items › On Desktop turns off. Turn it off → the icons come back to the same places.
2. Change On Desktop in System Settings and open the menu → the switch follows. Repeat with Stage Manager on.
3. (App Store) Settings › Finder › Hide desktop icons shows the animation (Show items › On Desktop off) and Open → System Settings opens on Desktop & Dock. In the menu the same row closes the menu and opens the same page (no animation there).

### Show hidden files

**Does:** Shows the files and folders macOS hides, dimmed, in Finder and on the desktop.

**How it works:** Website: writes `AppleShowAllFiles` in `com.apple.finder` and restarts Finder; Finder’s windows and tabs come back (`DesktopTools.swift:157`, `HiddenFilesTool` :63-168). Waits for copying (“Waiting for Finder to finish copying”) so a copy is never interrupted. App Store: no switch, only a hint (`HiddenFilesHint`, `DesktopTools.swift:230-237`) with the keys ⇧⌘. : “Press these keys in Finder, and again to hide them”.

**Edition:** Both; App Store differs: a hint with the keys instead of the switch.

**Test:**
1. (Website) Write down `defaults read com.apple.finder AppleShowAllFiles`. Turn on Show hidden files → Finder restarts for a moment, its windows and tabs come back, hidden files and folders appear dimmed in Finder and on the desktop, the same as ⇧⌘. ; turning it off restarts Finder the same way and hides them again. Restore Defaults on the Finder page leaves both as they are.
2. Start copying a large folder (several GB) in Finder, then turn Show hidden files on or off → the row says “Waiting for Finder to finish copying”, the copy is not interrupted, and Finder restarts only after the copy is done. Turning the switch back before the copy ends leaves Finder alone.
3. (App Store) Settings › Finder shows a Show hidden files row with the ⇧⌘. keys and no switch; typing “hidden” in the Settings search finds it.

### Restart Finder

**Does:** Restarts Finder when a change needs it.

**How it works:** `FinderRestartBar` (`Sources/pika-tools/Tools/Windows/FinderExtension.swift:228`) at the bottom of the Finder tab; also in the menu bar panel (help: “Restart Finder once to bring back the right-click items”). The App Store `FinderRestart` is a stub (`FinderExtension.swift:164`).

**Edition:** Both in code; effectively Website only (App Store: the restart does nothing there).

**Test:**
1. (Website) Turn an extension switch on or off → the bar appears; press Restart Finder → Finder relaunches and the menu items match.

## Animations

*Website: full page. App Store: a page of rows with an animated guide and an Open button to System Settings (`AnimationLinksPage`, `SettingsWindow.swift:1036-1075`; the guides are `SettingsGuide` in `Sources/pika-tools/Common/SettingsGuide.swift`, their labels come from your Mac, in its language, and with Reduce Motion on each is one still frame with the click marked).*

### Animation speed

**Does:** One slider that sets every effect below at once: As in macOS, Faster, Instant.

**How it works:** `PaceSlider` (`Sources/pika-tools/Tools/Animations/AnimationsTool.swift:325`, `AnimationSetting.swift`); “Sets all the effects below at once.”

**Nuances:** Changes bar: “Works in apps after you reopen them”; “Finder picks up the changes after a restart” with a Restart Finder button. The Dock restarts through `/usr/bin/killall`. `--uninstall` puts everything back.

**Edition:** Website only (App Store: cut — cannot change these settings).

**Test:**
1. (Website) Move the slider to Instant → opening and minimizing windows, the Dock and Quick Look become instant after the apps are reopened. Choose As in macOS → everything returns.

### Hide the Dock automatically

**Does:** Hides the Dock until the pointer touches the edge.

**How it works:** Website: `autohide` in `com.apple.dock` (`AnimationsTool.swift:251`). App Store: an animated guide (“Automatically hide and show the Dock” turned on) above an Open row to System Settings › Desktop & Dock (`SettingsWindow.swift:1061-1066`).

**Edition:** Both; App Store differs: guide and Open button instead of the switch.

**Test:**
1. (Website) Turn it on → the Dock hides; off → it stays.
2. (App Store) The row shows the animation of the click, then press Open → System Settings › Desktop & Dock opens.

### Fine-tuning

**Does:** Fine controls for each effect.

**How it works:** Section at `AnimationsTool.swift:255`, `AnimationSetting.swift`, in the defaults named below.

**Options:**
- Delay before the Dock appears — slider, `autohide-delay` in `com.apple.dock` (`AnimationsTool.swift:200`).
- How fast the Dock slides out — slider, `autohide-time-modifier` (`:201`).
- Opening windows — toggle, `NSAutomaticWindowAnimationsEnabled` in the global domain (`:204`).
- Save dialogs and resizing — slider, `NSWindowResizeTime` (`:205`).
- Quick Look — slider, `QLPanelAnimationDuration` (`:206`).
- Columns in Finder — slider, `NSBrowserColumnAnimationSpeedMultiplier` (`:207`).
- Finder animations — toggle, `DisableAllAnimations` in `com.apple.finder` (`:208`).
- Minimize effect and Bouncing icons have their own entries below.

**Edition:** Website only (App Store: cut — cannot write these settings).

**Test:**
1. (Website) Drag each slider and toggle in turn → the matching effect changes after the app is reopened (Dock, windows, save dialogs, Quick Look, Finder columns, Finder). Restore Defaults puts them back.

### Minimize effect

**Does:** Chooses Genie, Scale or Suck for minimizing windows.

**How it works:** Website: `mineffect` in `com.apple.dock` (`AnimationsTool.swift:416`). App Store: an animated guide (the effect changes from Genie Effect to Scale Effect) above an Open row (“Choose “Scale Effect” for a quicker animation”, `SettingsWindow.swift:1045-1050`).

**Edition:** Both; App Store differs: guide and Open button instead of the picker.

**Test:**
1. (Website) Pick Scale, minimize a window → it uses the scale effect.
2. (App Store) The row shows the animation (Genie Effect to Scale Effect), then press Open → System Settings › Desktop & Dock.

### Bouncing icons

**Does:** Turns off the Dock icons’ bounce when an app opens.

**How it works:** Website: `no-bouncing` in `com.apple.dock` (`AnimationsTool.swift:203`). App Store: an animated guide (“Animate opening applications” turned off) above an Open row (`SettingsWindow.swift:1053-1058`).

**Edition:** Both; App Store differs: guide and Open button instead of the switch.

**Test:**
1. (Website) Turn it on, open a stub app → its Dock icon does not bounce.
2. (App Store) The row shows the animation (the switch turns off), then press Open → System Settings › Desktop & Dock.

### Even calmer: Reduce Motion in Accessibility

**Does:** Opens System Settings › Accessibility › Motion so you can turn on Reduce Motion, and shows where to click.

**How it works:** A row with an Open button (`SystemSettingsRow`, `AnimationsTool.swift:274`; App Store `SettingsWindow.swift:1068`) and the animated guide `SettingsGuide.reduceMotion` (Accessibility › Motion › “Reduce motion” on), in both editions. The link `SettingsGuide.reduceMotionLink` opens the Motion page (anchor `AX_REDUCE_MOTION`) and falls back to Display when this macOS has no such anchor.

**Edition:** Both.

**Test:**
1. The row shows the animation of the clicks. Press Open → System Settings opens on Accessibility › Motion (on a macOS without the Motion anchor: Display).
2. With Reduce Motion on → the animation is one still frame with the click marked.

## Uninstaller

*Hidden in the App Store build.*

### Offer to clean up when an app goes to the Trash

**Does:** When you drag an app to the Trash in Finder, offers to remove its leftovers too. Nothing is removed until you choose.

**How it works:** `Sources/pika-tools/Tools/Uninstaller/TrashWatchTool.swift:48` watches `~/.Trash`; needs Full Disk Access.

**Edition:** Website only (App Store: cut).

**Test:**
1. (Website, released app with Full Disk Access) Turn it on and drag a stub app to the Trash in Finder → Settings opens on this page with that app and the files it left behind; nothing is removed until you choose.

### Installed apps

**Does:** Lists the installed apps; click one to preview what removing it would take.

**How it works:** List in `UninstallerPage.swift`; context menu Show in Finder; empty state “No apps found”; you can also drop a test app on the picture.

**Options:**
- Search apps — search field that filters the list by name (`Sources/pika-tools/Tools/Uninstaller/UninstallerPage.swift:70`); “No apps found” when nothing matches.
- Sort by — picker: Name, Size or Last used (`UninstallerPage.swift:76`).

**Edition:** Website only.

**Test:**
1. (Website) Right-click a stub › Show in Finder → it opens in Finder. Drop a small stub app on the picture → its preview opens.
2. (Website) Type part of a stub app’s name → only matching apps remain; “No apps found” when nothing matches.
3. (Website) Switch Name, Size, Last used → the order changes each time.

### Move to Trash

**Does:** Moves an app and its leftovers to the Trash after a preview where you tick what goes.

**How it works:** Preview sheet (`UninstallerPreview.swift`, `UninstallerSections.swift`) with checkbox groups; removal through `trashItem` (`AppRemover.swift:392`); items that need an administrator ask for the password once (“Needs your password” marker). An app that is running is asked to quit first (Quit / Force Quit alert). The result lists “These stayed where they are” with Put Back and Done.

**Options:**
- Groups: The app, Saved data, Private storage, Temporary files, Settings, Background helpers, Add-ons, Logs, Installer records.
- Select All / Deselect All, Quick Look, Copy Path, Cancel.

**Edition:** Website only.

**Test:**
1. (Website) In Settings › Uninstaller drop a small test app on the picture and click Move to Trash → the app and its files are in the Trash, and the removal is listed under Recently removed.
2. An app that is open is asked to quit first; an item that needs an administrator asks for the password once.

### Reset App

**Does:** Clears an app’s saved data and settings without removing the app.

**How it works:** Button in the preview sheet (`UninstallerPreview.swift`), same removal path as Move to Trash for the data groups only.

**Edition:** Website only.

**Test:**
1. (Website) With a stub that has saved data, open its preview › Reset App → the data goes to the Trash, the app stays.

### In the Trash

**Does:** Lists apps that are in the Trash with their leftovers.

**How it works:** List section in `UninstallerPage.swift`.

**Edition:** Website only.

**Test:**
1. (Website) Put a stub app in the Trash → it shows under In the Trash.

### Recently removed

**Does:** Lists what pikapik removed, with Put Back for each.

**How it works:** List section; **Put Back** returns the app and its files to where they were.

**Edition:** Website only.

**Test:**
1. (Website) After removing a stub, press Put Back → everything returns to its place.

### Leftovers of removed apps

**Does:** Lists files left behind by apps already deleted.

**How it works:** List section in `UninstallerPage.swift`.

**Edition:** Website only.

**Test:**
1. (Website) Delete a stub by hand, reopen the page → its leftovers show; preview and remove them with Move to Trash.

## Background Tasks

*Shows what starts in the background and which app added it: launch agents and daemons in /Library and the user’s Library, and helpers inside apps. Website can switch them off and on; App Store is view-only.*

### Open at Login

**Does:** Lists the login items (apps that start when you log in).

**How it works:** `LoginItemsList` (`Sources/pika-tools/Tools/Background/BackgroundTasks.swift:257,280`), group at `BackgroundPage.swift:119`.

**Edition:** Website only (App Store: the group is not shown).

**Test:**
1. (Website) Open Settings › Background Tasks → the Open at Login group lists your login items, including pikapik if Open at Login is on.

### In the Background

**Does:** Lists launch agents and daemons that run or are loaded now.

**How it works:** Reads property lists in `/Library` and `~/Library`, `SMAppService.statusForLegacyPlist`, and runs `/bin/launchctl print` for the gui/<uid>, user/<uid> and system domains, read-only (`BackgroundPage.swift:121`, `BackgroundTasks.swift`). Each row shows the app, a green dot when running and the file path; clicking the path shows the file in Finder. Empty state: “Nothing runs in the background”.

**Options:**
- Turn Off / Turn Back On — button on each launch agent or daemon (Website): switches the task off and on again without deleting it, with `launchctl disable|enable` plus bootout and bootstrap (`BackgroundPage.swift:20,70,241-242`). Nothing on disk is deleted. App Store: view only, no button.
- Turn Off… / Turn On… — button on login-item tasks, shown instead of the switch where pikapik cannot change a task (`BackgroundPage.swift:237-247`): it opens System Settings › Login Items so you can change the item yourself; nothing on disk changes. Website: Turn On… for an item that is off there; App Store: Turn Off… on running tasks, the only action there. When any such task is listed, an animated guide at the top (`SettingsGuide.loginItems`, `BackgroundPage.swift:115-117`, `BackgroundTasks.swift:86`) shows where to click: Login Items & Extensions, then the pikapik switch; its labels come from your Mac, in its language.
- Show in Finder — on every task in every group: clicking the file path, the Show in Finder context-menu item (`BackgroundPage.swift:201`) or the path’s help (`:195`) reveals the task’s file in Finder.

**Edition:** Both; App Store differs: view only, shorter header text, home-folder tasks only after Folders access.

**Test:**
1. Open Settings › Background Tasks → a list with apps, green dots for running tasks and file paths; clicking a path shows the file in Finder.
2. (Website) Make a test agent `~/Library/LaunchAgents/org.example.background-test.plist` that runs `/bin/sleep 3600` with RunAtLoad and load it with `launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/org.example.background-test.plist`. Open Settings › Background Tasks → it is listed with a green dot.
3. Click Turn Off → the row dims, `launchctl print-disabled gui/$(id -u)` shows it as disabled, the sleep process is gone and the file is still there. Click Turn Back On → it runs again.
4. Remove the test agent afterwards with `launchctl bootout gui/$(id -u)/org.example.background-test` and delete the file.
5. (App Store) Click Turn Off… on any task → System Settings opens on Login Items; nothing on disk changes.
6. Click Show in Finder on a task → Finder opens with the file selected.

### Left by deleted apps

**Does:** Groups tasks whose app is gone, so you can find them.

**How it works:** Group in `BackgroundPage.swift:122`.

**Edition:** Both.

**Test:**
1. Open the group → tasks of apps that no longer exist are listed.

### Tasks in your home folder

**Does:** Lets the App Store build see the tasks in `~/Library/LaunchAgents` once you allow it.

**How it works:** Security-scoped home-folder bookmark (`FolderAccess`, `BackgroundPage.swift:34,46,93`) with a Folders permission bar. The page says “To see the tasks in your home folder, allow access to it.”; Allow shows the Open panel at the home folder with the button Allow Access. Turn Off on the Folders row of Permissions forgets the access.

**Edition:** App Store only.

**Test:**
1. (App Store) Open Settings › Background Tasks before giving access → a grey “Tasks in your home folder” row and a bar that asks for access. Click Allow, choose your home folder in the Open window → tasks from ~/Library/LaunchAgents appear with their app, a green dot when running and the file path.

## Games

### Game Mode

**Does:** While a game from your list is in front, your Mac’s shortcuts, swipes and keys do not pull you out of it.

**How it works:** `Sources/pika-tools/Tools/Games/GameModeTool.swift:854`. An Accessibility `.defaultTap` event tap (`gameModeCallback` :613) swallows or passes keys by the rules below, reads the full system shortcut catalogue of this Mac (`SystemShortcutCatalog.swift`, about 235 shortcuts, including your own assignments) and pauses actions that would interrupt the game. The footer says “To leave a game, press …” (the quit and close keys from Protect quitting and closing); ⌥⌘Esc always works. Screen-lock handling differs in the App Store build (`GameModeTool.swift:299,391-401`). Shortcuts with Control or without Command pass through as game input.

**Options:**
- More game settings — disclosure group (`GameModeTool.swift:729`) that opens the detailed game settings: System keyboard shortcuts, Other apps watching keys and Game safeguards (see their entries).

**Nuances:** While a game is in front the menu bar status shows Game Mode. After you quit the game or lock the screen the shortcuts work again at once; after the Mac wakes or you switch back to your user account Game Mode turns on again by itself (1.49.1). The sandbox hides `com.apple.symbolichotkeys`, so the App Store build reads the shortcuts with the public `CopySymbolicHotKeys`: on macOS 27 its records are matched to IDs by position, on other versions through Apple’s `DefaultShortcutsTable.xml`, which misses shortcuts you changed (`GameRules.swift:230`). It swallows ⌘ shortcuts in the tap instead of private calls (`GameRules.swift:284`, `GameModeTool.swift:668`); mouse-button shortcuts aren’t listed there, because its tap doesn’t see extra mouse buttons, and it shows only the rules whose shortcuts it can read (`GameModeTool.swift:829`); Dock corners and hiding are untouched there, and the pointer fence keeps 16 points away from the screen corners instead (1.49.1). With two copies of pikapik running, ⇧⌘Q and ⇧⌘W in a game used to do nothing; fixed in 1.49.1. Swipe and hot-corner pausing was only covered by unit tests, never by real gestures.

**Edition:** Both; App Store differs: fewer rules (those it can read), no Dock or hot-corner calming.

**Test:**
1. Turn on Game Mode, press Add a Game… and add a stub game (or Chess), open it → ⌘Space and ⌘` are swallowed while playing; in the App Store build the rules list shows only shortcuts that exist on this Mac.
2. Quit the game, or lock the screen mid-game → shortcuts work again at once; (App Store) Dock corners and hiding are untouched.
3. With Protect quitting and closing on, in the game press ⇧⌘Q → the game quits; ⇧⌘W → its window closes. Press ⌥⌘Esc → Force Quit opens.
4. (two copies installed) Quit one copy and repeat step 3 → it works; with both running it works too since 1.49.1.
5. Open Settings › Games › More game settings → the three parts show.

### Your games

**Does:** The list of games Game Mode protects. pikapik suggests games it finds.

**How it works:** `Sources/pika-tools/Tools/Games/GameList.swift:16`; detection `looksLikeGame`. “Open your game, and it shows up here”.

**Options:**
- Add a Game… — opens a shelf of open apps and Dock apps; you can also drag an app from Finder; Done closes it (`GameList.swift:13`).
- Ignore — a quiet button that dismisses a suggestion.
- Add — accepts a suggestion.

**Edition:** Both.

**Test:**
1. Open a stub app that looks like a game → a suggestion shows; Add puts it in Your games; Ignore removes it from suggestions.
2. Press Add a Game…, pick an open app, then press Done → it is in the list. Drag an app from Finder onto the list → added.

### Show FPS

**Does:** Shows a small frame-rate pill in a corner of the game window.

**How it works:** `Sources/pika-tools/Tools/Games/FrameRateArt.swift:27`, `FrameRateMeter.swift`, `FrameRate.swift`. Website on macOS 27: `/usr/bin/metalperftrace listen --json --pid PID` (Metal games only; no permission). After 3 seconds of silence, and on macOS 14–26 and in the App Store build: a ScreenCaptureKit display stream at one-eighth size, counting changed frames; needs Screen Recording and shows the system recording indicator. No picture is stored. A game drawing 30 frames a second shows about 30, a frozen picture shows a dimmed 0, and no number goes above the screen’s refresh rate.

**Options:**
- Corner for FPS — four corner buttons in the picture; hovering a corner shows its name (`FrameRateArt.swift:26`).
- Allow — under “Needs a permission. Click to allow it.”: asks Screen Recording and opens Permissions on the row (`FrameRateArt.swift:39`).

**Nuances:** pikapik never prompts during a game. On macOS 27 the Screen Recording row and the line appear only after a game the system could not count (an OpenGL one); they stay on later launches until allowed. If macOS asks to reopen pikapik after you allow it, do that. Never live-checked: the real Screen Recording grant flow, the relaunch after granting, and the handoff from trace to capture with the permission granted.

**Edition:** Both; App Store differs: always the screen-recording counter.

**Test:**
1. Turn on Show FPS without Screen Recording on macOS 26 or in the App Store build → no prompt yet; the line “Needs a permission. Click to allow it.” shows under the switch and Permissions lists Screen Recording with “Needed to count frames”. Click Allow in the line → the Screen Recording prompt appears and Permissions opens on the row. Both go away once allowed and update when you come back from System Settings. Deny it → the pill shows a dimmed “—”, with no crash and no further prompts.
2. (macOS 27, Website) Expected: no prompt and no Screen Recording row while games are counted by the system. Play a game the system cannot count (an OpenGL one) → after about three seconds the line and the row “Needed for some games” appear, still without a prompt during the game, and both stay on later launches until allowed.
3. Start a game with Show FPS on → a small pill with a dash appears in the chosen corner of the game window (top corners sit below the title bar), then shows the frame rate. From 100 on the pill gets one digit wider and stays in its corner, with the small FPS on the same baseline. Quit the game → the pill fades out at once.
4. Click each corner of the picture, then turn the switch off and on while the game runs → the pill in the picture and the one over the game move to the corner at once; off fades the pill out, on brings it back without restarting the game. With Reduce Motion on the pill appears and goes without fading.
5. Repeat with a native full-screen game and a game on a second display → the pill shows in the chosen corner of that display.

### System keyboard shortcuts

**Does:** Lists every macOS shortcut with a choice of what happens to it while you play.

**How it works:** `SystemShortcutList.swift`, about 235 shortcuts from `SystemShortcutCatalog` read from this Mac (`AppleSymbolicHotKeys`, `NSUserKeyEquivalents`; in the App Store build `CopySymbolicHotKeys`, only ⌘ shortcuts), each with a “While playing” picker.

**Options:**
- While playing: Follow Game Mode rules — the safeguards decide.
- Disable in games — the shortcut does nothing in a game.
- Switch language on every press — only for the input-language shortcut.
- Allow in games — the shortcut works as usual.

**Nuances:** Settings search finds each shortcut. The shortcuts are read again when pikapik becomes active. A shortcut without keys shows “No key assigned”: clicking it opens System Settings › Keyboard › Keyboard Shortcuts… on its section; when pikapik cannot click there itself, a popover shows the animated guide (Keyboard Shortcuts… → the section) (`ShortcutAssignmentLink`, `SystemShortcutList.swift:235`; `SystemShortcuts.open`, `ShortcutField.swift:98`).

**Edition:** Both.

**Test:**
1. Search Settings for “Mission Control” → the shortcut row opens. Set it to Allow in games, start a game, press it → Mission Control opens; set Disable in games → nothing happens.
2. Click “No key assigned” on a shortcut without keys → System Settings opens on Keyboard Shortcuts… at its section; without Accessibility a popover over the link shows the animation of those clicks.

### Other apps watching keys

**Does:** Shows other apps that listen to your keyboard, so you know what can interfere in a game.

**How it works:** `KeyboardListeners.swift`; each app is marked “Can change keys” or “Only listens”.

**Edition:** Both.

**Test:**
1. Open the list → apps with event taps appear with their marking (a stub or another tool that taps keys shows up).

### Game safeguards

**Does:** Switches the individual protections of Game Mode on or off, each with a small picture.

**How it works:** `GameModeTool.swift:739`, `GameRules.swift`, art in `GameRuleArt.swift`. In the App Store build rules whose hotkeys cannot be read are filtered out (`GameModeTool.swift:804`).

**Options:**
- The game doesn’t close — ⌘Q does not quit the game (Closing the game).
- The game window doesn’t close — ⌘W does not close the window.
- Apps and windows don’t switch — ⌘Tab and ⌘` are held back.
- The game doesn’t hide — ⌘H and friends are held back.
- Search doesn’t pop up — Spotlight.
- Siri and voice typing don’t start.
- The app grid doesn’t open — Launchpad.
- The view of all windows doesn’t open — Mission Control.
- The view of the game’s windows doesn’t open — App Exposé.
- The game doesn’t slide off the screen — Show Desktop.
- Desktops don’t switch — moving between Spaces.
- Desktops don’t switch by number.
- Emoji don’t open.
- The dictionary doesn’t pop up — Look Up.
- The keyboard stays in the game — no input-source change.
- 🌐 shortcuts are paused.
- ⌃-click works as a plain click — no right-click while playing.
- Gestures don’t leave the game — see its own entry.
- The pointer stays in the game — see its own entry.
- The screen stays on — the display neither dims nor sleeps while you play (IOKit power assertion).

**Nuances:** App Store: Search, Siri, app grid, all-windows view, the game’s windows view, slide off the screen, Desktops (both), Emoji, dictionary, keyboard, 🌐 and Gestures show only when their hotkeys can be read; the pointer rule is limited there.

**Edition:** Both; App Store differs: only readable rules are listed.

**Test:**
1. In a stub game press each protected shortcut with its rule on → nothing happens; turn the rule off → the system reaction returns.
2. Turn on The screen stays on while a game is in front → `pmset -g assertions` shows a display assertion from pikapik; it ends when you leave the game.
3. ⌃-click in the game with the rule on → it acts as a plain click.

### The pointer stays in the game

**Does:** Keeps the pointer inside the game’s display, so a fast mouse does not slip to the other screen.

**How it works:** Now: `GameRules.fence` pushes the pointer back when it crosses the edge; calms Dock and hot corners (`DockEdges`; a stub in the App Store build, where `GameRules.fenceCorners` keeps the pointer 16 points (x + y) from every corner pixel so a push can't reach it, `GameModeTool.swift:454`), and entering or leaving a game restarts the Dock once. After PR #71: `CursorLock` asks the WindowServer to confine the pointer through `SLSSetCursorRegionLock`, the same mechanism the Dock and screencapture use; nothing moves the pointer any more; hot corners Game Mode keeps stay reachable; checked again every second and released when the game is left or pikapik quits.

**Nuances:** The App Store version leaves the option out after the change because it relies on a private macOS call. Needs two displays to test.

**Edition:** Both now; after PR #71 Website only.

**Status:** Pending — PR #71: the pointer is confined by macOS itself instead of being moved back; the option leaves the App Store build. Not merged until the owner’s hand check (a fast mouse at every edge, the pointer free after leaving the game, and free right after pikapik is killed).

**Test:**
1. (two displays) Turn it on, play a stub game and push a fast mouse against every edge toward the other display → the pointer never crosses (before the change it briefly jumped over and back).
2. Leave the game → the pointer is free; kill pikapik during a game → the pointer is free at once.

### Gestures don’t leave the game

**Does:** Drops Dock gestures (Mission Control, Spaces and similar swipes) and mouse button shortcuts while a game is in front.

**How it works:** DockSwipe events (`CGEventType` 30, field 110 = 23; field 123 motion, 132 phase) are dropped at the “began” phase (`PointerShortcuts.swift`, `GameRules.dropsSwipe`). Hot corners: `DockEdges` zeroes only the paused corners. The motion codes came from event logging, not from Apple documents.

**Nuances:** Not covered: shake to locate the pointer, zoom with a modifier key and scrolling, clicking the wallpaper to show the desktop. Never verified by hand with real gestures. App Store: `PointerShortcuts.buttons` is empty (`PointerShortcuts.swift:42`) and hot-corner reading is Website only (`:145`).

**Edition:** Both; App Store differs: no mouse buttons and no hot-corner reading.

**Test:**
1. (trackpad) In a stub game do a three-finger swipe up (Mission Control) and a four-finger swipe sideways → nothing happens with the rule on; set a row to Allow in games → that swipe works.

## Pet

### Pet on the desktop

**Does:** A small pet walks along the bottom of the screen and reacts to you.

**How it works:** `Sources/pika-tools/Tools/Pet/PetTool.swift:151`, overlay window `PetStage`, physics `PetPhysics.swift`. No permission needed. Website reads Dock icon positions through Accessibility (`PetStage.swift:346`) and announces updates (`:673`); App Store uses a window-list check for full screen and the screen’s full width (`PetStage.swift:272,338`).

**Options:**
- Talks sometimes — speech bubbles (`PetTool.swift:160`).
- Follows your rhythm — reacts to typing (`:167`).
- Ball — a ball the pet plays with (`:174`).
- “To make it jump when you press Space, allow Input Monitoring” — note with a permission bar (`:183`); a listen-only tap checks only whether Space was pressed.

**Nuances:** The only tool on by default in the App Store build.

**Edition:** Both; App Store differs: does not find Dock icons, no update phrase.

**Test:**
1. Turn it on → the pet appears at the bottom; pick it up and throw it; push the ball; turn each sub-switch off and on → behavior follows.
2. Switch an app to full screen on each display → the pet hides on that display only and returns when full screen ends; works across Spaces and after sleep and wake.

### Wardrobe

**Does:** Things the pet can wear: 38 things in seven groups, six free; the rest unlock with awards.

**How it works:** `Sources/pika-tools/Tools/Pet/PetWardrobeView.swift`, `PetClothes.swift`; tiles, slot chips, “New” tags.

**Options:**
- Take Everything Off — clears the outfit (`PetWardrobeView.swift:346`).

**Edition:** Both.

**Test:**
1. Open Settings › Pet → Wardrobe shows 38 things in seven groups with six unlocked. Click an unlocked thing → the pet puts it on and takes it off again; Take Everything Off clears the outfit. Click a locked thing → its award opens and nothing is worn.

### Looks

**Does:** Ready-made outfits: 10 looks.

**How it works:** Look cards (`PetTool.swift:135`, `PetLooks`).

**Edition:** Both.

**Test:**
1. Click a look with missing pieces → nothing is worn; click a complete look → the pet wears it all.

### Awards

**Does:** Awards you earn by playing with the pet: 24 in the App Store build, 25 on the Website; they unlock clothes.

**How it works:** `PetAwardsView.swift`, `PetAwards.swift`. The Website adds an Open Source award, earned by opening the GitHub link in About; the App Store build drops it and gives the explorer award extra unlocks (`PetAwards.swift:3,23,100`). Plain totals of steps, pick-ups, throws and the like, the date of each award and the outfit are stored only in five preferences keys (pet-counts, pet-awards, pet-seen, pet-fresh, pet-outfit); never sent, never exported, never synced. Detail sheet: Done, “Earned on …”, Unlocks. The sidebar badge shows new awards.

**Options:**
- Erase Progress… — button in Awards (`PetAwardsView.swift:304`); after the alert “Erase Progress” it deletes all pet progress on this Mac and removes the five pet keys.

**Nuances:** Network access unlocks nothing. Restore Defaults keeps awards and outfit.

**Edition:** Both; App Store differs: no Open Source award.

**Test:**
1. Open Settings › Pet → Awards shows 24 awards (App Store; no “Open Source” award) or 25 (Website).
2. Earn an award (pick the pet up and throw it high 10 times) → the pet announces it, Pet in the sidebar shows a badge, the award and what it unlocks are marked “New” until you leave the page, and the unlocked things can be worn. Quit and relaunch → outfit, counts and awards are kept.
3. Export Settings and open the file → no pet-counts, pet-awards, pet-seen, pet-fresh or pet-outfit. Restore Defaults keeps the awards and the outfit.
4. (Website) Click the GitHub link in About → the “Open Source” award is earned; with iCloud sync on, a second Mac does not receive the awards or the outfit.
5. Press Erase Progress… and confirm → awards, unlocked things and counts are gone, only the six free things can be worn, and `defaults read <bundle id>` shows none of the five pet keys. Repeat the wardrobe and award steps with Wi-Fi off → same result, no error.

## Permissions

*pikapik asks for a permission only on this tab, or from a grey tool that leads here; never at launch and never during a game.*

### Permission rows (Allow and Turn Off)

**Does:** Shows each permission, whether it is granted, and one button: Allow or Turn Off.

**How it works:** `Sources/pika-tools/Common/Permissions.swift` (`PermissionsView` :404, `PermissionRow` :504, `PermissionBar` :385). The header reads “All set” when everything is on, “Both permissions are on” when the two main ones are on but a tool still lacks another, and otherwise “pikapik needs two permissions” (Website) or “Permissions for some tools” (App Store). pikapik rechecks every 1.5 seconds. A tool that needs a missing permission is half-grey and does nothing; clicking it opens this tab on the row (Accessibility, Input Monitoring and Screen Recording also show the macOS prompt in the App Store build). A bar on each tool tab shows when its tools need a missing permission, and names that permission and what it is for. While Accessibility (on macOS 27: Device Control and Data Access), Input Monitoring or Screen & System Audio Recording is shown and not granted, an animated guide at the top of the first section walks through System Settings: Privacy & Security, that list, then turn on pikapik (`Permissions.swift:65-71,435-437`, `Sources/pika-tools/Common/SettingsGuide.swift`; both editions).

**Options:**
- Allow — asks, or opens System Settings with an arrow icon when the permission can only be granted there.
- Turn Off — Website: an alert “pikapik will restart, and the tools that need it will turn grey until you allow it again.”, then resets the permission with `tccutil` (`Permissions.swift:263-264,289,548`). App Store: opens the matching System Settings list, because the app cannot revoke permissions itself; the footer says “macOS lets you turn these off only in System Settings…”.

**Edition:** Both; App Store differs: Turn Off opens System Settings.

**Test:**
1. Launch after `tccutil reset All <bundle id>` → no system prompt at launch, in both editions; the first launch opens General Settings, later launches open no window, and the tools that need a permission are grey. The menu bar icon appears. Already-granted permissions stay on.
2. Turn on any Keyboard, Mouse or Windows tool (for example Scroll by lines) → the Accessibility prompt, then Input Monitoring if needed. The status shows “Needs Access” until granted, then “Active”.
3. Revoke a permission in System Settings while the app runs → status returns to “Needs Access” without a crash; granting again restores the tool without relaunch.
4. Click a grey tool → this tab opens on the row to allow.
5. (App Store) Turn Off on Accessibility and Input Monitoring → the right System Settings list opens. (Website) Turn Off → the restart alert.
6. A missing permission shows the animated guide; it points at the right list and the pikapik switch, and goes away once every permission in it is granted.
7. (App Store) Settings has no Fans, Animations (full page), Uninstaller, Key repeat, Pointer, Updates, iCloud sync or “Stay in the background after Quit” rows.

### Accessibility

**Does:** The permission for tools that read or change keys, clicks and windows.

**How it works:** Row `case accessibility`; titled “Device Control and Data Access” on macOS 27 or later. Used by Brightness keys, the Mouse tools, Protect quitting and closing, Cut files in Finder, Retype words you typed in the wrong language, Game Mode and more.

**Edition:** Both.

**Test:**
1. Allow it → the row gets a green check and the tools turn active. Turn Off → see Permission rows.

### Input Monitoring

**Does:** The permission to see key presses without changing them.

**How it works:** Used by Switch language, Quit when the last window closes and the pet’s Space jump.

**Edition:** Both.

**Test:**
1. Turn on Switch language → it asks; after Allow the row shows a green check.

### Screen Recording

**Does:** Lets Show FPS count frames.

**How it works:** Section “For some features”; shown only when Show FPS is on and the permission is missing (“Needed to count frames”).

**Edition:** Both.

**Test:**
1. Turn on Show FPS without it → the row appears; Allow → the system prompt.

### System Audio Recording

**Does:** Lets App Volume change one app’s volume. Nothing is recorded or saved.

**How it works:** Row on macOS 14.2 or later, shown when App Volume is enabled or asked; help text “pikapik passes each app’s sound through itself… Nothing is recorded or saved.” The app plays a brief inaudible test signal and taps only its own process to learn whether the permission is given.

**Edition:** Both.

**Test:**
1. Turn on App Volume → the row appears; Allow shows the prompt (after a refusal it opens System Settings › Privacy & Security).

### Fan control

**Does:** Installs or removes the fan helper.

**How it works:** `Permissions.swift:36,175,206`; the administrator password installs a helper in `/Library/PrivilegedHelperTools` and a LaunchDaemon. Shown only when the Mac has fans.

**Edition:** Website only (App Store: cut — no helper).

**Test:**
1. (Website, Mac with fans) Allow → one administrator prompt; Turn Off removes the helper.

### Finder Extensions

**Does:** Shows whether New File, Smaller Copy, Convert (and Archives) are enabled in System Settings.

**How it works:** Row shown when an extension is active or waiting. Allow opens System Settings › Login Items & Extensions › Finder; Turn Off opens the same list (App Store). While the Finder permission is missing, an animated guide above the row shows Login Items & Extensions → pikapik’s info button → the switch on (`SettingsGuide.finderExtensions`, `Permissions.swift:458`).

**Edition:** Both.

**Test:**
1. See Finder › New File in Finder, step 1.

### Folders

**Does:** Lets the App Store build save new files next to yours and see background tasks.

**How it works:** `FolderAccess` (`Permissions.swift:11,43,117,181,217,250`), a security-scoped bookmark. Allow shows the home folder panel; Turn Off forgets the saved folders and the next file action asks again.

**Edition:** App Store only.

**Test:**
1. (App Store) Press Allow → an Open panel on the home folder with Allow Access. Press Turn Off → the access is forgotten; the next New File asks again.

### iCloud Drive

**Does:** Lets Sync settings with iCloud use iCloud Drive.

**How it works:** Row shown when sync is on; resets Ubiquity and FileProviderDomain on Turn Off.

**Edition:** Website only.

**Test:**
1. (Website, signed build) Turn sync on → the row appears.

### Full Disk Access

**Does:** Lets pikapik find permissions left by deleted apps and watch the Trash.

**How it works:** Resets SystemPolicyAllFiles on Turn Off.

**Edition:** Website only.

**Test:**
1. (Website, released app) The row appears when needed; after Allow the Left by deleted apps list fills.

### Left by deleted apps

**Does:** Website: lists permissions still held by apps you deleted, and removes them. App Store: the section “Other apps’ permissions” shows, for each Privacy & Security list, how many apps in /Applications can ask for it, and opens the list.

**How it works:** Website: `LeftoverPermissionsSection` (`Sources/pika-tools/Common/LeftoverPermissions.swift`) scans the system TCC database (needs Full Disk Access) and removes entries of apps that no longer exist (no copy outside the Trash, no helper, launch agent or system extension). App Store: one row for each list (`Permissions.privacyLists`, `Permissions.swift:340,468-475`, `PrivacyListRow` in `Sources/pika-tools/Common/PrivacyAsksView.swift`) with an Open button, because the app cannot remove anything. For Camera, Microphone, Automation, Files and Folders and Bluetooth the row reads “Can ask for it: N” or “No app can ask for it”, with up to four app icons and “+N”; clicking the icons opens a list of the apps (`PrivacyAsks.scan`, `Sources/pika-tools/Common/PrivacyAsks.swift`). The count comes from the usage-description keys (`NSCameraUsageDescription` and similar) in each app’s Info.plist in /Applications, so it means “can ask”, never “has the permission”. Accessibility, Screen Recording, Input Monitoring, Full Disk Access, App Management and Developer Tools have no such key: their rows say “Only System Settings shows who has it”. The footer says “Deleted apps keep their permissions: select one in the list and press − or turn it off.”

**Options:**
- Open — opens the matching Privacy & Security list in System Settings (`Permissions.openSettings`).
- App icons — App Store: click to see the apps that can ask for that permission.

**Edition:** Both; App Store differs: counts, icons and Open buttons only (nothing can be removed).

**Test:**
1. (Website, released app, a deleted stub app that held a permission) The list shows it; remove the entry → it is gone.
2. (App Store) Each Open button opens the matching Privacy & Security list.
3. (App Store) Camera, Microphone, Automation, Files and Folders and Bluetooth show “Can ask for it: N” or “No app can ask for it”; the numbers match the apps in /Applications that ask for that permission in their Info.plist (`plutil -p /Applications/<app>/Contents/Info.plist | grep UsageDescription`).
4. (App Store) Click the icon stack → a list of those apps opens; its note says only System Settings shows who has the permission.
5. (App Store) Accessibility, Screen Recording, Input Monitoring, Full Disk Access, App Management and Developer Tools say “Only System Settings shows who has it” and show no icons.
6. (App Store) Install or delete a stub app that asks for the Camera, then reopen the tab or switch back to pikapik → the camera count changes.

## About

### pikapik

**Does:** Header with the app icon and “Small tools that make your Mac nicer to use”.

**How it works:** `SettingsWindow.swift:1108` (`AboutView` :1078-1222).

**Options:**
- GitHub — link to the source code (`SettingsWindow.swift:1138`); bundled `github.svg`; the URL differs per edition (App Store opens the App Store source folder). Website: opening it also earns the Open Source pet award.
- What’s New — opens the localized `docs/whats-new` page in the app’s language (`SettingsWindow.swift:1139`).
- License (MIT) — link to the LICENSE file on GitHub (`SettingsWindow.swift:1141`).

**Edition:** Both.

**Test:**
1. Open Settings › About → the icon, the name and the line show.
2. Click GitHub → the repository opens.
3. Click What’s New → the page opens in the app’s language.
4. Click License (MIT) → the LICENSE file opens on GitHub.

### Check for updates automatically

**Does:** Lets pikapik look for new versions and install them itself.

**How it works:** In-app `Updater` (`Sources/pika-tools/Common/Updater.swift`, key `check-updates`, `SettingsSync.swift:21`); no Sparkle. Downloads the release, checks it, replaces the app and relaunches. A copy named pika-tools.app renames itself to pikapik.app on launch and when updating; Homebrew copies stay until `brew upgrade`.

**Options:**
- Check Now — checks right away (`SettingsWindow.swift:1122`).
- Update to %@ — prominent button when a newer version exists; also in the menu bar panel and the icon menu.
- Version — the installed version. Website: a row in the Updates section that also shows the updater state; App Store: a version-only row (`SettingsWindow.swift:1111`).

**Nuances:** In the menu bar panel, Update to %@ is a prominent footer button (`updateFooter`, `MenuView.swift:257`), Website only, shown while a newer version exists; the icon’s right-click menu has the same item.

**Edition:** Both; App Store differs: no updater, switch, Check Now or Update button (updates come from the App Store); only the Version row.

**Test:**
1. (Website) Press Check Now with an older build → it finds the newer release, installs it and relaunches.
2. (Website) Turn the switch off → no automatic check.
3. Open About → the Version number matches Finder › Get Info on the app.
4. (Website, older build) The Update button shows at the bottom of the menu bar panel with the new version; press it → the app updates and relaunches.

### Say thanks

**Does:** Tip buttons (Small, Medium, Large) with local prices. Nothing unlocks.

**How it works:** StoreKit (`Sources/pika-tools/Common/TipJar.swift`, `SettingsWindow.swift:1133`). Hidden while no tip products exist. Error “The tip did not go through.”

**Edition:** App Store only.

**Test:**
1. (App Store, after products exist in App Store Connect) About shows three buttons with local prices. Buy one with a sandbox account → “Thank you!” appears and nothing unlocks. Cancel the purchase → no error. Offline → “Tips are not available right now” with Try Again that recovers. Search “tip” → finds Say thanks.

### Report a Problem

**Does:** Opens the bug form on GitHub with the edition and version already filled in.

**How it works:** Link to `issues/new?template=bug_report.yml` with `edition` and `version` (`SettingsWindow.swift:1140`); the “Which feature?” list comes from this file.

**Edition:** Both.

**Test:**
1. Click Report a Problem → the form opens with Edition and Version filled in and the feature list from this catalog.

### Buy me a coffee

**Does:** Link to support the author, with the footer “Made with care”.

**How it works:** `CoffeeLine` (`SettingsWindow.swift:1185`) to buymeacoffee.com/pikapik.

**Edition:** Website only (App Store: cut — the tip jar replaces it).

**Test:**
1. (Website) Click it → the page opens.

## Menu bar

### Menu bar icon

**Does:** The icon next to the clock opens pikapik’s panel (330 pt wide) with quick switches.

**How it works:** SwiftUI `MenuBarExtra` window (`Sources/pika-tools/App.swift:30-34`, `MenuView.swift:63`) and the status item (`Common/StatusMenu.swift`). On macOS 27 the status button opens the panel on press through a swizzled `accessibilityPerformPress` (`StatusMenu.swift:57,66`, Website only). Default hidden rows are in `defaultHidden` (`MenuView.swift:4`).

**Options:**
- Settings… — icon button at the bottom of the panel that opens Settings (⌘,; `MenuView.swift:198`).
- Quit — icon button at the bottom of the panel that quits pikapik (⌘Q; `MenuView.swift:203`). Website: with Stay in the background after Quit on it only closes windows.

**Nuances:** Nothing is asked at launch; Settings opens on first launch, later from the menu.

**Edition:** Both; App Store differs: no macOS 27 press workaround.

**Test:**
1. Launch → the icon appears; click it → the panel opens. Press Esc or click elsewhere → it closes.
2. Click it or press ⌘, → Settings opens.
3. Press Quit → (App Store) the app quits; (Website) per Stay in the background after Quit.

### Right-click menu of the icon

**Does:** A short classic menu from the icon.

**How it works:** `StatusMenu.swift:95-120`: Keep Awake (checkmark), Settings…, Permissions needed, Update to %@ or Check for Updates (Website, `:104-108`), About, Open at Login, Quit, Quit Completely (⌥⌘Q alternate, Website, `:116`).

**Edition:** Both; App Store differs: no update items and no Quit Completely.

**Test:**
1. Right-click (or Ctrl-click) the icon → the items show; each does what it says. (Website) Hold ⌥ → Quit becomes Quit Completely.

### Keep Awake

**Does:** The Keep Awake row of the panel: a switch with a chevron that expands.

**How it works:** `MenuView.swift:81`; the subtitle shows the status.

**Options:**
- Display — Always on / Turns off as usual (`MenuView.swift:222-228`).
- Turn off the display now — button (`MenuView.swift:234`).

**Edition:** Both.

**Test:**
1. Turn it on, expand it, choose a Display option → `pmset -g assertions` follows. Press Turn off the display now → the screen goes dark.

### Brightness

**Does:** A slider row per listed monitor.

**How it works:** `MenuView.swift:31` (`BrightnessRow`); hidden by default and visible only when a monitor is controllable.

**Edition:** Both.

**Test:**
1. See Brightness › Brightness, step 5.

### Speed Test

**Does:** A button row that starts a speed check.

**How it works:** `SpeedTestRow`; hidden by default (add it in Customize…).

**Edition:** Both.

**Test:**
1. Customize… › turn on Speed Test › Done → press Check on the card → a check runs.

### Fans

**Does:** A slider row for the fan speed.

**How it works:** `MenuView.swift:120` (`FanRow`); `showsFans` is false in the App Store build (`MenuView.swift:25`).

**Edition:** Website only (App Store: hidden).

**Test:**
1. (Website, Mac with fans) The row works like Fans › Fan speed.

### Temperature

**Does:** The thermal verdict row.

**How it works:** `TemperatureRow`.

**Edition:** Both.

**Test:**
1. The row shows the same word as Settings › Temperature.

### Tool rows

**Does:** One switch per tool, grouped by tab, with the status Active, Off, Needs Access or Game Mode.

**How it works:** `MenuView.swift:138-147`, `Tool.swift:27`; only the tools registered in the edition appear; a row whose tool needs a permission is half-grey.

**Edition:** Both; App Store differs: fewer tools.

**Test:**
1. Switch a tool on and off in the panel → the Settings switch follows; with a missing permission the row shows Needs Access and opens Permissions.

### App Volume

**Does:** Compact per-app volume sliders in the panel.

**How it works:** Only on macOS 14.2 or later; hidden before.

**Edition:** Both.

**Test:**
1. (macOS 14.0 or 14.1) No App Volume row. Otherwise the sliders match Settings › Sound.

### Permissions needed

**Does:** A button that appears only while a tool you switched on lacks a permission, and opens the Permissions tab. With nothing switched on it stays hidden, so a new install shows no warning.

**How it works:** `MenuView.swift:153-165`; the same condition (`ToolRegistry.needsPermission`) decides whether the right-click menu on the menu bar icon has a Permissions needed item (`StatusMenu.swift:101`).

**Edition:** Both.

**Test:**
1. With a tool on and its permission missing (switch it on, then turn pikapik off in System Settings › Privacy & Security) → the button shows in the panel and in the right-click menu; click it → Settings opens on Permissions.
2. With every tool off, or every switched-on tool allowed → no button and no menu item, also in the App Store build.

### Restart Finder

**Does:** A button that restarts Finder to bring back the right-click items.

**How it works:** `MenuView.swift:167-180`; shown when needed.

**Edition:** Both in code; effectively Website only.

**Test:**
1. (Website) After toggling a Finder extension, press it → Finder relaunches.

### Customize…

**Does:** Chooses which rows the panel shows.

**How it works:** `MenuView.swift:200`; rows turn into checkboxes under “Choose what this menu shows”; Done ends.

**Edition:** Both.

**Test:**
1. Press Customize…, uncheck a row, press Done → the row is gone; check it again → it returns.

### App menu commands

**Does:** Settings… (⌘,) and Quit Completely (⌥⌘Q, shown while Stay in the background after Quit is on).

**How it works:** `App.swift:35-50`; Help menu is empty; Quit Completely is Website only.

**Edition:** Both; App Store differs: no Quit Completely.

**Test:**
1. Press ⌘, → Settings opens. (Website) ⌥⌘Q → the process ends.

## Install and uninstall

### One-line install

**Does:** Installs the Website edition with one command.

**How it works:** `install.sh` (`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dev-pikapik/pika-tools/main/install.sh)"`). Needs macOS 14 or later. Downloads `pikapik.zip` from the latest release and installs it only if `codesign --verify --deep --strict` passes against pikapik’s Developer ID requirement and `spctl --assess` passes (signature and Apple’s notarization check). Quits a running copy, replaces `/Applications/pikapik.app` (and an old `pika-tools.app`), launches it, and opens help for Accessibility and Input Monitoring. `-- --source` builds from source instead.

**Nuances:** It refuses to run when the App Store version is in `/Applications`. Test with a copy of the script, stub apps and a fake release URL, never on the real app of someone running the App Store copy.

**Edition:** Website only.

**Test:**
1. (clean Mac or after `uninstall.sh`) Run the command → “Checking the developer’s signature and Apple’s malware check”, then the app lands in /Applications and opens in the menu bar.
2. With a tampered or ad-hoc-signed zip (local test with a file:// URL) → “nothing was installed”.
3. With the App Store version in /Applications → it stops with the App Store message.

### Homebrew

**Does:** Installs and updates with Homebrew.

**How it works:** `brew install --cask dev-pikapik/pika-tools/pikapik && open -a pikapik`; `brew upgrade --cask pikapik`; cask generated by `scripts/cask.sh` (removes quarantine, removes an old `pika-tools.app`, runs `--uninstall` before removal).

**Edition:** Website only.

**Test:**
1. Run the install command → pikapik is in /Applications and opens. `brew upgrade --cask pikapik` → upgrades when a newer release exists.

### Uninstall

**Does:** Removes the Website edition and puts the system back.

**How it works:** `uninstall.sh` runs `pika-tools --uninstall` first (turns off launch at login and restores what the app changed: Animations, Key repeat, Dock display, pointer, Game Mode hot corners), quits the app, deletes `/Applications/pikapik.app` and `pika-tools.app`, removes the fan helper and its LaunchDaemon, resets Accessibility and Input Monitoring for the bundle id and deletes its defaults. It leaves an App Store copy alone. Homebrew: `brew uninstall --cask --zap pikapik`. Other launch flags: `--permissions`, `--settings` (`App.swift:144`).

**Edition:** Website only (App Store: remove the app like any other).

**Test:**
1. Turn on Open at Login, Repeat a held key and Keep the Dock on one display, then run the uninstall command → the app is gone, login item gone, key repeat popup and the Dock’s display behavior are back, and a second copy from the App Store (if present) stays.
2. `brew uninstall --cask --zap pikapik` does the same for a Homebrew install.
