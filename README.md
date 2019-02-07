# kakoune-ranger

A wrapper to use [Ranger](https://ranger.github.io/) as a file picker for [Kakoune](http://kakoune.org/). Inspired by an example on the [wiki](https://github.com/mawww/kakoune/wiki/Ranger).

This script defines the command `ranger-select`. When executed, Kakoune is suspended and Ranger is started in select mode. To open a single file, navigate to it and press enter. To open multiple files, use space to select and enter to open all selected files. When Ranger exits, Kakoune is resumed and the selected files are opened for editing.
