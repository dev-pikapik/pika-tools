import AppKit
import AVKit

@main
enum TestPictureInPicture {
    final class Owner {}

    final class Weak<T: AnyObject> {
        weak var value: T?
        init(_ value: T?) { self.value = value }
    }

    @MainActor static func main() async {
        guard AVPictureInPictureController.isPictureInPictureSupported() else {
            print("skipped: this Mac cannot show Picture in Picture")
            return
        }
        _ = NSApplication.shared
        var owners: [Weak<Owner>] = [], pips: [Weak<PictureInPicture>] = []
        let cycles = 200
        for _ in 0..<cycles {
            autoreleasepool {
                let held = Owner()
                var made = PictureInPicture(layer: AVSampleBufferDisplayLayer(), host: PictureInPicture.Host(
                    duration: { _ = held; return .zero }, isPlaying: { false }, setPlaying: { _ in }, skip: { _ in }, changed: {}, started: {}, stopped: {}))
                owners.append(Weak(held))
                pips.append(Weak(made))
                made?.refresh()
                made?.close()
                precondition(made?.isActive == false && made?.isPossible == false, "a closed small window must report nothing")
                made = nil
            }
        }
        try? await Task.sleep(for: .milliseconds(300))
        let pipsLeft = pips.filter { $0.value != nil }.count, ownersLeft = owners.filter { $0.value != nil }.count
        precondition(pipsLeft == 0 && ownersLeft == 0, "the small window must let go of the player when it is closed: \(pipsLeft) windows and \(ownersLeft) players stayed")
        print("Picture in Picture: closing it frees the video it was showing in \(cycles) of \(cycles) cycles: ok")
    }
}
