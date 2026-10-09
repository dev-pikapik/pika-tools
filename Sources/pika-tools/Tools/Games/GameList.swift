import AppKit
import SwiftUI

struct GameList: View {
    @Bindable var tool: GameModeTool
    @State private var adding = false

    var body: some View {
        LabeledContent {
            if adding {
                Button("Done") { adding = false }
            } else {
                Button("Add a Game…") { adding = true }
            }
        } label: {
            RowLabel(Text("Your games"), tool.games.isEmpty ? Text("Add a game, and Game Mode turns on by itself while you play it") : nil)
        }
        .settingAnchor(String(localized: "Your games"))
        if adding { GameShelf(tool: tool) }
        ForEach(tool.games, id: \.self) { key in
            AppRow(bundleID: key) { tool.games.removeAll { $0 == key } }
        }
    }
}

private struct GameShelf: View {
    let tool: GameModeTool

    var body: some View {
        AppShelf(
            hint: Text("Here’s what’s in your Dock. Click your game to add it"),
            empty: Text("Open your game, and it shows up here"),
            added: tool.games,
            suggest: { GameRules.shelf(AppShelf.dock().compactMap(GameModeTool.key) + AppShelf.running.map(GameModeTool.key)) },
            toggle: { key in
                if tool.games.contains(key) { tool.games.removeAll { $0 == key } } else { tool.confirm(key) }
            },
            other: { AppExclusions.choose().forEach(tool.add) }
        )
    }
}
