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
            board.clearContents()
            board.setString("\(minecraft.processIdentifier)\tjava\t7,02 ГБ\t4,78 ГБ\tme\t97,5\t27,2\t94\t741\t", forType: .string)
            precondition(AppShelf.apps(on: board).isEmpty)
            let files = AppShelf.apps(on: board, accepting: { GameModeTool.key($0) != nil }, textFiles: GameModeTool.processFiles)
            precondition(files == [minecraft.executableURL!])
            precondition(files.compactMap(GameModeTool.key) == [GameModeTool.key(minecraft)])
            let actual = AppShelf.apps(on: NSPasteboard(name: .drag), accepting: { GameModeTool.key($0) != nil }, textFiles: GameModeTool.processFiles)
            if NSPasteboard(name: .drag).string(forType: .string)?.contains("\(minecraft.processIdentifier)\tjava") == true {
                precondition(actual == [minecraft.executableURL!])
                print("Activity Monitor drag: ok")
            }
            print("running Minecraft: ok")
        }

        board.clearContents()
        board.writeObjects(["/System/Applications/Calculator.app" as NSString])
        precondition(AppShelf.apps(on: board).isEmpty)

        board.releaseGlobally()
        print("ok")
    }
}
