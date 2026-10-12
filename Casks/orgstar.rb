# Template for krz/homebrew-tap's Casks/orgstar.rb; scripts/release-mac.sh fills in the version
# and checksum. Install with:
#   brew tap krz/tap https://gitbay.org/krz/homebrew-tap.git && brew install --cask orgstar

cask "orgstar" do
  version "0.3.2"
  sha256 "55543e86fa0ac4ac239eeca9f32623acc83308f6a91e6274f9111c1d0998222e"

  url "https://gitbay.org/krz/orgstar/releases/download/v#{version}/orgstar-#{version}.dmg"
  name "orgstar"
  desc "Native org-mode editor and agenda"
  auto_updates true
  homepage "https://gitbay.org/krz/orgstar"

  depends_on macos: :tahoe

  app "orgstar.app"

  zap trash: [
    "~/.config/orgstar",
    "~/Library/Application Support/Orgstar",
    "~/Library/Preferences/sh.krz.orgstar.plist",
  ]
end
