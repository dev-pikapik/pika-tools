import SwiftUI

struct QuitCloseArt: View {
    enum Action { case quit, close }

    let action: Action
    let keys: Shortcut
    let on: Bool

    private static let size = CGSize(width: 100, height: 56)

    var body: some View {
        IllustrationRow {
            ArtLoop(durations: on ? [1.6, 0.9, 0.7] : [1.7, 0.45, 0.7]) { tick in
                let step = tick % 3
                let gone = step == 2
                let plain = ["⌘", action == .quit ? "Q" : "W"]
                let caps = on && step != 1 ? KeyCaps.caps(keys.text) : plain
                let shake = on ? tick / 3 + (step >= 1 ? 1 : 0) : 0
                Stage {
                    window([46, 60, 34], active: action == .close && gone, gone: action == .quit && gone, shake: action == .quit ? shake : 0)
                        .position(x: 120, y: 38)
                    window([54, 38, 46], active: true, gone: gone, shake: shake, locked: on)
                        .position(x: 180, y: 50)
                    HStack(spacing: 6) {
                        ForEach(caps, id: \.self) { symbol in
                            ArtKey(down: step >= 1, width: max(34, CGFloat(symbol.count) * 8 + 16)) { Text(verbatim: symbol) }
                                .transition(.asymmetric(insertion: .scale(scale: 0.5).combined(with: .opacity), removal: .opacity))
                        }
                    }
                    .position(x: 150, y: 104)
                }
                .animation(.smooth(duration: 0.35), value: step)
            }
            .id(on)
        }
    }

    private func window(_ widths: [CGFloat], active: Bool, gone: Bool, shake: Int, locked: Bool = false) -> some View {
        ArtWindow(size: Self.size, active: active) {
            VStack(alignment: .leading, spacing: 5) {
                ForEach(widths, id: \.self) { Capsule().fill(Color.primary.opacity(0.12)).frame(width: $0, height: 4) }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(10)
        }
        .overlay {
            if locked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 26, height: 26)
                    .background(Color.accentColor, in: Circle())
                    .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                    .offset(y: 6)
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
        .opacity(gone ? 0 : 1)
    }
}
