cask "pika-tools" do
  version "1.0.0"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"

  url "https://github.com/dev-pikapik/pika-tools/releases/download/v#{version}/pika-tools.zip"
  name "pika-tools"
  desc "Menu bar tools: Ctrl+click works as a plain click"
  homepage "https://github.com/dev-pikapik/pika-tools"

  auto_updates true
  depends_on macos: ">= :sonoma"

  app "pika-tools.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{appdir}/pika-tools.app"]
    system_command "/usr/bin/tccutil", args: ["reset", "Accessibility", "com.pesotchi.pika-tools"], must_succeed: false
    system_command "/usr/bin/tccutil", args: ["reset", "ListenEvent", "com.pesotchi.pika-tools"], must_succeed: false
    system_command "/usr/bin/open", args: ["#{appdir}/pika-tools.app"]
  end

  uninstall_preflight do
    system_command "#{appdir}/pika-tools.app/Contents/MacOS/pika-tools", args: ["--uninstall"], must_succeed: false
  end

  uninstall quit: "com.pesotchi.pika-tools"

  zap trash: "~/Library/Preferences/com.pesotchi.pika-tools.plist"

  caveats <<~EOS
    Дай pika-tools два доступа в System Settings › Privacy & Security:
      Accessibility и Input Monitoring
    Окно с подсказкой откроется само.
  EOS
end
