import SwiftUI

func petCount(_ a: Int, _ b: Int) -> String {
    String(localized: "\(a.formatted()) of \(b.formatted())")
}

private extension PetSlot {
    var lens: CGRect {
        switch self {
        case .head: CGRect(x: -10, y: -22, width: 20, height: 23)
        case .back: CGRect(x: -13, y: -25, width: 26, height: 26)
        default: CGRect(x: -10, y: -15, width: 20, height: 16)
        }
    }
}

private extension PetItem {
    var award: PetAward? { PetAward.all.first { $0.items.contains(self) } }
}

extension PetLook {
    var outfit: [PetSlot: PetItem] { Dictionary(items.map { ($0.slot, $0) }, uniquingKeysWith: { $1 }) }
    var rank: PetRank { items.map(\.rank).max() ?? .common }
}

struct PetThumb: View {
    let outfit: [PetSlot: PetItem]
    let lens: CGRect
    var ghost = false
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Canvas { context, size in
            let scale = min(size.width / lens.width, size.height / lens.height)
            let environment = context.environment
            var figure = context
            figure.translateBy(x: size.width / 2 - lens.midX * scale, y: size.height / 2 - lens.midY * scale)
            figure.scaleBy(x: scale, y: scale)
            let pose = PetPose(outfit: outfit)
            PetFigure.shadow(pose) { figure.fill($0, with: .color($1)) }
            PetFigure.draw(pose, night: scheme == .dark) { path, color in
                let resolved = color.resolve(in: environment)
                let grey = Double(0.3 * resolved.red + 0.59 * resolved.green + 0.11 * resolved.blue)
                figure.fill(path, with: .color(ghost ? Color(white: scheme == .dark ? grey : grey * 0.72, opacity: Double(resolved.opacity)) : color))
            }
        }
        .opacity(ghost ? 0.5 : 1)
    }
}

struct TileGrid: Layout {
    let minimum: CGFloat
    var spacing: CGFloat = 8

    private func frames(_ subviews: Subviews, width: CGFloat) -> [CGRect] {
        let columns = max(1, Int(((width + spacing) / (minimum + spacing)).rounded(.down)))
        let tile = (width - spacing * CGFloat(columns - 1)) / CGFloat(columns)
        var frames: [CGRect] = []
        var y: CGFloat = 0
        for start in stride(from: 0, to: subviews.count, by: columns) {
            let row = subviews[start..<min(start + columns, subviews.count)]
            let height = row.map { $0.sizeThatFits(ProposedViewSize(width: tile, height: nil)).height }.max() ?? 0
            for column in 0..<row.count {
                frames.append(CGRect(x: CGFloat(column) * (tile + spacing), y: y, width: tile, height: height))
            }
            y += height + spacing
        }
        return frames
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = min(proposal.width ?? minimum, 2000)
        return CGSize(width: width, height: frames(subviews, width: width).last?.maxY ?? 0)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        for (subview, frame) in zip(subviews, frames(subviews, width: bounds.width)) {
            subview.place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: ProposedViewSize(frame.size))
        }
    }
}

private struct ChipRow: Layout {
    var spacing: CGFloat = 6

    private func lines(_ sizes: [CGSize], _ width: CGFloat) -> [[Int]] {
        var lines: [[Int]] = [[]]
        var x: CGFloat = 0
        for (index, size) in sizes.enumerated() {
            if x > 0, x + size.width > width {
                lines.append([])
                x = 0
            }
            lines[lines.count - 1].append(index)
            x += size.width + spacing
        }
        return lines
    }

