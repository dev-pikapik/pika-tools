import CoreGraphics
import Foundation

typealias Layer = (width: Int, height: Int, presented: Double, frames: Int, skipped: Double)

func report(_ layers: [Layer]) -> String {
    func stats(_ fps: Double, _ frames: Int) -> [String: Any] {
        ["FPS": fps, "Frame Count": frames, "Command Buffer Count": frames, "On-GPU Walltime Stats": ["Count": frames, "Min (ms)": 0.5]]
    }
    let root: [String: Any] = [
        "Layers": layers.map { layer in
            [
                "Configuration": ["Width (pixels)": layer.width, "Height (pixels)": layer.height, "Name": ""],
                "Performance Stats": [
                    "Skipped Frame Stats": stats(layer.skipped, 1),
                    "Presented Frame Stats": stats(layer.presented, layer.frames),
                    "Frame-On-Glass Interval Stats": ["Min (ms)": 8.3, "Count": layer.frames],
                ],
            ] as [String: Any]
        },
        "States": [] as [Any],
        "Process": "game",
        "PID": 1902,
    ]
    let data = try! JSONSerialization.data(withJSONObject: root, options: [.prettyPrinted, .sortedKeys])
    return String(decoding: data, as: UTF8.self) + "\n"
}

func rates(_ text: String, split sizes: [Int] = [Int.max]) -> [Double] {
    var reader = PerfTraceReader()
    var out: [Double] = []
    let bytes = Array(text.utf8)
    var start = 0, turn = 0
    while start < bytes.count {
        let size = sizes[turn % sizes.count]
        out += reader.feed(bytes[start..<min(bytes.count, start + size)])
        start += size
        turn += 1
    }
    return out
}

