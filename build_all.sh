#!/usr/bin/env bash

shopt -s nullglob

# asterisk matches dotfiles too
shopt -s dotglob

SCRIPTDIR=$(dirname "$(readlink -f "$0")")

mkdir -p build
while IFS="" read -r package || [ -n "$package" ]
do
    cp -a ${package} build/
done < <(awk '/^[^#]/ {print $1}' ${SCRIPTDIR}/packages.txt)

# Step 1a: patch packages
PATCHED_PACKAGES=$(awk '/^[^#]/ && NF==2' ${SCRIPTDIR}/packages.txt)
while IFS="" read -r line || [ -n "$line" ]
do
    [ -z "$line" ] && continue
    package=${line%% *}
    vanilla=${line#* }

    echo "Patching package: ${package}..."
    pushd .

    cd ${SCRIPTDIR}/build/${package} || { popd; echo "Cannot cd to package ${package}"; exit 1; }
    rm -rf ${vanilla}
    pbget --pull --aur ${vanilla} || { popd; echo "Cannot download PKGBUILD for ${vanilla}"; exit 1; }
    mv ${vanilla}/* .
    rm -rf ${vanilla} .git
    patch -F 3 -p0 < PKGBUILD.patch || { popd; echo "Cannot patch package ${package}"; exit 1; }

    popd
done <<< "$PATCHED_PACKAGES"

# Step 1b: build patched packages
while IFS="" read -r line || [ -n "$line" ]
do
    [ -z "$line" ] && continue
    package=${line%% *}

    echo "====================================================================="
    echo "Building patched package: ${package}..."
    echo "====================================================================="
    pushd .

    cd ${SCRIPTDIR}/build/${package} || { popd; echo "Cannot cd to package ${package}"; exit 1; }
    makepkg -cCsf --sign --noconfirm || { popd; echo "Cannot build package ${package}"; exit 1; }

    popd
done <<< "$PATCHED_PACKAGES"

# Step 2: build non-patched packages
NON_PATCHED_PACKAGES=$(awk '/^[^#]/ && NF==1' ${SCRIPTDIR}/packages.txt)
while IFS="" read -r line || [ -n "$line" ]
do
    [ -z "$line" ] && continue
    package=${line%% *}

    echo "====================================================================="
    echo "Building non-patched package: ${package}..."
    echo "====================================================================="
    pushd .

    cd ${SCRIPTDIR}/build/${package} || { popd; echo "Cannot cd to package ${package}"; exit 1; }
    makepkg -cCsf --sign --noconfirm || { popd; echo "Cannot build package ${package}"; exit 1; }

    popd
done <<< "$NON_PATCHED_PACKAGES"
