import Foundation

if CommandLine.arguments.contains("--uninstall") {
    LoginItem.shared.apply(false)
    exit(0)
}

PikaToolsApp.main()
