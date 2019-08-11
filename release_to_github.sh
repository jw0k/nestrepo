#!/usr/bin/env bash

echo "querying current release..."
RELID=$(./query_github.sh -X GET https://api.github.com/repos/jw0k/nestrepo/releases/tags/current | jq -r '.id')

if [[ $RELID -ne "null" ]]; then
    echo "current release exists; deleting..."
    ./query_github.sh -X DELETE https://api.github.com/repos/jw0k/nestrepo/releases/$RELID
else
    echo "current release does not exist; proceeding..."
fi

echo "removing current tag..."
git push --delete origin current

NEWRELID=$(./query_github.sh -X POST -H "Content-Type: application/json" -d @release.json https://api.github.com/repos/jw0k/nestrepo/releases | jq -r '.id')

if [[ $NEWRELID -ne "null" ]]; then
    echo "uploading assets..."

    FILES=$(ls networkmanager_auto/*.pkg.tar.xz)

    rm nestrepo.db.tar.gz
    while read -r file; do
        repo-add nestrepo.db.tar.gz $file
        BASEFILENAME=$(basename -- $file)
        ./query_github.sh -X POST https://uploads.github.com/repos/jw0k/nestrepo/releases/$NEWRELID/assets?name=$BASEFILENAME -H "Content-Type: application/gzip" --data-binary @$file
        printf "\n"
    done <<< "$FILES"

    ./query_github.sh -X POST https://uploads.github.com/repos/jw0k/nestrepo/releases/$NEWRELID/assets?name=nestrepo.db -H "Content-Type: application/gzip" --data-binary @nestrepo.db.tar.gz
    printf "\n"
else
    echo "error while creating new release"
    exit 1
fi

echo "done"
