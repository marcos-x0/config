#!/usr/bin/env zsh
# Pull current VSCode settings and extensions into this directory

set -euo pipefail

SCRIPT_DIR="${0:A:h}"
VSCODE_USER="$HOME/Library/Application Support/Code/User"

# Pull settings
for file in settings.json keybindings.json; do
  if [[ -f "$VSCODE_USER/$file" ]]; then
    cp "$VSCODE_USER/$file" "$SCRIPT_DIR/$file"
    echo "Pulled $file"
  else
    echo "No $file found (skipping)"
  fi
done

# Pull snippets
if [[ -d "$VSCODE_USER/snippets" ]] && [[ -n "$(ls -A "$VSCODE_USER/snippets" 2>/dev/null)" ]]; then
  mkdir -p "$SCRIPT_DIR/snippets"
  cp "$VSCODE_USER/snippets/"* "$SCRIPT_DIR/snippets/"
  echo "Pulled snippets"
else
  echo "No snippets found (skipping)"
fi

# Pull extension list
code --list-extensions > "$SCRIPT_DIR/extensions.txt"
echo "Pulled extensions list ($(wc -l < "$SCRIPT_DIR/extensions.txt" | tr -d ' ') extensions)"
