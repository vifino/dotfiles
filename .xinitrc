#!/bin/sh
###
## Setup
###

# Basics
setxkbmap de
xrdb -merge ~/.Xresources

# Compositor
pgrep compton && killall -9 compton
compton -cCGb --unredir-if-possible --paint-on-overlay --backend glx

# URXVTd
pgrep urxvtd && killall -9 urxvtd
urxvtd &

# Growl on Linux
pgrep gol && killall -9 gol
gol &

# Synergy
synergys --name zen -c ~/.synergy

# Launch WM
#i3
if [ "$WM" == "" ]; then
	awesome &
else
	"$WM" &
fi

# wait until stuffs done
wait

###
## De-Initalization
###

# Compositor
killall compton # Fuck you, crash when the X Server goes down, for fucks sake!
