#!/bin/sh
###
## Setup
###

# Basics
setxkbmap de
xrdb -merge ~/.Xresources

# Compositor
# Only start compton if no compton is already running.
pgrep compton || compton -cCGb --unredir-if-possible --paint-on-overlay --backend glx

# Growl on Linux
gol &

# Launch WM
#i3
awesome &

# wait until stuffs done
wait

###
## De-Initalization
###

# Compositor
killall compton # Fuck you, crash when the X Server goes down, for fucks sake!
