#!/bin/sh

DOTFILES=`basename ${PWD}`
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
	sudo pacman -S --noconfirm git mc openssh vim screen tmux zsh
else
	echo "No suitable package manager found."
	exit 1
fi

# create a default empty zshrc file, to avoid first usage prompts
if [ ! -e "${HOME}/.zshrc" ]; then
	touch ~/.zshrc
	echo "Created '~/.zshrc' placeholder."
fi

ZSH_SHELL=`which zsh`
if [ "${ZSH_SHELL}" != "${SHELL}" ]; then
	echo "Switching user shell to ZSH."
	chsh -s ${ZSH_SHELL} ${USER}
fi

# create symlinks
if [ ! -e "${HOME}/.zshrc_local" ]; then
	echo "Creating '~/.zshrc_local' symlink."
	ln -s ${DOTFILES}/zsh/.zshrc_local ~/.zshrc_local
fi

# source local configurations
if [ -e "${HOME}/.zshrc" ]; then
        if ! grep -F ". ~/.zshrc_local" ~/.zshrc 2>/dev/null ; then
                echo "Sourcing local configuration into '.zshrc'."
                cat ~/${DOTFILES}/zsh/.zshrc_source >> ~/.zshrc
        fi
fi

# setup ZSH prompt
# @todo: how to handle authentication without passphrase prompt?
if [ ! -e "zsh/prompt/pure" ]; then
	mkdir -p zsh/prompt/pure
	cd zsh/prompt/pure
	git init
	git remote add origin https://github.com/sindresorhus/pure.git
	git config core.sparseCheckout true
	echo "pure.zsh" > .git/info/sparse-checkout
	git pull origin master
	patch pure.zsh ../../pure.zsh.patch
else
	cd zsh/prompt/pure
	git pull origin master
fi
