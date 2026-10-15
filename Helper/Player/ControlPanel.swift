import AppKit

enum ControlPanel {
    static func make() -> NSView {
        if #available(macOS 26.0, *) {
            let glass = NSGlassEffectView()
            glass.style = .regular
            glass.tintColor = NSColor.black.withAlphaComponent(0.5)
            glass.cornerRadius = 12
            return glass
        }
        let blur = NSVisualEffectView()
        blur.material = .hudWindow
        blur.blendingMode = .withinWindow
        blur.state = .active
        blur.wantsLayer = true
        blur.layer?.cornerRadius = 12
        blur.layer?.masksToBounds = true
        return blur
    }

    static func fill(_ panel: NSView, with row: NSView) {
        if #available(macOS 26.0, *), let glass = panel as? NSGlassEffectView {
            glass.contentView = row
            return
        }
        panel.addSubview(row)
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: panel.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: panel.trailingAnchor),
            row.centerYAnchor.constraint(equalTo: panel.centerYAnchor),
        ])
    }
}
