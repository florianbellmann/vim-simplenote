#!/bin/zsh

echo "Enter note name"
read -r query

cd ~/Private/vim-simplenote
source vim-simplenote.zsh
nn $query
cd -
