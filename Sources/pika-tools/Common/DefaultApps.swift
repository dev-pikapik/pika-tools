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

    private var current: [String: URL] = [:]
    private(set) var busy = false

    init(types: [UTType], target: URL, previousKey: String, fallback: String? = nil, system: DefaultAppSystem = NSWorkspace.shared, defaults: UserDefaults = .standard) {
        self.types = types
        self.target = target
        self.previousKey = previousKey
        self.fallback = fallback
        self.system = system
        self.defaults = defaults
        refresh()
    }

    var isOn: Bool { isOn(types) }

    func isOn(_ types: [UTType]) -> Bool {
        types.allSatisfy { current[$0.identifier].map(isTarget) == true }
    }

    func app(of types: [UTType]) -> URL? {
        types.compactMap { current[$0.identifier] }.first { !isTarget($0) } ?? (isOn(types) ? target : nil)
    }

    func refresh() {
        current = Dictionary(types.compactMap { type in system.handler(of: type).map { (type.identifier, $0) } }, uniquingKeysWith: { first, _ in first })
    }

    @discardableResult
    func set(_ on: Bool, for subset: [UTType]? = nil) -> Task<Void, Never> {
        let types = subset ?? self.types
        var previous = remembered
        if on {
            for type in types {
                guard let id = system.handler(of: type).flatMap({ Bundle(url: $0)?.bundleIdentifier }), id != targetID else { continue }
                previous[type.identifier] = id
            }
            defaults.set(previous, forKey: previousKey)
        }
        let apps = types.map { on ? target : restoring($0, previous) }
        return Task { @MainActor in
            busy = true
            for (type, app) in zip(types, apps) {
                guard let app, !handles(type, app) else { continue }
                guard await assign(app, to: type) else { break }
                refresh()
            }
            if !on { forget(types.filter { !handles($0, target) }) }
            busy = false
            refresh()
        }
    }

    @MainActor
    private func assign(_ app: URL, to type: UTType) async -> Bool {
        var answer: Bool?
        Task { @MainActor in
            do { try await system.assign(app, to: type); answer = true } catch { answer = ((error as NSError).userInfo[NSUnderlyingErrorKey] as? NSError)?.code == Int(userCanceledErr) }
        }
        await Task.yield()
        let deadline = Date.now.addingTimeInterval(60)
        while answer == nil, !handles(type, app), Date.now < deadline {
            try? await Task.sleep(for: .milliseconds(200))
        }
        return answer ?? handles(type, app)
    }

    private func forget(_ types: [UTType]) {
        var previous = remembered
        types.forEach { previous[$0.identifier] = nil }
        defaults.set(previous.isEmpty ? nil : previous, forKey: previousKey)
    }

    private var remembered: [String: String] {
        defaults.dictionary(forKey: previousKey) as? [String: String] ?? [:]
    }

    private var targetID: String? { Bundle(url: target)?.bundleIdentifier }

    private func isTarget(_ url: URL) -> Bool { same(url, target) }

    private func handles(_ type: UTType, _ app: URL) -> Bool { system.handler(of: type).map { same($0, app) } == true }

    private func same(_ a: URL, _ b: URL) -> Bool {
        a.resolvingSymlinksInPath() == b.resolvingSymlinksInPath() || Bundle(url: a)?.bundleIdentifier.map { $0 == Bundle(url: b)?.bundleIdentifier } == true
    }

    private func restoring(_ type: UTType, _ previous: [String: String]) -> URL? {
        let id = previous[type.identifier]
        let capable = fallback.flatMap(system.app(withID:)).flatMap { app in system.handlers(of: type).contains { same($0, app) } ? app : nil }
        if let app = id.flatMap(system.app(withID:)) ?? capable { return app }
        return id == nil ? nil : system.handlers(of: type).first { !isTarget($0) }
    }
}
