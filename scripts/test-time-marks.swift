import AppKit

@main
enum TestTimeMarks {
    @MainActor static func main() {
        _ = NSApplication.shared
        let slider = NSSlider(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
        slider.controlSize = .small
        slider.doubleValue = 0.2
        let marks = TimeMarks(frame: slider.bounds)
        marks.chapters = [0.5]
        slider.addSubview(marks)
        let glass = NSView(frame: slider.bounds)
        glass.appearance = NSAppearance(named: .darkAqua)
        glass.wantsLayer = true
        glass.layer?.backgroundColor = NSColor(white: 0.15, alpha: 1).cgColor
        glass.addSubview(slider)
        let picture = glass.bitmapImageRepForCachingDisplay(in: glass.bounds)!
        glass.cacheDisplay(in: glass.bounds, to: picture)
        let scale = picture.pixelsWide / 300
        let brightness = { (x: Int, y: Int) in picture.colorAt(x: x * scale, y: y * scale)?.usingColorSpace(.deviceRGB)?.brightnessComponent ?? 0 }
        let mark = brightness(150, 9), glassAround = brightness(110, 9)
        precondition(mark - glassAround > 0.4, "a chapter mark must be visible on the dark glass: mark \(mark), glass \(glassAround)")
        print("chapter marks on the dark glass: mark \(String(format: "%.2f", mark)) against \(String(format: "%.2f", glassAround)): ok")
    }
}
