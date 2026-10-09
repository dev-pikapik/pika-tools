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

        board.clearContents()
        board.writeObjects(["/System/Applications/Calculator.app" as NSString])
        precondition(AppShelf.apps(on: board).isEmpty)

        board.releaseGlobally()
        print("ok")
    }
}
