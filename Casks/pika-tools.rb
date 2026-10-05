cask "pika-tools" do
  version "1.2.1"
  sha256 "285daa683abec9f3607c892c96ff4e40f37d7564f411812fe50331132b9e277d"

  url "https://github.com/dev-pikapik/pika-tools/releases/download/v#{version}/pika-tools.zip"
  name "pika-tools"
  desc "Menu bar gaming tools: plain clicks, blocked Ctrl shortcuts and double-space"
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
