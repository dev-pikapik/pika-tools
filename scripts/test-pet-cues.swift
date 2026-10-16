import Foundation
import Observation

enum SettingsTab: String, CaseIterable, Identifiable {
    case general, keepAwake, fans, speedTest, sound, keyboard, mouse, windows, dock, finder, animations, games, pet, permissions, about

    var id: Self { self }
    var isAvailable: Bool { true }
}

struct Rig {
    static let name = "pikapik-test-pet-cues"
    static let defaults = UserDefaults(suiteName: name)!
    static let morning = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
    static let afternoon = Calendar.current.date(bySettingHour: 14, minute: 0, second: 0, of: Date())!

    let progress: PetProgress
    var pet = PetPhysics(bounds: CGRect(x: 0, y: 0, width: 600, height: 190), x: 300)
    var cues = PetCues()
    var now = 100.0
    var date = morning
    var free = true
    var said: [String] = []

    init() {
        Self.defaults.removePersistentDomain(forName: Self.name)
        progress = PetProgress(store: Self.defaults)
        cues.progress = progress
    }

    mutating func tick() {
        now += 1.0 / 30
        pet.step(1.0 / 30, cursor: nil)
        cues.cue(pet.drain(), now, date, &pet)
        if let phrase = cues.speak(now, &pet, free: free) { said.append(phrase.id) }
    }

    mutating func run(_ seconds: Double) {
        let end = now + seconds
        while now < end { tick() }
    }

    @discardableResult
    mutating func rouse() -> Double {
        pet.wake()
        while pet.state == .wake { tick() }
        return now
    }

    mutating func doze() {
        precondition(pet.doze() && pet.state == .doze)
    }
}

