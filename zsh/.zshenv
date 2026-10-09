
# . "$HOME/.cargo/env"
 eval "$(/opt/homebrew/bin/brew shellenv)"
 eval "$(/usr/local/bin/devbox global shellenv --init-hook)"


if [[ -n "$CLAUDECODE" ]]; then
 eval "$(direnv hook zsh)"
 eval "$(direnv export zsh)"
fi
