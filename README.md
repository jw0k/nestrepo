# nestrepo

Modified Arch packages. And other packages, too.


## Packages

- networkmanager_auto - keeps trying to connect to WiFi even if it is started before gnome-keyring
- sxiv-large - sxiv configured to display large thumbnails
- polybar-correct-time - polybar with time module fixes (time wouldn't update after unhibernating)

## Configuration

Add the following to `/etc/pacman.conf`:

```
[nestrepo]
Server = https://github.com/jw0k/nestrepo/releases/download/current/
```

## Usage

Just install a package you want with `pacman -Syu package`.

## Scripts for development

- check_for_new_versions.sh - checks if there are newer versions of vanilla packages in Arch/AUR repositories. Update your system before running this script
- release_to_github.sh - uploads packages to GitHub. You should build all packages before running this script
- build_all_and_release.sh - automates all the steps necessary to build all the packages and release them to GitHub

