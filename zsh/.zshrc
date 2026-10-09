
# Dev environment
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(devbox global shellenv --init-hook)"
eval "$(direnv hook zsh)"

export EDITOR="nvim"
export DOCKER_HOST="unix://$HOME/.colima/default/docker.sock"
export PATH="$HOME/.local/bin:$PATH"
export DISABLE_AUTOUPDATER=1

export CLAUDE_CODE_MAX_OUTPUT_TOKENS=64000
# export CLAUDE_CODE_ENABLE_TODO_TOOLS=1
alias dev='zellij -l ~/.config/zellij/dev.kdl'
export CLAUDE_CODE_ENABLE_TODO_TOOLS=1
