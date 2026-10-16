import AppKit
import AVKit

@main
enum TestPictureInPicture {
    final class Owner {}

    final class Weak<T: AnyObject> {
        weak var value: T?
        init(_ value: T?) { self.value = value }
    }

    static func footprint() -> Double {
        var info = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<natural_t>.size)
        _ = withUnsafeMutablePointer(to: &info) { $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count) } }
        return Double(info.phys_footprint) / 1_048_576
    }

    @MainActor static func main() async {
        guard AVPictureInPictureController.isPictureInPictureSupported() else {
            print("skipped: this Mac cannot show Picture in Picture")
            return
        }
        _ = NSApplication.shared
        var owners: [Weak<Owner>] = [], pips: [Weak<PictureInPicture>] = []
        let cycles = 200, warmUp = 10, tolerance = 2.0
        let layer = AVSampleBufferDisplayLayer()
        var base = 0.0
        for cycle in -warmUp..<cycles {
            if cycle == 0 {
                try? await Task.sleep(for: .milliseconds(300))
                base = footprint()
            }
            autoreleasepool {
                let held = Owner()
                var made = PictureInPicture(layer: layer, host: PictureInPicture.Host(
                    duration: { _ = held; return .zero }, isPlaying: { false }, setPlaying: { _ in }, skip: { _ in }, changed: {}, started: {}, stopped: {}))
                if cycle >= 0 { owners.append(Weak(held)); pips.append(Weak(made)) }
                made?.refresh()
                made?.close()
                precondition(made?.isActive == false && made?.isPossible == false, "a closed small window must report nothing")
                made = nil
            }
        }
        try? await Task.sleep(for: .milliseconds(300))
        let pipsLeft = pips.filter { $0.value != nil }.count, ownersLeft = owners.filter { $0.value != nil }.count
        precondition(pipsLeft == 0 && ownersLeft == 0, "the small window must let go of the player when it is closed: \(pipsLeft) windows and \(ownersLeft) players stayed")
        let grown = footprint() - base
        precondition(grown < tolerance, "memory grew by \(String(format: "%.1f", grown)) MB over \(cycles) cycles, the limit is \(tolerance) MB")
        print("Picture in Picture: closing it frees the video it was showing in \(cycles) of \(cycles) cycles and memory grew by \(String(format: "%.1f", grown)) MB (limit \(tolerance) MB): ok")
    }
}
