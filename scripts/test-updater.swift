@main
enum TestUpdater {
    static func main() {
        precondition(!Version.isNewer("1.26.2", than: "1.26.2"))
        precondition(!Version.isNewer("1.26.1", than: "1.26.2"))
        precondition(!Version.isNewer("1.9.9", than: "1.26.0"))
        precondition(Version.isNewer("1.26.10", than: "1.26.9"))
        precondition(!Version.isNewer("1.26.9", than: "1.26.10"))
        precondition(!Version.isNewer("v1.27.0", than: "1.27.0") && !Version.isNewer("1.27.0", than: "v1.27.0"))
        precondition(Version.parts("v1.27.0") == Version.parts("1.27.0"))
        precondition(!Version.isNewer("1.27.0", than: "1.27") && !Version.isNewer("1.27", than: "1.27.0"))
        precondition(Version.isNewer("2.0", than: "1.99.99"))
        print("updater: ok")
    }
}
