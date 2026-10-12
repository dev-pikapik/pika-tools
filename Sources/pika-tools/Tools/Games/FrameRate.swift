import CoreGraphics
import Foundation

enum FrameRateCorner: String, CaseIterable {
    case topLeft = "top-left"
    case topRight = "top-right"
    case bottomLeft = "bottom-left"
    case bottomRight = "bottom-right"

    static let standard = topRight

    var isTop: Bool { self == .topLeft || self == .topRight }
    var isLeft: Bool { self == .topLeft || self == .bottomLeft }
}

enum FrameRateShown: Equatable {
    case measuring
    case paused
    case live(Int)

    init(_ fps: Double) {
        let rounded = fps.isFinite ? Int(min(max(fps.rounded(), 0), 999)) : 0
        self = rounded > 0 ? .live(rounded) : .paused
    }
}

struct PerfTraceReader {
    private static let newline = UInt8(ascii: "\n"), carriage = UInt8(ascii: "\r")
    private static let open = [UInt8(ascii: "{")], close = [UInt8(ascii: "}")]

    private var line: [UInt8] = []
    private var object: [UInt8] = []
    private var inside = false

    mutating func feed(_ chunk: some Sequence<UInt8>) -> [Double] {
        var rates: [Double] = []
        for byte in chunk {
            guard byte == Self.newline else {
                line.append(byte)
                continue
            }
            if line.last == Self.carriage { line.removeLast() }
            if line == Self.open {
                inside = true
                object = line
            } else if inside {
                object.append(Self.newline)
                object += line
                if line == Self.close {
                    inside = false
                    if let rate = Self.rate(Data(object)) { rates.append(rate) }
                }
            }
            line.removeAll(keepingCapacity: true)
        }
        return rates
    }

    static func rate(_ json: Data) -> Double? {
        guard let root = (try? JSONSerialization.jsonObject(with: json)) as? [String: Any],
              let layers = root["Layers"] as? [[String: Any]]
        else { return nil }
        let drawing = layers.compactMap { layer -> (area: Double, fps: Double)? in
            let size = layer["Configuration"] as? [String: Any]
            let presented = (layer["Performance Stats"] as? [String: Any])?["Presented Frame Stats"] as? [String: Any]
            guard let frames = presented?["Frame Count"] as? Int, frames > 0, let fps = presented?["FPS"] as? Double else { return nil }
            return ((size?["Width (pixels)"] as? Double ?? 0) * (size?["Height (pixels)"] as? Double ?? 0), fps)
        }
        return drawing.max { $0.area < $1.area }?.fps ?? 0
    }
}

enum FrameCoverage {
    static let share = 0.3

    static func target(window: CGRect, display: CGRect, output: CGSize) -> CGRect {
        let visible = window.intersection(display)
        guard !visible.isNull, display.width > 0, display.height > 0 else { return .null }
        let sx = output.width / display.width, sy = output.height / display.height
        return CGRect(x: (visible.minX - display.minX) * sx, y: (visible.minY - display.minY) * sy, width: visible.width * sx, height: visible.height * sy)
    }

    static func presents(dirty: [CGRect], target: CGRect) -> Bool {
        let whole = area(target)
        return whole > 0 && dirty.reduce(0) { $0 + area($1.intersection(target)) } >= whole * share
    }

    private static func area(_ rect: CGRect) -> CGFloat {
        rect.isNull ? 0 : rect.width * rect.height
    }
}

enum FramePillPlace {
    static let margin: CGFloat = 12
    static let titleBar: CGFloat = 28

    static func cocoa(_ quartz: CGRect, primaryHeight: CGFloat) -> CGRect {
        CGRect(x: quartz.minX, y: primaryHeight - quartz.maxY, width: quartz.width, height: quartz.height)
    }

    static func isFullscreen(window: CGRect, display: CGRect, top: CGFloat = 0) -> Bool {
        window.width >= display.width - 1 && window.maxY >= display.maxY - 1 && window.minY <= display.minY + top + 1
    }

    static func frame(of pill: CGSize, corner: FrameRateCorner, in area: CGRect, belowTitleBar: Bool) -> CGRect {
        let x = corner.isLeft ? area.minX + margin : area.maxX - margin - pill.width
        let y = corner.isTop ? area.maxY - margin - (belowTitleBar ? titleBar : 0) - pill.height : area.minY + margin
        return CGRect(origin: CGPoint(x: x, y: y), size: pill)
    }
}

struct FrameRateSource {
    static let grace = 3.0
    static let silence = 1.6

    private let begun: Double
    private let wait: Double
    private var lastTrace: Double?
    private var tried = false

    init(traceCanRun: Bool, at now: Double) {
        begun = now
        wait = traceCanRun ? Self.grace : 0
    }

    var traceSeen: Bool { lastTrace != nil }

    mutating func traced(at now: Double) {
        lastTrace = now
    }

    func traceStalled(at now: Double) -> Bool {
        lastTrace.map { now - $0 > Self.silence } ?? false
    }

    func wantsCapture(at now: Double) -> Bool {
        lastTrace == nil && !tried && now - begun >= wait
    }

    mutating func startsCapture(at now: Double, allowed: () -> Bool) -> Bool {
        guard wantsCapture(at: now), allowed() else { return false }
        tried = true
        return true
    }
}
