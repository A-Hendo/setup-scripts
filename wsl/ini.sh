#!/usr/bin/env sh

sudo apt update -y && sudo apt upgrade -y

sudo apt install zsh git fzf

curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh