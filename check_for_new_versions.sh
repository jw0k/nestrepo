#!/usr/bin/env bash

get_version()
{
    pacman -Si $1 | grep ^Version | awk '{ print $NF }'
}

compare_versions()
{
    ver1=$(get_version "$1")
    ver2=$(get_version "$2")
    if [[ $ver1 != $ver2 ]] ; then
        echo "$1 has different version than $2: $1 is $ver1, whereas $2 is $ver2"
    fi
}

compare_versions "sxiv" "sxiv-large"
compare_versions "networkmanager" "networkmanager_auto"
compare_versions "polybar" "polybar-correct-time"
