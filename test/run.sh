#!/usr/bin/env bash

DIR="$(dirname "$0")"
cd $DIR/..

vim -n -Nu "$DIR/vimrc_test" -c 'Vader! test/*.vader' > /dev/null

