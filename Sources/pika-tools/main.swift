import Foundation

if CommandLine.arguments.contains("--uninstall") {
    LoginItem.shared.apply(false)
    #if !APPSTORE
    AnimationsTool.uninstall()
    #endif
    exit(0)
}

#if !APPSTORE
if Updater.moveToNewName() { exit(0) }
#endif

PikaToolsApp.main()
