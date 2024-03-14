## xrandr scripts
if [ -e /home/jc/.myalta ]; then
	/home/jc/bin/alta_singlescreen
fi

## initialize X resource database (if file ~/.Xresources is present on the system)
xrdb -I$HOME ~/.Xresources

## start awesome
exec awesome
