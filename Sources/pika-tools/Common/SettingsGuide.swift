import AppKit
import SwiftUI

enum GuidePane {
    case desktop, mouse, keyboard, displays, accessibility, privacy, general

    fileprivate var bundles: [String] {
        switch self {
        case .desktop: ["DesktopSettings"]
        case .mouse: ["MouseExtension"]
        case .keyboard: ["KeyboardSettings"]
        case .displays: ["DisplaysExt"]
        case .accessibility: ["AccessibilitySettingsExtension", "AccessibilitySettingsWidgetExtension"]
        case .privacy: ["SecurityPrivacyExtension"]
        case .general: ["GeneralSettings", "LoginItems"]
        }
    }

    fileprivate var symbol: String {
        switch self {
        case .desktop: "dock.rectangle"
        case .mouse: "computermouse.fill"
        case .keyboard: "keyboard.fill"
        case .displays: "sun.max.fill"
        case .accessibility: "accessibility"
        case .privacy: "hand.raised.fill"
        case .general: "gearshape.fill"
        }
    }

    fileprivate var tint: Color {
        switch self {
        case .desktop: Color(white: 0.2)
        case .mouse, .keyboard, .general: Color(white: 0.55)
        case .displays, .accessibility, .privacy: Color(red: 0.1, green: 0.45, blue: 0.98)
        }
    }

    fileprivate var slot: Int {
        switch self {
        case .general: 0
        case .displays: 1
        case .accessibility: 2
        case .desktop, .mouse, .keyboard: 3
        case .privacy: 4
        }
    }
}

enum GuideStep {
    case toggle(String, on: Bool)
    case checkbox(String, option: String, on: Bool)
    case popup(String?, from: String, to: String)
    case button(String)
    case page(String)
    case info(String)
    case app(on: Bool)
    case appInfo
    case select(String)
    case display

    fileprivate var label: String? {
        switch self {
        case .toggle(let text, _), .checkbox(let text, _, _), .page(let text), .info(let text), .select(let text): text
        case .popup(let text, _, _): text
        case .button, .app, .appInfo, .display: nil
        }
    }

    fileprivate var opens: GuideLayer.Kind? {
        switch self {
        case .page: .page
        case .button, .info, .appInfo: .sheet
        default: nil
        }
    }
}

struct SettingsGuide: View {
    let pane: GuidePane
    let steps: [GuideStep]

    var body: some View {
        IllustrationRow(loop: [0.8] + (0...steps.count).flatMap { _ in [1.1, 0.35] } + [2.2]) { tick in
            SettingsGuideScene(pane: pane, steps: steps, tick: tick)
        }
    }
}

extension SettingsGuide {
    static let reduceMotionLink: URL = {
        let terms = Bundle(path: "/System/Library/ExtensionKit/Extensions/AccessibilitySettingsExtension.appex")?
            .url(forResource: "UniversalAccess", withExtension: "searchTerms").flatMap { NSDictionary(contentsOf: $0) }
        return URL(string: "x-apple.systempreferences:com.apple.preference.universalaccess?" + (terms?["AX_REDUCE_MOTION"] == nil ? "Seeing_Display" : "AX_REDUCE_MOTION"))!
    }()

    static var reduceMotion: SettingsGuide {
        SettingsGuide(pane: .accessibility, steps: [.page("Motion"), .toggle("Reduce motion", on: true)])
    }

    static var loginItems: SettingsGuide {
        SettingsGuide(pane: .general, steps: [.page("Login Items & Extensions"), .app(on: true)])
    }

    static var finderExtensions: SettingsGuide {
        SettingsGuide(pane: .general, steps: [.page("Login Items & Extensions"), .appInfo, .app(on: true)])
    }
}

struct SettingsGuideScene: View {
    let pane: GuidePane
    let steps: [GuideStep]
    let tick: Int
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let origin = CGPoint(x: 32, y: 20)
    private static let rowHeight: CGFloat = 20

