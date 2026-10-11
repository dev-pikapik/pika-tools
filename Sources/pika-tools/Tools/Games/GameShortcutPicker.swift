import AppKit
import SwiftUI

struct GameShortcutPicker: View {
    let entry: SystemGameShortcut
    let rules: Set<GameRule>
    @Binding var selection: GameShortcutMode
    @State private var presented = false

    var body: some View {
        Button { presented.toggle() } label: {
            HStack(spacing: 8) {
                Text(verbatim: selection.title)
                Image(systemName: "chevron.up.chevron.down").font(.system(size: 9, weight: .medium)).foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.bordered)
        .accessibilityLabel(Text("While playing"))
        .accessibilityValue(Text(verbatim: selection.title))
        .popover(isPresented: $presented, arrowEdge: .bottom) {
            GameShortcutOptions(entry: entry, rules: rules, selection: $selection, presented: $presented)
        }
    }
}

private struct GameShortcutOptions: View {
    let entry: SystemGameShortcut
    let rules: Set<GameRule>
    @Binding var selection: GameShortcutMode
    @Binding var presented: Bool
    @State private var hovered: GameShortcutMode?
    @FocusState private var focused: GameShortcutMode?

    private var options: [GameShortcutMode] { GameShortcutMode.allCases.filter { $0 != .background || entry.supportsBackground } }

    var body: some View {
        VStack(spacing: 3) {
            ForEach(options, id: \.self) { option in
                Button {
                    selection = option
                    presented = false
                } label: {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark").font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.accentColor).opacity(selection == option ? 1 : 0)
                            .frame(width: 14).padding(.top, 2).accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(verbatim: option.title).fontWeight(.medium)
                            Text(verbatim: entry.explanation(for: option, rules: rules))
                                .font(.subheadline).foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(10)
                    .contentShape(Rectangle())
                    .background(Color.accentColor.opacity(hovered == option || focused == option ? 0.1 : 0), in: RoundedRectangle(cornerRadius: 7))
                }
                .buttonStyle(.plain)
                .focusable().focusEffectDisabled()
                .focused($focused, equals: option)
                .onHover { hovered = $0 ? option : nil }
                .accessibilityAddTraits(selection == option ? .isSelected : [])
            }
        }
        .padding(8).frame(width: 370)
        .onAppear { DispatchQueue.main.async { if focused == nil { focused = selection } } }
        .background(ShortcutMenuKeys { event in
            guard event.modifierFlags.intersection([.command, .control, .option]).isEmpty else { return false }
            switch event.keyCode {
            case 125: moveFocus(1)
            case 126: moveFocus(-1)
            case 48: moveFocus(event.modifierFlags.contains(.shift) ? -1 : 1)
            case 36, 76: selection = focused ?? selection; presented = false
            case 53: presented = false
            default: return false
            }
            return true
        })
    }

    private func moveFocus(_ step: Int) {
        let index = options.firstIndex(of: focused ?? selection) ?? 0
        focused = options[(index + options.count + step) % options.count]
    }
}

private struct ShortcutMenuKeys: NSViewRepresentable {
    let handle: (NSEvent) -> Bool

    func makeNSView(context: Context) -> ShortcutMenuKeyView { ShortcutMenuKeyView() }
    func updateNSView(_ view: ShortcutMenuKeyView, context: Context) { view.handle = handle }
    static func dismantleNSView(_ view: ShortcutMenuKeyView, coordinator: ()) { view.stop() }
}

private final class ShortcutMenuKeyView: NSView {
    var handle: (NSEvent) -> Bool = { _ in false }
    private var monitor: Any?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        stop()
        guard window != nil else { return }
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self, self.window != nil else { return event }
            return self.handle(event) ? nil : event
        }
    }

    func stop() {
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
    }
}
