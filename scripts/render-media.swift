import AppKit
import SwiftUI

@main
@MainActor
enum RenderMedia {
    static let out = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
    static let fps = 15
    static let card = CGSize(width: 340, height: Art.height)

    static let cards: [(name: String, seconds: Double, art: AnyView)] = [
        ("keep-awake", 4.0, AnyView(KeepAwakeCard())),
        ("command-keys", 4.5, AnyView(CommandKeysArt())),
        ("compress", 6.6, AnyView(CompressArt(on: true))),
        ("convert", 8.05, AnyView(ConvertArt(on: true))),
        ("input-switch", 7.9, AnyView(InputSwitchArt(on: true))),
        ("quit-on-close", 4.5, AnyView(QuitOnCloseArt(on: true))),
        ("window-zoom", 5.95, AnyView(WindowZoomArt(on: true))),
        ("dock-hide", 5.1, AnyView(DockHideArt(on: true))),
        ("new-file", 7.1, AnyView(NewFileArt(on: true))),
        ("finder-cut", 3.7, AnyView(FinderCutArt(on: true))),
        ("finder-open", 4.7, AnyView(FinderOpenArt(on: true))),
        ("finder-delete", 3.2, AnyView(FinderDeleteArt(on: true))),
        ("game-mode", 8.0, AnyView(GameModeArt(on: true))),
        ("speed-test", 5.4, AnyView(SpeedTestArt())),
        ("side-buttons", 5.1, AnyView(SideButtonsArt(on: true, swapped: false))),
        ("wheel-lines", 3.2, AnyView(ScrollStepArt(on: true, distance: 30))),
        ("wheel-direction", 3.0, AnyView(ScrollDirectionArt(trackpadNatural: true, mouseNatural: false))),
        ("linear-pointer", 4.0, AnyView(PointerArt(on: true))),
        ("key-repeat", 4.55, AnyView(KeyRepeatArt(on: true))),
        ("home-end", 5.0, AnyView(HomeEndArt(on: true))),
        ("animations", 6.2, AnyView(AnimationsArt(values: AnimationSpeed.preset(0.5)))),
        ("leftover-permissions", 3.8, AnyView(LeftoversArt())),
        ("whats-new/1.23.2/game-shortcuts", 4.2, AnyView(SwitchRowsArt(rows: [(AnyView(KeyCaps(keys: ["⌘Q"])), 64), (AnyView(KeyCaps(keys: ["⌘W"])), 52), (AnyView(KeyCaps(keys: ["⌘Tab", "⌘`"])), 40)]))),
        ("whats-new/1.25.0/game-pictures", 4.2, AnyView(SwitchRowsArt(rows: [(AnyView(GameRuleFrame(rule: .commandQ, story: .still(on: false), height: 32)), 64), (AnyView(GameRuleFrame(rule: .spotlight, story: .still(on: false), height: 32)), 52), (AnyView(GameRuleFrame(rule: .missionControl, story: .still(on: false), height: 32)), 72)], height: 36))),
        ("whats-new/1.26.1/game-previews", 6.2, AnyView(IllustrationRow { HStack(spacing: 14) { GameRuleArt(rule: .spotlight, keys: ["⌘Space"], height: 96); GameRuleArt(rule: .showDesktop, keys: ["F11"], height: 96) } })),
        ("whats-new/1.25.1/dock-games", 3.85, AnyView(DockShelfArt())),
    ]

    static func main() {
        NSApplication.shared.setActivationPolicy(.accessory)
        Task {
            let only = Set(CommandLine.arguments.dropFirst(3).filter { !$0.hasPrefix("-") && !$0.hasPrefix("(") })
            if CommandLine.arguments[2] == "cards" {
                for card in cards where only.isEmpty || only.contains(card.name) {
                    for dark in [false, true] { await render(card.name, card.seconds, card.art, dark: dark) }
                }
            } else {
                await settings(CommandLine.arguments[2])
            }
            exit(0)
        }
        NSApplication.shared.run()
    }

