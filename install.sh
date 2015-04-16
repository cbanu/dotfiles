#!/bin/sh

# @todo: check if it is run using sudo and suggest to run as regular user

echo "Installing packages..."

sudo apt-get install git
sudo apt-get install mc
sudo apt-get install openssh-server
sudo apt-get install vim
sudo apt-get install screen
sudo apt-get install tmux
sudo apt-get install zsh

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
	ln -s dotfiles/zsh/.zshrc_local ~/.zshrc_local
fi

# source local configurations
if [ -e "${HOME}/.zshrc" ]; then
        if ! grep -F ". ~/.zshrc_local" ~/.zshrc 2>/dev/null ; then
                echo "Sourcing local configuration into '.zshrc'."
                cat ~/dotfiles/zsh/.zshrc_source >> ~/.zshrc
        fi
fi

# setup ZSH prompt
if [ ! -e "zsh/prompt/pure" ]; then
	mkdir -p zsh/prompt/pure
	cd zsh/prompt/pure
	git init
	git remote add origin https://github.com/sindresorhus/pure.git
	git config core.sparseCheckout true
	echo "pure.zsh" > .git/info/sparse-checkout
fi
git pull origin master
