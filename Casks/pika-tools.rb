cask "pika-tools" do
  version "1.0.2"
  sha256 "92c7d03cd46c5d4e61b5c04a5b35cba0bac5dbcad1ebc9d8ed164f1758fb43d0"

  url "https://github.com/dev-pikapik/pika-tools/releases/download/v#{version}/pika-tools.zip"
  name "pika-tools"
  desc "Menu bar tools: plain clicks and blocked Ctrl shortcuts for games"
  homepage "https://github.com/dev-pikapik/pika-tools"

  auto_updates true
  depends_on macos: :sonoma

  app "pika-tools.app"

  postflight_steps do
    run "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "{{appdir}}/pika-tools.app"], must_succeed: false
  end

  uninstall_preflight_steps do
    run "{{appdir}}/pika-tools.app/Contents/MacOS/pika-tools", args: ["--uninstall"], must_succeed: false
  end

  uninstall quit: "com.pesotchi.pika-tools"

  zap trash: "~/Library/Preferences/com.pesotchi.pika-tools.plist"

  caveats <<~EOS
    Дай pika-tools два доступа в System Settings › Privacy & Security:
      Accessibility и Input Monitoring
    Окно с подсказкой откроется само.
  EOS
end
