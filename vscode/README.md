# VSCode Config

Portable VSCode settings managed via dotfiles. VSCode stores its config in
platform-specific locations — these scripts sync between this repo and those
locations.

## Scripts

- **`push.zsh`** — Copies settings, keybindings, and snippets from this
  directory into VSCode's default config location. Also installs extensions
  from `extensions.txt`. **Overwrites existing VSCode config without merging.**
- **`pull.zsh`** — Copies current VSCode settings, keybindings, and snippets
  into this directory. Exports the installed extension list.
  **Overwrites files in this directory without merging.**
- **`install-plugins.zsh`** — Installs VSCode extensions. This is the source
  of truth for which extensions to install on a fresh machine.

## Setup on a new machine

```sh
# 1. Install VSCode
brew install --cask visual-studio-code

# 2. Open VSCode once, then close it (generates default config dirs)

# 3. Install extensions
./install-plugins.zsh

# 4. Push settings
./push.zsh

# 5. Install Symbols Nerd Font (for terminal icons)
devbox global add nerd-fonts.symbols-only
# Nix doesn't install into macOS font dirs — copy manually:
cp /nix/store/*nerd-fonts-symbols-only*/share/fonts/truetype/NerdFonts/Symbols/*.ttf ~/Library/Fonts/
# Restart VSCode after installing fonts
```

## Keybindings

### Editor panes

| Shortcut | Action |
|---|---|
| `Alt+←/→/↑/↓` | Navigate between editor panes |
| `Alt+\` | Split editor right |
| `Alt+-` | Split editor down |

### Terminal

| Shortcut | Action |
|---|---|
| `` Ctrl+` `` | Toggle terminal |
| `` Ctrl+Shift+` `` | New terminal instance |
| `Cmd+\` | Split terminal (side-by-side only) |
| `Cmd+←/→` | Navigate between terminal splits |
| `Cmd+↑/↓` | Switch between terminal instances |

### Search and navigation

| Shortcut | Action |
|---|---|
| `Cmd+P` | Find file by name / switch open files |
| `Cmd+Shift+F` | Search string across all files |
| `Cmd+Shift+P` | Command palette |

### Sidebar

| Shortcut | Action |
|---|---|
| `Cmd+Shift+E` | Open/focus explorer |
| `Cmd+Shift+F` | Open/focus search |
| `Cmd+B` | Close sidebar |

### Editor ↔ Terminal

| Shortcut | Action |
|---|---|
| `Ctrl+Alt+↓` | Focus terminal from editor |
| `Ctrl+Alt+↑` | Focus editor from terminal |

### Source control (jj)

| Shortcut | Action |
|---|---|
| `Cmd+Shift+J` | Open/focus source control panel |

### Panel tabs (Problems, Output, Terminal, etc.)

| Shortcut | Action |
|---|---|
| `Alt+←/→` | Switch panel tabs (when panel focused) |

## vscode-neovim

The `vscode-neovim` extension runs a real neovim process for vim keybindings.
It uses `nvim` from PATH — ensure nvim is installed (via devbox global).

Known limitation: `<C-d>zz` and `<C-u>zz` (half-page scroll + center) does
not work — the centering part is ignored by vscode-neovim.

Requires the LazyVim `vscode` extra to be enabled:

```sh
# In nvim, run:
:LazyExtras
# Find "vscode", press x to enable, restart nvim
```
