#!/bin/bash

# echo all commands
set -x
set -e

DOTFILES=${PWD}

# @todo: check if it is run using sudo and suggest to run as regular user
SUDO=
if [[ $EUID -ne 0 ]] ; then
	SUDO=sudo
fi

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
    ${SUDO} apt-get -y install git-core mc openssh-server vim screen tmux zsh ctags cscope ranger htop patch
elif command -v pacman 2>/dev/null ; then
    ${SUDO} pacman -S --noconfirm git mc openssh vim screen tmux zsh ctags cscope ranger htop patch
elif command -v dnf 2>/dev/null ; then
    ${SUDO} dnf -y install git mc openssh vim screen tmux zsh ctags cscope ranger htop patch util-linux-user
elif command -v yum 2>/dev/null ; then
    ${SUDO} yum -y install git mc openssh vim screen tmux zsh ctags cscope ranger htop patch
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

# create a default empty git config file
createPlaceholder ${HOME}/.gitconfig

# create a default empty vimrc file
createPlaceholder ${HOME}/.vimrc

# create a default empty tmux config file
createPlaceholder ${HOME}/.tmux.conf

# create symlinks
createSymlink ${HOME}/.zshrc_local ${DOTFILES}/zsh/.zshrc_local
createSymlink ${HOME}/.vimrc_local ${DOTFILES}/vim/.vimrc_local
createSymlink ${HOME}/.vimrc_vundle ${DOTFILES}/vim/.vimrc_vundle
createSymlink ${HOME}/.gitcfg_local ${DOTFILES}/git/.gitcfg_local
createSymlink ${HOME}/.tmuxcfg_local ${DOTFILES}/tmux/.tmuxcfg_local

# source local configurations
sourceLocalConfig ${HOME}/.zshrc ".zshrc_local" ${DOTFILES}/zsh/.zshrc_source
sourceLocalConfig ${HOME}/.vimrc ".vimrc_local" ${DOTFILES}/vim/.vimrc_source
sourceLocalConfig ${HOME}/.gitconfig ".gitcfg_local" ${DOTFILES}/git/.gitcfg_source
sourceLocalConfig ${HOME}/.tmux.conf ".tmuxcfg_local" ${DOTFILES}/tmux/.tmuxcfg_source

# setup dotfiles folder in zshrc_local
sed -i "/^export DOTFILES=.*$/c\\export DOTFILES=${DOTFILES}" ${DOTFILES}/zsh/.zshrc_local

# setup ZSH prompt
# TODO: how to handle authentication without passphrase prompt?
cd ${DOTFILES}
if [ ! -e "zsh/prompt/pure" ]; then
    mkdir -p zsh/prompt/pure
    pushd zsh/prompt/pure
    git init
    git remote add origin https://github.com/sindresorhus/pure.git
    git config core.sparseCheckout true
    echo "pure.zsh" > .git/info/sparse-checkout
    git fetch origin
    git checkout 467a1a6ce25e61e744106b52704a5ae8c46243af
    patch pure.zsh ../../pure.zsh.patch
    popd
else
    pushd zsh/prompt/pure
    git checkout pure.zsh
    git pull origin 467a1a6ce25e61e744106b52704a5ae8c46243af
    patch pure.zsh ../../pure.zsh.patch
    popd
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
    git checkout master
else
    cd ${VUNDLEDIR}
    git pull
fi
# automatically install vim packages (temporarily bypass local settings)
vim -u ${HOME}/.vimrc_vundle +PluginInstall +qall

# setup powerline fonts
if [ -e "${HOME}/.fonts" ]; then
    pwrFontsCount=`ls -1 ${HOME}/.fonts/*Powerline* | wc -l`
    if [ ${pwrFontsCount} -gt 0 ] ; then
        pwrFontsInstalled=Y
    fi
fi
if [ -z ${pwrFontsInstalled} ]; then
    PWRFONTS_TMPDIR=/tmp/powerline-fonts
    git clone https://github.com/powerline/fonts.git ${PWRFONTS_TMPDIR}
    pushd ${PWRFONTS_TMPDIR} >/dev/null
    ./install.sh
    popd >/dev/null
    rm -rf ${PWRFONTS_TMPDIR}
fi
