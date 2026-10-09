import CoreGraphics

@main
enum TestPet {
    typealias State = PetPhysics.State

    static let screen = CGRect(x: 0, y: 0, width: 600, height: 190)

    static func inside(_ pet: PetPhysics) -> Bool {
        let f = pet.frame, b = pet.bounds
        return f.minX >= b.minX - 1e-6 && f.maxX <= b.maxX + 1e-6 && f.minY >= b.minY - 1e-6 && f.maxY <= b.maxY + 1e-6
    }

    static func overlap(_ a: CGRect, _ b: CGRect) -> Bool {
        a.minX < b.maxX && b.minX < a.maxX && a.minY < b.maxY && b.minY < a.maxY
    }

    @discardableResult
    static func trace(_ pet: inout PetPhysics, _ seconds: Double, dt: Double = 1.0 / 30, cursor: (Double) -> CGPoint? = { _ in nil }, check: (PetPhysics, State) -> Void = { _, _ in }) -> [State] {
        var states = [pet.state]
        var t = 0.0
        while t < seconds - 1e-9 {
            t += dt
            let before = pet.state
            pet.step(dt, cursor: cursor(t))
            precondition(inside(pet), "out of bounds: \(pet.frame) in \(pet.bounds)")
            precondition(pet.origin.y >= pet.bounds.minY)
            check(pet, before)
            if pet.state != states.last { states.append(pet.state) }
        }
        return states
    }

    static func random(seed: UInt64, steps: Int) -> PetPhysics {
        var seed = seed
        func next() -> Double {
            seed = seed &* 6364136223846793005 &+ 1442695040888963407
            return Double(seed >> 11) / Double(1 << 53)
        }
        var pet = PetPhysics(bounds: screen)
        var point = CGPoint(x: 300, y: 20)
        var last = pet.origin, lastState = pet.state
        for i in 0..<steps {
            let dt = next() < 0.1 ? next() * 0.3 : 1.0 / 30
            let r = next()
            if r < 0.3 {
                point = CGPoint(x: next() * 700 - 50, y: next() * 140 - 20)
            } else if r < 0.7 {
                point.x += (next() - 0.5) * 60
                point.y += (next() - 0.5) * 30
            }
            if next() < 0.03 { pet.jump() }
            if next() < 0.005 { pet.sit(next() * 3) }
            if next() < 0.003 { pet.calm.toggle() }
            if next() < 0.002 {
                pet.resize(CGRect(x: next() * 100, y: next() * 40, width: 200 + next() * 800, height: 120 + next() * 100))
            }
            pet.step(dt, cursor: next() < 0.05 ? nil : point)
            precondition(inside(pet), "out of bounds at step \(i): \(pet.frame) in \(pet.bounds)")
            precondition(pet.origin.y >= pet.bounds.minY, "below ground at step \(i)")
            precondition(!(dt > 1e-3 && lastState == .walk && pet.state == .walk && pet.origin == last), "stuck at step \(i)")
            last = pet.origin
            lastState = pet.state
        }
        return pet
    }

