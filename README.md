# dotfiles

macOS development environment managed with jj (jujutsu) and git.

## Prerequisites

- install xcode command line tools

  ```bash
    xcode-select --install
  ```

- visit the [release](https://github.com/macports/macports-base/releases/) page.
- download the pkg for your macOS version
  - for Sequoia (macOS 15) [here](https://github.com/macports/macports-base/releases/download/v2.10.5/MacPorts-2.10.5-15-Sequoia.pkg)
- follow the GUI installer instructions.

## Setup

```bash
~/.config/bin/install-env.bash
```

This is the main setup script. It must not be run as root. It does the following:

1. Creates `~/.local/bin` and `~/.local/share/npm-global`
2. Copies `.npmrc` to `~/` (needed before deps — npm prefix affects brew bundle)
3. Runs `install-deps.bash` which:
   - Installs Homebrew (if missing)
   - Installs Devbox (if missing), updates it, and installs global packages from `devbox/devbox-deps.txt`
   - Runs `brew doctor`, `brew update`, `brew upgrade`, and installs packages from `homebrew/Brewfile`
4. Copies dotfiles to `~/`: `.envrc`, `.zshrc`, `.zshenv`
5. Copies starship prompt scripts to `~/.local/bin/`: `repo-prompt.bash`, `is-jj-repo.bash`, `is-git-no-jj.bash`
6. Enables Touch ID for sudo

All copies are idempotent — unchanged files are skipped, and existing files are backed up with a timestamp before overwriting.

## What's included

| Directory    | What                              |
|-------------|-----------------------------------|
| `bin/`      | Setup scripts and starship prompts |
| `devbox/`   | Devbox global package list         |
| `homebrew/` | Brewfile                           |
| `zsh/`      | `.zshrc` and `.zshenv`             |
| `direnv/`   | direnv config                      |
| `git/`      | git config and ignore              |
| `jj/`       | Jujutsu VCS config                 |
| `nvim/`     | Neovim (LazyVim)                   |
| `ghostty/`  | Ghostty terminal config            |
| `starship.toml` | Starship prompt config         |
| `aerospace/`| AeroSpace window manager           |
| `fish/`     | Fish shell config                  |
| `zellij/`   | Zellij terminal multiplexer       |
| `bat/`      | bat (cat replacement) config       |
| `karabiner/`| Karabiner-Elements key remapping   |

