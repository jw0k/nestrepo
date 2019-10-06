# nestrepo

Modified Arch packages.

## Packages

- networkmanager_auto - keeps trying to connect to WiFi even if it is stared before gnome-keyring
- sxiv-large - sxiv configured to display large thumbnails

## Configuration

Add the following to `/etc/pacman.conf`:

```
[nestrepo]
Server = https://github.com/jw0k/nestrepo/releases/download/current/
```

## Usage

Just install a package you want with `pacman -Syu package`.

## Scripts for development

- check_for_new_versions.sh - checks if there are newer versions of vanilla packages in Arch repositories. Update your system before running this script
- show_diff.sh - shows the diff between vanilla package and nestrepo package. Usage: `show_diff.sh vanilla_package nestrepo_package`, e.g.: `show_diff.sh sxiv sxiv-large`. Useful when updating PKGBUILDs
- release_to_github.sh - uploads packages to GitHub. Build all packages before running this script by running `makepkg -s --sign` in every package folder.


