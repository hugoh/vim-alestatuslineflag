#!/usr/bin/env bash

cd "$(dirname "$0")"
plugin=vader.vim
[ -d $plugin ] || git clone --depth 1 https://github.com/junegunn/vader.vim.git $plugin