    static func render(_ name: String, _ seconds: Double, _ art: AnyView, dark: Bool) async {
        let page = dark ? Color(red: 13 / 255, green: 17 / 255, blue: 23 / 255) : .white
        let host = NSHostingView(rootView: art
            .background(RoundedRectangle(cornerRadius: Art.radius, style: .continuous).fill(page))
            .frame(width: card.width, height: card.height))
        let window = NSWindow(contentRect: CGRect(origin: CGPoint(x: -8000, y: -8000), size: card), styleMask: .borderless, backing: .buffered, defer: false)
        window.appearance = NSAppearance(named: dark ? .darkAqua : .aqua)
        window.backgroundColor = .clear
        window.isOpaque = false
        window.contentView = host
        window.orderFrontRegardless()
        let start = ContinuousClock.now
        var frames: [[UInt32]] = []
        for index in 0..<Int((seconds * Double(fps)).rounded()) {
            try? await Task.sleep(until: start + .seconds(seconds + Double(index) / Double(fps)), clock: .continuous)
            frames.append(pixels(host))
        }
        window.orderOut(nil)
        let url = out.appendingPathComponent("\(name)-\(dark ? "dark" : "light").png")
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? APNG.encode(frames, width: Int(card.width) * 2, height: Int(card.height) * 2, fps: fps).write(to: url)
        print(url.lastPathComponent, frames.count)
    }

    static func pixels(_ view: NSView) -> [UInt32] {
        let size = view.bounds.size
        let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size.width) * 2, pixelsHigh: Int(size.height) * 2, bitsPerSample: 16, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
        rep.size = size
        view.cacheDisplay(in: view.bounds, to: rep)
        return APNG.bytes(rep.cgImage!)
    }

    static func settings(_ language: String) async {
        for dark in [false, true] {
            NSApp.appearance = NSAppearance(named: dark ? .darkAqua : .aqua)
            SettingsWindow.show(.keyboard)
            NSApp.activate(ignoringOtherApps: true)
            guard let window = SettingsWindow.window else { return }
            try? await Task.sleep(for: .seconds(2))
            let name = "settings-\(language)-\(dark ? "dark" : "light").png"
            let capture = Process()
            capture.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
            capture.arguments = ["-x", "-o", "-l", String(window.windowNumber), out.appendingPathComponent(name).path]
            try? capture.run()
            capture.waitUntilExit()
            print(name)
        }
    }
}

private struct KeepAwakeCard: View {
    @State private var tick = 0

    var body: some View {
        KeepAwakeScene(on: tick % 2 == 1, bright: true, closed: false, hasLid: true, remaining: nil)
            .loop($tick, [1.4, 2.6])
    }
}

private struct CommandKeysArt: View {
    @State private var tick = 0

    var body: some View {
        let step = tick % 5
        let closed = step >= 3
        IllustrationRow {
            Stage {
                ArtWindow {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach([54, 38, 46], id: \.self) { Capsule().fill(Color.primary.opacity(0.12)).frame(width: CGFloat($0), height: 4) }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(10)
                }
                .keyframeAnimator(initialValue: 0.0, trigger: tick / 5 + (step >= 1 ? 1 : 0)) { content, x in
                    content.offset(x: x)
                } keyframes: { _ in
                    KeyframeTrack {
                        for x in [-6.0, 5, -4, 3, 0] { LinearKeyframe(x, duration: 0.07) }
                    }
                }
                .scaleEffect(closed ? 0.9 : 1)
                .opacity(closed ? 0 : 1)
                .position(x: 150, y: 46)
                HStack(spacing: 6) {
                    ArtKey(down: step == 3, width: 40) { Text(verbatim: "⇧") }
                    ArtKey(down: step == 1 || step == 3) { Text(verbatim: "⌘") }
                    ArtKey(down: step == 1 || step == 3) { Text(verbatim: "Q") }
                }
                .position(x: 150, y: 104)
            }
            .animation(.smooth(duration: 0.3), value: step)
        }
        .loop($tick, [0.9, 0.9, 0.5, 1.0, 1.2])
    }
}

private struct DockShelfArt: View {
    @State private var tick = 0

    private static let colors: [Color] = [.teal, .orange, .purple, .pink]

