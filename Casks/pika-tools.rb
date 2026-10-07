cask "pika-tools" do
  version "1.18.0"
  sha256 "e671fc870c5a41e8c90d52e44dd3325620d0ba8860cf5dcf66600fb841e3b494"

  url "https://github.com/dev-pikapik/pika-tools/releases/download/v#{version}/pika-tools.zip"
  name "pika-tools"
  desc "Menu bar tools for keys, windows and the Dock, plus Keep Awake"
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
    pika-tools needs two permissions in System Settings › Privacy & Security:
      Accessibility and Input Monitoring
    The app opens a window that walks you through them.
  EOS
end
