import SwiftUI

enum PetSlot: String, CaseIterable, Identifiable {
    case head, face, neck, body, legs, feet, back

    var id: Self { self }

    var title: String {
        switch self {
        case .head: String(localized: "Hats")
        case .face: String(localized: "Face")
        case .neck: String(localized: "Neckwear")
        case .body: String(localized: "Tops")
        case .legs: String(localized: "Bottoms")
        case .feet: String(localized: "Shoes")
        case .back: String(localized: "Extras")
        }
    }
}

enum PetRank: Int, CaseIterable, Comparable {
    case common = 1, uncommon, rare, epic, legendary

    static func < (a: Self, b: Self) -> Bool { a.rawValue < b.rawValue }

    var title: String {
        switch self {
        case .common: String(localized: "Common")
        case .uncommon: String(localized: "Uncommon")
        case .rare: String(localized: "Rare")
        case .epic: String(localized: "Epic")
        case .legendary: String(localized: "Legendary")
        }
    }

    var color: Color {
        switch self {
        case .common: .gray
        case .uncommon: .green
        case .rare: .blue
        case .epic: .purple
        case .legendary: .orange
        }
    }
}

enum PetItem: String, CaseIterable, Identifiable {
    case cap, beanie, party, flowers, bunny, cowboy, tophat, detective, pirate, propeller, wizard, viking, helmet, crown
    case shades, round, hearts, mask
    case bowtie, scarf, bandana
    case tee, stripes, hoodie, labcoat, tux, hero, suit
    case jeans, overalls, tutu
    case sneakers, boots, skates
    case cape, balloon, wings, angel

    var id: Self { self }

    var slot: PetSlot {
        switch self {
        case .cap, .beanie, .party, .flowers, .bunny, .cowboy, .tophat, .detective, .pirate, .propeller, .wizard, .viking, .helmet, .crown: .head
        case .shades, .round, .hearts, .mask: .face
        case .bowtie, .scarf, .bandana: .neck
        case .tee, .stripes, .hoodie, .labcoat, .tux, .hero, .suit: .body
        case .jeans, .overalls, .tutu: .legs
        case .sneakers, .boots, .skates: .feet
        case .cape, .balloon, .wings, .angel: .back
        }
    }

    var rank: PetRank {
        switch self {
        case .cap, .beanie, .party, .shades, .bowtie, .scarf, .tee, .jeans, .sneakers, .boots: .common
        case .flowers, .bunny, .cowboy, .round, .hearts, .bandana, .stripes, .hoodie, .overalls, .tutu: .uncommon
        case .tophat, .detective, .pirate, .propeller, .mask, .labcoat, .cape, .balloon: .rare
        case .wizard, .viking, .helmet, .tux, .hero, .suit, .skates, .wings: .epic
        case .crown, .angel: .legendary
        }
    }

    var free: Bool {
        switch self {
        case .cap, .shades, .bowtie, .tee, .jeans, .sneakers: true
        default: false
        }
    }

    var title: String {
        switch self {
        case .cap: String(localized: "Cap")
        case .beanie: String(localized: "Pom-Pom Beanie")
        case .party: String(localized: "Party Hat")
        case .flowers: String(localized: "Flower Crown")
        case .bunny: String(localized: "Bunny Ears")
        case .cowboy: String(localized: "Cowboy Hat")
        case .tophat: String(localized: "Top Hat")
        case .detective: String(localized: "Detective Cap")
        case .pirate: String(localized: "Pirate Hat")
        case .propeller: String(localized: "Propeller Cap")
        case .wizard: String(localized: "Wizard Hat")
        case .viking: String(localized: "Viking Helmet")
        case .helmet: String(localized: "Space Helmet")
        case .crown: String(localized: "Crown")
        case .shades: String(localized: "Sunglasses")
        case .round: String(localized: "Round Glasses")
        case .hearts: String(localized: "Heart Glasses")
        case .mask: String(localized: "Hero Mask")
        case .bowtie: String(localized: "Bow Tie")
        case .scarf: String(localized: "Knitted Scarf")
        case .bandana: String(localized: "Bandana")
        case .tee: String(localized: "T-Shirt")
        case .stripes: String(localized: "Striped Shirt")
        case .hoodie: String(localized: "Hoodie")
        case .labcoat: String(localized: "Lab Coat")
        case .tux: String(localized: "Tuxedo")
        case .hero: String(localized: "Hero Suit")
        case .suit: String(localized: "Space Suit")
        case .jeans: String(localized: "Jeans")
        case .overalls: String(localized: "Overalls")
        case .tutu: String(localized: "Tutu")
        case .sneakers: String(localized: "Sneakers")
        case .boots: String(localized: "Rain Boots")
        case .skates: String(localized: "Roller Skates")
        case .cape: String(localized: "Cape")
        case .balloon: String(localized: "Balloon")
        case .wings: String(localized: "Fairy Wings")
        case .angel: String(localized: "Angel Wings")
        }
    }
}

struct PetLook: Identifiable {
    let id: String
    let title: String
    let items: [PetItem]

    static var all: [PetLook] {
        [
            PetLook(id: "wizard", title: String(localized: "Wizard"), items: [.wizard, .cape]),
            PetLook(id: "pirate", title: String(localized: "Pirate"), items: [.pirate, .stripes, .bandana]),
            PetLook(id: "astronaut", title: String(localized: "Astronaut"), items: [.helmet, .suit]),
            PetLook(id: "hero", title: String(localized: "Superhero"), items: [.mask, .hero, .cape]),
            PetLook(id: "cowboy", title: String(localized: "Cowboy"), items: [.cowboy, .bandana, .jeans]),
            PetLook(id: "fairy", title: String(localized: "Fairy"), items: [.flowers, .wings, .tutu]),
            PetLook(id: "king", title: String(localized: "King"), items: [.crown, .cape]),
            PetLook(id: "gentleman", title: String(localized: "Gentleman"), items: [.tophat, .tux, .bowtie]),
            PetLook(id: "scientist", title: String(localized: "Scientist"), items: [.labcoat, .round]),
            PetLook(id: "detective", title: String(localized: "Detective"), items: [.detective, .scarf]),
        ]
    }
}
