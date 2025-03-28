abbr -a nv nvim
abbr -a vi vim
abbr -a o open

abbr -a l lsd
abbr -a l1 "clear; lsd -1"
abbr -a ll "lsd -hlt"
abbr -a la "lsd -A"
abbr -a lla "lsd -Ahlt"
abbr -a lc "clear; lsd"
abbr -a llc "clear; lsd -hlt"
abbr -a lca "clear; l -A"
abbr -a llca "clear; lsd -Ahlt"
abbr -a lr "lsd -RFlA | more"

abbr -a poweroff "sudo poweroff"
abbr -a reboot "sudo reboot"

abbr -a cp "cp -R"
abbr -a cl clear

abbr -a cfg "cd ~/.config && nvim; cd -"
abbr -a clean-nvim "rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim"

abbr -a qsetup "qmk setup -H ."
abbr -a qflash "qmk flash -kb mx0/v1 -km default"
abbr -a qgen "qmk generate-compilation-database -kb mx0/v1 -km default"

function jjrebase
    jj rebase -R @ -A $argv[1] && jj b set $argv[1] && jj edit @+ && jj new
end
