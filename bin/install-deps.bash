#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -eq 0 ]]; then
  echo "This script must NOT be run with sudo or as root." >&2
  exit 1
fi

CONFIG_DIR="$HOME/.config"

# Install Homebrew if not present
if [[ -x /opt/homebrew/bin/brew ]]; then
  echo "Homebrew already installed"
else
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
if [[ ! -x /opt/homebrew/bin/brew ]]; then
  echo "Homebrew installation failed" >&2
  exit 1
fi

# Install devbox if not present
if [[ -x /usr/local/bin/devbox ]]; then
  echo "Devbox already installed"
else
  echo "Installing Devbox..."
  curl -fsSL https://get.jetify.com/devbox | bash
fi
if [[ ! -x /usr/local/bin/devbox ]]; then
  echo "Devbox installation failed" >&2
  exit 1
fi

# Update devbox to latest and install global packages from pinned versions
echo "Updating devbox..."
/usr/local/bin/devbox version
/usr/local/bin/devbox version update
echo "Installing devbox global packages..."
/usr/local/bin/devbox global add $(cat "$CONFIG_DIR/devbox/devbox-deps.txt" | sed 's/^\* //' | sed 's/@latest - /@/' | tr -s '\n' ' ')

# Install Homebrew packages from Brewfile
echo "Checking Homebrew health..."
/opt/homebrew/bin/brew doctor || exit 1
echo "Updating Homebrew..."
/opt/homebrew/bin/brew update
/opt/homebrew/bin/brew doctor || exit 1
echo "Upgrading Homebrew packages..."
/opt/homebrew/bin/brew upgrade
/opt/homebrew/bin/brew doctor || exit 1
echo "Installing Homebrew packages from Brewfile..."
/opt/homebrew/bin/brew bundle install --force --file "$CONFIG_DIR/homebrew/Brewfile" || exit 1
/opt/homebrew/bin/brew doctor
