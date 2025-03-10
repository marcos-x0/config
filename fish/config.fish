set fish_greeting

# fish_add_path $HOME/.cargo/bin
#
#
# set -U -x XDG_CONFIG_HOME "$HOME/.config/" 
#
# # /nix/store/bin is here just to trick powerlevel 10k to display the nix icon
# export PATH=$HOME/.nix-profile/bin/:/nix/store/bin/:$HOME/.cargo/bin/:/opt/homebrew/bin/:/opt/homebrew/sbin/:$PATH
# #export PATH=/nix/var/nix/profiles/default/bin:$PATH
#
# export PATH="$PATH:$HOME/.local/bin:$HOME/.local/share/containers/podman-desktop/extensions-storage/compose/bin:$HOME/.local/share/containers/podman-desktop/extensions-storage/kind/kind-darwin-arm64"
# export PATH="$PATH:/Applications/WezTerm.app/Contents/MacOS/"
# #export PATH="$HOME/miniconda3/bin/:$PATH"
#
# #export VIMINIT='source $XDG_CONFIG_HOME/vim/vimrc'
# export DENO_DIR=/Volumes/Tritium/.deno_cache
#
#
# export CONTAINERS_REGISTRIES_CONF="~/.config/containers/registries.conf"
# export ANDROID_HOME=$HOME/Library

if status is-interactive
    jj util completion fish | source
    /opt/homebrew/bin/brew shellenv | source
    fnm env --use-on-cd --shell fish | source
    fnm completions --shell fish | source
end

starship init fish | source

# set nord0 2e3440
# set nord1 3b4252
# set nord2 434c5e
# set nord3 4c566a
# set nord4 d8dee9
# set nord5 e5e9f0
# set nord6 eceff4
# set nord7 8fbcbb
# set nord8 88c0d0
# set nord9 81a1c1
# set nord10 5e81ac
# set nord11 bf616a
# set nord12 d08770
# set nord13 ebcb8b
# set nord14 a3be8c
# set nord15 b48ead
#
# set fish_color_normal $nord4
# set fish_color_command $nord9
# set fish_color_quote $nord14
# set fish_color_redirection $nord9
# set fish_color_end $nord6
# set fish_color_error $nord11
# set fish_color_param $nord4
# set fish_color_comment $nord3
# set fish_color_match $nord8
# set fish_color_search_match $nord8
# set fish_color_operator $nord9
# set fish_color_escape $nord13
# set fish_color_cwd $nord8
# set fish_color_autosuggestion $nord6
# set fish_color_user $nord4
# set fish_color_host $nord9
# set fish_color_cancel $nord15
# set fish_pager_color_prefix $nord13
# set fish_pager_color_completion $nord6
# set fish_pager_color_description $nord10
# set fish_pager_color_progress $nord12
# set fish_pager_color_secondary $nord1

# set -U tide_color_prompt 81A1C1 # Nord Blue
# set -U tide_color_prompt_success 81A1C1 # Nord Blue
# set -U tide_color_prompt_error BF616A # Nord Red
# set -U tide_color_git_branch A3BE8C # Nord Green
# set -U tide_color_git_dirty EBCB8B # Nord Yellow
# set -U tide_color_git_staged 88C0D0 # Nord Cyan
# set -U tide_color_git_untracked B48EAD # Nord Purple
# set -U tide_color_virtual_env 8FBCBB # Nord Teal
# set -U tide_color_pwd 81A1C1 # Nord Blue

# tide configure --auto --style=Lean --prompt_colors='True color' --show_time='24-hour format' --lean_prompt_height='Two lines' --prompt_connection=Disconnected --prompt_spacing=Sparse --icons='Few icons' --transient=Yes
