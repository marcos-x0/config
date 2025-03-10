#!/usr/bin/env bash

ln ~/.config/zsh/zshenv ~/.zshenv 2>/dev/null
ln ~/.config/zsh/zshrc ~/.zshrc 2>/dev/null
ln ~/.config/zsh/zprofile ~/.zprofile 2>/dev/null
ln ~/.config/git/gitconfig ~/.gitconfig 2>/dev/null

# Enable Touch ID authentication for sudo by adding "auth sufficient pam_tid.so"
# to the top of /etc/pam.d/sudo if it is not already present.
if ! grep -q "^auth sufficient pam_tid.so" /etc/pam.d/sudo; then
  sudo sed -i '' '1s|^|auth sufficient pam_tid.so\n|' /etc/pam.d/sudo
fi
