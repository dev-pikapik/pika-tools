import AppKit

@main
enum TestAppDrop {
    static func main() {
        let board = NSPasteboard(name: NSPasteboard.Name("test-app-drop-\(UUID().uuidString)"))
        let app = URL(fileURLWithPath: "/System/Applications/Calculator.app")
        let file = URL(fileURLWithPath: "/etc/hosts")
        let folder = URL(fileURLWithPath: "/System/Applications")

        board.clearContents()
        board.writeObjects([file as NSURL, folder as NSURL])
        precondition(AppShelf.apps(on: board).isEmpty)

        board.clearContents()
        board.writeObjects([file as NSURL, app as NSURL, folder as NSURL])
        precondition(AppShelf.apps(on: board) == [app])

        let executable = URL(fileURLWithPath: "/bin/ls")
        board.clearContents()
        board.writeObjects([file as NSURL, executable as NSURL, app as NSURL, folder as NSURL])
        precondition(AppShelf.apps(on: board) == [app])
        precondition(AppShelf.apps(on: board, accepting: { GameModeTool.key($0) != nil }) == [executable, app])
        precondition(GameModeTool.key(executable) == executable.path)
        precondition(GameModeTool.key(file) == nil && GameModeTool.key(folder) == nil)
        precondition(GameModeTool.key(app) == "com.apple.calculator")

        if let minecraft = AppShelf.windowed.first(where: { GameRules.minecraft($0.executableURL?.path ?? "") != nil }) {
            precondition(minecraft.title == "Minecraft")
            precondition(GameModeTool.key(minecraft).hasSuffix("/runtime/"))
            precondition(GameModeTool.key(minecraft.executableURL!) == GameModeTool.key(minecraft))
            print("running Minecraft: ok")
        }

        board.clearContents()
        board.writeObjects(["/System/Applications/Calculator.app" as NSString])
        precondition(AppShelf.apps(on: board).isEmpty)

        board.releaseGlobally()
        print("ok")
    }
}
