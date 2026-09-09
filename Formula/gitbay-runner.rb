class GitbayRunner < Formula
  desc "CI runner for gitbay: builds the repositories you attach it to"
  homepage "https://gitbay.org/krz/gitbay"
  url "https://gitbay.org/krz/gitbay.git",
      tag:      "v1.17.0",
      revision: "315847fa7864df2e1f29700ee5bb856a637dce8b"
  license "0BSD"
  head "https://gitbay.org/krz/gitbay.git", branch: "main"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "./cmd/gitbay-runner"
  end

  service do
    # No arguments: the runner reads ~/.config/gitbay-runner/config.toml,
    # which `gitbay-runner init` writes.
    run [opt_bin/"gitbay-runner"]
    keep_alive true
    log_path var/"log/gitbay-runner.log"
    error_log_path var/"log/gitbay-runner.err.log"
  end

  def caveats
    <<~EOS
      Generate this machine's key and config, and print the key to attach:
        gitbay-runner init -remote git@gitbay.org
      Attach it to each repository it should build, as a repository admin:
        gitbay repo runner add owner/name < ~/.config/gitbay-runner/id_ed25519.pub
      Then:
        brew services start krz/tap/gitbay-runner
    EOS
  end

  test do
    assert_match "gitbay-runner", shell_output("#{bin}/gitbay-runner -version")
  end
end
