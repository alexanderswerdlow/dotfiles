# Taps
tap 'homebrew/cask'
tap 'homebrew/cask-versions'
tap 'homebrew/bundle'
tap 'AdoptOpenJDK/openjdk'

# Binaries
brew 'bash' # Latest Bash version
brew 'coreutils' # Those that come with macOS are outdated
brew 'ffmpeg' # Audio/Video Transcoding/Streaming
brew 'git' # Git gud
brew 'grep' # You know...grep
brew 'httpie' # Wget but better
brew 'mackup' # Syncs mac preferences
brew 'mas' # Mac App Store manager
brew 'pkg-config' # https://github.com/driesvints/dotfiles/issues/20
brew 'fasd' # Better cd (https://github.com/clvv/fasd)

# Development
brew 'imagemagick' # CLI image  optimizer/transformer
brew 'yarn' # When npm is too annoying
brew 'python' # When you need the super new syntactical sugar
brew 'bat' # When you need a new cat
brew 'exa' # 
brew 'wget' # Sometimes you gotta wget things
brew 'iperf3' # Testing LAN Speeds. Useful for getting your *actual* WiFi speed and not just the WAN/internet speed
brew 'wireguard-tools' # VPN
brew 'rga'
brew 'pandoc'
brew 'poppler'
brew 'tesseract'
brew 'fzf'

# Apps
cask '1password' # Shhhhh
cask 'aerial' # Sweet screensaver videos taken from tvOS
cask 'authy' # Shhhhh
cask 'appcleaner' # Removes trace files while deleting apps
cask 'coderunner' # Quickly run/debug code in a bunch of languages, don't even need to save a file
cask 'discord' # Goddamn discord
cask 'docker' # The annoying containers
cask 'github' # The gits
cask 'google-chrome' # The webs
cask 'iina' # VLC that looks pretty
cask 'istat-menus' # All the graphs
cask 'iterm2' # Best terminal
cask 'imageoptim' # Image Compression
cask 'sublime-text' # Great for giant text files, quick editing without setup
cask 'spotify' # The tunes
cask 'the-unarchiver' # Archive Utility doesn't always cut it
cask 'typora' # Markdown editor
cask 'visual-studio-code' # All the random code
cask 'monitorcontrol' # External Monitor Brightness Control
cask 'upic' # Image Uploader, primarily for Typora
cask 'mactex-no-gui' # MacTeX without the GUI applications. I use Texpad
cask 'daisydisk'
cask 'clion'
cask 'intellij-idea'
cask 'pycharm' #  Best C/C++/Java IDE if it's not a super quick edit
cask 'alfred' # Spotlight but way better
cask 'adoptopenjdk'
cask 'adoptopenjdk8'

# Wolfram Desktop - Mathematica basically
# PDFSearch - Excellent PDF Searching + can index a whole folder of various text files
# Terminus Beta
# MacTracker - Complete history/specs of Apple devices
# PDFExpert - Best PDF Editor that isn't super slow Acrobat
# Forklift - Best SFTP Client
# Matlab - ...

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
  mas 'Speedtest', id: 1153157709 # Get that speed
  mas 'Notability', id: 736189492 # favorite iPad note taking app, syncs notes to iCloud
  mas 'Magnet', id: 441258766 # macOS window manager
  mas 'Newton - Supercharged emailing', id: 1059655371 # Dope email client
  mas 'nPlayer', id: 1451273814 # Plays back some video files smoother than IINA + better FTP/AFP playback
end
