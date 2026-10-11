import Foundation

if CommandLine.arguments.contains("--uninstall") {
    LoginItem.shared.apply(false)
    AnimationsTool.uninstall()
    KeyRepeatTool.uninstall()
    DockEdges.restore()
    HotKeyTrace().restore()
    exit(0)
}

if Updater.moveToNewName() { exit(0) }

PikaToolsApp.main()
