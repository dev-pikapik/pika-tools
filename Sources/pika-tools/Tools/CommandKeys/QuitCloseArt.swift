import SwiftUI

struct QuitCloseArt: View {
    enum Action { case quit, close }

    let action: Action
    let keys: Shortcut
    let on: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let durations = [1.1, 0.9, 0.8, 1.0, 1.0]
    private static let size = CGSize(width: 100, height: 56)

    var body: some View {
        IllustrationRow(loop: Self.durations) { tick in
            let step = reduceMotion ? (on ? 3 : 1) : tick % Self.durations.count
            let gone = on ? step >= 3 : step == 1 || step == 2
            let shake = on ? tick / Self.durations.count + (step >= 1 ? 1 : 0) : 0
            let caps = on && step >= 2 ? KeyCaps.caps(keys.text) : ["⌘", action == .quit ? "Q" : "W"]
            let down = on ? step == 1 || step == 3 : step == 1
            Stage {
                window([46, 60, 34], active: action == .close && gone, gone: action == .quit && gone, shake: action == .quit ? shake : 0)
                    .position(x: 120, y: 38)
                window([54, 38, 46], active: true, gone: gone, shake: shake, lock: on && (1...3).contains(step) ? step == 3 ? "lock.open.fill" : "lock.fill" : nil)
                    .position(x: 180, y: 50)
                HStack(spacing: 6) {
                    ForEach(caps, id: \.self) { symbol in
                        ArtKey(down: down, width: max(34, CGFloat(symbol.count) * 8 + 16)) { Text(verbatim: symbol) }
                            .transition(.asymmetric(insertion: .scale(scale: 0.5).combined(with: .opacity), removal: .opacity))
                    }
                }
                .position(x: 150, y: 104)
            }
            .animation(reduceMotion ? nil : .smooth(duration: 0.35), value: step)
        }
    }

    private func window(_ widths: [CGFloat], active: Bool, gone: Bool, shake: Int, lock: String? = nil) -> some View {
        ArtWindow(size: Self.size, active: active) {
            VStack(alignment: .leading, spacing: 5) {
                ForEach(widths, id: \.self) { Capsule().fill(Color.primary.opacity(0.12)).frame(width: $0, height: 4) }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(10)
        }
        .overlay {
            if let lock {
                Image(systemName: lock)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 26, height: 26)
                    .background(Color.accentColor, in: Circle())
                    .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                    .offset(y: 6)
                    .transition(.scale(scale: 0.4).combined(with: .opacity))
            }
        }
        .keyframeAnimator(initialValue: 0.0, trigger: shake) { content, x in
            content.offset(x: x)
        } keyframes: { _ in
            KeyframeTrack {
                for x in [-6.0, 5, -4, 3, 0] { LinearKeyframe(x, duration: 0.07) }
            }
        }
        .scaleEffect(gone ? 0.9 : 1)
        .opacity(gone ? (reduceMotion ? 0.4 : 0) : 1)
    }
}
