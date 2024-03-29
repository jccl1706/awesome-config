#!/bin/sh

run() {
    if ! pgrep -f "$1"; then
        "$@" &
    fi
}

run "/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1"
#run "keepassxc" &
#run "xscreensaver" --no-splash &
#run "volumeicon" &
run "nm-applet" &
#run "ibus-daemon" -drxR &
#run "feh" --randomize --recursive --bg-fill ~/Pictures/Wallpapers/ &
#run "cbatticon" -n &

# Check if the .myalta file exists in the home folder before running picom
if [ -e "$HOME/.myalta" ]; then
    run "picom" -b &
    run "caffeine-indicator" &
fi
