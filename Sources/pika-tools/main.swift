import Foundation

if CommandLine.arguments.contains("--uninstall") {
    LoginItem.shared.set(false)
    exit(0)
}

PikaToolsApp.main()
