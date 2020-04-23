#!/usr/bin/env bash

get_version()
{
    yay -Si $1 | grep ^Version | awk '{ print $NF }'
}

compare_versions()
{
    ver1=$(get_version "$1")
    ver2=$(get_version "$2")
    if [[ $ver1 != $ver2 ]] ; then
        echo "$1 has different version than $2: $1 is $ver1, whereas $2 is $ver2"
    fi
}

SCRIPTDIR=$(dirname "$(readlink -f "$0")")

while IFS="" read -r line || [ -n "$line" ]
do
    modified=${line%% *}
    vanilla=${line#* }
    echo "comparing $vanilla with $modified"
    compare_versions "$vanilla" "$modified"
done < <(awk "/^[^#]/ && NF==2" ${SCRIPTDIR}/packages.txt)