    var body: some View {
        let step = tick % 4
        IllustrationRow {
            Stage {
                HStack(spacing: 14) {
                    ForEach(Self.colors.indices, id: \.self) { index in
                        VStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 9, style: .continuous)
                                .fill(LinearGradient(colors: [Self.colors[index], Self.colors[index].opacity(0.65)], startPoint: .top, endPoint: .bottom))
                                .frame(width: 40, height: 40)
                                .overlay {
                                    if index == 2 { Image(systemName: "gamecontroller.fill").font(.system(size: 18)).foregroundStyle(.white) }
                                }
                                .overlay(alignment: .bottomTrailing) {
                                    if index == 2 && step == 3 {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 17, weight: .semibold))
                                            .symbolRenderingMode(.palette)
                                            .foregroundStyle(.white, Color.accentColor)
                                            .offset(x: 4, y: 4)
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                }
                                .scaleEffect(index == 2 && step == 2 ? 0.9 : 1)
                            Capsule().fill(Color.primary.opacity(0.18)).frame(width: 28, height: 4)
                        }
                    }
                }
                .padding(14)
                .background(.fill.quaternary, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .position(x: 150, y: 64)
                ArtCursor(pressed: step == 2)
                    .cursor(at: step == 0 ? CGPoint(x: 238, y: 108) : CGPoint(x: 168, y: 52))
            }
            .animation(.smooth(duration: 0.4), value: step)
        }
        .loop($tick, [1.2, 1.1, 0.15, 1.4])
    }
}

private struct SwitchRowsArt: View {
    let rows: [(lead: AnyView, line: CGFloat)]
    var height: CGFloat = 32
    @State private var tick = 0

    var body: some View {
        let step = tick % 4
        let shape = RoundedRectangle(cornerRadius: 8, style: .continuous)
        IllustrationRow {
            VStack(spacing: 0) {
                ForEach(rows.indices, id: \.self) { index in
                    HStack(spacing: 10) {
                        rows[index].lead
                        Capsule().fill(Color.primary.opacity(0.12)).frame(width: rows[index].line, height: 4)
                        Spacer(minLength: 0)
                        ArtSwitch(on: step != index + 1)
                    }
                    .padding(.horizontal, 12)
                    .frame(height: height)
                }
            }
            .frame(width: 252)
            .background(Color(nsColor: .controlBackgroundColor), in: shape)
            .overlay(shape.strokeBorder(Color.primary.opacity(0.1), lineWidth: 0.5))
            .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
            .animation(.smooth(duration: 0.3), value: step)
        }
        .loop($tick, [1.2, 1.0, 1.0, 1.0])
    }
}

private struct ArtSwitch: View {
    let on: Bool

    var body: some View {
        Capsule()
            .fill(on ? Color.accentColor : Color.primary.opacity(0.16))
            .frame(width: 26, height: 15)
            .overlay {
                Circle()
                    .fill(.white)
                    .frame(width: 13, height: 13)
                    .shadow(color: .black.opacity(0.2), radius: 0.5, y: 0.5)
                    .offset(x: on ? 5.5 : -5.5)
            }
    }
}

private struct SpeedTestArt: View {
    @State private var tick = 0

    private static let speeds: [(Double?, Double?)] = [(nil, nil), (184, nil), (436, nil), (512, 46), (512, 98)]

    var body: some View {
        let step = tick % Self.speeds.count
        let (down, up) = Self.speeds[step]
        IllustrationRow {
            HStack(spacing: 0) {
                number("arrow.down", down, active: step == 1 || step == 2)
                Rectangle().fill(Color.primary.opacity(0.12)).frame(width: 0.5, height: 56)
                number("arrow.up", up, active: step == 3)
            }
            .frame(width: 260)
            .animation(.snappy, value: step)
        }
        .loop($tick, [1.0, 0.8, 0.8, 0.8, 2.0])
    }

