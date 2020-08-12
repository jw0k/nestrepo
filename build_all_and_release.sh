#!/usr/bin/env bash

echo "Building packages..."
./build_all.sh || { exit 1; }

echo "Releasing to github..."
./release_to_github.sh || { exit 1; }
