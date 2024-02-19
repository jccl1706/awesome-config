[[ -f ~/.Xresourcess ]] && xrdb -merge -I$HOME ~/.Xresourcess

## start awesome
exec awesome
