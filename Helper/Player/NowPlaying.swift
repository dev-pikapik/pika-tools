import MediaPlayer

final class NowPlaying {
    static let shared = NowPlaying()
    private weak var owner: PlayerController?

    private init() {
        let center = MPRemoteCommandCenter.shared()
        func add(_ command: MPRemoteCommand, _ action: @escaping (PlayerController, MPRemoteCommandEvent) -> Void) {
            command.addTarget { [weak self] event in
                guard let owner = self?.owner else { return .noActionableNowPlayingItem }
                DispatchQueue.main.async { action(owner, event) }
                return .success
            }
        }
        add(center.playCommand) { owner, _ in owner.setPlaying(true) }
        add(center.pauseCommand) { owner, _ in owner.setPlaying(false) }
        add(center.togglePlayPauseCommand) { owner, _ in owner.playPause(nil) }
        add(center.nextTrackCommand) { owner, _ in _ = owner.perform(.next) }
        add(center.previousTrackCommand) { owner, _ in _ = owner.perform(.previous) }
        add(center.changePlaybackPositionCommand) { owner, event in
            if let event = event as? MPChangePlaybackPositionCommandEvent { owner.seek(event.positionTime) }
        }
    }

    func publish(_ info: [String: Any], playing: Bool, for controller: PlayerController) {
        owner = controller
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        MPNowPlayingInfoCenter.default().playbackState = playing ? .playing : .paused
    }

    func clear(_ controller: PlayerController) {
        guard owner === controller else { return }
        owner = nil
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        MPNowPlayingInfoCenter.default().playbackState = .stopped
    }
}
