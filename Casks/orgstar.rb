# Template for krz/homebrew-tap's Casks/orgstar.rb; scripts/release-mac.sh fills in the version
# and checksum. Install with:
#   brew tap krz/tap https://gitbay.org/krz/homebrew-tap.git && brew install --cask orgstar

cask "orgstar" do
  version "0.8.0"
  sha256 "0481343aee197f527cca0eb690477a642f8932390c942a8086d0ca41e86bed37"

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
