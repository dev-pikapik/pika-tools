import Foundation

@main
struct TestSettingsSearch {
    static func main() {
        precondition(SettingsSearch.matches("sound GAME", fields: ["Game Mode", "Changes the sound level."]))
        precondition(SettingsSearch.matches("controle", fields: ["Contrôle"]))
        precondition(SettingsSearch.matches("Ctrl+Space", fields: ["⌃Space"]))
        precondition(SettingsSearch.matches("Control Spacebar", fields: ["⌃Space"]))
        precondition(SettingsSearch.matches("Alt Shift D", fields: ["⌥⇧D"]))
        precondition(SettingsSearch.matches("Command Enter", fields: ["⌘↩"]))
        precondition(SettingsSearch.matchesKeys("game Ctrl+Q", keys: "⌃Q"))
        precondition(!SettingsSearch.matchesKeys("Ctrl+Q", keys: "⌃F1"))
        precondition(!SettingsSearch.matchesKeys("Ctrl+Space", keys: "⌘Space"))
        precondition(!SettingsSearch.matchesKeys("Ctrl+Space", keys: ""))
        precondition(!SettingsSearch.matches("Ctrl+Space", fields: ["Mission Control", "Spaces"]))
        precondition(SettingsSearch.matches("Mission Control", fields: ["Mission Control"]))
        precondition(SettingsSearch.matchesKeys("Mission Control", keys: "F3"))
        precondition(!SettingsSearch.matches("unknown", fields: ["Game Mode", "Language"]))
        precondition(!SettingsSearch.matches("  +  ", fields: ["Game Mode"]))
        precondition(SettingsSearch.score("CMD Control Space", title: "Input source", keys: "⌃⌘Space") > SettingsSearch.score("CMD Control Space", title: "Keyboard focus", keys: "⌃⌘F1"))
        print("global search: phrases, accents, modifier aliases, exact keys and ranking: ok")
    }
}
