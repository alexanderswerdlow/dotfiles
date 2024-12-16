### Misc shell info that is easy to forget

https://www.thegeekstuff.com/2008/10/execution-sequence-for-bash_profile-bashrc-bash_login-profile-and-bash_logout/

From `man bash`:

/bin/bash
       The bash executable
/etc/profile
       The systemwide initialization file, executed for login shells
~/.bash_profile
       The personal initialization file, executed for login shells
~/.bashrc
       The individual per-interactive-shell startup file
~/.bash_logout
       The individual login shell cleanup file, executed when a login shell exits
~/.inputrc
       Individual readline initialization file

For ZSH:

From: https://zsh.sourceforge.io/Guide/zshguide02.html
/etc/zshenv
       Always run for every zsh.
~/.zshenv
       Usually run for every zsh (see below).
/etc/zprofile
       Run for login shells.
~/.zprofile
       Run for login shells.
/etc/zshrc
       Run for interactive shells.
~/.zshrc
       Run for interactive shells.
/etc/zlogin
       Run for login shells.
~/.zlogin
       Run for login shells.



### ZSH Guide (I always forget this)

Use [[ ]] where possible. Only use [ ] for bash/sh compatibility.

[[ -z "$VAR" ]] and [[ -z $VAR ]] are equivalent (since we have double brackets)

if [[ -z "$VAR" ]]; then echo "VAR is not set or empty."; fi

if [[ -n "$VAR" ]]; then echo "VAR is set and not empty."; fi

if [[ -v "$VAR" ]]; then echo "VAR is set (may be empty)"; fi

if [[ ${VAR-} -eq 1 ]]; then echo "VAR is set and equal to one"; fi

${VAR:-} : sets var to default value (in this case empty) if not set or empty
${VAR:-"test"} : sets var to default value (in this case "test") if not set or empty
${VAR-} : sets var to empty if not set

if [[ "$VAR" = "value" ]]; then echo "VAR equals value."; fi

if [[ "$VAR" == v*l* ]]; then echo "VAR matches the pattern."; fi

if [[ -f "/path/to/file" ]]; then echo "File exists."; fi

if [[ -d "/path/to/directory" ]]; then echo "Directory exists."; fi

if command -v git >/dev/null 2>&1; then echo "Git is installed."; else echo "Git is not installed."; fi