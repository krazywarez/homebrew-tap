class AmbientCompanions < Formula
  desc "Ambient system companions over one privacy-preserving signal daemon"
  homepage "https://gitbay.org/krz/ambient-companions"
  url "https://gitbay.org/krz/ambient-companions.git",
      tag:      "v1.0.0",
      revision: "106c62e2f9a644811a6f9c261331a70b76139497"
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

    # The IOKit collector runs out of process as a child of signald.
    # --disable-sandbox: SwiftPM sandboxes its own manifest compile, and that
    # sandbox_apply fails inside Homebrew's build sandbox. Homebrew's is still
    # in force around the whole build.
    system "swift", "build", "-c", "release", "--disable-sandbox",
                    "--package-path", "macos-collector",
                    "--scratch-path", buildpath/"swift-build"
    bin.install buildpath/"swift-build/release/macos-collector"

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
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/signald --version")
    assert_match version.to_s, shell_output("#{bin}/terminal-garden --version")
    assert_match version.to_s, shell_output("#{bin}/terminal-pet --version")
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
