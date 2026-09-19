class Gitbay < Formula
  desc "CLI for gitbay, the CLI-first git forge"
  homepage "https://gitbay.org"
  url "https://gitbay.org/krz/gitbay.git",
      tag:      "v1.28.1",
      revision: "da232bfde4952959944a074ccec455f38eab3b66"
  license "0BSD"
  head "https://gitbay.org/krz/gitbay.git", branch: "main"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "./cmd/gitbay"
  end

  test do
    assert_match "forge", shell_output("#{bin}/gitbay --help")
  end
end
