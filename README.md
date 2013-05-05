National Geographic Wallpaper Downloader for Ubuntu
===================

Description
-------------------

Download daily wallpaper from national geographic [official website][1]

Usage
-------------------

    ng-wallpaper [-23fhlns] [-u URL]
    
    Options:
      -2      -- Change GNOME2 desktop background*
      -3      -- Change GNOME3 desktop background*
      -f      -- Force download even if the resolution
                 of photo is not designed for wallpaper 
      -h      -- Show this message 
      -l FILE -- Check filename of last downloaded photo
                 stored in FILE. Exit if filename read from
                 URL is same.
                 Also record photo name to FILE if current
                 download succeeds. FILE is /home/genzj/.ng_last_wallpaper
                 by default. An empty string to FILE disables
                 checking and recording.
      -n      -- Download only, keep current desktop
                 background*
      -s      -- Save photo by its original name
      -u URL  -- Specify URL of photo page
                 By default script download 
                 from photo-of-the-day main page
    Note:
      *  If more than one of {-2, -3, -n} are specified,
         the last occurrence is effective.
         By default -3 is enabled.

Example
-------------------

On Ubuntu 12.10, just execute it from shell:

    ng-wallpaper

And check your wallpaper now.

To update wallpaper at login, execute

    gnome-session-properties

from dash home or shell, then add a new item

    Name:       Wallpaper Changer
    Command:    /path/to/the/ng-wallpaper
    Comment:    Download photo from NG website and set as wallpaper

You can set Name and Comment texts as you like.

Troubleshooting
-------------------

Sometimes your wallpaper won't be updated, because either NG photo today is not for wallpaper resolution (sometimes happens), or there is a bug or network issue. To locate the problem, just try

    ng-wallpaper -f

If your wallpaper can be replaced by a NG photo (even in awful resolution or/and ratio), script just works.
In other cases please don't hesitate to [create an issue][2] as long as you can open the [NG photography website][1] from a browser.

  [1]: http://photography.nationalgeographic.com/photography/photo-of-the-day

  [2]: https://github.com/genzj/ubuntu-ng-wallpaper/issues