    static func main() {
        var pet = PetPhysics(bounds: screen, x: 560, facing: 1)
        var turning = 0.0
        var states = trace(&pet, 3, check: { p, _ in if p.state == .turn { turning += 1.0 / 30 } })
        precondition(Array(states.prefix(3)) == [.walk, .turn, .walk])
        precondition(pet.facing == -1 && pet.origin.x < 560 && abs(turning - 0.7) < 0.1)
        pet = PetPhysics(bounds: screen, x: 40, facing: -1)
        states = trace(&pet, 3)
        precondition(Array(states.prefix(3)) == [.walk, .turn, .walk] && pet.facing == 1 && pet.origin.x > 40)
        print("edge turn: ok")

        let a = random(seed: 42, steps: 10_000), b = random(seed: 42, steps: 10_000)
        precondition(a.origin == b.origin && a.state == b.state && a.facing == b.facing)
        for seed in 1...5 as ClosedRange<UInt64> { _ = random(seed: seed, steps: 10_000) }
        print("10 000 random steps stay in bounds: ok")

        for height in [CGFloat(10), 30, 56] {
            pet = PetPhysics(bounds: screen, x: 100, facing: 1)
            let point = CGPoint(x: 300, y: height)
            let rect = PetPhysics.cursorRect(at: point)
            var passed = false
            states = trace(&pet, 12, cursor: { _ in point }) { p, _ in
                precondition(!overlap(p.frame, rect), "touched a cursor at \(height)")
                if p.frame.minX > rect.maxX { passed = true }
            }
            precondition(states.contains(.jump) && !states.contains(.tumble) && passed)
        }
        pet = PetPhysics(bounds: screen, x: 100, facing: 1)
        states = trace(&pet, 12, cursor: { _ in CGPoint(x: 300, y: 100) })
        precondition(states.allSatisfy { $0 == .walk || $0 == .turn })
        print("jump clears a low cursor, a high cursor is ignored: ok")

        for calm in [false, true] {
            pet = PetPhysics(bounds: screen, x: 450, facing: 1)
            pet.calm = calm
            let point = CGPoint(x: 552, y: 20)
            let rect = PetPhysics.cursorRect(at: point).insetBy(dx: 0.01, dy: 0.01)
            states = trace(&pet, 6, cursor: { _ in point }) { p, _ in precondition(!overlap(p.frame, rect)) }
            let expected: [State] = calm ? [.walk, .turn, .walk] : [.walk, .tumble, .lie, .getUp, .walk]
            precondition(Array(states.prefix(expected.count)) == expected, "\(states)")
            precondition(pet.facing == -1 && pet.frame.maxX < rect.minX - 20)
        }
        print("bump, fall and turn on a blocking cursor: ok")

        for dt in [1.0 / 30, 0.1, 0.25] {
            pet = PetPhysics(bounds: screen, x: 300, facing: 1)
            states = trace(&pet, 0.5, dt: dt, cursor: { CGPoint(x: -800 + 3000 * $0, y: 20) })
            precondition(states.contains(.tumble), "tunneled sideways at dt \(dt)")
            pet = PetPhysics(bounds: screen, x: 300, facing: 1)
            states = trace(&pet, 0.5, dt: dt, cursor: { CGPoint(x: 293, y: 1200 - 3000 * $0) })
            precondition(states.contains(.tumble), "tunneled from above at dt \(dt)")
        }
        print("no tunneling at 3000 pt/s: ok")

        for calm in [false, true] {
            for x in [CGFloat(30), 200, 400, 560] {
                pet = PetPhysics(bounds: screen, x: 100, facing: 1)
                pet.calm = calm
                let point = CGPoint(x: x, y: 20)
                let rect = PetPhysics.cursorRect(at: point)
                var triggers = 0, away = true
                trace(&pet, 120, cursor: { _ in point }) { p, before in
                    if abs(rect.midX - p.origin.x) - (rect.width + PetPhysics.size.width) / 2 > PetPhysics.reach { away = true }
                    let wall = p.frame.minX < screen.minX + 1 || p.frame.maxX > screen.maxX - 1
                    guard p.state != before, p.state == .jump || p.state == .tumble || p.state == .turn && !wall else { return }
                    precondition(away, "re-triggered without coming back, cursor at \(x)")
                    triggers += 1
                    away = false
                }
                precondition(triggers >= 2 && triggers < 40, "\(triggers) triggers, cursor at \(x)")
            }
        }
        print("no re-trigger loop with a resting cursor: ok")

        pet = PetPhysics(bounds: CGRect(x: 0, y: 0, width: 1000, height: 190), x: 960)
        pet.resize(CGRect(x: 0, y: 0, width: 500, height: 190))
        precondition(inside(pet) && pet.origin.y == 0)
        pet.jump()
        trace(&pet, 0.2)
        pet.resize(CGRect(x: 100, y: 40, width: 300, height: 150))
        precondition(inside(pet))
        trace(&pet, 20, cursor: { CGPoint(x: 100 + 300 * sin($0), y: 50 + 40 * cos($0 * 3)) })
        pet.resize(CGRect(x: -800, y: 0, width: 200, height: 120))
        precondition(inside(pet) && pet.origin.y == 0)
        trace(&pet, 5)
        print("re-clamp after a screen shrink: ok")

        pet = PetPhysics(bounds: screen)
        precondition(pet.jump())
        var top: CGFloat = 0
        trace(&pet, 0.1)
        let vy = pet.vy
        precondition(!pet.jump() && pet.vy == vy && pet.state == .jump)
        while pet.state == .jump {
            precondition(!pet.jump())
            pet.step(1.0 / 30, cursor: nil)
            top = max(top, pet.origin.y)
        }
        precondition(pet.state == .walk && abs(top - PetPhysics.hop) < 1)
        pet.bump(pet.frame.offsetBy(dx: 20, dy: 0))
        precondition(!pet.jump())
        trace(&pet, 3)
        precondition(pet.jump())
        print("space ignored mid-air: ok")

        let room = CGRect(x: 0, y: 4, width: 1400, height: 860)
        for thrown in [false, true] {
            pet = PetPhysics(bounds: room, x: 700)
            if thrown {
                pet.grab(at: CGPoint(x: 700, y: 30))
                for i in 1...12 { pet.step(1.0 / 120, cursor: CGPoint(x: 700, y: 30 + 3000 * CGFloat(i) / 120)) }
                pet.release()
            } else {
                pet.jump()
            }
            let before = pet.frame
            pet.step(thrown ? 1.0 / 30 : 0.25, cursor: nil)
            let gap = CGPoint(x: before.midX + 4, y: (before.maxY + pet.frame.minY) / 2)
            precondition(pet.state == (thrown ? .thrown : .jump) && pet.frame.minY > before.maxY, "no gap to test")
            precondition(!pet.grab(at: CGPoint(x: pet.frame.maxX + 20, y: gap.y)))
            precondition(pet.grab(at: gap) && pet.state == .held, "missed a catch, thrown: \(thrown)")
            precondition(!pet.grab(at: gap))
        }
        print("catch mid-air at full speed: ok")

        var seed: UInt64 = 7
        func next() -> CGFloat {
            seed = seed &* 6364136223846793005 &+ 1442695040888963407
            return CGFloat(seed >> 11) / CGFloat(1 << 53)
        }
        for _ in 0..<10_000 {
            pet = PetPhysics(bounds: room, x: 20 + next() * 1360)
            pet.calm = next() < 0.2
            var point = CGPoint(x: next() * 1500 - 50, y: next() * 900)
            pet.grab(at: CGPoint(x: pet.frame.midX, y: pet.frame.midY))
            let angle = next() * 2 * .pi, speed: CGFloat = 3000
            for _ in 0..<8 {
                point.x += cos(angle) * speed / 60
                point.y += sin(angle) * speed / 60
                pet.step(1.0 / 60, cursor: point)
                precondition(inside(pet))
            }
            pet.release()
            precondition(hypot(pet.vx, pet.vy) <= PetPhysics.fling + 1e-6)
            var t = 0.0
            while pet.aloft || pet.state == .tumble || pet.state == .lie || pet.state == .getUp {
                let dt = next() < 0.05 ? Double(next()) * 0.25 : 1.0 / 30
                pet.step(dt, cursor: nil)
                t += dt
                precondition(inside(pet), "left the screen: \(pet.frame)")
                precondition(!(pet.calm && pet.state == .tumble), "tumbled with Reduce Motion")
                precondition(t < 30, "never landed")
            }
        }
        for calm in [false, true] {
            pet = PetPhysics(bounds: room, x: 700)
            pet.calm = calm
            pet.grab(at: CGPoint(x: 700, y: 30))
            pet.step(0.1, cursor: CGPoint(x: 700, y: 500))
            pet.step(0.1, cursor: CGPoint(x: 700, y: 500))
            pet.release()
            states = trace(&pet, 4)
            precondition(states.contains(.tumble) != calm && states.last == .walk, "\(states)")
        }
        print("10 000 throws stay on screen: ok")

        pet = PetPhysics(bounds: room, x: 400, facing: 1)
        pet.grab(at: CGPoint(x: 400, y: 30))
        pet.step(1.0 / 30, cursor: CGPoint(x: 400, y: 30))
        pet.release()
        var bumped = false
        trace(&pet, PetPhysics.shyness - 0.05, cursor: { CGPoint(x: 360 + 700 * $0, y: 24) }) { p, _ in
            if p.state != .walk && p.state != .thrown { bumped = true }
        }
        precondition(!bumped && pet.state == .walk, "bumped right after a throw")
        let ahead = CGPoint(x: pet.origin.x + pet.facing * 70, y: 24)
        states = trace(&pet, 3, cursor: { _ in ahead })
        precondition(states.contains(.jump) || states.contains(.tumble), "\(states)")
        print("no bump for a second after a throw: ok")

        pet = PetPhysics(bounds: room, x: 400)
        pet.grab(at: CGPoint(x: 400, y: 20))
        precondition(!pet.jump() && pet.state == .held)
        trace(&pet, 0.5, cursor: { CGPoint(x: 400 + 100 * $0, y: 200) })
        precondition(!pet.jump() && pet.state == .held && pet.origin.y > 100)
        print("a held pet ignores Space: ok")

        pet = PetPhysics(bounds: room, x: 400, facing: 1)
        pet.jump()
        precondition(pet.state == .jump && !pet.aloft)
        pet.bump(pet.frame.offsetBy(dx: 20, dy: 0))
        precondition(pet.state == .tumble && !pet.aloft)
        trace(&pet, 3)
        pet.grab(at: CGPoint(x: pet.origin.x, y: 20))
        precondition(pet.state == .held && pet.aloft)
        pet.release()
        precondition(pet.state == .thrown && pet.aloft)
        print("only a held or thrown pet rises above windows: ok")

        for (roof, hop) in [(CGFloat(60), CGFloat(24)), (40, PetPhysics.hop / 2), (.infinity, PetPhysics.hop)] {
            pet = PetPhysics(bounds: room, x: 400)
            pet.roof = roof
            precondition(pet.jump())
            var top: CGFloat = 0
            trace(&pet, 2, check: { p, _ in top = max(top, p.origin.y - room.minY) })
            precondition(abs(top - hop) < 1, "hop \(top) under roof \(roof)")
        }
        for calm in [false, true] {
            for height in [CGFloat(10), 30, 56] {
                pet = PetPhysics(bounds: room, x: 300, facing: 1)
                pet.roof = 60
                pet.calm = calm
                let point = CGPoint(x: 500, y: height)
                states = trace(&pet, 12, cursor: { _ in point }) { p, _ in
                    precondition(p.frame.maxY <= 60 + 1e-6, "rose above the roof: \(p.frame) cursor at \(height)")
                }
                precondition(!states.contains(.jump), "\(states)")
            }
        }
        for i in 0..<20_000 {
            if i % 2_000 == 0 {
                pet = PetPhysics(bounds: room, x: 20 + next() * 1360)
                pet.roof = 60
            }
            if next() < 0.03 { pet.jump() }
            if pet.grounded, next() < 0.01 { pet.bump(pet.frame.offsetBy(dx: next() < 0.5 ? -20 : 20, dy: 0)) }
            if next() < 0.003 { pet.calm.toggle() }
            pet.step(next() < 0.05 ? Double(next()) * 0.25 : 1.0 / 30, cursor: CGPoint(x: next() * 1400, y: next() * 80))
            precondition(pet.frame.maxY <= 60 + 1e-6, "rose above the roof at step \(i): \(pet.frame)")
            precondition(!pet.grounded || pet.origin.y == room.minY, "hovering at step \(i): \(pet.frame)")
        }
        print("jumps stay below the roof: ok")

        let floor = CGRect(x: 0, y: 4, width: 1400, height: 860)
        let step = CGRect(x: 600, y: 0, width: 200, height: 34)
        for x in [CGFloat(300), 1100] {
            pet = PetPhysics(bounds: floor, x: x, facing: x < 700 ? 1 : -1)
            pet.ledge = step
            var climbed = false
            trace(&pet, 20, check: { p, _ in
                precondition(!overlap(p.frame, step.insetBy(dx: 0.5, dy: 0.5)), "walked into the ledge: \(p.frame)")
                if p.grounded, p.origin.y == step.maxY { climbed = true }
            })
            precondition(climbed, "never climbed from \(x)")
            while pet.origin.y != step.maxY || !pet.grounded { pet.step(1.0 / 30, cursor: nil) }
            pet.ledge = nil
            states = trace(&pet, 2)
            precondition(states.contains(.jump) && pet.grounded && pet.origin.y == floor.minY, "\(states)")
        }
        pet = PetPhysics(bounds: floor, x: 300, facing: 1)
        let wall = CGRect(x: 600, y: 0, width: 60, height: 400)
        pet.ledge = wall
        trace(&pet, 20, check: { p, _ in precondition(!overlap(p.frame, wall.insetBy(dx: 0.5, dy: 0.5)) && p.origin.x < 600) })
        pet = PetPhysics(bounds: floor, x: 300, facing: 1)
        let shelf = CGRect(x: 500, y: 60, width: 300, height: 20)
        pet.ledge = shelf
        states = trace(&pet, 20)
        precondition(states.allSatisfy { $0 == .walk || $0 == .turn } && pet.origin.y == floor.minY, "\(states)")
        print("climbs a selection, walks under a high one, turns at a wall, falls when it goes: ok")

        for i in 0..<40_000 {
            if i % 2_000 == 0 {
                pet = PetPhysics(bounds: floor, x: 20 + next() * 1360)
                pet.roof = 60 + next() * 140
            }
            if next() < 0.01 { pet.ledge = next() < 0.3 ? nil : CGRect(x: next() * 1400, y: next() * 120, width: 4 + next() * 400, height: 4 + next() * 160) }
            if next() < 0.03 { pet.jump() }
            if pet.grounded, next() < 0.005 { pet.bump(pet.frame.offsetBy(dx: next() < 0.5 ? -20 : 20, dy: 0)) }
            pet.step(next() < 0.05 ? Double(next()) * 0.25 : 1.0 / 30, cursor: next() < 0.5 ? nil : CGPoint(x: next() * 1400, y: next() * 120))
            precondition(inside(pet), "left the screen at step \(i): \(pet.frame)")
            precondition(pet.frame.maxY <= pet.roof + 1e-6 || pet.origin.y == floor.minY, "rose above the roof at step \(i): \(pet.frame) roof \(pet.roof)")
        }
        print("selections keep the pet on screen and below the roof: ok")

        func inBall(_ ball: BallPhysics) -> Bool {
            let f = ball.frame, b = ball.bounds
            return f.minX >= b.minX - 1e-6 && f.maxX <= b.maxX + 1e-6 && f.minY >= b.minY - 1e-6 && f.maxY <= b.maxY + 1e-6
        }
        func settle(_ ball: inout BallPhysics, _ limit: Double, ledge: CGRect? = nil) {
            var t = 0.0
            while !ball.resting {
                ball.step(1.0 / 30, cursor: nil)
                t += 1.0 / 30
                precondition(inBall(ball), "ball left the screen: \(ball.frame)")
                precondition(ball.aloft || ball.frame.maxY <= ball.roof + 1e-6, "ball above the roof: \(ball.frame)")
                precondition(t < limit, "ball never stopped: \(ball.center) v \(ball.vx), \(ball.vy)")
            }
        }

        var ball = BallPhysics(bounds: screen, x: 300)
        ball.kick(CGVector(dx: 0, dy: 600))
        var peaks: [CGFloat] = [], rising = true
        while peaks.count < 3 {
            ball.step(1.0 / 240, cursor: nil)
            if rising, ball.vy < 0 { peaks.append(ball.center.y) }
            rising = ball.vy > 0
        }
        precondition(peaks[1] < peaks[0] && peaks[2] < peaks[1] && peaks[1] > peaks[0] * 0.3, "bounces \(peaks)")
        settle(&ball, 10)
        ball.kick(CGVector(dx: 300, dy: 0))
        for _ in 0..<15 { ball.step(1.0 / 30, cursor: nil) }
        precondition(ball.vx > 0 && ball.vx < 300 && abs(ball.spin + ball.vx / BallPhysics.radius) < 1e-6, "not rolling: \(ball.vx) \(ball.spin)")
        settle(&ball, 15)
        print("ball bounces lower each time, rolls and stops: ok")

        ball = BallPhysics(bounds: room, x: 300)
        var t = 0.0
        while t < 0.4 {
            t += 1.0 / 30
            ball.step(1.0 / 30, cursor: CGPoint(x: 240 + 600 * t, y: 18))
        }
        precondition(ball.vx > 100 && ball.center.x > 300, "cursor did not kick: \(ball.vx)")
        ball = BallPhysics(bounds: screen, x: 300)
        for i in 0..<60 { ball.step(1.0 / 30, cursor: CGPoint(x: 280 + CGFloat(i), y: 16)) }
        precondition(ball.center.x == 300 && ball.resting, "a slow pointer pushed the ball")
        precondition(ball.grab(at: CGPoint(x: 300, y: 12)) && ball.held && ball.aloft)
        print("a quick pointer kicks the ball, a slow one lets you pick it up: ok")

        for _ in 0..<2_000 {
            ball = BallPhysics(bounds: room, x: 20 + next() * 1360)
            ball.roof = 60 + next() * 140
            var point = CGPoint(x: ball.center.x, y: ball.center.y)
            precondition(ball.grab(at: point))
            let angle = next() * 2 * .pi, speed = next() * 3000
            for _ in 0..<8 {
                point.x += cos(angle) * speed / 60
                point.y += sin(angle) * speed / 60
                ball.step(1.0 / 60, cursor: point)
                precondition(inBall(ball))
            }
            ball.release()
            precondition(hypot(ball.vx, ball.vy) <= PetPhysics.fling + 1e-6 && !ball.held)
            settle(&ball, 60)
            precondition(!ball.aloft)
        }
        print("2 000 thrown balls stay on screen and come to rest: ok")

        ball = BallPhysics(bounds: room, x: 700)
        ball.roof = 90
        for i in 0..<60_000 {
            if next() < 0.003 { ball.kick(CGVector(dx: (next() - 0.5) * 3000, dy: next() * 1500)) }
            if next() < 0.002 { ball.ledge = next() < 0.3 ? nil : CGRect(x: next() * 1400, y: next() * 80, width: 4 + next() * 400, height: 4 + next() * 120) }
            let point = CGPoint(x: ball.center.x + (next() - 0.5) * 200, y: next() * 100)
            ball.step(next() < 0.05 ? Double(next()) * 0.25 : 1.0 / 30, cursor: next() < 0.7 ? nil : point)
            precondition(inBall(ball), "ball left the screen at step \(i): \(ball.frame)")
            precondition(ball.frame.maxY <= 90 + 1e-6, "ball above the roof at step \(i): \(ball.frame)")
        }
        ball.ledge = nil
        settle(&ball, 30)
        print("60 000 random kicks keep the ball on screen and below the roof: ok")

        ball = BallPhysics(bounds: room, x: 700)
        ball.ledge = CGRect(x: 600, y: 0, width: 300, height: 40)
        ball.step(1.0 / 30, cursor: nil)
        settle(&ball, 5)
        precondition(abs(ball.frame.minY - 40) < 0.5 && ball.floor == 40, "ball not on the selection: \(ball.frame)")
        ball.ledge = nil
        ball.step(1.0 / 30, cursor: nil)
        settle(&ball, 5)
        precondition(ball.frame.minY == room.minY)
        print("ball rests on a selection and falls when it goes: ok")

        for facing in [CGFloat(1), -1] {
            pet = PetPhysics(bounds: room, x: 700, facing: facing)
            ball = BallPhysics(bounds: room, x: 700 + facing * 120)
            var kicked = false
            for _ in 0..<300 {
                let before = pet.frame
                pet.step(1.0 / 30, cursor: nil)
                if pet.kick(&ball) { kicked = true }
                ball.step(1.0 / 30, cursor: nil, body: (before, pet.frame))
                if kicked { break }
            }
            precondition(kicked && pet.state == .kick && ball.vx * facing > 100 && ball.vy > 0, "no kick facing \(facing)")
            states = trace(&pet, 1)
            precondition(states.last == .walk)
        }
        pet = PetPhysics(bounds: room, x: 1300, facing: 1)
        ball = BallPhysics(bounds: room, x: room.maxX - BallPhysics.radius)
        var kicks = 0
        for _ in 0..<300 {
            let before = pet.frame
            pet.step(1.0 / 30, cursor: nil)
            if pet.kick(&ball) { kicks += 1 }
            ball.step(1.0 / 30, cursor: nil, body: (before, pet.frame))
        }
        precondition(kicks == 0 && pet.facing == -1, "kicked a ball stuck at the wall")
        pet = PetPhysics(bounds: room, x: 700, facing: 1)
        precondition(pet.face(400) && pet.state == .turn && !pet.face(400))
        pet = PetPhysics(bounds: room, x: 700, facing: 1)
        ball = BallPhysics(bounds: room, x: 400)
        ball.kick(CGVector(dx: 900, dy: 0))
        var hit: CGFloat = 0
        for _ in 0..<30 {
            let before = pet.frame
            pet.step(1.0 / 30, cursor: nil)
            ball.step(1.0 / 30, cursor: nil, body: (before, pet.frame))
            if ball.impact > 0, hit == 0 { precondition(ball.vx < 0, "ball did not bounce off the pet") }
            hit = max(hit, ball.impact)
            precondition(!overlap(ball.frame.insetBy(dx: 0.5, dy: 0.5), pet.frame), "ball went through the pet")
        }
        precondition(hit > 300, "ball missed the pet: \(hit)")
        print("pet kicks the ball, turns at a stuck one, the ball bounces off the pet: ok")
    }
}
