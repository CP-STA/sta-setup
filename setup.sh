#!/usr/bin/env bash

# Install zsh and/or brew, configured for St Andrews CS lab PCs / host servers.

# Usage: see -h / usage()

#######################################
# Adds the specified string to the shell-rc files if it doesn't already exist.
# This adds the specified string to both .zshrc and .bashrc if they exist.
# Globals:
#   HOME
# Arguments:
#   $1: the string to be added to .bashrc.
#######################################

add_to_rc () {
    for shell_file in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if  [ -f "$shell_file" ]; then
            append_if_not_present "$1" "$shell_file"
        fi
    done
}

#######################################
# Adds the given string to the given file if it doesn't already exist.
# Arguments:
#   $1: the string to be added to the file.
#   $2: the path to the file.
#######################################

append_if_not_present () {
grep -qx "$1" "$2" || echo "$1" >> "$2"
}

#######################################
# Installs brew under the local user from git.
# Globals:
#   HOME
# Arguments:
#   None
#######################################

stasetup::install_brew () {
    set -e 
    originaldir=$(pwd)
    if [ ! -d "$HOME/.linuxbrew" ]; then
        git clone https://github.com/Homebrew/brew "$HOME/.linuxbrew"
    fi

    $HOME/.linuxbrew/bin/brew update --force --quiet
    eval "$($HOME/.linuxbrew/bin/brew shellenv)"
    brew install --force-bottle binutils
    brew install --force-bottle gcc
    cd "$HOMEBREW_PREFIX/bin"
    ln -sf gcc-11 gcc 
    ln -sf g++-11 g++ 
    ln -sf cpp-11 cpp 
    ln -sf c++-11 c++


    add_to_rc 'eval "$($HOME/.linuxbrew/bin/brew shellenv)"'

    cd "$originaldir"
    set +e
}

#######################################
# Install zsh using brew, and configure.
# Globals:
#   HOME
#   HOMEBREW_PREFIX
#   BASH_VERSION
#   ZSH_VERSION
# Arguments:
#   None
#######################################

stasetup::install_zsh () {
    originaldir=$(pwd)

    ## copied from old setup script, with brew bits removed
    cd ${HOME}
    NO_SHELL=false
    if [ -n "$BASH_VERSION" ]; then
    echo "$(which zsh)" >> ${HOME}/.bashrc
    elif [ -n "$ZSH_VERSION" ]; then
    :
    else
    NO_SHELL=true
    fi

    git clone https://github.com/ohmyzsh/ohmyzsh.git ${HOME}/.oh-my-zsh
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

    if [ -f "${HOME}/.zshrc" ]; then
    ZSHRC_BACKUP="${HOME}/.zshrc.backup"
    while [ -f "${ZSHRC_BACKUP}" ]; do
        ZSHRC_BACKUP="${ZSHRC_BACKUP}.backup"
    done
    ZSHRC_BACKUP_REL=$(realpath --relative-to="${HOME}" "${ZSHRC_BACKUP}")
    echo "~/.zshrc exists, moving it to ~/${ZSHRC_BACKUP_REL}"
    mv ${HOME}/.zshrc ${ZSHRC_BACKUP}
    fi

    NO_ZSHRC=false
    if [ -f "${HOME}/.zshrc" ]; then
    NO_ZSHRC=true
    else
    curl -fsSL https://raw.githubusercontent.com/STAOJ/sta-setup/master/.zshrc > ${HOME}/.zshrc
    fi

    if [ -f "${HOME}/.p10k.zsh" ]; then
    P10K_BACKUP="${HOME}/.p10k.zsh.backup"
    while [ -f "${P10K_BACKUP}" ]; do
        P10K_BACKUP="${P10K_BACKUP}.backup"
    done
    P10K_BACKUP_REL=$(realpath --relative-to="${HOME}" "${P10K_BACKUP}")
    echo "~/.p10k.zsh exists, moving it to ~/${P10K_BACKUP_REL}"
    mv ${HOME}/.p10k.zsh ${P10K_BACKUP}
    fi

    NO_P10K=false
    if [ -f "${HOME}/.p10k.zsh" ]; then
    NO_P10K=true 
    else
    curl -fsSL https://raw.githubusercontent.com/STAOJ/sta-setup/master/.p10k.zsh > ${HOME}/.p10k.zsh
    fi

    if [ "$NO_SHELL" = true ]; then
    echo "Install successful, you don't seem to be using either bash or zsh so we can't figure out how to change your shell to zsh. Using zsh is not necessary, but it has some nice things installed like syntax highlighting and auto completion"
    fi

    if [ "$NO_ZSHRC" = true ]; then
    echo "~/.zshrc already exists and we are unable to create an backup of it. So the recommended ~/.zshrc was not installed. To install it, consider removing your ~/.zshrc and run \n    curl -fsSL https://raw.githubusercontent.com/STAOJ/sta-setup/master/.zshrc > ${HOME}/.zshrc"
    fi

    if [ "$NO_P10K" = true ]; then 
    echo "~/.p10k.zsh already exists and we are unable to create an backup of it. So the recommended ~/.p10k.zsh was not installed. To install it, consider removing your ~/.p10k.configure and run \n     curl -fsSL https://raw.githubusercontent.com/STAOJ/sta-setup/master/.p10k.zsh > ${HOME}/.p10k.zsh"
    fi

    cd "$originaldir"
}


usage () {
    echo "setup.sh -hB
    
    FLAGS:
      -h  Show this help message, and exit.
      -B  Only install brew not zsh.
    "
}

# run if the script is directly executed (not sourced)
if [ "${BASH_SOURCE[0]}" == "$0" ]; then 
    install_zsh=true
    
    while getopts "hB" arg; do
        case $arg in
            h) usage; exit 0;;
            B) install_zsh=false;;
            *) echo "invalid arguments"; usage; exit 1;;
        esac
    done

    echo "Installing brew"
    stasetup::install_brew
    
    if [ "$install_zsh" = true ]; then
        echo "Installing zsh"
        stasetup::install_zsh
    fi
fi
