<<<<<<< HEAD
## xrandr scripts
if [ -e /home/jc/.myalta ]; then
	/home/jc/bin/alta_singlescreen
fi

## initialize X resource database (if file ~/.Xresources is present on the system)
xrdb -I$HOME ~/.Xresources
=======
xrdb -merge ~/.Xresourcess
>>>>>>> ceb5dad86ba91a3b152c0f21ada1489f4104a824

## start awesome
exec awesome
