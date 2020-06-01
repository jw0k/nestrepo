#!/usr/bin/env bash

shopt -s nullglob

# asterisk matches dotfiles too
shopt -s dotglob

SCRIPTDIR=$(dirname "$(readlink -f "$0")")

# Step 1: build patched packages
while IFS="" read -r line || [ -n "$line" ]
do
    package=${line%% *}
    vanilla=${line#* }

    echo "Building patched package: ${package}..."
    pushd .

    cd ${SCRIPTDIR}/${package} || { popd; echo "Cannot cd to package ${package}"; exit 1; }
    rm -rf ${vanilla}
    pbget --pull --aur ${vanilla} || { popd; echo "Cannot download PKGBUILD for ${vanilla}"; exit 1; }
    mv ${vanilla}/* .
    rm -rf ${vanilla} .git
    patch -F 3 -p0 < PKGBUILD.patch || { popd; echo "Cannot patch package ${package}"; exit 1; }
    makepkg -cCsf --sign --noconfirm || { popd; echo "Cannot build package ${package}"; exit 1; }

    popd
done < <(awk "/^[^#]/ && NF==2" ${SCRIPTDIR}/packages.txt)

# Step 2: build non-patched packages
while IFS="" read -r line || [ -n "$line" ]
do
    package=${line%% *}

    echo "Building non-patched package: ${package}..."
    pushd .

    cd ${SCRIPTDIR}/${package} || { popd; echo "Cannot cd to package ${package}"; exit 1; }
    makepkg -cCsf --sign --noconfirm || { popd; echo "Cannot build package ${package}"; exit 1; }

    popd
done < <(awk "/^[^#]/ && NF==1" ${SCRIPTDIR}/packages.txt)

echo "Releasing to github..."
./release_to_github.sh
