#!/usr/bin/env bash

echo "Building packages..."
./build_all.sh

echo "Releasing to github..."
./release_to_github.sh
