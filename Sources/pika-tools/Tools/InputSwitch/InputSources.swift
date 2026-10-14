import Carbon

enum InputSources {
    static var currentID: String? {
        TISCopyCurrentKeyboardInputSource().flatMap { string($0.takeRetainedValue(), kTISPropertyInputSourceID) }
    }

    /// Steps from `currentID`, not from the source selected now: every running copy of pikapik
    /// sees the same gesture, and stepping from the same source makes them all pick the same one.
    static func select(_ direction: InputSwitchGesture.Direction, from currentID: String? = InputSources.currentID) {
        let filter = [
            kTISPropertyInputSourceCategory: kTISCategoryKeyboardInputSource as Any,
            kTISPropertyInputSourceIsSelectCapable: true,
            kTISPropertyInputSourceIsEnabled: true,
        ] as CFDictionary
        guard let all = TISCreateInputSourceList(filter, false)?.takeRetainedValue() as? [TISInputSource] else { return }

        let types = [kTISTypeKeyboardLayout, kTISTypeKeyboardInputMode, kTISTypeKeyboardInputMethodWithoutModes]
            .map { $0! as String }
        let sources = all.filter { types.contains(string($0, kTISPropertyInputSourceType) ?? "") }
        guard sources.count > 1 else { return }

        let target: Int
        if let index = sources.firstIndex(where: { string($0, kTISPropertyInputSourceID) == currentID }) {
            let step = direction == .next ? 1 : sources.count - 1
            target = (index + step) % sources.count
        } else {
            target = direction == .next ? 0 : sources.count - 1
        }
        TISSelectInputSource(sources[target])
    }

    static func string(_ source: TISInputSource, _ key: CFString) -> String? {
        guard let value = TISGetInputSourceProperty(source, key) else { return nil }
        return Unmanaged<CFString>.fromOpaque(value).takeUnretainedValue() as String
    }
}
