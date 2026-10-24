#!/usr/bin/env zsh
# Push stored VSCode settings and extensions into VSCode's default locations

set -euo pipefail

SCRIPT_DIR="${0:A:h}"
VSCODE_USER="$HOME/Library/Application Support/Code/User"

mkdir -p "$VSCODE_USER"

# Push settings
for file in settings.json keybindings.json; do
  if [[ -f "$SCRIPT_DIR/$file" ]]; then
    cp "$SCRIPT_DIR/$file" "$VSCODE_USER/$file"
    echo "Pushed $file"
  else
    echo "No $file in repo (skipping)"
  fi
done

# Push snippets
if [[ -d "$SCRIPT_DIR/snippets" ]] && [[ -n "$(ls -A "$SCRIPT_DIR/snippets" 2>/dev/null)" ]]; then
  mkdir -p "$VSCODE_USER/snippets"
  cp "$SCRIPT_DIR/snippets/"* "$VSCODE_USER/snippets/"
  echo "Pushed snippets"
else
  echo "No snippets in repo (skipping)"
fi

# Install extensions
if [[ -f "$SCRIPT_DIR/extensions.txt" ]]; then
  while IFS= read -r ext; do
    [[ -z "$ext" ]] && continue
    code --install-extension "$ext" --force
  done < "$SCRIPT_DIR/extensions.txt"
  echo "Installed extensions"
else
  echo "No extensions.txt found (skipping)"
fi
