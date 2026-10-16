import CoreGraphics

@main
enum TestMood {
    static func main() {
        var mind = PetMind()
        precondition(mind.face(at: 0) == PetFace() && mind.mood == .calm, "a fresh pet has no face")
        precondition(!mind.feel(.calm, at: 0), "calm is not a cue")

        precondition(mind.feel(.happy, at: 10), "a cue starts a mood")
        precondition(mind.mood == .happy && mind.face(at: 10) == PetFace(), "the face starts from the calm one")
        precondition(mind.face(at: 10.125) != PetFace() && mind.face(at: 10.125) != PetMood.happy.face(0), "the face fades in")
        precondition(mind.face(at: 10.25) == PetMood.happy.face(0) && mind.face(at: 12) == PetMood.happy.face(0), "the face holds")
        print("a cue starts a mood and the face fades in: ok")

        precondition(!mind.feel(.happy, at: 11), "the same cue does not start it again")
        precondition(mind.face(at: 13.4) == PetMood.happy.face(0), "the same cue extends the mood")
        precondition(mind.face(at: 13.5 + PetMind.fall) == PetFace() && mind.face(at: 13.5 + PetMind.fall / 2) != PetFace(), "an extended mood ends 2.5 s after the last cue")
        print("the same cue extends the mood without a restart: ok")

        var busy = PetMind()
        precondition(busy.feel(.grumpy, at: 0))
        precondition(!busy.feel(.happy, at: 1) && !busy.feel(.curious, at: 1) && !busy.feel(.bored, at: 1), "a lower mood waits while a higher one lasts")
        precondition(busy.feel(.surprised, at: 1), "a higher mood interrupts")
        let shown = busy.face(at: 1.1)
        precondition(shown != PetFace() && shown != PetMood.surprised.face(0), "an interruption fades from the face on screen")
        precondition(busy.face(at: 1.2) != PetMood.surprised.face(0) && busy.face(at: 1.25) == PetMood.surprised.face(0), "the switch takes the usual 0.25 s")
        precondition(busy.feel(.happy, at: 2.1), "a lower mood starts once the higher one has ended")
        print("rank: higher interrupts, lower waits: ok")

        var tired = PetMind()
        precondition(tired.feel(.happy, at: 0))
        precondition(!tired.feel(.happy, at: 2.6) && !tired.feel(.happy, at: 5.4), "rest keeps the same mood away")
        precondition(tired.feel(.happy, at: 5.6), "rest is over")
        precondition(tired.feel(.proud, at: 6) && !tired.feel(.proud, at: 38.9), "pride rests for 30 s")
        precondition(tired.feel(.surprised, at: 40) && tired.feel(.surprised, at: 41.1), "surprise never rests")
        var cut = PetMind()
        precondition(cut.feel(.shy, at: 0) && cut.feel(.surprised, at: 1))
        precondition(!cut.feel(.shy, at: 2.5) && !cut.feel(.shy, at: 45.9), "an interrupted mood rests from the moment it was cut")
        precondition(cut.feel(.shy, at: 46.1), "and is free after the rest")
        print("rest after a mood: ok")

        var own = PetMind()
        precondition(own.feel(.curious, at: 0))
        precondition(!own.feel(.bored, at: 100) && !own.feel(.sleepy, at: 179), "own moods wait 180 s across all three")
        precondition(own.feel(.bored, at: 181), "after the gap an own mood may start")
        precondition(!own.feel(.sleepy, at: 300), "the gap restarts with each own mood")
        precondition(own.feel(.happy, at: 300) && own.feel(.surprised, at: 301), "cues from outside ignore the gap")
        var lazy = PetMind()
        precondition(lazy.feel(.bored, at: 0) && !lazy.feel(.bored, at: 3) && !lazy.feel(.bored, at: 300), "bored rests for 10 minutes")
        precondition(lazy.feel(.bored, at: 608.1), "and comes back")
        print("own moods: one per 180 s: ok")

        for mood in PetMood.allCases where mood != .calm {
            var m = PetMind()
            precondition(m.feel(mood, at: 100))
            let end = 100 + mood.length
            let held = m.face(at: end - 0.01)
            precondition(mood == .sleepy ? held.open == 0.3 : held == mood.face(0), "\(mood) holds until it ends")
            precondition(m.face(at: end + PetMind.fall / 2) != PetFace(), "\(mood) fades out")
            precondition(m.face(at: end + PetMind.fall) == PetFace() && m.face(at: end + 50) == PetFace(), "\(mood) fades exactly to the calm face")
            precondition(mood.face(0).mark == .none ? mood.face(0).glow == 0 : mood.face(0).glow == 1, "\(mood) has a mark only with a glow")
        }
        precondition(PetMood.sleepy.face(0).gape == 0 && abs(PetMood.sleepy.face(0.5).gape - 1) < 1e-9 && abs(PetMood.sleepy.face(1).gape) < 1e-9, "a yawn opens and closes")
        print("every mood fades exactly to the calm face: ok")

        var look = PetMind()
        look.gaze = CGVector(dx: 1, dy: -0.4)
        precondition(look.feel(.curious, at: 0) && look.face(at: 1).look == CGVector(dx: 1, dy: -0.4), "a curious pet looks where the pointer is")
        look.gaze = CGVector(dx: 0.5, dy: 0)
        precondition(look.face(at: 1).look == CGVector(dx: 0.5, dy: 0))
        print("curious look follows the pointer: ok")

        let a = PetMood.happy.face(0), b = PetMood.excited.face(0), c = PetMood.surprised.face(0), calm = PetFace()
        precondition(PetFace.mix(a, b, 0) == a && PetFace.mix(a, b, 1) == b && PetFace.mix(a, c, 0) == a && PetFace.mix(calm, a, 1) == a, "mix hits both ends")
        let half = PetFace.mix(a, b, 0.5)
        precondition(abs(half.open - 1.05) < 1e-9 && abs(half.curve - 0.85) < 1e-9 && abs(half.gape - 0.45) < 1e-9, "mix blends numbers")
        precondition(PetFace.mix(calm, a, 0.5).mark == .heart && PetFace.mix(calm, a, 0.5).glow == 0.5, "a mark fades in without a pop")
        precondition(PetFace.mix(a, calm, 0.25).mark == .heart && PetFace.mix(a, calm, 0.25).glow == 0.75, "a mark fades out without a pop")
        let swap = (0...20).map { PetFace.mix(a, c, CGFloat($0) / 20) }
        precondition(swap.allSatisfy { $0.glow >= 0 && $0.glow <= 1 } && swap[10].glow == 0 && swap[5].mark == .heart && swap[15].mark == .bang, "a mark swaps through zero")
        print("mix endpoints and marks: ok")
    }
}
