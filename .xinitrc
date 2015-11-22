#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

#xrandr --setprovideroutputsource modesetting NVIDIA-0
#xrandr --auto

xrdb -quiet -merge ~/.Xresources
#setxkbmap -option compose:caps

/usr/bin/synclient "TouchpadOff=1"

#if [ -d /etc/X11/xinit/xinitrc.d ]; then
#  for f in /etc/X11/xinit/xinitrc.d/*; do
#    [ -x "$f" ] && . "$f"
#  done
#  unset f
#fi

#urxvtd -f -q -o

# exec gnome-session
# exec startkde
# exec startxfce
# ...or the Window Manager of your choice

#exec skippysh &
#exec emacs --daemon &
#exec dropboxd &

#wmname LG3D
#redshift -l 40:32.7 -t 6200:5700 -m randr &
$exec ck-launch-session awesome
exec awesome >> ~/.cache/awesome/stdout 2>> ~/.cache/awesome/stderr
#compton -bzcCG --backend glx --vsync opengl-swc --paint-on-overlay  -r3 -l-4 -t-4 --use-ewmh-active-win  --glx-swap-method 0 --glx-no-stencil  --unredirf-possible --glx-no-rebind-pixmap --shadow-ignore-shaped
#exec xterm