    var body: some View {
        let layout = GuideLayout(steps)
        let last = 2 * steps.count + 3
        let t = reduceMotion ? last : tick % (last + 1)
        let done = t / 2
        let click = min((t - 1) / 2, steps.count)
        let pressing = t >= 2 && t.isMultiple(of: 2) && t < last
        let local = t == 0 ? CGPoint(x: 230, y: 92) : click == 0 ? CGPoint(x: 60, y: 14.5 + 16 * CGFloat(pane.slot)) : layout.point(click - 1)
        let point = CGPoint(x: local.x + Self.origin.x, y: local.y + Self.origin.y)
        Stage {
            ArtWindow(size: CGSize(width: 236, height: 116)) {
                ZStack(alignment: .topLeading) {
                    sidebar(selected: done >= 1)
                    content(layout, done: done, pressed: pressing ? click - 1 : nil)
                }
            }
            .position(x: 150, y: 64)
            if pressing {
                ArtRipple().position(point)
            } else if reduceMotion {
                Circle().strokeBorder(Color.accentColor.opacity(0.8), lineWidth: 2).frame(width: 24, height: 24).position(point)
            }
            ArtCursor(pressed: pressing).cursor(at: point)
        }
        .animation(reduceMotion ? nil : .smooth(duration: 0.3), value: t)
    }

    private func sidebar(selected: Bool) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            ForEach(0..<5, id: \.self) { index in
                if index == pane.slot {
                    HStack(spacing: 3) {
                        Image(systemName: pane.symbol)
                            .font(.system(size: 5.5, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 9, height: 9)
                            .background(pane.tint, in: RoundedRectangle(cornerRadius: 2.2, style: .continuous))
                        if let name = GuideText.name(of: pane) {
                            Text(verbatim: name).font(.system(size: 6.5)).lineLimit(2).minimumScaleFactor(0.5).multilineTextAlignment(.leading)
                        } else {
                            bar(24)
                        }
                        Spacer(minLength: 0)
                    }
                    .foregroundStyle(selected ? Color.white : Color.primary)
                    .padding(.horizontal, 3)
                    .frame(height: 17)
                    .background(selected ? Color.accentColor : .clear, in: RoundedRectangle(cornerRadius: 3, style: .continuous))
                } else {
                    bar([30, 38, 26, 34, 28][index]).padding(.leading, 15).frame(height: 13)
                }
            }
        }
        .padding(.horizontal, 4)
        .padding(.top, 6)
        .frame(width: 76, height: 102, alignment: .top)
        .background(Color.primary.opacity(0.05))
        .overlay(alignment: .trailing) { Rectangle().fill(Color.primary.opacity(0.1)).frame(width: 0.5) }
    }

    @ViewBuilder
    private func content(_ layout: GuideLayout, done: Int, pressed: Int?) -> some View {
        if done == 0 {
            place(CGRect(x: 84, y: 8, width: 144, height: 8)) { bar(40).frame(maxWidth: .infinity, alignment: .leading) }
            place(CGRect(x: 84, y: 21, width: 144, height: 60)) { list([nil, nil, nil], done: done, pressed: nil) }
        } else {
            let shown = layout.shown(afterSteps: done - 1)
            let page = layout.layers[...shown].lastIndex { $0.kind != .sheet } ?? 0
            let frame = layout.geometry(page)
            ZStack(alignment: .topLeading) {
                if layout.layers[page].kind == .page, let title = steps[layout.layers[page].opener].label {
                    place(CGRect(x: 84, y: 6, width: 144, height: 10)) {
                        HStack(spacing: 3) {
                            Image(systemName: "chevron.left").font(.system(size: 6, weight: .bold)).foregroundStyle(Color.accentColor)
                            GuideLabel(text: title, pane: pane, size: 8, weight: .semibold)
                        }
                    }
                } else {
                    place(CGRect(x: 84, y: 6, width: 144, height: 10)) {
                        Group {
                            if let name = GuideText.name(of: pane) {
                                Text(verbatim: name).font(.system(size: 8, weight: .semibold)).lineLimit(1).minimumScaleFactor(0.7)
                            } else {
                                bar(50)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                layer(layout, page, frame, done: done, pressed: pressed)
            }
            .id(page)
            .transition(.opacity.combined(with: .offset(x: page == 0 ? 0 : 30)))
            if layout.layers[shown].kind == .sheet {
                Color.black.opacity(0.14).transition(.opacity)
                let frame = layout.geometry(shown)
                if let sheet = frame.sheet {
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(Color(nsColor: .windowBackgroundColor))
                            .overlay(RoundedRectangle(cornerRadius: 7, style: .continuous).hairline(Color.primary.opacity(0.14)))
                            .shadow(color: .black.opacity(0.2), radius: 5, y: 3)
                            .frame(width: sheet.width, height: sheet.height)
                            .position(x: sheet.midX, y: sheet.midY)
                        layer(layout, shown, frame, done: done, pressed: pressed)
                        place(CGRect(x: sheet.maxX - 36, y: sheet.maxY - 17, width: 28, height: 10)) {
                            Capsule().fill(Color.accentColor)
                        }
                    }
                    .id(shown)
                    .transition(.scale(scale: 0.9, anchor: .top).combined(with: .opacity))
                }
            }
        }
    }

    @ViewBuilder
    private func layer(_ layout: GuideLayout, _ index: Int, _ frame: GuideFrame, done: Int, pressed: Int?) -> some View {
        let display = layout.display(index)
        if let strip = frame.strip, let step = display {
            place(strip) {
                HStack(spacing: 12) {
                    ForEach(0..<2, id: \.self) { monitor in
                        VStack(spacing: 1.5) {
                            RoundedRectangle(cornerRadius: 2.5, style: .continuous)
                                .fill(LinearGradient(colors: [Color.accentColor.opacity(0.5), Color.purple.opacity(0.4)], startPoint: .top, endPoint: .bottom))
                                .overlay(RoundedRectangle(cornerRadius: 2.5, style: .continuous).strokeBorder(Color.accentColor, lineWidth: monitor == 1 && done >= step + 2 ? 1.5 : 0))
                                .frame(width: 38, height: 21)
                            Capsule().fill(Color.primary.opacity(0.2)).frame(width: 10, height: 2)
                        }
                        .scaleEffect(pressed == step && monitor == 1 ? 0.95 : 1)
                    }
                }
            }
        }
        let items = frame.items
        let dim = display.map { done < $0 + 2 } ?? false
        place(frame.list) { list(items, done: done, pressed: pressed, dim: dim) }
    }

    private func list(_ items: [Int?], done: Int, pressed: Int?, dim: Bool = false) -> some View {
        let shape = RoundedRectangle(cornerRadius: 5, style: .continuous)
        return VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { offset, item in
                if offset > 0 { Rectangle().fill(Color.primary.opacity(0.08)).frame(height: 0.5).padding(.leading, 6) }
                if let item {
                    row(steps[item], applied: done >= item + 2, pressed: pressed == item)
                        .opacity(dim ? 0.4 : 1)
                } else {
                    HStack {
                        bar([44, 62, 36][offset % 3])
                        Spacer(minLength: 0)
                        Capsule().fill(Color.primary.opacity(0.08)).frame(width: [14, 8, 18][offset % 3], height: 6)
                    }
                    .padding(.horizontal, 6)
                    .frame(height: Self.rowHeight)
                }
            }
        }
        .background(Color(nsColor: .controlBackgroundColor), in: shape)
        .overlay(shape.hairline(Color.primary.opacity(0.1)))
    }

    private func row(_ step: GuideStep, applied: Bool, pressed: Bool) -> some View {
        let selected = if case .select = step { applied } else { false }
        return HStack(spacing: 4) {
            switch step {
            case .app, .appInfo:
                Image(nsImage: GuideText.icon).resizable().frame(width: 11, height: 11)
                Text(verbatim: "pikapik").font(.system(size: 7))
            default:
                if let label = step.label { GuideLabel(text: label, pane: pane) } else { bar(36) }
            }
            Spacer(minLength: 2)
            control(step, applied: applied, pressed: pressed)
        }
        .padding(.horizontal, 6)
        .frame(height: Self.rowHeight)
        .foregroundStyle(selected ? Color.white : Color.primary)
        .background { if selected { RoundedRectangle(cornerRadius: 3, style: .continuous).fill(Color.accentColor).padding(1) } }
    }

    @ViewBuilder
    private func control(_ step: GuideStep, applied: Bool, pressed: Bool) -> some View {
        switch step {
        case .toggle(_, let on), .app(let on):
            let value = applied ? on : !on
            Capsule().fill(value ? Color.accentColor : Color.primary.opacity(0.2))
                .frame(width: 17, height: 10)
                .overlay { Circle().fill(.white).frame(width: 8, height: 8).shadow(color: .black.opacity(0.2), radius: 0.5, y: 0.5).offset(x: value ? 3.5 : -3.5) }
        case .checkbox(_, let option, let on):
            let value = applied ? on : !on
            HStack(spacing: 3) {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(value ? Color.accentColor : Color(nsColor: .textBackgroundColor))
                    .overlay(RoundedRectangle(cornerRadius: 2, style: .continuous).hairline(Color.primary.opacity(0.3)))
                    .overlay { if value { Image(systemName: "checkmark").font(.system(size: 5.5, weight: .heavy)).foregroundStyle(.white) } }
                    .frame(width: 8, height: 8)
                if let text = GuideText.text(option, in: pane) {
                    Text(verbatim: text).font(.system(size: 7)).lineLimit(1).minimumScaleFactor(0.7)
                } else {
                    bar(26)
                }
                Spacer(minLength: 0)
            }
            .frame(width: 76)
        case .popup(_, let from, let to):
            HStack(spacing: 2) {
                if let text = GuideText.text(applied ? to : from, in: pane) {
                    Text(verbatim: text).font(.system(size: 7)).lineLimit(1).minimumScaleFactor(0.6)
                } else {
                    bar(26)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.up.chevron.down").font(.system(size: 5, weight: .bold)).foregroundStyle(.secondary)
            }
            .padding(.horizontal, 4)
            .frame(width: 80, height: 12)
            .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 3, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 3, style: .continuous).hairline(Color.primary.opacity(pressed ? 0.4 : 0.2)))
        case .button(let text):
            Group {
                if let text = GuideText.text(text, in: pane) {
                    Text(verbatim: text).font(.system(size: 7)).lineLimit(1).minimumScaleFactor(0.6)
                } else {
                    bar(30)
                }
            }
            .padding(.horizontal, 4)
            .frame(width: 56, height: 12)
            .background(pressed ? Color.primary.opacity(0.12) : Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 3, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 3, style: .continuous).hairline(Color.primary.opacity(0.2)))
        case .page:
            Image(systemName: "chevron.right").font(.system(size: 6, weight: .bold)).foregroundStyle(.secondary)
        case .info, .appInfo:
            Image(systemName: "info.circle").font(.system(size: 9)).foregroundStyle(Color.accentColor)
        case .display, .select:
            EmptyView()
        }
    }

    private func bar(_ width: CGFloat) -> some View {
        Capsule().fill(Color.primary.opacity(0.12)).frame(width: width, height: 4)
    }

    private func place(_ rect: CGRect, @ViewBuilder _ view: () -> some View) -> some View {
        view().frame(width: rect.width, height: rect.height).position(x: rect.midX, y: rect.midY)
    }
}

private struct GuideLabel: View {
    let text: String
    let pane: GuidePane
    var size: CGFloat = 7
    var weight = Font.Weight.regular

    var body: some View {
        if let shown = GuideText.text(text, in: pane) {
            Text(verbatim: shown)
                .font(.system(size: size, weight: weight))
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            Capsule().fill(Color.primary.opacity(0.12)).frame(width: 40, height: 4)
        }
    }
}

struct GuideFrame {
    var strip: CGRect?
    var list: CGRect
    var sheet: CGRect?
    var items: [Int?]
}

struct GuideLayer {
    enum Kind { case pane, page, sheet }
    var kind: Kind
    var opener = -1
    var steps: [Int] = []
}

struct GuideLayout {
    let steps: [GuideStep]
    let layers: [GuideLayer]
    private let owner: [Int]

    init(_ steps: [GuideStep]) {
        var layers = [GuideLayer(kind: .pane)]
        var owner: [Int] = []
        for (index, step) in steps.enumerated() {
            layers[layers.count - 1].steps.append(index)
            owner.append(layers.count - 1)
            if let kind = step.opens { layers.append(GuideLayer(kind: kind, opener: index)) }
        }
        self.steps = steps
        self.layers = layers
        self.owner = owner
    }

    func shown(afterSteps count: Int) -> Int {
        layers.dropFirst().prefix { $0.opener < count }.count
    }

    func display(_ layer: Int) -> Int? {
        layers[layer].steps.first { if case .display = steps[$0] { true } else { false } }
    }

