import Foundation

struct PetPhrase: Identifiable, Equatable {
    let id: String
    let text: String
    var link: URL?
}

enum PetPhrases {
    static var all: [PetPhrase] {
        [
            PetPhrase(id: "patrol", text: String(localized: "Just a quick patrol break.")),
            PetPhrase(id: "water", text: String(localized: "Water break? I’ll keep your seat warm.")),
            PetPhrase(id: "stretch", text: String(localized: "Stretch time! I’d join you, but I have no arms.")),
            PetPhrase(id: "great", text: String(localized: "You’re doing great. I checked.")),
            PetPhrase(id: "snack", text: String(localized: "Is it snack time yet?")),
            PetPhrase(id: "eyes", text: String(localized: "Look out the window for 20 seconds. I’ll guard the screen.")),
            PetPhrase(id: "saving", text: String(localized: "I’m not lazy. I’m in power-saving mode.")),
            PetPhrase(id: "space", text: String(localized: "Psst… press Space.")),
            PetPhrase(id: "loading", text: String(localized: "Loading motivation… 99%")),
            PetPhrase(id: "kingdom", text: String(localized: "This whole edge is my kingdom.")),
        ]
    }

    static func update(_ version: String) -> PetPhrase {
        PetPhrase(id: "update", text: String(localized: "Psst, version \(version) is out! Click me."))
    }
}
