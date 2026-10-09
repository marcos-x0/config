#!/usr/bin/env bash

if [[ $EUID -eq 0 ]]; then
  echo "This script must NOT be run with sudo or as root." >&2
  exit 1
fi

CONFIG_DIR="$HOME/.config"
TIMESTAMP=$(date +%Y-%m-%d.%H:%M:%S)

mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.local/share/npm-global"

# Backup and copy .npmrc (must be before deps — npm prefix affects brew bundle)
if ! cmp -s "$CONFIG_DIR/bin/.npmrc" "$HOME/.npmrc" 2>/dev/null; then
  mv "$HOME/.npmrc" "$HOME/.npmrc.bak-$TIMESTAMP" 2>/dev/null
  cp "$CONFIG_DIR/bin/.npmrc" "$HOME/.npmrc"
  echo "Updated ~/.npmrc"
else
  echo "~/.npmrc unchanged, skipping"
fi

# Install package managers and dependencies — if this fails, stop
"$CONFIG_DIR/bin/install-deps.bash" || exit 1

# Backup and copy .zshrc
if ! cmp -s "$CONFIG_DIR/zsh/.zshrc" "$HOME/.zshrc" 2>/dev/null; then
  mv "$HOME/.zshrc" "$HOME/.zshrc.bak-$TIMESTAMP" 2>/dev/null
  cp "$CONFIG_DIR/zsh/.zshrc" "$HOME/.zshrc"
  echo "Updated ~/.zshrc"
else
  echo "~/.zshrc unchanged, skipping"
fi

# Backup and copy .zshenv
if ! cmp -s "$CONFIG_DIR/zsh/.zshenv" "$HOME/.zshenv" 2>/dev/null; then
  mv "$HOME/.zshenv" "$HOME/.zshenv.bak-$TIMESTAMP" 2>/dev/null
  cp "$CONFIG_DIR/zsh/.zshenv" "$HOME/.zshenv"
  echo "Updated ~/.zshenv"
else
  echo "~/.zshenv unchanged, skipping"
fi

# Backup and copy repo-prompt
if ! cmp -s "$CONFIG_DIR/bin/repo-prompt.bash" "$HOME/.local/bin/repo-prompt.bash" 2>/dev/null; then
  mv "$HOME/.local/bin/repo-prompt.bash" "$HOME/.local/bin/repo-prompt.bash.bak-$TIMESTAMP" 2>/dev/null
  cp "$CONFIG_DIR/bin/repo-prompt.bash" "$HOME/.local/bin/repo-prompt.bash"
  echo "Updated ~/.local/bin/repo-prompt.bash"
else
  echo "repo-prompt.bash unchanged, skipping"
fi

# Touch ID for sudo
if ! grep -q "^auth sufficient pam_tid.so" /etc/pam.d/sudo; then
  sudo sed -i '' '1s|^|auth sufficient pam_tid.so\n|' /etc/pam.d/sudo
  echo "Enabled Touch ID for sudo"
else
  echo "Touch ID for sudo already enabled"
fi
