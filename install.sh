#!/bin/sh

# @todo: check if it is run using sudo and suggest to run as regular user

echo "Installing packages..."

if command -v apt-get 2>/dev/null ; then
	sudo apt-get install git
	sudo apt-get install mc
	sudo apt-get install openssh-server
	sudo apt-get install vim
	sudo apt-get install screen
	sudo apt-get install tmux
	sudo apt-get install zsh
elif command -v pacman 2>/dev/null ; then
	sudo pacman -S git
	sudo pacman -S mc
	sudo pacman -S openssh
	sudo pacman -S vim
	sudo pacman -S screen
	sudo pacman -S tmux
	sudo pacman -S zsh
else
	echo "No suitable package manager found."
	exit 1
fi

# create a default empty zshrc file, to avoid first usage prompts
if [ ! -f ~/.zshrc ]; then
	touch ~/.zshrc
	echo "Created '~/.zshrc' placeholder."
fi

ZSH_SHELL=`which zsh`
if [ ${ZSH_SHELL} != ${SHELL} ]; then
	echo "Switching user shell to ZSH."
	chsh -s ${ZSH_SHELL} ${USER}
fi

# create symlinks
if [ ! -f ~/.zshrc_local ]; then
	echo "Creating '~/.zshrc_local' symlink."
	ln -s dotfiles/zsh/.zshrc_local ~/.zshrc_local
fi

# source local configurations
if [ -f ~/.zshrc ]; then
        if ! grep -F ". ~/.zshrc_local" ~/.zshrc 2>/dev/null ; then
                echo "Sourcing local configuration into '.zshrc'."
                cat ~/dotfiles/zsh/.zshrc_source >> ~/.zshrc
        fi
fi
