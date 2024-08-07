# Alex's Dotfiles

## Main Install

### Before you re-install

First, go through the checklist below to make sure you didn't forget anything before you wipe your hard drive.

- Did you commit and push any changes/branches to your git repositories?
- Did you remember to save all important documents from non-iCloud directories?
- Did you save all of your work from apps which aren't synced through iCloud?
- Did you remember to export important data from your local database?
- Did you update [mackup](https://github.com/lra/mackup) to the latest version and ran `mackup backup`?

### Installing macOS cleanly

After going to our checklist above and making sure you backed everything up, we're going to cleanly install macOS with the latest release. Follow [this article](https://www.imore.com/how-do-clean-install-macos) to cleanly install the latest macOS version.

### Setting up your Mac

If you did all of the above you may now follow these install instructions to setup a new Mac.

1. 

For macOS:
```
xcode-select --install
sh -c "$(curl -fsSL https://raw.githubusercontent.com/alexanderswerdlow/dotfiles/master/install.sh)"
```

For Ubuntu:
```
wget --no-check-certificate --no-cache --no-cookies -O - https://raw.githubusercontent.com/alexanderswerdlow/dotfiles/master/install.sh | sh
```

2. After mackup is synced with your cloud storage, restore preferences by running `mackup restore`
3. Restart your computer to finalize the process

Your Mac is now ready to use!

> Note: you can use a different location than `~/.dotfiles` if you want. Just make sure you also update the reference in the [`.zshrc`](./.zshrc) file.

### macOS Non-automated Setup (Dangerous!!!)

The commands below disable important macOS security features and should not be taken lightly. They will make it much easier for malware to break things and/or be more invasive. I decide to disable these features both for convinience (i.e. macOS doesn't need to verify the signature of every program, make it diffcult to open some programs etc.) and because I've run into several programs (specifically for development) that require SIP to be disabled anyway.

I've taken these commands from [here](https://www.naut.ca/blog/2020/11/13/forbidden-commands-to-liberate-macos/)
- Disable GateKeeper: `sudo spctl --master-disable`
- Disable Library Validation: `sudo defaults write /Library/Preferences/com.apple.security.libraryvalidation.plist DisableLibraryValidation -bool true`

The following commands must be executed from recovery mode:

- Disable SIP:  `csrutil disable`
- Disable Apple Mobile File Integrity: `nvram boot-args="amfi_get_out_of_my_way=1"`

If you want to disable any Apple programs from bypassing the Network Extensions API, see [here](https://tinyapps.org/blog/202010210700_whose_computer_is_it.html)


### Safe but unfortunately manual config

- iMessage -> Edit -> Substitutions -> Disable Emoji Replacement
- Sublime Text Configs
- PopClip
- Install custom chrome extensions: https://github.com/iamadamdev/bypass-paywalls-chrome
- Create chrome profiles (cchrome)

### More Info
Installs iTerm2, oh-my-zsh, and the [Powerlevel10k theme](https://github.com/romkatv/powerlevel10k)

## Minimal Shell

```
wget --no-check-certificate --no-cache --no-cookies -O - https://raw.githubusercontent.com/alexanderswerdlow/dotfiles/master/minimal_shell.sh | sh
```

### Additional Programs

- Wolfram Desktop
- PDF Expert
- Texpad
- Forklift
- Numi
- Alfred
- WiFi Explorer Pro
- Wireguard
- Matlab

## Thanks To...

Initially this was based off of [Dries's Dotfiles](https://github.com/driesvints/dotfiles) but it's since been completely re-written.
