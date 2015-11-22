. $HOME/.bashrc
export PATH="$(cope_path):/home/can/bin:/usr/lib/ccache/bin/:$PATH"
export HISTIGNORE="&:[ ]*"
export EDITOR=vim
export TERMINAL="urxvtc -e"
export DE=generic
export C_INCLUDE_PATH="/usr/include/freetype2"
stty -ixon
xhost local:
[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx

