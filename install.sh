#!/bin/sh

DOTFILES=`basename ${PWD}`
DOTFILES_DIR=${PWD}
# @todo: check if it is run using sudo and suggest to run as regular user

# creates empty placeholder file (only if the file doesn't exist)
createPlaceholder() {
    file=$1
    if [ ! -e "${file}" ] ; then
        touch "${file}"
        echo "Created '${file}' placeholder."
    else
        echo "File '${file}' already exists."
    fi
}

# creates a symlink to the specified target (only if symlink file doesn't exist)
createSymlink() {
    link=$1
    target=$2
    if [ -h "${link}" ] ; then
        linkTarget=`readlink ${link}`
        if [ "${linkTarget}" != "${target}" ] ; then
            echo "ERROR: Symlink '${link}' already exists, but points to wrong target '${linkTarget}'." 1>&2
            exit 1
        else
            echo "Symlink '${link}' already exists."
        fi
    elif [ -e "${link}" ] ; then
        echo "ERROR: File '${link}' already exists and it's not a symlink." 1>&2
        exit 1
    else
        ln -s "${target}" "${link}"
        echo "Created '${link}' symlink."
    fi
}

# source local configurations
sourceLocalConfig() {
    configFile=$1
    match=$2
    sourceFile=$3
    if [ -e "${configFile}" ] ; then
        if ! grep -F "${match}" "${configFile}" 2>/dev/null ; then
            echo "Sourcing local configuration into '${configFile}'."
            cat "${sourceFile}" >> "${configFile}"
        fi
    fi
}

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
createPlaceholder ${HOME}/.zshrc

# create a default empty vimrc file
createPlaceholder ${HOME}/.vimrc

# create symlinks
createSymlink ${HOME}/.zshrc_local ${DOTFILES}/zsh/.zshrc_local
createSymlink ${HOME}/.vimrc_local ${DOTFILES}/vim/.vimrc_local
createSymlink ${HOME}/.vimrc_vundle ${DOTFILES}/vim/.vimrc_vundle
createSymlink ${HOME}/.gitcfg_local ${DOTFILES}/git/.gitcfg_local

# source local configurations
sourceLocalConfig ${HOME}/.zshrc ".zshrc_local" ~/${DOTFILES}/zsh/.zshrc_source
sourceLocalConfig ${HOME}/.vimrc ".vimrc_local" ~/${DOTFILES}/vim/.vimrc_source
sourceLocalConfig ${HOME}/.gitconfig ".gitcfg_local" ~/${DOTFILES}/git/.gitcfg_source

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
    git fetch origin
    git branch --set-upstream master origin/master
    git checkout master
    patch pure.zsh ../../pure.zsh.patch
else
    cd zsh/prompt/pure
    git checkout pure.zsh
    git pull
    patch pure.zsh ../../pure.zsh.patch
fi

# setup vundle package manager for VIM
# TODO: maybe move vundle installation to ${DOTFILES}/vim/vundle ?
VUNDLEDIR=${HOME}/.vim/bundle/Vundle.vim
if [ ! -e "${VUNDLEDIR}" ]; then
    mkdir -p ${VUNDLEDIR}
    cd ${VUNDLEDIR}
    git init
    git remote add origin https://github.com/gmarik/Vundle.vim.git
    git fetch origin
    git branch --set-upstream master origin/master
    git checkout master
else
    cd ${VUNDLEDIR}
    git pull
fi
