#!/usr/bin/env bash

if [[ $EUID -eq 0 ]]; then
  echo "This script must NOT be run with sudo or as root." >&2
  exit 1
fi

sudo port install \
  zsh@5.9_3 \
  zsh-autosuggestions@0.7.0 \
  zsh-syntax-highlighting@0.8.0 \
  tree@2.2.1_0 \
  ttf-nerd-fonts-symbols@3.3.0 \
  cmake@3.31.3 \
  jujutsu@0.27.0 \
  fish@4.0.0 \
  fnm@1.38.1 \
  qemu@9.2.2 \
  bun@1.1.43 \
  fd@10.2.0_0 \
  bat@0.25.0_0 \
  git-delta@0.18.2_0 \
  zoxide@0.9.7_0 \
  neovim@0.10.2_0 \
  btop@1.4.0_0 \
  lsd@1.1.5_0 \
  jq@1.7.1_1 \
  jqp@0.7.0_0 \
  yq@4.45.1_1 \
  jqp@0.7.0_0 \
  ripgrep@14.1.1_0 \
  podman@5.3.2_0 \
  deno@2.2.3_0 \
  pnpm@10.6.1_0 \
  lua-luarocks@3.9.2_0 \
  cargo@0.86.0_0 \
  curl@8.12.0_1+brotli+http2+idn+psl+ssl+zstd \
  curl-ca-bundle@8.12.0_0 \
  cargo@0.86.0_0 \
  go@1.24.1_0 \
  go-md2man@2.0.5_0 \
  lua@5.3.6_3 \
  lua-luarocks@3.9.2_0 \
  lua51@5.1.5_9 \
  lua51-lpeg@1.1.0_0 \
  lua53@5.3.6_3 \
  lua53-luarocks@3.9.2_0 \
  luajit@2.1.1736781742_0 \
  luv-luajit@1.50.0-1_0 \
  nodejs22@22.14.0_0 \
  rust@1.85.0_0 \
  sqlite3@3.49.1_0 \
  xz@5.6.4_0

if command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

brew bundle install --file ~/.config/homebrew/Brewfile

exit 0

# another script to setup macos preferences is needed.
# just writing the commands here fr loggin

# Now, you can move windows by holding ctrl+cmd and dragging any part of the window (not necessarily the window title)
defaults write -g NSWindowShouldDragOnGesture -bool true

# added the one for using finger print for sudo
#
# look here https://miguelcrespo.co/posts/automate-installation-and-configuration-of-macos

#
# brew install --cask karabiner-elements
# brew install —-cask qmk-toolbox
# brew install --cask nikitabobko/tap/aerospace
# brew install --cask ghostty
# brew install --cask qmk-toolbox
#
# brew install clang-format
