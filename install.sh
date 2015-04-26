#!/bin/sh

DOTFILES=`basename ${PWD}`
DOTFILES_DIR=${PWD}
# @todo: check if it is run using sudo and suggest to run as regular user

echo "Installing packages..."

if command -v apt-get 2>/dev/null ; then
	sudo apt-get install git-core mc openssh-server vim screen tmux zsh
elif command -v pacman 2>/dev/null ; then
	sudo pacman -S --noconfirm git mc openssh vim screen tmux zsh
else
	echo "No suitable package manager found."
	exit 1
fi

# change shell to ZSH
ZSH_SHELL=`which zsh`
if [ "${ZSH_SHELL}" != "${SHELL}" ]; then
	echo "Switching user shell to ZSH."
	chsh -s ${ZSH_SHELL} ${USER}
fi

# create a default empty zshrc file, to avoid first usage prompts
if [ ! -e "${HOME}/.zshrc" ]; then
	touch ~/.zshrc
	echo "Created '~/.zshrc' placeholder."
fi

# create a default empty vimrc file
if [ ! -e "${HOME}/.vimrc" ]; then
	touch ~/.vimrc
	echo "Created '~/.vimrc' placeholder."
fi

# create symlinks
if [ ! -e "${HOME}/.zshrc_local" ]; then
	echo "Creating '~/.zshrc_local' symlink."
	ln -s ${DOTFILES}/zsh/.zshrc_local ~/.zshrc_local
fi
if [ ! -e "${HOME}/.vimrc_local" ]; then
	echo "Creating '~/.vimrc_local' symlink."
	ln -s ${DOTFILES}/vim/.vimrc_local ~/.vimrc_local
fi

# source local configurations
if [ -e "${HOME}/.zshrc" ]; then
        if ! grep -F ".zshrc_local" ~/.zshrc 2>/dev/null ; then
                echo "Sourcing local configuration into '.zshrc'."
                cat ~/${DOTFILES}/zsh/.zshrc_source >> ~/.zshrc
        fi
fi
if [ -e "${HOME}/.vimrc" ]; then
        if ! grep -F ".vimrc_local" ~/.vimrc 2>/dev/null ; then
                echo "Sourcing local configuration into '.vimrc'."
                cat ~/${DOTFILES}/vim/.vimrc_source >> ~/.vimrc
        fi
fi

# setup ZSH prompt
# @todo: how to handle authentication without passphrase prompt?
cd ${DOTFILES_DIR}
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
	git checkout pure.zsh
	git pull origin master
	patch pure.zsh ../../pure.zsh.patch
fi

# setup vundle package manager for VIM
cd ${DOTFILES_DIR}
if [ ! -e "vim/vundle" ]; then
	mkdir -p vim/vundle
	cd vim/vundle
	git init
	git remote add origin https://github.com/gmarik/Vundle.vim.git
	git pull origin master
else
	cd vim/vundle
	git pull origin master
fi
