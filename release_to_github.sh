#!/usr/bin/env bash

shopt -s nullglob

SCRIPTDIR=$(dirname "$(readlink -f "$0")")

echo "querying current release..."
RELID=$(${SCRIPTDIR}/query_github.sh -X GET "https://api.github.com/repos/jw0k/nestrepo/releases/tags/current" | jq -r '.id')

if [[ $RELID -ne "null" ]]; then
    echo "current release exists; deleting..."
    ${SCRIPTDIR}/query_github.sh -X DELETE "https://api.github.com/repos/jw0k/nestrepo/releases/$RELID"
else
    echo "current release does not exist; proceeding..."
fi

echo "removing current tag..."
git push --delete origin current

NEWRELID=$(${SCRIPTDIR}/query_github.sh -X POST -H "Content-Type: application/json" -d @release.json "https://api.github.com/repos/jw0k/nestrepo/releases" | jq -r '.id')

if [[ $NEWRELID -ne "null" ]]; then
    echo "uploading assets..."

    FILES=()
    while IFS="" read -r line || [ -n "$line" ]
    do
        package=${line%% *}
        FILES+=("${SCRIPTDIR}/build/${package}"/*.pkg.tar.zst)
    done < <(awk "/^[^#]/" ${SCRIPTDIR}/packages.txt)

    echo "files to upload: ${FILES[@]}"

    pushd .
    cd ${SCRIPTDIR}/build || { popd; echo "Cannot cd to build"; exit 1; }

    rm -f nestrepo.db.tar.gz
    rm -f nestrepo.files.tar.gz
    for file in ${FILES[@]}; do
        repo-add --sign --verify nestrepo.db.tar.gz $file
        BASEFILENAME=$(basename -- $file)

        ${SCRIPTDIR}/query_github.sh -X POST "https://uploads.github.com/repos/jw0k/nestrepo/releases/$NEWRELID/assets?name=$BASEFILENAME" -H "Content-Type: application/gzip" --data-binary "@$file"
        printf "\n"

        ${SCRIPTDIR}/query_github.sh -X POST "https://uploads.github.com/repos/jw0k/nestrepo/releases/$NEWRELID/assets?name=${BASEFILENAME}.sig" -H "Content-Type: application/gzip" --data-binary "@${file}.sig"
        printf "\n"

    done

    ${SCRIPTDIR}/query_github.sh -X POST "https://uploads.github.com/repos/jw0k/nestrepo/releases/$NEWRELID/assets?name=nestrepo.db" -H "Content-Type: application/gzip" --data-binary @nestrepo.db.tar.gz
    printf "\n"

    ${SCRIPTDIR}/query_github.sh -X POST "https://uploads.github.com/repos/jw0k/nestrepo/releases/$NEWRELID/assets?name=nestrepo.db.sig" -H "Content-Type: application/gzip" --data-binary @nestrepo.db.tar.gz.sig
    printf "\n"

    ${SCRIPTDIR}/query_github.sh -X POST "https://uploads.github.com/repos/jw0k/nestrepo/releases/$NEWRELID/assets?name=nestrepo.files" -H "Content-Type: application/gzip" --data-binary @nestrepo.files.tar.gz
    printf "\n"

    ${SCRIPTDIR}/query_github.sh -X POST "https://uploads.github.com/repos/jw0k/nestrepo/releases/$NEWRELID/assets?name=nestrepo.files.sig" -H "Content-Type: application/gzip" --data-binary @nestrepo.files.tar.gz.sig
    printf "\n"

    popd

else
    echo "error while creating new release"
    exit 1
fi

echo "done"
