# Game input and shortcut catalogue

Game Mode reads the shortcut assignments on the current Mac. Changing a shortcut in System Settings changes the keys shown by pikapik and the combination it handles when the game next comes forward.

`CopySymbolicHotKeys` supplies the operating system's catalogue size. The live SkyLight reader resolves each action's identifier, key, modifiers and enabled state. Discovery starts with the identifiers in the system's settings resources and saved preferences, then expands its search until the reported catalogue is covered. It includes unassigned actions and has no dependency on a particular default key combination. Names and categories come from the installed Keyboard Settings resources. Actions without a published name keep their identifier and current keys visible.

The catalogue on the development Mac contains 234 actions. The 201 assigned actions have 185 unique combinations; 33 have no assigned keyboard key. These numbers are a snapshot, and discovery runs against each user's Mac.

| Source | What is visible | What Game Mode does |
| --- | --- | --- |
| macOS symbolic shortcuts | Action, current key, modifiers, enabled state, category where published | Pauses the chosen action while its game is frontmost and restores its original state on leaving |
| Input source switching | The user's actual previous/next language combinations | Pauses the system menu and selects the input source directly for a deliberate shortcut, passing the key through to the game |
| pikapik's language gesture | The configured Option/Shift gesture | Allows a short deliberate gesture without a system picker; held game controls have priority |
| Other applications' event taps | Process, keyboard event mask, enabled state, filter or listener | Shows the owners separately; their private shortcut logic is not part of the macOS catalogue |
| App-specific menus, services and hardware-only handling | Not all assignments are available from the symbolic catalogue | Requires a separate adapter; this catalogue does not claim to enumerate those private handlers |

Automatic is the default for every action. Actions that open windows or move focus are paused. Input-source actions can run in the background. A modifier chord is considered deliberate when it is short (up to 450 ms) and no other game key is held. Explicit Background mode lets the user request the action without that intent check. Physical key-down and key-up events continue through the game input path. The supported background action set is explicit: an unsupported action cannot be assigned to Background through the UI.

More game settings contains the searchable catalogue and the existing detailed rules. Each catalogue action has a preview using the same game timeline, key caps and animation continuity as the original Game Mode previews. Unknown actions use an explicitly generic system-action preview.

Per-action choices are stored by action identifier in `game-mode-system-shortcuts`, included in settings backup and sync. Existing group rules remain the baseline for their known actions. A per-action choice takes priority. Emergency Force Quit stays available.

## Validation

`scripts/test-system-shortcuts.swift` checks discovery beyond the starting range, remapped keys, duplicate combinations, per-action choices, deliberate language input and held movement keys, and compares live discovery with the native catalogue. `scripts/render-system-shortcuts.swift` renders the available preview families in light and dark. `scripts/dump-system-shortcuts.swift` writes an inspectable snapshot without committing user-specific key assignments.

The shortcut-link crash fixed in 1.30.14 was a separate issue: a lazy compact-map lookup read a changing accessibility row twice. The second read could return nil after the first had succeeded, triggering a Swift trap. The lookup now reads each node once, with a regression test for disappearing text.
