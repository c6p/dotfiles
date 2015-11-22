#!/bin/bash
trap SIGINT SIGTERM

pidfile=/tmp/ampc.pid
if [ -f "$pidfile" ] && kill -0 `cat $pidfile` 2>/dev/null; then
    exit 1
fi
echo $$ > $pidfile

/usr/bin/mpc idleloop player |\
while read; do
    mpc=$(mpc)
    oldTrack=$track
    track=$(echo "$mpc" | sed '1!d')
    oldState=$state
    state=$(echo "$mpc" | sed '2!d;s/.*\[//g;s/\].*//g')
    if [[ "$state" != "$oldState" ]]; then
        if [[ "$state" == "paused" ]]; then
            echo "mpc.setState('pause')" | awesome-client
        elif [[ "$state" == "playing" ]]; then
            echo "mpc.setState('play')" | awesome-client
        else
            echo "mpc.setState('stop')" | awesome-client
        fi
    fi
    if [[ "$track" != "$oldTrack" && -n "$oldTrack"  ]]; then
        echo "mpc.setState('newsong')" | awesome-client
    fi
done

