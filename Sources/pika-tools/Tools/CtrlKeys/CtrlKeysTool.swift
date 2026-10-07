import AppKit
import CoreGraphics
import SwiftUI

@Observable
final class CtrlKeysTool: Tool {
    let id = "ctrl-keys"
    let icon = "control"
    var title: String { String(localized: "Block Control shortcuts") }

    private(set) var isActive = false

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: id)
            refresh()
        }
    }

    var excluded: [String] {
        didSet {
            UserDefaults.standard.set(excluded, forKey: Self.excludedKey)
            frontmostIsExcluded = excluded.contains(NSWorkspace.shared.frontmostApplication?.bundleIdentifier ?? "")
        }
    }

    private static let excludedKey = "ctrl-keys-excluded"

    @ObservationIgnored private var tap: CFMachPort?
    @ObservationIgnored private var source: CFRunLoopSource?
    @ObservationIgnored private var activation: NSObjectProtocol?
    @ObservationIgnored fileprivate var frontmostIsExcluded = false

    init() {
        isEnabled = UserDefaults.standard.object(forKey: id) as? Bool ?? true
        excluded = UserDefaults.standard.stringArray(forKey: Self.excludedKey) ?? []
    }

    func load() {
        excluded = UserDefaults.standard.stringArray(forKey: Self.excludedKey) ?? []
        isEnabled = UserDefaults.standard.object(forKey: id) as? Bool ?? true
    }

    var isDefault: Bool { !isEnabled && excluded.isEmpty }

    func reset() {
        isEnabled = false
        excluded = []
    }

    var settingsView: AnyView {
        AnyView(CtrlKeysSettings(tool: self))
    }

    func refresh() {
        stop()
        if isEnabled { start() }
    }

    private func start() {
        let types: [CGEventType] = [.keyDown, .keyUp, .leftMouseDown, .leftMouseUp, .leftMouseDragged]
        let mask = types.reduce(CGEventMask(0)) { $0 | (1 << $1.rawValue) }

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: ctrlKeysCallback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else { return }

        let source = CFMachPortCreateRunLoopSource(nil, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        self.tap = tap
        self.source = source
        frontmostIsExcluded = excluded.contains(NSWorkspace.shared.frontmostApplication?.bundleIdentifier ?? "")
        activation = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: .main
        ) { [weak self] note in
            let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
            self?.frontmostIsExcluded = self?.excluded.contains(app?.bundleIdentifier ?? "") ?? false
        }
        isActive = true
    }

    private func stop() {
        if let tap {
            CGEvent.tapEnable(tap: tap, enable: false)
            CFMachPortInvalidate(tap)
        }
        if let source {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
        if let activation {
            NSWorkspace.shared.notificationCenter.removeObserver(activation)
        }
        tap = nil
        source = nil
        activation = nil
        frontmostIsExcluded = false
        isActive = false
    }
}

private func ctrlKeysCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let refcon else { return Unmanaged.passUnretained(event) }
    let tool = Unmanaged<CtrlKeysTool>.fromOpaque(refcon).takeUnretainedValue()
    switch type {
    case .tapDisabledByTimeout, .tapDisabledByUserInput:
        DispatchQueue.main.async { tool.refresh() }
    case .keyDown, .keyUp, .leftMouseDown, .leftMouseUp, .leftMouseDragged:
        if !tool.frontmostIsExcluded, event.flags.contains(.maskControl) {
            event.flags.remove(.maskControl)
            if event.flags.contains(.maskCommand) {
                event.flags.remove(.maskCommand)
            }
        }
    default:
        break
    }
    return Unmanaged.passUnretained(event)
}

struct CtrlKeysArt: View {
    let on: Bool
    @State private var tick = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let durations = [0.9, 0.6, 0.5, 2, 0.6]
    private static let file = CGPoint(x: 168, y: 64)

    var body: some View {
        let step = reduceMotion ? 3 : tick % Self.durations.count
        let down = (2...3).contains(step)
        let clicked = step == 3
        IllustrationRow {
            Stage {
                ArtKey(down: down, width: 46) { Text(verbatim: "⌃") }
                    .position(x: 56, y: 64)
                ArtWindow(size: CGSize(width: 124, height: 84)) {
                    ArtFile(selected: on && clicked)
                }
                .position(x: 168, y: 58)
                if clicked, !on {
                    ArtMenu {
                        ArtMenuRow(width: 38)
                        ArtMenuRow(width: 30)
                        ArtMenuRow(width: 42)
                    }
                    .position(x: Self.file.x + 48, y: Self.file.y + 29)
                    .transition(.scale(scale: 0.85, anchor: .topLeading).combined(with: .opacity))
                }
                if clicked {
                    ArtRipple().position(x: Self.file.x, y: Self.file.y)
                }
                ArtCursor()
                    .cursor(at: step == 0 ? CGPoint(x: 250, y: 100) : CGPoint(x: Self.file.x - 4, y: Self.file.y + 2))
            }
            .animation(reduceMotion ? nil : .smooth(duration: 0.3), value: step)
        }
        .loop($tick, Self.durations)
    }
}

private struct CtrlKeysSettings: View {
    @Bindable var tool: CtrlKeysTool
    @Environment(\.inSettings) private var inSettings

    var body: some View {
        if inSettings { CtrlKeysArt(on: tool.isEnabled) }
        ToggleRow(
            icon: tool.icon,
            title: tool.title,
            subtitle: Text("No ⌃ shortcuts, no ⌃-click menu"),
            hint: Text("⌃ works as a plain key"),
            help: Text("⌃ works as a plain key: no shortcuts, no ⌃-click menu"),
            keys: ["⌃"],
            isOn: $tool.isEnabled
        )
        AppExclusions(
            title: String(localized: "⌃ works as usual in these apps"),
            apps: $tool.excluded,
            isEnabled: tool.isEnabled
        )
    }
}
