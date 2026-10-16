import Foundation

struct PetCues {
    var mind = PetMind()
    var hello = false
    var muted = false
    var progress: PetProgress?
    private(set) var owed: (phrase: PetPhrase, by: Double)?
    private var dressed: [PetSlot: PetItem]?
    private var told = 0
    private var nextScold = 0.0
    private var tumbled = -Double.infinity

    mutating func begin(news: Int) {
        hello = true
        dressed = nil
        told = news
    }

    @discardableResult
    mutating func feel(_ mood: PetMood, _ now: Double, _ physics: inout PetPhysics) -> Bool {
        let sits = mood == .bored || mood == .sleepy
        guard !muted, physics.state != .doze, !sits || physics.canSit, mind.feel(mood, at: now) else { return false }
        progress?.mark("mood:\(mood.rawValue)")
        switch mood {
        case .happy: progress?.add(.smiles)
        case .shy: progress?.add(.blushes)
        case .bored, .sleepy: physics.sit(mood.length)
        case .excited:
            progress?.add(.smiles)
            if physics.grounded, !physics.calm, physics.state != .sit { physics.jump() }
        default: break
        }
        return true
    }

    mutating func cue(_ events: [PetPhysics.Event], _ now: Double, _ date: Date, _ physics: inout PetPhysics) {
        let flung = events.contains(.fling)
        for event in events {
            switch event {
            case .fling:
                feel(.grumpy, now, &physics)
                if now >= nextScold {
                    nextScold = now + 600
                    owed = (PetPhrases.gently, now + 8)
                }
            case .tumble where !flung:
                feel(now - tumbled < 60 ? .grumpy : .surprised, now, &physics)
                tumbled = now
            case .leap, .climb: feel(.proud, now, &physics)
            case .woke: feel(.sleepy, now, &physics)
            default: break
            }
        }
        if let progress {
            let outfit = progress.outfit, news = progress.news.count
            if let dressed, dressed != outfit { feel(.proud, now, &physics) }
            dressed = outfit
            if news > told { feel(.excited, now, &physics) }
            told = news
        }
        if hello, physics.state == .walk {
            hello = false
            feel(.happy, now, &physics)
            if (5..<12).contains(Calendar.current.component(.hour, from: date)), progress?.greet(date) == true, let noon = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: date) { owed = (PetPhrases.morning, now + noon.timeIntervalSince(date)) }
        }
    }

    mutating func speak(_ now: Double, _ physics: inout PetPhysics, free: Bool) -> PetPhrase? {
        guard let line = owed else { return nil }
        if now > line.by {
            owed = nil
        } else if free, physics.sit(3.4) {
            owed = nil
            return line.phrase
        }
        return nil
    }
}
