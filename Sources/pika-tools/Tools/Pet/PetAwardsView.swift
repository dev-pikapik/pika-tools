import SwiftUI

private extension PetAward.Kind {
    var enamel: [Color] {
        switch self {
        case .walk: [Color(red: 0.42, green: 0.84, blue: 0.56), Color(red: 0.10, green: 0.56, blue: 0.36)]
        case .play: [Color(red: 1.00, green: 0.70, blue: 0.34), Color(red: 0.92, green: 0.38, blue: 0.14)]
        case .friend: [Color(red: 1.00, green: 0.56, blue: 0.70), Color(red: 0.84, green: 0.22, blue: 0.44)]
        case .time: [Color(red: 0.50, green: 0.66, blue: 1.00), Color(red: 0.22, green: 0.32, blue: 0.84)]
        case .legend: [Color(red: 0.76, green: 0.56, blue: 1.00), Color(red: 0.46, green: 0.22, blue: 0.80)]
        }
    }
}

struct MedalShape: Shape {
    let kind: PetAward.Kind
    var inset: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let r = rect.insetBy(dx: inset, dy: inset)
        let centre = CGPoint(x: r.midX, y: r.midY), radius = min(r.width, r.height) / 2
        switch kind {
        case .walk:
            return Path(ellipseIn: r)
        case .play:
            return Self.polar(centre, radius, steps: 240) { _, angle in 0.94 + 0.06 * cos(14 * (angle + .pi / 2)) }
        case .friend:
            return Self.shield(r)
        case .time:
            let corners = (0..<6).map { k -> CGPoint in
                let angle = Double(k) * .pi / 3 - .pi / 2
                return CGPoint(x: centre.x + cos(angle) * radius, y: centre.y + sin(angle) * radius)
            }
            var path = Path()
            path.move(to: CGPoint(x: (corners[5].x + corners[0].x) / 2, y: (corners[5].y + corners[0].y) / 2))
            for k in 0..<6 { path.addArc(tangent1End: corners[k], tangent2End: corners[(k + 1) % 6], radius: radius * 0.16) }
            path.closeSubpath()
            return path
        case .legend:
            return Self.polar(centre, radius, steps: 24) { index, _ in index.isMultiple(of: 2) ? 1 : 0.86 }
        }
    }

    private static func polar(_ centre: CGPoint, _ radius: CGFloat, steps: Int, _ factor: (Int, Double) -> Double) -> Path {
        var path = Path()
        for k in 0..<steps {
            let angle = Double(k) / Double(steps) * 2 * .pi - .pi / 2
            let r = radius * factor(k, angle)
            let point = CGPoint(x: centre.x + cos(angle) * r, y: centre.y + sin(angle) * r)
            if k == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }

    private static func shield(_ r: CGRect) -> Path {
        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: r.minX + x * r.width, y: r.minY + y * r.height) }
        var path = Path()
        path.move(to: point(0.5, 0))
        path.addCurve(to: point(0.94, 0.14), control1: point(0.66, 0.10), control2: point(0.80, 0.14))
        path.addLine(to: point(0.94, 0.48))
        path.addCurve(to: point(0.5, 1), control1: point(0.94, 0.76), control2: point(0.72, 0.90))
        path.addCurve(to: point(0.06, 0.48), control1: point(0.28, 0.90), control2: point(0.06, 0.76))
        path.addLine(to: point(0.06, 0.14))
        path.addCurve(to: point(0.5, 0), control1: point(0.20, 0.14), control2: point(0.34, 0.10))
        path.closeSubpath()
        return path
    }
}

struct Medal: View {
    let award: PetAward
    var size: CGFloat
    var earned = true
    var fraction = 0.0
    @Environment(\.colorScheme) private var scheme

    private static let gold = Gradient(stops: [
        .init(color: Color(red: 1.00, green: 0.93, blue: 0.62), location: 0),
        .init(color: Color(red: 0.90, green: 0.69, blue: 0.27), location: 0.16),
        .init(color: Color(red: 0.62, green: 0.42, blue: 0.13), location: 0.34),
        .init(color: Color(red: 0.98, green: 0.84, blue: 0.47), location: 0.52),
        .init(color: Color(red: 0.76, green: 0.54, blue: 0.19), location: 0.72),
        .init(color: Color(red: 1.00, green: 0.93, blue: 0.62), location: 1),
    ])