    private func frames(_ subviews: Subviews, width: CGFloat) -> [CGRect] {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let count = lines(sizes, width).count
        var low = sizes.map(\.width).max() ?? 0, high = width
        while high - low > 1 {
            let middle = (low + high) / 2
            if lines(sizes, middle).count > count { low = middle } else { high = middle }
        }
        var frames = [CGRect](repeating: .zero, count: sizes.count)
        var y: CGFloat = 0
        for line in lines(sizes, high) {
            let used = line.reduce(0) { $0 + sizes[$1].width } + spacing * CGFloat(line.count - 1)
            var x = max(0, (width - used) / 2)
            for index in line {
                frames[index] = CGRect(origin: CGPoint(x: x, y: y), size: sizes[index])
                x += sizes[index].width + spacing
            }
            y += (line.map { sizes[$0].height }.max() ?? 0) + spacing
        }
        return frames
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = min(proposal.width ?? 2000, 2000)
        return CGSize(width: width, height: max(0, (frames(subviews, width: width).map(\.maxY).max() ?? 0)))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        for (subview, frame) in zip(subviews, frames(subviews, width: bounds.width)) {
            subview.place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: ProposedViewSize(frame.size))
        }
    }
}

struct TileStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.smooth(duration: 0.12), value: configuration.isPressed)
    }
}

extension View {
    func tileShape() -> some View {
        let shape = RoundedRectangle(cornerRadius: 12, style: .continuous)
        return contentShape(shape).contentShape(.focusEffect, shape)
    }
}

private struct TileFrame: ViewModifier {
    let tint: Color
    var selected = false
    var locked = false
    @State private var hover = false

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: 12, style: .continuous)
        content
            .background(shape.fill(selected ? Color.accentColor.opacity(0.14) : tint.opacity(hover && !locked ? 0.16 : 0.08)))
            .overlay(shape.strokeBorder(selected ? Color.accentColor : tint.opacity(locked ? 0.28 : 0.55), lineWidth: selected ? 2 : 1))
            .tileShape()
            .onHover { hover = $0 }
    }
}

private struct Badge: View {
    let symbol: String
    let fill: Color
    let ink: Color

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 8, weight: .bold))
            .foregroundStyle(ink)
            .frame(width: 16, height: 16)
            .background(fill, in: Circle())
    }
}

struct NewTag: View {
    var body: some View {
        Text("New")
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(Color.accentColor, in: Capsule())
    }
}

private struct RankLabel: View {
    let rank: PetRank

    var body: some View {
        HStack(spacing: 4) {
            Circle().fill(rank.color).frame(width: 6, height: 6)
            Text(rank.title).font(.caption2).foregroundStyle(.secondary).lineLimit(1).minimumScaleFactor(0.7)
        }
    }
}

private struct SlotChip: View {
    let slot: PetSlot
    @Binding var selected: PetSlot
    private let progress = PetProgress.shared

