#!/usr/bin/env fish

# general
abbr -- a abbr
abbr --add aa addabbr
abbr fne find-and-edit
# expand dotdot from anywhere in string
abbr --add dotdot --regex '^\.\.+$' --function multicd --position anywhere

# fish
abbr -a -- efa 'e $HOME/.config/fish/conf.d/99-abbrs.fish'
abbr -a -- efc 'find-and-edit -s $HOME/.config/fish/conf.d'
abbr -a -- eff 'find-and-edit -s $HOME/.config/fish/functions'
abbr -a -- gfc 'cd $HOME/.config/fish/'
abbr -a -- gff 'cd $HOME/.config/fish/functions'

# git
abbr gcp git_commit_and_push
abbr gip  'git push'
abbr gpu 'git pull'
abbr gis  'git status'
abbr gid  'git diff'
abbr gia  'git add'
abbr gib  'git branch'
abbr gich 'git checkout'
# gh repo create
abbr grc --set-cursor "gh repo create '%' --source . --private --push"
abbr --add g git
abbr --add --set-cursor gc git commit -m '"%"'

# yadm
# abbr y yadm
abbr ycp yadm-commit-and-push
abbr yp 'yadm push'
abbr ypu 'yadm pull'
abbr ys 'yadm status'
abbr yd 'yadm diff'
abbr ya 'yadm add'

# nix
abbr -a -- nrs "nh os switch /home/paul/nix-config --hostname $hostname"
abbr efn e $HOME/nix-config/flake.nix
abbr ehp e $HOME/nix-config/home-manager/programs.nix
abbr egn find-and-edit -s $HOME/nix-config/home-manager/gnome
abbr en find-and-edit -s $HOME/nix-config
abbr -a try-package --position command --set-cursor "nix shell 'nixpkgs#%' -c fish"
abbr enable-direnv 'echo "use flake" > .envrc && direnv allow'
# doom emacs
abbr dsd -- 'doom sync && doom doctor'
abbr ekill -- 'killall emacs'

# system stuff
abbr lodpi gnome-randr modif eDP-1 --scale=1 --mode 1920x1080@59.963
abbr hidpi gnome-randr modify eDP-1 --scale=2 --mode 3840x2160@60.000
# these are for boxbridge
abbr box_obsdpi 'gnome-randr modify DP-3 --scale=1 --mode 1920x1080@119.879+vrr && gsettings set org.gnome.desktop.interface text-scaling-factor 1.00'
abbr box_uwdpi 'gnome-randr modify DP-3 --scale=1 --mode 3440x1440@159.962+vrr && gsettings set org.gnome.desktop.interface text-scaling-factor 1.25'
abbr paper_refresh "gnome-extensions disable paperwm@paperwm.github.com && gnome-extensions enable paperwm@paperwm.github.com"

#zellij
abbr --add za zellij attach
# custom-defined in functions folder
abbr --add zs zellij_session


### ADDED ON THE FLY ###
# (consider sorting later)
abbr --add ds sort_folder -s ~/Downloads
abbr --add ros distrobox enter ros
abbr --add enable-direnv 'echo "use flake" > .envrc && direnv allow'
abbr --add md mkdir -p
abbr --add o xdg-open
abbr --add gd cd /home/paul/Downloads
abbr --add stopros distrobox stop ros
abbr --add cht curl cht.sh/
abbr --add gipu git pull
abbr --add kmok killall kmonad
abbr --add kmo "killall kmonad ; sleep 0.5 && kmonad ~/.config/kmonad/new-conf.kbd & disown"
abbr --add kmom "sudo killall kmonad ; sleep 0.5 && sudo kmonad ~/.config/kmonad/mac-func.kbd & disown"
abbr --add cons find-and-edit -s /home/paul/.config
abbr --add spr systemctl --user restart spotifyd.service
abbr --add yst yadm stash
abbr --add enp e /home/paul/nix-config/nixos/packages.nix
abbr --add gst git stash
abbr --add ehn e nix-config/home-manager/home.nix
abbr --add co fish_clipboard_paste
abbr --add mkx chmod +x
abbr --add aij distrobox enter srtd -- aij
abbr --add gl git log
abbr --add robo ssh robo@robo.local
abbr --add skmok sudo killall kmonad
abbr --add yl "yadm list | fzf"

abbr --add isaac "cd $ISAAC_ROS_WS/src/isaac_ros_common && \
./scripts/run_dev.sh"
