#!/bin/sh
i3status --config ~/.i3/i3status.conf | while :
do
        read line
        playing=$(mpc status | head -n1 | sed 's/volume:.*repeat:.*random:.*single:.*consume:.*/Not playing./')
        echo "$playing | $line" || exit 1
done
