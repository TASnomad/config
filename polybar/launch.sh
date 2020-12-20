#!/usr/bin/env sh

# Kill all running instances
killall -q polybar

while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

polybar mainbar-bspwm -c ~/dotfiles/polybar/config &
