#!/bin/sh

# @todo: check if it is run using sudo and suggest to run as regular user

sudo apt-get install git
sudo apt-get install mc
sudo apt-get install openssh-server
sudo apt-get install vim
sudo apt-get install screen
sudo apt-get install tmux
sudo apt-get install zsh

# create a default empty zshrc file, to avoid first usage prompts
if [ ! -f ~/.zshrc ]; then
	touch ~/.zshrc
fi

sudo chsh -s `which zsh` ${USER}