    var body: some View {
        let on = selected == slot
        let fresh = PetItem.allCases.contains { $0.slot == slot && progress.fresh.contains($0.rawValue) }
        Button { selected = slot } label: {
            HStack(spacing: 5) {
                Text(slot.title).lineLimit(1)
                if fresh { Circle().fill(on ? Color.white : Color.accentColor).frame(width: 6, height: 6) }
            }
            .font(.callout.weight(.medium))
            .foregroundStyle(on ? Color.white : Color.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(on ? Color.accentColor : Color.primary.opacity(0.07), in: Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(on ? .isSelected : [])
    }
}

struct ItemTile: View {
    let item: PetItem
    let open: (PetAward) -> Void
    private let progress = PetProgress.shared

    var body: some View {
        let unlocked = progress.unlocked(item)
        let on = progress.outfit[item.slot] == item
        let award = item.award
        let fresh = progress.fresh.contains(item.rawValue)
        Button {
            if unlocked { progress.wear(item) } else if let award { open(award) }
        } label: {
            VStack(spacing: 4) {
                PetThumb(outfit: [item.slot: item], lens: item.slot.lens, ghost: !unlocked)
                    .frame(height: 52)
                Text(item.title)
                    .font(.caption)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(unlocked ? .primary : .secondary)
                Spacer(minLength: 0)
                RankLabel(rank: item.rank)
            }
            .padding(8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .modifier(TileFrame(tint: item.rank.color, selected: on, locked: !unlocked))
            .overlay(alignment: .topTrailing) {
                if on {
                    Badge(symbol: "checkmark", fill: .accentColor, ink: .white).padding(5)
                } else if !unlocked {
                    Badge(symbol: "lock.fill", fill: Color.primary.opacity(0.12), ink: .secondary).padding(5)
                }
            }
            .overlay(alignment: .topLeading) {
                if fresh { NewTag().padding(5) }
            }
        }
        .buttonStyle(TileStyle())
        .help(unlocked ? "" : award?.hint ?? "")
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.title)
        .accessibilityValue([unlocked ? nil : String(localized: "Locked"), fresh ? String(localized: "New") : nil, item.rank.title].compactMap { $0 }.joined(separator: ", "))
        .accessibilityHint(unlocked ? "" : award?.hint ?? "")
        .accessibilityAddTraits(on ? .isSelected : [])
    }
}

private struct LookCard: View {
    let look: PetLook
    private let progress = PetProgress.shared
    private static let lens = CGRect(x: -13, y: -22, width: 26, height: 23)

    var body: some View {
        let have = look.items.filter(progress.unlocked).count
        let ready = have == look.items.count
        let on = Set(progress.outfit.values) == Set(look.items)
        let progressText = String(localized: "\(have.formatted()) of \(look.items.count.formatted()) unlocked")
        Button { progress.wear(look) } label: {
            VStack(spacing: 4) {
                PetThumb(outfit: look.outfit, lens: Self.lens, ghost: !ready)
                    .frame(height: 70)
                Text(look.title)
                    .font(.callout.weight(.medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundStyle(ready ? .primary : .secondary)
                Spacer(minLength: 0)
                if ready {
                    RankLabel(rank: look.rank)
                } else {
                    HStack(spacing: 3) {
                        Image(systemName: "lock.fill")
                        Text(petCount(have, look.items.count)).lineLimit(1)
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .modifier(TileFrame(tint: look.rank.color, selected: on, locked: !ready))
            .overlay(alignment: .topTrailing) {
                if on { Badge(symbol: "checkmark", fill: .accentColor, ink: .white).padding(5) }
            }
        }
        .buttonStyle(TileStyle())
        .disabled(!ready)
        .help(ready ? "" : ([progressText] + look.items.filter { !progress.unlocked($0) }.compactMap { item in item.award.map { "\(item.title): \($0.hint)" } }).joined(separator: "\n"))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(look.title)
        .accessibilityValue(ready ? look.rank.title : progressText)
        .accessibilityAddTraits(on ? .isSelected : [])
    }
}

struct PetWardrobeSection: View {
    let open: (PetAward) -> Void
    @State private var slot = PetSlot.head
    private let progress = PetProgress.shared

    var body: some View {
        Section {
            VStack(spacing: 14) {
                ChipRow {
                    ForEach(PetSlot.allCases) { SlotChip(slot: $0, selected: $slot) }
                }
                TileGrid(minimum: 88) {
                    ForEach(PetItem.allCases.filter { $0.slot == slot }) { ItemTile(item: $0, open: open) }
                }
            }
            .padding(.vertical, 6)
        } header: {
            HStack {
                Text("Wardrobe")
                Spacer(minLength: 0)
                Text(petCount(PetItem.allCases.filter(progress.unlocked).count, PetItem.allCases.count)).foregroundStyle(.secondary)
            }
        } footer: {
            HStack {
                Spacer()
                Button("Take Everything Off", systemImage: "hanger") {
                    for item in progress.outfit.values { progress.wear(item) }
                }
                .disabled(progress.outfit.isEmpty)
            }
        }
        .settingAnchor(String(localized: "Wardrobe"))
    }
}

struct PetLooksSection: View {
    private let progress = PetProgress.shared

    var body: some View {
        let looks = PetLook.all
        Section {
            TileGrid(minimum: 104) {
                ForEach(looks) { LookCard(look: $0) }
            }
            .padding(.vertical, 6)
        } header: {
            HStack {
                Text("Looks")
                Spacer(minLength: 0)
                Text(petCount(looks.filter { $0.items.allSatisfy(progress.unlocked) }.count, looks.count)).foregroundStyle(.secondary)
            }
        }
        .settingAnchor(String(localized: "Looks"))
    }
}
