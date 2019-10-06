#!/usr/bin/env bash

if [ "$#" -ne 2 ]; then
    me=`basename "$0"`
    echo "Usage: ${me} vanilla_package nestrepo_package"
    exit 1
fi

vanilla_package="$1"
nestrepo_package="$2"

mkdir temp_pkg
cd temp_pkg
asp update $vanilla_package > /dev/null 2>&1
asp export $vanilla_package > /dev/null 2>&1
cd ..
diff --color temp_pkg/${vanilla_package}/PKGBUILD ${nestrepo_package}/PKGBUILD

rm -rf temp_pkg