    private func number(_ symbol: String, _ value: Double?, active: Bool) -> some View {
        VStack(spacing: 2) {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(active ? Color.accentColor : .secondary)
            Text(verbatim: value.map(SpeedTest.format) ?? "–")
                .font(.system(size: 36, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(value == nil ? .tertiary : .primary)
                .contentTransition(.numericText(value: value ?? 0))
        }
        .frame(maxWidth: .infinity)
    }
}

enum APNG {
    private static let table: [UInt32] = (0..<256).map { n in
        (0..<8).reduce(UInt32(n)) { c, _ in c & 1 == 1 ? 0xEDB8_8320 ^ (c >> 1) : c >> 1 }
    }

    static func bytes(_ image: CGImage) -> [UInt32] {
        var data = [UInt32](repeating: 0, count: image.width * image.height)
        let context = CGContext(data: &data, width: image.width, height: image.height, bitsPerComponent: 8, bytesPerRow: image.width * 4,
                                space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        return data
    }

    static func encode(_ frames: [[UInt32]], width: Int, height: Int, fps: Int) throws -> Data {
        let palette = quantize(frames)
        let indexed = map(frames, to: palette, width: width)
        var canvas = indexed[0]
        var parts: [(x: Int, y: Int, w: Int, h: Int, pixels: [UInt8], over: Bool, length: Int)] = [(0, 0, width, height, canvas, false, 1)]
        for frame in indexed.dropFirst() {
            var box = (minX: width, minY: height, maxX: -1, maxY: -1)
            for i in 0..<frame.count where frame[i] != canvas[i] {
                box = (min(box.minX, i % width), min(box.minY, i / width), max(box.maxX, i % width), max(box.maxY, i / width))
            }
            if box.maxX < 0 {
                parts[parts.count - 1].length += 1
                continue
            }
            let w = box.maxX - box.minX + 1, h = box.maxY - box.minY + 1
            var sub = [UInt8](repeating: 0, count: w * h)
            var over = true
            for y in 0..<h {
                for x in 0..<w {
                    let i = (box.minY + y) * width + box.minX + x
                    sub[y * w + x] = frame[i]
                    if frame[i] != canvas[i] {
                        if palette[Int(frame[i])] >> 24 < 255 { over = false }
                    } else {
                        sub[y * w + x] = 0
                    }
                    canvas[i] = frame[i]
                }
            }
            if !over {
                for y in 0..<h { sub.replaceSubrange(y * w..<(y + 1) * w, with: frame[(box.minY + y) * width + box.minX..<(box.minY + y) * width + box.minX + w]) }
            }
            parts.append((box.minX, box.minY, w, h, sub, over, 1))
        }

        var out: [UInt8] = [137, 80, 78, 71, 13, 10, 26, 10]
        var sequence: UInt32 = 0
        func be(_ value: some FixedWidthInteger) -> [UInt8] { withUnsafeBytes(of: value.bigEndian) { Array($0) } }
        func chunk(_ type: String, _ body: [UInt8]) {
            let typed = Array(type.utf8) + body
            out += be(UInt32(body.count)) + typed + be(~typed.reduce(~UInt32(0)) { table[Int(($0 ^ UInt32($1)) & 0xFF)] ^ ($0 >> 8) })
        }
        chunk("IHDR", be(UInt32(width)) + be(UInt32(height)) + [8, 3, 0, 0, 0])
        chunk("acTL", be(UInt32(parts.count)) + be(UInt32(0)))
        chunk("PLTE", palette.flatMap { color in
            let alpha = color >> 24
            return [0, 8, 16].map { UInt8(alpha == 0 ? 0 : min(255, (color >> $0 & 0xFF) * 255 / alpha)) }
        })
        chunk("tRNS", palette.map { UInt8($0 >> 24) })
        for (index, part) in parts.enumerated() {
            chunk("fcTL", be(sequence) + be(UInt32(part.w)) + be(UInt32(part.h)) + be(UInt32(part.x)) + be(UInt32(part.y))
                + be(UInt16(part.length)) + be(UInt16(fps)) + [0, part.over ? 1 : 0])
            sequence += 1
            let data = try zlib((0..<part.h).flatMap { [0] + part.pixels[$0 * part.w..<($0 + 1) * part.w] })
            if index == 0 {
                chunk("IDAT", data)
            } else {
                chunk("fdAT", be(sequence) + data)
                sequence += 1
            }
        }
        chunk("IEND", [])
        return Data(out)
    }

    private static func quantize(_ frames: [[UInt32]]) -> [UInt32] {
        var counts: [UInt32: Int] = [:]
        for frame in frames { for color in frame where color >> 24 > 0 { counts[color, default: 0] += 1 } }
        var colors = counts.map { (color: $0.key, count: $0.value) }
        var boxes = [0..<colors.count]
        while boxes.count < 255 {
            var best: (score: Int, box: Int, shift: UInt32) = (0, -1, 0)
            for (index, box) in boxes.enumerated() where box.count > 1 {
                let weight = colors[box].reduce(0) { $0 + $1.count }
                for shift: UInt32 in [0, 8, 16, 24] {
                    let values = colors[box].map { $0.color >> shift & 0xFF }
                    let score = Int(values.max()! - values.min()!) * Int(Double(weight).squareRoot())
                    if score > best.score { best = (score, index, shift) }
                }
            }
            guard best.box >= 0 else { break }
            let box = boxes[best.box]
            colors[box].sort { $0.color >> best.shift & 0xFF < $1.color >> best.shift & 0xFF }
            let half = colors[box].reduce(0) { $0 + $1.count } / 2
            var split = box.lowerBound, total = 0
            while split < box.upperBound - 1, total + colors[split].count <= half || split == box.lowerBound {
                total += colors[split].count
                split += 1
            }
            boxes[best.box] = box.lowerBound..<split
            boxes.append(split..<box.upperBound)
        }
        let palette: [UInt32] = [0] + boxes.map { box in
            let weight = colors[box].reduce(0) { $0 + $1.count }
            return [0, 8, 16, 24].reduce(UInt32(0)) { color, shift in
                color | UInt32((colors[box].reduce(0) { $0 + Int($1.color >> UInt32(shift) & 0xFF) * $1.count } + weight / 2) / weight) << UInt32(shift)
            }
        }
        return palette
    }

    private static let bayer = [0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5]

    private static func map(_ frames: [[UInt32]], to palette: [UInt32], width: Int) -> [[UInt8]] {
        var lookup: [UInt64: UInt8] = [:]
        func nearest(_ color: UInt32) -> UInt8 {
            UInt8(palette.indices.dropFirst().min { distance(palette[$0], color) < distance(palette[$1], color) }!)
        }
        return frames.map { frame in
            frame.indices.map { i in
                let color = frame[i]
                guard color >> 24 > 0 else { return 0 }
                let cell = bayer[(i / width & 3) * 4 + i % width & 3]
                if let index = lookup[UInt64(color) << 5 | UInt64(cell)] ?? lookup[UInt64(color) << 5 | 16] { return index }
                let exact = nearest(color)
                if color >> 24 < 255 || distance(palette[Int(exact)], color) <= 27 {
                    lookup[UInt64(color) << 5 | 16] = exact
                    return exact
                }
                let offset = (cell * 2 - 15) * 2 / 5
                let index = nearest([0, 8, 16].reduce(color & 0xFF00_0000) { sum, shift in
                    sum | UInt32(max(0, min(255, Int(color >> UInt32(shift) & 0xFF) + offset))) << UInt32(shift)
                })
                lookup[UInt64(color) << 5 | UInt64(cell)] = index
                return index
            }
        }
    }

    private static func distance(_ a: UInt32, _ b: UInt32) -> Int {
        [0, 8, 16, 24].reduce(0) { sum, shift in
            let d = Int(a >> UInt32(shift) & 0xFF) - Int(b >> UInt32(shift) & 0xFF)
            return sum + d * d
        }
    }

    private static func zlib(_ raw: [UInt8]) throws -> [UInt8] {
        let deflated = try (Data(raw) as NSData).compressed(using: .zlib) as Data
        var a: UInt32 = 1, b: UInt32 = 0
        for byte in raw {
            a = (a + UInt32(byte)) % 65521
            b = (b + a) % 65521
        }
        return [0x78, 0x9C] + deflated + withUnsafeBytes(of: (b << 16 | a).bigEndian) { Array($0) }
    }
}
