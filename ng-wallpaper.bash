#!/bin/bash

#TODO
# add option to change background fill mode

photo_page="http://photography.nationalgeographic.com/photography/photo-of-the-day"
user_page=""
download_tool="curl -s"
download_output_arg="-o "
save_file=""
gnome_version=3
ng_last_record=~/.ng_last_wallpaper

trait_regex='<a[^>]*>\s*Download Wallpaper[^<]*</a>'

force='n'
fallback_regex='<img[^>]+src="[^"]+.jpg"[^>]+width="9[0-9][0-9]"[^>]*/>'

my_name=`basename $0`

function usage() {
	echo "${my_name} [-23fhlns] [-u URL]"
	echo
	echo "Download and change wallpaper from National Geography official website"
	echo ""
	echo "Options:"
	echo "  -2      -- Change GNOME2 desktop background*"
	echo "  -3      -- Change GNOME3 desktop background*"
	echo "  -f      -- Force download even if the resolution"
	echo "             of photo is not designed for wallpaper "
	echo "  -h      -- Show this message "
	echo "  -l FILE -- Check filename of last downloaded photo"
	echo "             stored in FILE. Exit if filename read from"
	echo "             URL is same."
	echo "             Also record photo name to FILE if current"
	echo "             download succeeds. FILE is $ng_last_record"
	echo "             by default. An empty string to FILE disables"
	echo "             checking and recording."
	echo "  -n      -- Download only, keep current desktop"
	echo "             background*"
	echo "  -s      -- Save photo by its original name"
	echo "  -u URL  -- Specify URL of photo page"
	echo "             By default script download "
	echo "             from photo-of-the-day main page"
	echo "Note:"
	echo "  *  If more than one of {-2, -3, -n} are specified,"
	echo "     the last occurrence is effective."
	echo "     By default -3 is enabled."
}

# setwallpaper gnome-ver{2|3} wallpaper-filename
function setwallpaper() {
	ver=$1
	file=$2
	case $ver in
		2)
			gconftool-2 --type=string --set /desktop/gnome/background/picture_filename "$file"
			;;
		3)
			gsettings set org.gnome.desktop.background picture-uri "file://$file"
			;;
		n)
			;;
		*)
			echo "Unsupported gnome version..."
			exit 4
			;;
	esac
}

# Parse options 
TEMP=`getopt -o 23fhl:nsu: -n "${my_name}" -- "$@"`

if [ $? != 0 ] ; then echo "Try \"$my_name -h\" for more information." >&2 ; exit 1 ; fi

eval set -- "$TEMP"

while true
do
	case "$1" in 
		-2|-3|-n) gnome_version=${1##*-}; shift ;;
		-f) force='y'; shift;;
		-h) usage; exit 0;;
		-l) if [[ -n "$2" ]]; then ng_last_record="$2"; fi; shift 2 ;;
		-s) save_file="y" ; shift ;;
		-u) if [[ -n "$2" ]]; then photo_page="$2"; fi; shift 2 ;;
		--) shift ; break ;;
		*) echo "Internal error..." ; exit 1 ;;
	esac
done

if [[ $# -gt 0 ]] 
then
	echo "Unknown arguments, ignored: $@"
fi
# Options over 

# Add 'http://' to url if no protocol specified
if echo $photo_page | grep -iq '^\w+://' ; then photo_page="http://"$photo_page ; fi

# Get wallpaper download link
photo_url=`$download_tool "$photo_page" | grep -oi "$trait_regex" | sed -ne '/.*href="\([^"]\+\)".*/s//\1/p'`

if [[ -z $photo_url ]] 
then
	if [[ $force == 'y' ]] 
   	then
		photo_url=`$download_tool "$photo_page" | grep -Eoi "$fallback_regex" | sed -ne '/.*src="\([^"]\+\)".*/s//\1/p'`
		if [[ -z $photo_url ]] ; then echo "Not proper resolution for wallpaper or wrong URL" >&2 ; exit 2 ; fi
	else
		echo "Not proper resolution for wallpaper or wrong URL" >&2
		echo "Try \"$my_name -f\" to force downloading." >&2
		exit 2
	fi
fi

# Download wallpaper
download_output_file=${photo_url##*/}

if [[ -n $ng_last_record && -r $ng_last_record ]] 
then
	read lastfile < $ng_last_record
	if [[ $lastfile == $download_output_file ]]; then exit 0; fi
fi
echo "Downloading wallpaper file $photo_url"

$download_tool $photo_url $download_output_arg $download_output_file || exit $!
wallpaper_file="`pwd -P`/wallpaper.${download_output_file##*.}"
if [[ $save_file != 'y' ]] ; then 
	mv $download_output_file "$wallpaper_file"
else
	cp $download_output_file "$wallpaper_file"
fi

# Download successfully, make a record
if [[ -n $ng_last_record ]]; then echo $download_output_file > $ng_last_record ; fi

if [[ $gnome_version != 'n' ]] ; then setwallpaper $gnome_version $wallpaper_file ; fi
