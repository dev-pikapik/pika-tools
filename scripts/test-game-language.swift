import CoreGraphics

@main
struct TestGameLanguage {
    static func main() {
        var intent = GameInputIntent()
        intent.changed(.maskAlternate, at: 1_000_000_000)
        intent.changed([.maskAlternate, .maskShift], at: 1_100_000_000)
        precondition(intent.allowsGesture(flags: [], at: 1_200_000_000))
        intent.changed([], at: 1_200_000_000)
        precondition(intent.allowsGesture(flags: [], at: 1_200_000_000))

        intent.changed(.maskAlternate, at: 2_000_000_000)
        intent.pressed(13, down: true)
        precondition(!intent.allowsGesture(flags: .maskShift, at: 2_100_000_000))
        intent.pressed(13, down: false)
        precondition(!intent.allowsGesture(flags: [], at: 2_800_000_000))
        intent.changed([], at: 2_800_000_000)
        precondition(!intent.allowsGesture(flags: [], at: 2_800_000_000))
        precondition(!GameInputIntent().allowsGesture(flags: [], at: 3_000_000_000))
        print("language gesture before and after game observer: ok")
        print("held game keys and long modifier chords: ok")
    }
}