    func geometry(_ index: Int) -> GuideFrame {
        let layer = layers[index]
        let sheet = layer.kind == .sheet
        let x: CGFloat = sheet ? 88 : 84
        let width: CGFloat = sheet ? 132 : 144
        var y: CGFloat = sheet ? 7 : 21
        let picked = display(index)
        var items: [Int?] = picked == nil ? [nil] : []
        items += layer.steps.filter { $0 != picked }.map { Optional($0) }
        while items.count < (picked == nil ? 3 : 2) { items.append(nil) }
        var strip: CGRect?
        if picked != nil {
            strip = CGRect(x: x, y: y, width: width, height: 28)
            y += 32
        }
        let list = CGRect(x: x, y: y, width: width, height: 20 * CGFloat(items.count))
        return GuideFrame(strip: strip, list: list, sheet: sheet ? CGRect(x: 80, y: 0, width: 148, height: list.maxY + 23) : nil, items: items)
    }

    func point(_ step: Int) -> CGPoint {
        let frame = geometry(owner[step])
        if case .display = steps[step], let strip = frame.strip { return CGPoint(x: strip.midX + 25, y: strip.minY + 10) }
        let row = frame.items.firstIndex(of: step) ?? 0
        let y = frame.list.minY + 20 * CGFloat(row) + 10
        let right = frame.list.maxX - 6
        switch steps[step] {
        case .toggle, .app: return CGPoint(x: right - 11, y: y - 2)
        case .checkbox: return CGPoint(x: right - 72, y: y + 3.5)
        case .popup: return CGPoint(x: right - 12, y: y - 1)
        case .button: return CGPoint(x: right - 28, y: y)
        case .page, .info, .appInfo: return CGPoint(x: right - 3, y: y)
        case .select: return CGPoint(x: right - 16, y: y)
        case .display: return CGPoint(x: right, y: y)
        }
    }
}

@MainActor
enum GuideText {
    private static let root = "/System/Library/ExtensionKit/Extensions"
    private static var tables: [String: [[String: [String: String]]]] = [:]
    private static var cache: [String: String?] = [:]
    private static let languages = CFPreferencesCopyValue("AppleLanguages" as CFString, kCFPreferencesAnyApplication, kCFPreferencesCurrentUser, kCFPreferencesAnyHost) as? [String] ?? Locale.preferredLanguages

    static let icon = NSWorkspace.shared.icon(forFile: Bundle.main.bundlePath)

    static func name(of pane: GuidePane) -> String? {
        cached("name|\(pane.bundles[0])") {
            tables(pane.bundles[0], only: "InfoPlist").lazy.compactMap { table in
                table[language(table)]?["CFBundleDisplayName"] ?? table["en"]?["CFBundleDisplayName"]
            }.first
        }
    }

    static func text(_ english: String, in pane: GuidePane) -> String? {
        cached("\(pane.bundles[0])|\(english)") {
            for bundle in pane.bundles {
                for table in tables(bundle) {
                    let en = table["en"] ?? [:]
                    let keys = [english] + en.filter { $0.value == english }.keys.sorted()
                    for key in keys {
                        if let value = table[language(table)]?[key] ?? en[key] { return value }
                    }
                    if table.values.contains(where: { $0[english] != nil }) { return english }
                }
            }
            return nil
        }
    }

    private static func cached(_ key: String, _ find: () -> String?) -> String? {
        if let known = cache[key] { return known }
        let value = find()
        cache[key] = value
        return value
    }

    private static func language(_ table: [String: [String: String]]) -> String {
        Bundle.preferredLocalizations(from: Array(table.keys), forPreferences: languages).first ?? "en"
    }

    private static func tables(_ bundle: String, only name: String? = nil) -> [[String: [String: String]]] {
        let key = bundle + (name ?? "")
        if let known = tables[key] { return known }
        let folder = URL(fileURLWithPath: "\(root)/\(bundle).appex/Contents/Resources")
        let files = ((try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)) ?? []).filter { $0.pathExtension == "loctable" }
        let wanted = files.filter { name == nil ? true : $0.deletingPathExtension().lastPathComponent == name }
        let ordered = wanted.filter { $0.lastPathComponent == "Localizable.loctable" } + wanted.filter { $0.lastPathComponent != "Localizable.loctable" }.sorted { $0.lastPathComponent < $1.lastPathComponent }
        let loaded = ordered.compactMap { NSDictionary(contentsOf: $0) as? [String: Any] }.map { raw in
            raw.compactMapValues { ($0 as? [String: Any])?.compactMapValues { $0 as? String } }
        }
        tables[key] = loaded
        return loaded
    }
}
