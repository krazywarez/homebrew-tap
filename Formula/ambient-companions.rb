class AmbientCompanions < Formula
  desc "Ambient system companions over one privacy-preserving signal daemon"
  homepage "https://gitbay.org/krz/ambient-companions"
  url "https://gitbay.org/krz/ambient-companions.git",
      tag:      "v1.2.1",
      revision: "d04b3e45ef2c3e929ea24273dabfcf7ecdb68715"
  license "0BSD"
  head "https://gitbay.org/krz/ambient-companions.git", branch: "main"

  depends_on "rust" => :build
  # macos-collector is a SwiftPM package; swift-tools-version 5.9 needs Xcode 15.
  depends_on xcode: ["15.0", :build]
  depends_on :macos

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/signald")
    system "cargo", "install", *std_cargo_args(path: "crates/terminal-garden")
    system "cargo", "install", *std_cargo_args(path: "crates/terminal-pet")
    system "cargo", "install", *std_cargo_args(path: "crates/pet-life")

    # The IOKit collector runs out of process as a child of signald.
    # --disable-sandbox: SwiftPM sandboxes its own manifest compile, and that
    # sandbox_apply fails inside Homebrew's build sandbox. Homebrew's is still
    # in force around the whole build.
    system "swift", "build", "-c", "release", "--disable-sandbox",
                    "--package-path", "macos-collector",
                    "--scratch-path", buildpath/"swift-build"
    bin.install buildpath/"swift-build/release/macos-collector"

    # The menu-bar face. SwiftPM cannot emit a .app, so the repo's own script
    # assembles the bundle; installing it into the prefix rather than shipping
    # a cask keeps this build-from-source, which also means Gatekeeper never
    # quarantines it.
    system "swift", "build", "-c", "release", "--disable-sandbox",
                    "--package-path", "menubar-pet",
                    "--scratch-path", buildpath/"menubar-build"
    system "menubar-pet/scripts/bundle.sh",
           buildpath/"menubar-build/release/menubar-pet", prefix
    # pet-life sits beside the app binary so the bundle finds it without PATH.
    (prefix/"menubar-pet.app/Contents/MacOS").install_symlink bin/"pet-life"

    # Sourced from the user's .zshrc; see the README install section.
    pkgshare.install "shell-hooks/signald-hooks.zsh"
    # The launchd template, for a manual install. `brew services` uses the
    # service block below instead.
    pkgshare.install "packaging/net.krz.signald.plist"
  end

  service do
    # Repositories to watch come from ~/.config/signald/repos — launchd starts
    # an agent in /, so there is no useful working directory to fall back on.
    run [opt_bin/"signald", "--collector", opt_bin/"macos-collector"]
    keep_alive true
    run_type :immediate
    log_path var/"log/signald.log"
    error_log_path var/"log/signald.err.log"
  end

  def caveats
    <<~EOS
      Name the repositories to watch, one path per line:
        mkdir -p ~/.config/signald
        echo ~/git/some-repo > ~/.config/signald/repos
        brew services restart ambient-companions

      Then source the terminal collector hooks from your .zshrc:
        source "#{opt_pkgshare}/signald-hooks.zsh"

      The menu-bar pet is an app, not a service. Launch it with:
        open "#{opt_prefix}/menubar-pet.app"
      and add it under System Settings > General > Login Items to keep it.
      It has one life: neglect it for a week and it dies for good.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/signald --version")
    assert_match version.to_s, shell_output("#{bin}/terminal-garden --version")
    assert_match version.to_s, shell_output("#{bin}/terminal-pet --version")
    assert_match version.to_s, shell_output("#{bin}/pet-life --version")
    # The app is only an app if the bundle is intact.
    assert_path_exists prefix/"menubar-pet.app/Contents/MacOS/menubar-pet"
    assert_match "true",
                 shell_output("plutil -extract LSUIElement raw " \
                              "#{prefix}/menubar-pet.app/Contents/Info.plist")
    # Unknown options exit 2 rather than being taken for a repository path.
    shell_output("#{bin}/signald --nonexistent-option 2>&1", 2)
    # One real IOKit read, no root. --once writes raw wire frames to stdout and
    # the human summary to stderr, so capture stderr alone: folding the binary
    # in with 2>&1 hands Ruby a string that is not valid UTF-8.
    assert_match "cpu_load", shell_output("#{bin}/macos-collector --once 2>&1 >/dev/null")
    # --hex is the same tick as ASCII: a 25-byte frame, 21-byte body. The
    # schema version deliberately is not pinned here — the canonical-frame
    # tests in the repo pin it on both the Rust and Swift sides, and asserting
    # it again from the tap only means this formula breaks on every schema
    # bump, in a different repository, for no extra coverage.
    hex = shell_output("#{bin}/macos-collector --once --hex 2>/dev/null")
    assert_match(/^15000000[0-9a-f]{42}$/, hex.lines.first.chomp)
  end
end