@main
enum TestPetCues {
    static func main() {
        var woken = Rig()
        woken.doze()
        woken.run(3)
        woken.rouse()
        precondition(woken.cues.mind.mood == .sleepy && woken.pet.state == .sit, "a pet that woke is not sleepy and sitting: \(woken.cues.mind.mood) \(woken.pet.state)")
        precondition(woken.progress.seen.contains("mood:sleepy"), "the sleepy face was not counted")
        woken.run(PetMood.sleepy.length + 0.5)
        precondition(woken.pet.state == .walk && woken.said.isEmpty, "a sleepy pet that woke up did not walk on, or spoke unasked")
        print("a pet that wakes from a doze is sleepy and sits down: ok")

        var morning = Rig()
        morning.cues.hello = true
        morning.doze()
        morning.run(3)
        precondition(morning.cues.hello && morning.progress.count(.mornings) == 0 && morning.said.isEmpty, "the greeting ran while the pet dozed")
        let up = morning.rouse()
        precondition(morning.cues.mind.mood == .sleepy && morning.pet.state == .sit, "the greeting cut the sleepy face short: \(morning.cues.mind.mood)")
        precondition(morning.cues.hello && morning.cues.owed == nil && morning.progress.count(.mornings) == 0, "the greeting was spent while the pet could not speak")
        var told = 0.0
        while morning.said.isEmpty, morning.now < up + 10 {
            morning.tick()
            told = morning.now
        }
        precondition(morning.said == ["morning"], "the morning phrase was lost: \(morning.said)")
        precondition(told - up >= PetMood.sleepy.length - 0.1 && morning.pet.state == .sit, "the phrase did not wait for the sleepy face to go: \(told - up) s, \(morning.pet.state)")
        precondition(morning.cues.mind.mood == .happy && morning.progress.count(.mornings) == 1 && morning.cues.owed == nil, "after the yawn the pet is not happy and counted once")
        morning.run(20)
        precondition(morning.said == ["morning"] && morning.progress.count(.mornings) == 1, "the morning phrase came twice")
        print("the morning phrase waits for the yawn, then is said once: ok")

        var seventh = Rig()
        for _ in 1...6 { seventh.progress.add(.mornings) }
        seventh.cues.hello = true
        seventh.doze()
        seventh.rouse()
        while seventh.said.isEmpty, seventh.now < 120 { seventh.tick() }
        let spoke = seventh.now
        while seventh.now < spoke + 3.3 {
            seventh.tick()
            precondition(seventh.pet.state == .sit, "the Good Morning award made the pet jump up in the middle of the greeting: \(seventh.pet.state)")
        }
        precondition(seventh.said == ["morning"] && seventh.progress.news.contains(.morning) && seventh.progress.seen.contains("mood:excited"), "on the seventh morning the greeting, the award or the joy was lost: \(seventh.said)")
        print("the award the greeting earns does not cut the greeting short: ok")

        var busy = Rig()
        busy.cues.hello = true
        busy.free = false
        busy.doze()
        busy.rouse()
        busy.run(PetMood.sleepy.length + 60)
        precondition(busy.said.isEmpty && busy.cues.owed != nil && busy.progress.count(.mornings) == 1, "a phrase held back by typing was dropped early")
        busy.free = true
        busy.run(0.5)
        precondition(busy.said == ["morning"] && busy.cues.owed == nil, "the held-back phrase was not said when the pet was free")
        print("the morning phrase held back for a minute by typing, the microphone or the Dock is said when they stop: ok")

        var quiet = Rig()
        quiet.cues.hello = true
        quiet.free = false
        quiet.doze()
        quiet.rouse()
        quiet.run(30)
        precondition(quiet.said.isEmpty, "a pet that may not talk said something: \(quiet.said)")
        precondition(quiet.progress.count(.mornings) == 1 && quiet.progress.seen.contains("mood:happy") && quiet.progress.count(.smiles) == 1, "with talks off the morning or the smile was not counted")
        var late = Rig()
        late.date = Rig.afternoon
        late.cues.hello = true
        late.run(10)
        precondition(late.said.isEmpty && late.progress.count(.mornings) == 0 && late.progress.count(.smiles) == 1 && !late.cues.hello, "an afternoon greeting is a smile and nothing else")
        print("with talks off, or after noon, there is no phrase and the morning still counts: ok")

        var tossed = Rig()
        tossed.run(1)
        tossed.pet.jump()
        tossed.cues.cue([.fling], tossed.now, tossed.date, &tossed.pet)
        precondition(tossed.cues.owed != nil && tossed.cues.mind.mood == .grumpy, "a hard throw owes no phrase")
        var air = 0
        while tossed.said.isEmpty, tossed.now < 110 {
            if !tossed.pet.canSit {
                air += 1
                precondition(tossed.cues.owed != nil, "the phrase owed after a toss was dropped while the pet could not sit: \(tossed.pet.state)")
            }
            tossed.tick()
        }
        precondition(air > 0, "the pet was never up in the air with a phrase owed, update this check")
        precondition(tossed.said == ["gently"] && tossed.cues.owed == nil, "the phrase owed after a toss was lost: \(tossed.said)")
        print("a phrase owed while the pet cannot sit waits until it can: ok")

        var unheard = Rig()
        unheard.pet.sit(30)
        unheard.cues.cue([.fling], unheard.now, unheard.date, &unheard.pet)
        unheard.free = false
        unheard.run(9)
        precondition(unheard.cues.owed == nil && unheard.said.isEmpty, "a stale phrase stayed owed")
        print("a phrase nobody could hear for 8 s is dropped: ok")

        var held = Rig()
        precondition(held.pet.grab(at: CGPoint(x: held.pet.origin.x, y: held.pet.frame.maxY - PetPhysics.scruff)))
        var jumping = Rig()
        jumping.pet.jump()
        var seated = Rig()
        seated.pet.sit(5)
        var dozing = Rig()
        dozing.doze()
        var waking = Rig()
        waking.doze()
        waking.pet.wake()
        for (name, rig) in [("held", held), ("jumping", jumping), ("sitting", seated), ("dozing", dozing), ("waking", waking)] {
            for mood in [PetMood.bored, .sleepy] {
                var other = rig
                let state = other.pet.state
                precondition(!other.cues.feel(mood, other.now, &other.pet) && other.cues.mind.mood == .calm && other.pet.state == state, "\(mood) started while \(name)")
                precondition(!other.progress.seen.contains("mood:\(mood.rawValue)"), "\(mood) was counted while \(name)")
            }
        }
        var walking = Rig()
        precondition(walking.cues.feel(.bored, walking.now, &walking.pet) && walking.pet.state == .sit, "a walking pet did not get bored")
        var refused = Rig()
        refused.pet.jump()
        refused.cues.feel(.sleepy, refused.now, &refused.pet)
        while !refused.pet.canSit { refused.tick() }
        precondition(refused.pet.canSit && refused.cues.feel(.sleepy, refused.now, &refused.pet) && refused.pet.state == .sit, "a refused sleepy cue used up its rest")
        print("bored and sleepy never start while the pet cannot sit: ok")

        var award = Rig()
        award.cues.begin(news: 0)
        award.cues.hello = false
        award.progress.add(.visits)
        award.tick()
        precondition(award.progress.news.count == 1 && award.cues.mind.mood == .excited && award.pet.state == .jump, "a new award did not excite the pet")
        print("a new award excites the pet: ok")

        Rig.defaults.removePersistentDomain(forName: Rig.name)
    }
}
