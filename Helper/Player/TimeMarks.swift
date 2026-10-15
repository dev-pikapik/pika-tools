import AppKit

final class TimeMarks: NSView {
    var chapters: [Double] = [] { didSet { needsDisplay = true } }
    var loop: [Double] = [] { didSet { needsDisplay = true } }

    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    override func draw(_ dirtyRect: NSRect) {
        let knob = Double((superview as? NSSlider).flatMap { ($0.cell as? NSSliderCell)?.knobThickness } ?? 0)
        let x = { (fraction: Double) in CGFloat(knob / 2 + fraction * max(Double(self.bounds.width) - knob, 1)) }
        NSColor.black.withAlphaComponent(0.55).setFill()
        for fraction in chapters { NSRect(x: x(fraction) - 1, y: bounds.midY - 4, width: 2, height: 8).fill() }
        NSColor.systemYellow.setFill()
        if let first = loop.first, let last = loop.last, loop.count == 2 { NSRect(x: x(first), y: bounds.midY - 1.5, width: x(last) - x(first), height: 3).fill() }
        for fraction in loop { NSBezierPath(roundedRect: NSRect(x: x(fraction) - 1.5, y: bounds.midY - 7, width: 3, height: 14), xRadius: 1.5, yRadius: 1.5).fill() }
    }
}
