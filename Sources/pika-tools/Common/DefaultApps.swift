import AppKit
import UniformTypeIdentifiers

protocol DefaultAppSystem {
    func handler(of type: UTType) -> URL?
    func handlers(of type: UTType) -> [URL]
    func app(withID id: String) -> URL?
    func assign(_ app: URL, to type: UTType) async throws
}

extension NSWorkspace: DefaultAppSystem {
    func handler(of type: UTType) -> URL? { urlForApplication(toOpen: type) }
    func handlers(of type: UTType) -> [URL] { urlsForApplications(toOpen: type) }
    func app(withID id: String) -> URL? { urlForApplication(withBundleIdentifier: id) }
    func assign(_ app: URL, to type: UTType) async throws { try await setDefaultApplication(at: app, toOpen: type) }
}

@Observable
final class DefaultApps {
    private let types: [UTType]
    private let target: URL
    private let previousKey: String
    private let fallback: String?
    private let system: DefaultAppSystem
    private let defaults: UserDefaults

    private(set) var isOn = false
    private(set) var returnsTo: [String] = []

    init(types: [UTType], target: URL, previousKey: String, fallback: String? = nil, system: DefaultAppSystem = NSWorkspace.shared, defaults: UserDefaults = .standard) {
        self.types = types
        self.target = target
        self.previousKey = previousKey
        self.fallback = fallback
        self.system = system
        self.defaults = defaults
        refresh()
    }

    func refresh() {
        isOn = types.allSatisfy { system.handler(of: $0).map(isTarget) == true }
        returnsTo = isOn ? names(of: remembered) : []
    }

    @discardableResult
    func set(_ on: Bool) -> Task<Void, Never> {
        var previous = remembered
        if on {
            for type in types {
                guard let id = system.handler(of: type).flatMap({ Bundle(url: $0)?.bundleIdentifier }), id != targetID else { continue }
                previous[type.identifier] = id
            }
            defaults.set(previous, forKey: previousKey)
        } else {
            defaults.removeObject(forKey: previousKey)
        }
        let apps = types.map { on ? target : restoring($0, previous) }
        isOn = on
        returnsTo = on ? names(of: previous) : []
        return Task { @MainActor in
            for (type, app) in zip(types, apps) {
                guard let app, system.handler(of: type).map({ same($0, app) }) != true else { continue }
                do { try await system.assign(app, to: type) } catch { break }
            }
            refresh()
        }
    }

    private var remembered: [String: String] {
        defaults.dictionary(forKey: previousKey) as? [String: String] ?? [:]
    }

    private var targetID: String? { Bundle(url: target)?.bundleIdentifier }

    private func isTarget(_ url: URL) -> Bool { same(url, target) }

    private func same(_ a: URL, _ b: URL) -> Bool {
        a.resolvingSymlinksInPath() == b.resolvingSymlinksInPath() || Bundle(url: a)?.bundleIdentifier.map { $0 == Bundle(url: b)?.bundleIdentifier } == true
    }

    private func restoring(_ type: UTType, _ previous: [String: String]) -> URL? {
        let id = previous[type.identifier]
        if let app = id.flatMap(system.app(withID:)) ?? fallback.flatMap(system.app(withID:)) { return app }
        return id == nil ? nil : system.handlers(of: type).first { !isTarget($0) }
    }

    private func names(of previous: [String: String]) -> [String] {
        var seen = Set<String>()
        return types.compactMap { previous[$0.identifier] }
            .compactMap { system.app(withID: $0)?.deletingPathExtension().lastPathComponent }
            .filter { seen.insert($0).inserted }
    }
}