    var body: some View {
        let kind = award.kind
        let margin = size * 0.08, rim = size * 0.085, ring = size * 0.04
        let dark = scheme == .dark
        ZStack {
            Canvas { context, canvas in
                let whole = CGRect(origin: .zero, size: canvas)
                let bounds = whole.insetBy(dx: margin, dy: margin)
                let outline = MedalShape(kind: kind).path(in: bounds)
                let face = MedalShape(kind: kind, inset: rim).path(in: bounds)
                if earned {
                    context.fill(outline, with: .conicGradient(Self.gold, center: CGPoint(x: whole.midX, y: whole.midY), angle: .degrees(-35)))
                    context.stroke(outline, with: .color(Color(red: 0.36, green: 0.22, blue: 0.04).opacity(0.5)), lineWidth: 0.6)
                    context.fill(
                        MedalShape(kind: kind, inset: rim - size * 0.012).path(in: bounds),
                        with: .linearGradient(Gradient(colors: [.black.opacity(0.4), .white.opacity(0.6)]), startPoint: CGPoint(x: whole.midX, y: bounds.minY), endPoint: CGPoint(x: whole.midX, y: bounds.maxY))
                    )
                    let enamel = MedalShape(kind: kind, inset: rim + size * 0.008).path(in: bounds)
                    context.fill(enamel, with: .linearGradient(Gradient(colors: kind.enamel), startPoint: CGPoint(x: whole.midX, y: bounds.minY), endPoint: CGPoint(x: whole.midX, y: bounds.maxY)))
                    var glass = context
                    glass.clip(to: enamel)
                    glass.fill(
                        Path(ellipseIn: CGRect(x: bounds.minX - bounds.width * 0.2, y: bounds.minY - bounds.height * 0.52, width: bounds.width * 1.4, height: bounds.height * 1.04)),
                        with: .linearGradient(Gradient(colors: [.white.opacity(0.42), .white.opacity(0.05)]), startPoint: CGPoint(x: whole.midX, y: bounds.minY), endPoint: CGPoint(x: whole.midX, y: bounds.minY + bounds.height * 0.52))
                    )
                } else {
                    context.fill(outline, with: .linearGradient(Gradient(colors: dark ? [Color(white: 0.34), Color(white: 0.22)] : [Color(white: 0.90), Color(white: 0.76)]), startPoint: CGPoint(x: whole.midX, y: bounds.minY), endPoint: CGPoint(x: whole.midX, y: bounds.maxY)))
                    context.fill(face, with: .color(dark ? Color(white: 0.16) : Color(white: 0.95)))
                    let track = Path(ellipseIn: whole.insetBy(dx: ring / 2, dy: ring / 2))
                    context.stroke(track, with: .color(Color.secondary.opacity(0.22)), lineWidth: ring)
                    if fraction > 0 {
                        var arc = Path()
                        arc.addArc(center: CGPoint(x: whole.midX, y: whole.midY), radius: whole.width / 2 - ring / 2, startAngle: .degrees(-90), endAngle: .degrees(-90 + 360 * fraction), clockwise: false)
                        context.stroke(arc, with: .color(kind.enamel[1]), style: StrokeStyle(lineWidth: ring, lineCap: .round))
                    }
                }
            }
            Image(systemName: award.symbol)
                .font(.system(size: size * 0.31, weight: .bold))
                .foregroundStyle(earned ? AnyShapeStyle(LinearGradient(colors: [.white, Color(white: 0.88)], startPoint: .top, endPoint: .bottom)) : AnyShapeStyle(Color.secondary.opacity(0.7)))
                .shadow(color: earned ? .black.opacity(0.35) : .white.opacity(dark ? 0 : 0.7), radius: 0.5, y: size * 0.012)
                .offset(y: kind == .friend ? -size * 0.02 : 0)
        }
        .frame(width: size, height: size)
    }
}

private struct AwardCell: View {
    let award: PetAward
    let open: (PetAward) -> Void
    private let progress = PetProgress.shared
    @State private var hover = false

    var body: some View {
        let earned = progress.earned(award)
        let fresh = progress.fresh.contains(award.rawValue)
        let status = progress.progress(award)
        Button { open(award) } label: {
            VStack(spacing: 6) {
                Medal(award: award, size: 62, earned: earned, fraction: Double(status.current) / Double(status.goal))
                    .scaleEffect(hover ? 1.08 : 1)
                    .overlay(alignment: .topTrailing) {
                        if fresh { NewTag().offset(x: 6, y: -2) }
                    }
                Text(award.title)
                    .font(.caption)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(earned ? .primary : .secondary)
                Spacer(minLength: 0)
            }
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .tileShape()
        }
        .buttonStyle(TileStyle())
        .onHover { hover = $0 }
        .animation(.smooth(duration: 0.18), value: hover)
        .help(award.hint)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(award.title)
        .accessibilityValue(earned ? (fresh ? String(localized: "New") : "") : "\(String(localized: "Locked")), \(petCount(status.current, status.goal))")
        .accessibilityHint(award.hint)
    }
}

private struct MedalBar: ProgressViewStyle {
    let tint: Color

    func makeBody(configuration: Configuration) -> some View {
        Capsule()
            .fill(Color.primary.opacity(0.12))
            .frame(height: 6)
            .overlay(alignment: .leading) {
                GeometryReader { Capsule().fill(tint).frame(width: $0.size.width * (configuration.fractionCompleted ?? 0)) }
            }
    }
}

