# Taps
tap 'homebrew/cask'
tap 'homebrew/cask-versions'
tap 'homebrew/bundle'

# Binaries
brew 'bash' # Latest Bash version
brew 'coreutils' # Those that come with macOS are outdated
brew 'ffmpeg'
brew 'gh'
brew 'git'
brew 'grep'
brew 'httpie'
brew 'hub'
brew 'mackup'
brew 'mas' # Mac App Store manager
brew 'pkg-config' # https://github.com/driesvints/dotfiles/issues/20
brew 'trash' # Manage the Trash bin
brew 'tree' # List directories in a tree structure
brew 'fasd'

# Development
brew 'imagemagick'
brew 'yarn'
brew 'python'
brew 'bat'
brew 'exa'
brew 'wget'

# Apps
cask '1password'
cask 'aerial'
cask 'authy'
cask 'appcleaner'
cask 'coderunner'
cask 'discord'
cask 'docker'
cask 'github'
cask 'google-chrome'
cask 'iina'
cask 'istat-menus'
cask 'iterm2'
cask 'imageoptim'
cask 'sublime-text'
cask 'spotify'
cask 'the-unarchiver'
cask 'typora'
cask 'visual-studio-code'
cask 'monitorcontrol'

# extra
# alfred
# Wolfram Desktop
# Clion
# IntelliJ
# PDFSearch
# Terminus Beta
# Mactracker
# PDFExpert
# Forklift

# Quicklook
cask 'qlcolorcode'
cask 'qlmarkdown'
cask 'quicklook-json'
cask 'quicklook-csv'
cask 'qlstephen'
cask 'qlimagesize'
cask 'quicklookase'
cask 'qlvideo'
cask 'provisionql'

# Mac App Store
unless ENV.has_key?('CI') then
  mas 'Speedtest', id: 1153157709
  mas 'Notability', id: 736189492
  mas 'Magnet', id: 441258766
  mas 'Newton - Supercharged emailing', id: 1059655371
  mas 'nPlayer', id: 1451273814
  mas 'ApolloOne - Photo Video Viewer', id: 1044484672
end
