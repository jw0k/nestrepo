#!/usr/bin/env bash

FIFO="/tmp/github_token_fifo_$$"
mkfifo -m 0600 $FIFO
printf "machine api.github.com\nlogin jw0k\npassword $(secret-tool lookup name github_token)\nmachine uploads.github.com\nlogin jw0k\npassword $(secret-tool lookup name github_token)\n" > $FIFO &
curl -s --netrc-file $FIFO "$@"
rm $FIFO