struct AwardSheet: View {
    let award: PetAward
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var tilt = CGSize.zero
    private let progress = PetProgress.shared
    private static let stage = CGSize(width: 320, height: 220)

    var body: some View {
        let earned = progress.earnedAt[award.rawValue]
        let status = progress.progress(award)
        let tint = award.kind.enamel[1]
        let glint = 0.5 + (tilt.width + tilt.height) / 4
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(RadialGradient(colors: [tint.opacity(0.30), tint.opacity(0.04)], center: .center, startRadius: 0, endRadius: 190))
                Medal(award: award, size: 176, earned: earned != nil, fraction: Double(status.current) / Double(status.goal))
                    .overlay {
                        if earned != nil {
                            MedalShape(kind: award.kind, inset: 176 * 0.16)
                                .fill(LinearGradient(
                                    stops: [.init(color: .white.opacity(0), location: 0), .init(color: .white.opacity(0.4), location: 0.5), .init(color: .white.opacity(0), location: 1)],
                                    startPoint: UnitPoint(x: -0.5 + glint, y: -0.5 + glint),
                                    endPoint: UnitPoint(x: 0.5 + glint, y: 0.5 + glint)
                                ))
                                .allowsHitTesting(false)
                        }
                    }
                    .rotation3DEffect(.degrees(Double(-tilt.height) * 16), axis: (x: 1, y: 0, z: 0), perspective: 0.5)
                    .rotation3DEffect(.degrees(Double(tilt.width) * 16), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
                    .shadow(color: .black.opacity(0.28), radius: 14, x: -tilt.width * 8, y: 10 - tilt.height * 4)
            }
            .frame(width: Self.stage.width, height: Self.stage.height)
            .contentShape(Rectangle())
            .onContinuousHover { phase in
                switch phase {
                case .active(let point) where !reduceMotion:
                    tilt = CGSize(
                        width: max(-1, min(1, (point.x - Self.stage.width / 2) / (Self.stage.width / 2))),
                        height: max(-1, min(1, (point.y - Self.stage.height / 2) / (Self.stage.height / 2)))
                    )
                default:
                    tilt = .zero
                }
            }
            .animation(.smooth(duration: 0.25), value: tilt)
            VStack(spacing: 4) {
                Text(award.title).font(.title2.weight(.semibold))
                Text(award.hint).foregroundStyle(.secondary)
                if let earned {
                    Text("Earned on \(earned.formatted(date: .long, time: .omitted))")
                        .font(.callout.weight(.medium))
                        .foregroundStyle(tint)
                }
            }
            .multilineTextAlignment(.center)
            if earned == nil {
                VStack(spacing: 4) {
                    ProgressView(value: Double(status.current), total: Double(status.goal)).progressViewStyle(MedalBar(tint: tint))
                    Text(petCount(status.current, status.goal)).font(.caption).foregroundStyle(.secondary)
                }
            }
            if !award.items.isEmpty {
                VStack(spacing: 8) {
                    Text("Unlocks").font(.subheadline.weight(.medium)).foregroundStyle(.secondary)
                    HStack(spacing: 8) {
                        ForEach(award.items) { ItemTile(item: $0, open: { _ in }).frame(width: 104, height: 112) }
                    }
                }
            }
            HStack {
                Spacer()
                Button("Done") { dismiss() }.keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 380)
    }
}

struct PetAwardsSection: View {
    let open: (PetAward) -> Void
    @State private var erasing = false
    private let progress = PetProgress.shared

    var body: some View {
        Section {
            TileGrid(minimum: 84) {
                ForEach(PetAward.all) { AwardCell(award: $0, open: open) }
            }
            .padding(.vertical, 6)
        } header: {
            HStack {
                Text("Awards")
                Spacer(minLength: 0)
                Text(petCount(PetAward.all.filter(progress.earned).count, PetAward.all.count)).foregroundStyle(.secondary)
            }
        } footer: {
            let privacy = Text("Awards are counted only on this Mac. Nothing is sent anywhere.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    privacy
                    Spacer(minLength: 0)
                    erase
                }
                VStack(alignment: .trailing, spacing: 8) {
                    privacy.frame(maxWidth: .infinity, alignment: .leading)
                    erase
                }
            }
        }
        .settingAnchor(String(localized: "Awards"))
    }

    private var erase: some View {
        Button("Erase Progress…", systemImage: "trash") { erasing = true }
            .lineLimit(1)
            .fixedSize()
            .settingAnchor(String(localized: "Erase Progress…"))
            .confirmationDialog("Erase all progress?", isPresented: $erasing, titleVisibility: .visible) {
                Button("Erase Progress", role: .destructive) { progress.erase() }
            } message: {
                Text("Your awards, unlocked clothes and counters are erased from this Mac. This can’t be undone.")
            }
    }
}
