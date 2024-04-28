# Fast Guides DE Ubuntu Updater
![fgde-uup logo](https://github.com/Tibsun75/fgde-uup/blob/main/fgde-uup.png)

This script provides an Dialag Gui and a easy way to update Ubuntu packages, Flatpaks, and Snap packages.

## Features

- Update Ubuntu deb packages
- Update Flatpaks
- Update Snap packages
- Update all
- Remove unnecessary deb packages with `apt autoremove`
- Repair deb packages
- Empty Ubuntu deb cache
- Empty Flatpak cache
- Empty Snap cache

## Requirements

- Ubuntu or Ubuntu-based distribution
- `dialog` package installed (Run `sudo apt install dialog` to install)
- `apt`, `flatpak`, and `snap` package managers installed
- Bash shell

## Usage

1. Clone this repository or download the `fgde-uup.bash` script.
2. Make the script executable: `chmod +x fgde-uup.bash`
3. Run the script: `./fgde-uupdbash`

## Language Settings

The script supports multiple languages. By default, it uses German language. 
You can also override the language setting using the `-l` option followed by the language code (`de`, `en`, `tr`). 

For example:
./fgde-uup.bash -l de
