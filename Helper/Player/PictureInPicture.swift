import AVKit

final class PictureInPicture: NSObject, AVPictureInPictureControllerDelegate, AVPictureInPictureSampleBufferPlaybackDelegate {
    struct Host {
        let duration: () -> CMTime
        let isPlaying: () -> Bool
        let setPlaying: (Bool) -> Void
        let skip: (Double) -> Void
        let changed: () -> Void
        let started: () -> Void
        let stopped: () -> Void
    }

    private let host: Host
    private var controller: AVPictureInPictureController!
    private var observation: NSKeyValueObservation?
    private var wasPlaying = false

    init?(layer: AVSampleBufferDisplayLayer, host: Host) {
        guard AVPictureInPictureController.isPictureInPictureSupported() else { return nil }
        self.host = host
        wasPlaying = host.isPlaying()
        super.init()
        controller = AVPictureInPictureController(contentSource: AVPictureInPictureController.ContentSource(sampleBufferDisplayLayer: layer, playbackDelegate: self))
        controller.delegate = self
        observation = controller.observe(\.isPictureInPicturePossible) { _, _ in DispatchQueue.main.async { host.changed() } }
    }

    var isPossible: Bool { controller.isPictureInPicturePossible }

    var isActive: Bool { controller.isPictureInPictureActive }

    func toggle() {
        if isActive { controller.stopPictureInPicture() } else if isPossible { controller.startPictureInPicture() }
    }

    func refresh() {
        let playing = host.isPlaying()
        guard playing != wasPlaying else { return }
        wasPlaying = playing
        controller.invalidatePlaybackState()
    }

    func close() {
        observation = nil
        controller.delegate = nil
        if isActive { controller.stopPictureInPicture() }
    }

    func pictureInPictureControllerDidStartPictureInPicture(_ controller: AVPictureInPictureController) {
        host.started()
        host.changed()
    }

    func pictureInPictureControllerDidStopPictureInPicture(_ controller: AVPictureInPictureController) {
        host.stopped()
        host.changed()
    }

    func pictureInPictureController(_ controller: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        host.stopped()
        completionHandler(true)
    }

    func pictureInPictureController(_ controller: AVPictureInPictureController, setPlaying playing: Bool) {
        host.setPlaying(playing)
    }

    func pictureInPictureControllerTimeRangeForPlayback(_ controller: AVPictureInPictureController) -> CMTimeRange {
        CMTimeRange(start: .zero, duration: host.duration())
    }

    func pictureInPictureControllerIsPlaybackPaused(_ controller: AVPictureInPictureController) -> Bool {
        !host.isPlaying()
    }

    func pictureInPictureController(_ controller: AVPictureInPictureController, didTransitionToRenderSize newRenderSize: CMVideoDimensions) {}

    func pictureInPictureController(_ controller: AVPictureInPictureController, skipByInterval skipInterval: CMTime, completion completionHandler: @escaping () -> Void) {
        host.skip(skipInterval.seconds)
        completionHandler()
    }
}