@main
enum TestFrameRate {
    static func main() {
        let one = report([(960, 600, 45.0, 45, 0)])
        precondition(one.hasPrefix("{\n  \"Layers\" : [\n"))
        precondition(rates(one) == [45.0])
        print("one object: ok")

        let stream = report([(960, 600, 30, 30, 0)]) + report([(960, 600, 44.5, 44, 0)]) + report([(960, 600, 60, 60, 0)])
        let expected = [30.0, 44.5, 60.0]
        precondition(rates(stream) == expected)
        for size in [1, 2, 3, 7, 64, 1000] { precondition(rates(stream, split: [size]) == expected) }
        precondition(rates(stream, split: [5, 1, 13, 2, 400, 3]) == expected)
        let bytes = Array(stream.utf8)
        for cut in 0...bytes.count where cut % 11 == 0 || cut > bytes.count - 4 {
            var reader = PerfTraceReader()
            precondition(reader.feed(bytes[..<cut]) + reader.feed(bytes[cut...]) == expected)
        }
        print("chunks at any byte boundary: ok")

        let terminal = stream.replacingOccurrences(of: "\n", with: "\r\n")
        precondition(rates(terminal) == expected)
        precondition(rates(terminal, split: [1]) == expected)
        precondition(rates(terminal, split: [9, 4, 31]) == expected)
        print("terminal line endings: ok")

        precondition(rates(report([(960, 600, 30, 30, 99)])) == [30])
        precondition(rates(report([(960, 600, 0, 0, 99)])) == [0])
        print("skipped frames are never counted: ok")

        precondition(rates(report([(100, 100, 10, 10, 0), (1920, 1080, 60, 60, 0), (800, 600, 24, 24, 0)])) == [60])
        precondition(rates(report([(1920, 1080, 60, 60, 0), (100, 100, 10, 10, 0)])) == [60])
        precondition(rates(report([(100, 100, 10, 10, 0), (3000, 3000, 0, 0, 77), (800, 600, 24, 24, 0)])) == [24])
        precondition(rates(report([(3000, 3000, 0, 0, 77), (800, 600, 0, 0, 5)])) == [0])
        precondition(rates(report([])) == [0])
        print("biggest layer with frames wins: ok")

        let next = report([(960, 600, 90, 90, 0)])
        let both = Array((one + next).utf8)
        var resumed = PerfTraceReader()
        precondition(resumed.feed(both.prefix(both.count - 100)) == [45])
        precondition(resumed.feed(both.suffix(100)) == [90])
        precondition(rates(one + String(next.prefix(next.count * 2 / 3))) == [45])
        precondition(rates(String(one.prefix(one.count / 2))) == [])
        print("unfinished last object waits for the rest: ok")

        precondition(rates("Starting\nwarning: something\n" + one + "\n\n") == [45])
        precondition(rates("{\nnot json\n}\n" + one) == [45])
        precondition(rates("{\n\"Layers\" : 5\n}\n" + one) == [45])
        precondition(rates("{\n  \"x\" : 1,\n" + one) == [45])
        precondition(rates("") == [] && rates("\n\n{\n") == [])
        print("noise around the objects: ok")

        precondition(FrameRateShown(29.36) == .live(29) && FrameRateShown(59.5) == .live(60) && FrameRateShown(120) == .live(120))
        precondition(FrameRateShown(0) == .paused && FrameRateShown(0.4) == .paused && FrameRateShown(.nan) == .paused && FrameRateShown(-3) == .paused)
        precondition(FrameRateShown(5000) == .live(999) && FrameRateShown(999.4) == .live(999) && FrameRateShown(1e300) == .live(999))
        precondition(FrameRateShown(-1e300) == .paused && FrameRateShown(.infinity) == .paused)
        print("shown number: ok")

        let display = CGRect(x: 0, y: 0, width: 1512, height: 984)
        let output = CGSize(width: 189, height: 123)
        let window = CGRect(x: 756, y: 492, width: 378, height: 246)
        let target = FrameCoverage.target(window: window, display: display, output: output)
        precondition(abs(target.minX - 94.5) < 1e-9 && abs(target.minY - 61.5) < 1e-9)
        precondition(abs(target.width - 47.25) < 1e-9 && abs(target.height - 30.75) < 1e-9)
        let second = CGRect(x: 1512, y: 0, width: 1000, height: 800)
        let beside = FrameCoverage.target(window: CGRect(x: 1300, y: 100, width: 400, height: 400), display: second, output: CGSize(width: 125, height: 100))
        precondition(abs(beside.minX) < 1e-9 && abs(beside.minY - 12.5) < 1e-9 && abs(beside.width - 23.5) < 1e-9 && abs(beside.height - 50) < 1e-9)
        precondition(FrameCoverage.target(window: CGRect(x: 3000, y: 0, width: 100, height: 100), display: display, output: output).isNull)
        precondition(FrameCoverage.target(window: window, display: .zero, output: output).isNull)
        print("window on the capture: ok")

        let box = CGRect(x: 10, y: 10, width: 100, height: 100)
        precondition(FrameCoverage.presents(dirty: [box], target: box))
        precondition(FrameCoverage.presents(dirty: [CGRect(x: 0, y: 0, width: 1000, height: 1000)], target: box))
        precondition(FrameCoverage.presents(dirty: [CGRect(x: 10, y: 10, width: 30, height: 100)], target: box))
        precondition(!FrameCoverage.presents(dirty: [CGRect(x: 10, y: 10, width: 29.9, height: 100)], target: box))
        precondition(FrameCoverage.presents(dirty: [CGRect(x: 10, y: 10, width: 15, height: 100), CGRect(x: 60, y: 10, width: 15, height: 100)], target: box))
        precondition(!FrameCoverage.presents(dirty: [CGRect(x: 10, y: 10, width: 15, height: 100), CGRect(x: 200, y: 10, width: 500, height: 100)], target: box))
        precondition(!FrameCoverage.presents(dirty: [CGRect(x: 300, y: 300, width: 50, height: 50)], target: box))
        precondition(!FrameCoverage.presents(dirty: [CGRect(x: 110, y: 10, width: 50, height: 100)], target: box))
        precondition(!FrameCoverage.presents(dirty: [], target: box))
        precondition(!FrameCoverage.presents(dirty: [box], target: .null))
        precondition(!FrameCoverage.presents(dirty: [box], target: CGRect(x: 10, y: 10, width: 0, height: 5)))
        print("frame counts only when the game area changed: ok")

        let pill = CGSize(width: 70, height: 26)
        let area = CGRect(x: 100, y: 50, width: 800, height: 600)
        func place(_ corner: FrameRateCorner, _ titleBar: Bool = false) -> CGRect {
            FramePillPlace.frame(of: pill, corner: corner, in: area, belowTitleBar: titleBar)
        }
        precondition(place(.topLeft) == CGRect(x: 112, y: 612, width: 70, height: 26))
        precondition(place(.topRight) == CGRect(x: 818, y: 612, width: 70, height: 26))
        precondition(place(.bottomLeft) == CGRect(x: 112, y: 62, width: 70, height: 26))
        precondition(place(.bottomRight) == CGRect(x: 818, y: 62, width: 70, height: 26))
        precondition(place(.topRight, true).minY == 612 - FramePillPlace.titleBar && place(.topLeft, true).minY == 584)
        precondition(place(.bottomRight, true) == place(.bottomRight) && place(.bottomLeft, true) == place(.bottomLeft))
        precondition(FrameRateCorner.allCases.allSatisfy { area.contains(place($0, true)) })
        precondition(FrameRateCorner(rawValue: "top-right") == FrameRateCorner.standard && FrameRateCorner(rawValue: "middle") == nil)
        precondition(Set(FrameRateCorner.allCases.map(\.rawValue)).count == 4)
        print("corner of the window: ok")

        let quartz = CGRect(x: 200, y: 100, width: 800, height: 600)
        precondition(FramePillPlace.cocoa(quartz, primaryHeight: 982) == CGRect(x: 200, y: 282, width: 800, height: 600))
        precondition(FramePillPlace.cocoa(CGRect(x: 0, y: 0, width: 1512, height: 982), primaryHeight: 982) == CGRect(x: 0, y: 0, width: 1512, height: 982))
        precondition(FramePillPlace.cocoa(CGRect(x: -800, y: -300, width: 500, height: 300), primaryHeight: 982) == CGRect(x: -800, y: 982, width: 500, height: 300))
        precondition(FramePillPlace.isFullscreen(window: display, display: display))
        precondition(FramePillPlace.isFullscreen(window: CGRect(x: 0, y: 0, width: 1512, height: 983.5), display: display))
        precondition(!FramePillPlace.isFullscreen(window: CGRect(x: 0, y: 38, width: 1512, height: 944), display: display))
        precondition(!FramePillPlace.isFullscreen(window: window, display: display))
        let notched = CGRect(x: 0, y: 0, width: 1352, height: 878)
        let belowNotch = CGRect(x: 0, y: 29, width: 1352, height: 849)
        precondition(FramePillPlace.isFullscreen(window: belowNotch, display: notched, top: 28.5))
        precondition(!FramePillPlace.isFullscreen(window: belowNotch, display: notched))
        precondition(!FramePillPlace.isFullscreen(window: CGRect(x: 0, y: 29, width: 1352, height: 760), display: notched, top: 28.5))
        print("screen coordinates: ok")

        var metal = FrameRateSource(traceCanRun: true, at: 100)
        precondition(!metal.startsCapture(at: 100, allowed: { true }))
        precondition(!metal.startsCapture(at: 102.9, allowed: { true }))
        metal.traced(at: 101)
        precondition(metal.traceSeen && !metal.traceStalled(at: 102.5) && metal.traceStalled(at: 102.7))
        precondition(!metal.startsCapture(at: 110, allowed: { true }))
        metal.traced(at: 110)
        precondition(!metal.traceStalled(at: 111.5))

        var opengl = FrameRateSource(traceCanRun: true, at: 0)
        precondition(!opengl.traceSeen && !opengl.traceStalled(at: 50))
        precondition(!opengl.startsCapture(at: 3, allowed: { false }))
        precondition(opengl.startsCapture(at: 4, allowed: { true }))
        precondition(!opengl.startsCapture(at: 5, allowed: { true }))
        opengl.traced(at: 8)
        precondition(opengl.traceSeen)

        var asked = 0
        var noTrace = FrameRateSource(traceCanRun: false, at: 7)
        let refused = noTrace.startsCapture(at: 7, allowed: { asked += 1; return false })
        precondition(!refused && asked == 1)
        let granted = noTrace.startsCapture(at: 7, allowed: { asked += 1; return true })
        precondition(granted && asked == 2)
        var early = FrameRateSource(traceCanRun: true, at: 0)
        let tooSoon = early.startsCapture(at: 1, allowed: { asked += 1; return true })
        precondition(!tooSoon && asked == 2)
        print("which counter measures the game: ok")

        var learning = FrameRateSource(traceCanRun: true, at: 0)
        precondition(!learning.wantsCapture(at: 2.9) && learning.wantsCapture(at: 3))
        precondition(!learning.startsCapture(at: 3, allowed: { false }) && learning.wantsCapture(at: 4))
        precondition(learning.startsCapture(at: 4, allowed: { true }) && !learning.wantsCapture(at: 5))
        var counted = FrameRateSource(traceCanRun: true, at: 0)
        counted.traced(at: 1)
        precondition(!counted.wantsCapture(at: 10))
        precondition(FrameRateSource(traceCanRun: false, at: 7).wantsCapture(at: 7))
        print("when the screen has to be recorded: ok")
    }
}
