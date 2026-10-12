# Template for krz/homebrew-tap's Casks/orgstar.rb; scripts/release-mac.sh fills in the version
# and checksum. Install with:
#   brew tap krz/tap https://gitbay.org/krz/homebrew-tap.git && brew install --cask orgstar

cask "orgstar" do
  version "0.3.0"
  sha256 "37077e75704c3cc01372ddd386ea96a5d7a5baed4614aad84a9fe046934793d9"

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
