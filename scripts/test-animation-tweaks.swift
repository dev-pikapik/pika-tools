import Foundation

@main
enum TestAnimationTweaks {
    static func near(_ a: Double, _ b: Double) -> Bool { abs(a - b) < 0.0001 }

    static func main() {
        let delay = AnimationSetting.dockDelay
        precondition(near(delay.mark, 0.8))
        precondition(delay.value(at: 1) == 0)
        precondition(delay.value(at: 0) == 1)
        precondition(delay.value(at: 0.78) == 0.2)
        precondition(delay.value(at: 0.83) == 0.2)
        precondition(near(delay.value(at: 0.9), 0.1))
        precondition(near(delay.value(at: 0.66), 0.35))
        precondition(near(delay.position(of: 0.2), 0.8))
        precondition(delay.position(of: 5) == 0)

        let columns = AnimationSetting.finderColumns
        precondition(columns.value(at: 0.65) == 1)
        precondition(near(columns.value(at: 0.83), 0.5))
        precondition(columns.label(1) == .macOS)
        precondition(columns.label(0) == .instant)
        precondition(columns.label(0.5) == .faster(2))
        precondition(columns.label(2) == .slower(2))

        precondition(AnimationSetting.resize.label(0.2) == .macOS)
        precondition(AnimationSetting.resize.label(0) == .instant)
        precondition(AnimationSetting.resize.label(0.15) == .seconds(0.15))
        precondition((AnimationSetting.resize.plist(0) as? NSNumber)?.doubleValue == 0.001)
        precondition(AnimationSetting.resize.value(from: 0.001 as NSNumber) == 0)
        precondition(AnimationSetting.dockSpeed.value(from: Float(0.1) as NSNumber) == 0.1)

        precondition((AnimationSetting.bounce.plist(0) as? NSNumber)?.boolValue == true)
        precondition(AnimationSetting.bounce.value(from: true as NSNumber) == 0)
        precondition((AnimationSetting.finder.plist(0) as? NSNumber)?.boolValue == true)
        precondition((AnimationSetting.windowOpen.plist(0) as? NSNumber)?.boolValue == false)
        precondition(AnimationSetting.windowOpen.value(from: false as NSNumber) == 0)
        precondition(AnimationSetting.minimize.plist(2) as? String == "suck")
        precondition(AnimationSetting.minimize.value(from: "scale" as NSString) == 1)
        precondition(AnimationSetting.minimize.value(from: "wobble" as NSString) == nil)

        precondition(AnimationSpeed.snapped(0.47) == 0.5)
        precondition(AnimationSpeed.snapped(0.97) == 1)
        precondition(AnimationSpeed.snapped(0.32) == 0.3)
        precondition(AnimationSpeed.label(nil) == .custom)
        precondition(AnimationSpeed.label(0) == .macOS)
        precondition(AnimationSpeed.label(1) == .instant)
        precondition(AnimationSpeed.label(0.5) == .faster(2))

        let fast = AnimationSpeed.preset(0.5)
        precondition(fast[.dockDelay] == 0.1 && fast[.dockSpeed] == 0.25 && fast[.finderColumns] == 0.5)
        precondition(fast[.windowOpen] == 1 && fast[.finder] == 1)
        precondition(fast[.minimize] == nil && fast[.bounce] == nil)
        let instant = AnimationSpeed.preset(1)
        precondition(instant.values.allSatisfy { $0 == 0 })
        precondition(AnimationSpeed.preset(0).allSatisfy { $0.value == $0.key.macOS })

        let mine: [AnimationSetting: Double] = [.dockDelay: 0, .dockSpeed: 0.1, .windowOpen: 0, .resize: 0.1, .quickLook: 0.2, .finderColumns: 1, .finder: 1]
        let faster = AnimationSpeed.preset(0.5, baseline: mine)
        precondition(faster.allSatisfy { $0.value <= mine[$0.key]! })
        precondition(faster[.dockDelay] == 0 && faster[.dockSpeed] == 0.1 && faster[.windowOpen] == 0 && faster[.quickLook] == 0.1 && faster[.finder] == 1)
        precondition(AnimationSpeed.preset(1, baseline: mine).values.allSatisfy { $0 == 0 })
        precondition(AnimationSpeed.preset(0, baseline: mine) == AnimationSpeed.preset(0))
        precondition(AnimationSpeed.speed(of: faster, stored: 0.5, baseline: mine) == 0.5)
        precondition(AnimationSpeed.speed(of: faster, stored: 0.5) == nil)

        precondition(AnimationSpeed.speed(of: [:], stored: nil) == 0)
        precondition(AnimationSpeed.speed(of: [.minimize: 2, .bounce: 0], stored: nil) == 0)
        precondition(AnimationSpeed.speed(of: fast, stored: 0.5) == 0.5)
        precondition(AnimationSpeed.speed(of: fast, stored: nil) == nil)
        var custom = fast
        custom[.quickLook] = 0.3
        precondition(AnimationSpeed.speed(of: custom, stored: 0.5) == nil)
        precondition(AnimationSpeed.speed(of: [.dockDelay: 0], stored: nil) == nil)

        let none = AnimationSetting.changes(from: [.dockDelay: 0], to: [.dockDelay: 0], system: [.dockDelay: 0])
        precondition(none.isEmpty)
        let rewrite = AnimationSetting.changes(from: [.dockDelay: 0], to: [.dockDelay: 0], system: [:])
        precondition(rewrite.count == 1 && rewrite[0].0 == .dockDelay && rewrite[0].1 == 0)
        let reset = AnimationSetting.changes(from: [.dockDelay: 0, .quickLook: 0.4], to: [:], system: [.dockDelay: 0, .quickLook: 0.4, .resize: 0.1])
        precondition(reset.map(\.0) == [.dockDelay, .quickLook] && reset.allSatisfy { $0.1 == nil })
        let gone = AnimationSetting.changes(from: [.finder: 0], to: [:], system: [:])
        precondition(gone.isEmpty)
        let untouched = AnimationSetting.changes(from: [:], to: [:], system: [.resize: 0.1])
        precondition(untouched.isEmpty)
        let restore = AnimationSetting.changes(from: [.dockSpeed: 0], to: [:], system: [.dockSpeed: 0], own: [.dockSpeed: 0.1])
        precondition(restore.count == 1 && restore[0].0 == .dockSpeed && restore[0].1 == 0.1)
        let lost = AnimationSetting.changes(from: [.dockSpeed: 0], to: [:], system: [:], own: [.dockSpeed: 0.1])
        precondition(lost.count == 1 && lost[0].1 == 0.1)
        precondition(AnimationSetting.changes(from: [.dockSpeed: 0], to: [:], system: [.dockSpeed: 0.1], own: [.dockSpeed: 0.1]).isEmpty)

        precondition(AnimationSetting.originals([:], owned: [:], new: [.dockSpeed: 0, .quickLook: 0], system: [.dockSpeed: 0.1]) == [.dockSpeed: 0.1])
        precondition(AnimationSetting.originals([.dockSpeed: 0.1], owned: [.dockSpeed: 0], new: [.dockSpeed: 0.3], system: [.dockSpeed: 0]) == [.dockSpeed: 0.1])
        precondition(AnimationSetting.originals([:], owned: [.resize: 0], new: [.resize: 0.05], system: [.resize: 0]).isEmpty)
        precondition(AnimationSetting.originals([.dockSpeed: 0.1], owned: [.dockSpeed: 0], new: [:], system: [.dockSpeed: 0]).isEmpty)
        precondition(AnimationSetting.quickLook.apply == .apps && AnimationSetting.finderColumns.apply == .apps && AnimationSetting.finder.apply == .finder)

        print("animation-tweaks: ok")
    }
}
