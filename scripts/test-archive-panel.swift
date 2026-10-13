// From the repo root: d=$(mktemp -d) && sed '/^}$/q' Sources/pika-tools/Tools/Archive/ArchivePrompts.swift > "$d/panel.swift" && swiftc -parse-as-library scripts/test-archive-panel.swift "$d/panel.swift" -o "$d/test" && "$d/test"
import AppKit
import SwiftUI

final class Calls {
    var count = 0
}

@main
enum TestArchivePanel {
    static var failed = false

    static func check(_ name: String, _ passed: Bool) {
        print("\(passed ? "ok  " : "FAIL") \(name)")
        if !passed { failed = true }
    }

    /// A panel far off screen, ordered in but never activated, counting how often it answers.
    @MainActor static func makePanel(_ calls: Calls?) -> ArchivePanel {
        let panel = ArchivePanel(NSHostingController(rootView: Text(verbatim: "Panel")), activating: true, onClose: calls.map { calls in { calls.count += 1 } })
        panel.setFrameOrigin(NSPoint(x: -20000, y: -20000))
        panel.orderFront(nil)
        return panel
    }

    @MainActor static func main() {
        NSApplication.shared.setActivationPolicy(.accessory)

        var calls = Calls()
        var panel = makePanel(calls)
        var shown = panel.isVisible
        panel.standardWindowButton(.closeButton)?.performClick(nil)
        check("red button click answers once and closes", shown && calls.count == 1 && !panel.isVisible)

        calls = Calls()
        panel = makePanel(calls)
        shown = panel.isVisible
        _ = panel.standardWindowButton(.closeButton)?.accessibilityPerformPress()
        check("red button VoiceOver press answers once and closes", shown && calls.count == 1 && !panel.isVisible)

        calls = Calls()
        panel = makePanel(calls)
        shown = panel.isVisible
        panel.dismiss()
        check("dismiss() closes without answering", shown && calls.count == 0 && !panel.isVisible)

        calls = Calls()
        panel = makePanel(calls)
        shown = panel.isVisible
        panel.close()
        panel.close()
        check("close() twice answers once", shown && calls.count == 1 && !panel.isVisible)

        panel = makePanel(nil)
        check("panel nobody answers has a disabled red button", panel.standardWindowButton(.closeButton)?.isEnabled == false)
        panel.dismiss()

        exit(failed ? 1 : 0)
    }
}
