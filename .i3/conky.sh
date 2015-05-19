#!/bin/sh
echo '{"version":1}' # Version
echo '[' # Start infinite array
echo '[],' # First element

exec conky -c $HOME/.i3/conkyrc
