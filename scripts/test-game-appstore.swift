import CoreGraphics
import Foundation

@main
enum TestGameAppStore {
    static func main() {
        let before = GameModeTool.screenLocked
        GameModeTool.shared.received("com.apple.screenIsLocked")
        #if APPSTORE
        precondition(GameModeTool.screenLocked)
        #endif
        precondition(!GameModeTool.shared.isPlaying)
        GameModeTool.shared.received("com.apple.screenIsUnlocked")
        precondition(GameModeTool.screenLocked == before)
        print("lock: ok")
    }
}
