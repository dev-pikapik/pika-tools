import Darwin

@main
enum TestBrew {
    static let ruby = ["/opt/homebrew/Library/Homebrew/vendor/portable-ruby/current/bin/ruby", "-W1", "--disable=gems,rubyopt"]
    static let sandbox = ruby + ["-I", "/opt/homebrew/Library/Homebrew", "--", "/opt/homebrew/Library/Homebrew/cask_artifact.rb", "/opt/homebrew/var/homebrew/sandbox/cask-1/payload.json", "0f1e"]
    static let shell = ["-zsh"]

    static func brew(_ args: String...) -> [String] {
        ruby + ["/opt/homebrew/Library/Homebrew/brew.rb"] + args
    }

    static func main() {
        precondition(Brew.replacesApp([brew("upgrade", "--cask", "pikapik"), shell]))
        precondition(Brew.replacesApp([sandbox, brew("upgrade", "--cask", "pikapik"), shell]))
        precondition(Brew.replacesApp([brew("reinstall", "--cask", "pikapik"), shell]))
        precondition(Brew.replacesApp([sandbox, brew("install", "--cask", "--force", "pikapik"), shell]))
        precondition(Brew.replacesApp([brew("--verbose", "upgrade", "pikapik")]))
        precondition(Brew.replacesApp([["/usr/local/Homebrew/Library/Homebrew/vendor/portable-ruby/current/bin/ruby", "/usr/local/Homebrew/Library/Homebrew/brew.rb", "upgrade"]]))

        precondition(!Brew.replacesApp([brew("uninstall", "--cask", "pikapik"), shell]))
        precondition(!Brew.replacesApp([sandbox, brew("uninstall", "--zap", "--cask", "pikapik"), shell]))
        precondition(!Brew.replacesApp([brew("bundle", "--file", "Brewfile"), shell]))
        precondition(!Brew.replacesApp([sandbox, brew("uninstall", "pikapik"), brew("upgrade"), shell]))
        precondition(!Brew.replacesApp([brew("--debug")]))
        precondition(!Brew.replacesApp([["/bin/sh", "-c", "upgrade"], ["/usr/bin/brew.rb.bak", "upgrade"]]))
        precondition(!Brew.replacesApp([[], shell]))
        precondition(!Brew.replacesApp([]))

        precondition(Brew.command(in: [sandbox, brew("--verbose", "reinstall", "pikapik")]) == "reinstall")
        precondition(Brew.command(in: [shell]) == nil)

        precondition(Brew.arguments(of: getpid()) == CommandLine.arguments)
        precondition(Brew.arguments(of: -1).isEmpty)
        print("brew: ok")
    }
}
