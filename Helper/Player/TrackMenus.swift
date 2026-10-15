import AppKit
import UniformTypeIdentifiers

extension PlayerController {
    static let trackItemTag = 4207
    private static let choiceStore = "trackChoices"
    private static let off = "off"

    private static func id(_ track: Track) -> String { "a\(track.index)" }

    private static func title(_ track: Track, in tracks: [Track]) -> String {
        PlayerTracks.title(language: track.language, name: track.title, number: (tracks.firstIndex { $0 === track } ?? 0) + 1)
    }

    func restoreTracks(of url: URL, resume: Double, siblings: [URL]?) {
        guard let engine else { return }
        let saved = (resumeKey.flatMap { (UserDefaults.standard.dictionary(forKey: Self.choiceStore) as? [String: [String]])?[$0] }) ?? []
        let audio = engine.audioTracks.first { Self.id($0) == saved.first }
        if let audio { engine.selectAudio(audio) }
        subtitles.position = { [weak self] in self?.engine?.position.seconds ?? 0 }
        subtitles.view.videoSize = engine.hasVideo ? engine.size : .zero
        subtitles.open(url, resume: resume, saved: saved.count > 1 ? saved[1] : "", delay: PlayerChoices.delay(saved), audioLanguage: (audio ?? engine.audioTrack)?.language, neighbours: siblings)
    }

    private func saveChoices() {
        guard let engine, let resumeKey else { return }
        let subtitle = subtitles.chosen ? subtitles.selected ?? Self.off : ""
        let saved = UserDefaults.standard.dictionary(forKey: Self.choiceStore) as? [String: [String]] ?? [:]
        UserDefaults.standard.set(PlayerChoices.updated(saved, key: resumeKey, audio: engine.audioTrack.map(Self.id) ?? "", subtitle: subtitle, delay: subtitles.delay, at: Date().timeIntervalSince1970), forKey: Self.choiceStore)
    }

    func audioItems() -> [NSMenuItem] {
        let tracks = engine?.audioTracks ?? []
        guard !tracks.isEmpty else { return [trackItem(String(localized: "None"), nil, nil)] }
        return tracks.map { trackItem(Self.title($0, in: tracks), #selector(chooseAudio), Self.id($0)) }
    }

    func subtitleItems() -> [NSMenuItem] {
        [trackItem(String(localized: "Off"), #selector(chooseSubtitle), Self.off)] + subtitles.tracks.map { trackItem($0.title, #selector(chooseSubtitle), $0.id) }
    }

    private func trackItem(_ title: String, _ action: Selector?, _ id: String?) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        item.representedObject = id
        item.tag = Self.trackItemTag
        return item
    }

    @objc func chooseAudio(_ sender: NSMenuItem) {
        guard let engine, let track = engine.audioTracks.first(where: { Self.id($0) == sender.representedObject as? String }) else { return }
        engine.selectAudio(track)
        saveChoices()
        showControls()
    }

    @objc func chooseSubtitle(_ sender: NSMenuItem) {
        let id = sender.representedObject as? String
        subtitles.choose(id == Self.off ? nil : id)
        saveChoices()
        showControls()
    }

    @objc func addSubtitleFile(_ sender: Any?) {
        guard let window else { return }
        let panel = NSOpenPanel()
        panel.allowedContentTypes = SubtitleFiles.extensions.sorted().compactMap { UTType(filenameExtension: $0) }
        panel.beginSheetModal(for: window) { [weak self] response in
            guard response == .OK, let url = panel.url else { return }
            self?.addSubtitle(url)
        }
    }

    func addSubtitle(_ url: URL) {
        guard engine?.hasVideo == true else { return }
        subtitles.load(url, select: true, failed: { [weak self] in self?.subtitles.announce(String(localized: "Couldn’t read this subtitle file.")) }, done: { [weak self] in self?.saveChoices() })
    }

    @objc func showTrackMenu(_ sender: NSButton) {
        let menu = NSMenu()
        menu.addItem(.sectionHeader(title: String(localized: "Audio")))
        audioItems().forEach(menu.addItem)
        menu.addItem(.sectionHeader(title: String(localized: "Subtitles")))
        subtitleItems().forEach(menu.addItem)
        let add = NSMenuItem(title: String(localized: "Add Subtitle File…"), action: #selector(addSubtitleFile), keyEquivalent: "")
        add.target = self
        menu.addItem(add)
        showControls()
        menu.popUp(positioning: nil, at: NSPoint(x: 0, y: sender.bounds.maxY + 6), in: sender)
    }

    func validateTrack(_ item: NSMenuItem) -> Bool {
        let id = item.representedObject as? String
        switch item.action {
        case #selector(chooseAudio):
            item.state = engine?.audioTrack.map(Self.id) == id ? .on : .off
            return true
        case #selector(chooseSubtitle):
            let available = id == Self.off || subtitles.tracks.first { $0.id == id }?.available == true
            item.state = (id == Self.off ? subtitles.selected == nil : subtitles.selected == id) ? .on : .off
            return available
        default:
            return engine?.hasVideo == true
        }
    }

    func performTrack(_ action: PlayerAction) -> Bool {
        guard let engine, engine.hasVideo else { return false }
        switch action {
        case .nextAudio:
            let tracks = engine.audioTracks
            guard tracks.count > 1 else { return false }
            let next = tracks[((engine.audioTrack.flatMap { current in tracks.firstIndex { $0 === current } } ?? -1) + 1) % tracks.count]
            engine.selectAudio(next)
            subtitles.announce(String(localized: "Audio: \(Self.title(next, in: tracks))"))
            saveChoices()
        case .nextSubtitle:
            subtitles.cycle()
            let name = subtitles.tracks.first { $0.id == subtitles.selected }?.title ?? String(localized: "Off")
            subtitles.announce(String(localized: "Subtitles: \(name)"))
            saveChoices()
        case .subtitleEarlier, .subtitleLater:
            subtitles.shift(by: action == .subtitleLater ? 0.1 : -0.1)
            saveChoices()
        case .subtitleLarger: subtitles.resize(by: 0.1)
        case .subtitleSmaller: subtitles.resize(by: -0.1)
        default: return false
        }
        return true
    }
}
