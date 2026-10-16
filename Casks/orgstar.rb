# Template for krz/homebrew-tap's Casks/orgstar.rb; scripts/release-mac.sh fills in the version
# and checksum. Install with:
#   brew tap krz/tap https://gitbay.org/krz/homebrew-tap.git && brew install --cask orgstar

cask "orgstar" do
  version "0.7.0"
  sha256 "e8ca80f9954c46c4e088be94a259d32350f589674b9aaaffea02b3a478ab530e"

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
