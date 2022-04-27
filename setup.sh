#!/usr/bin/env bash

cd ${HOME}
git clone https://github.com/Homebrew/brew ${HOME}/.linuxbrew
.linuxbrew/bin/brew update --force --quiet
echo 'eval "$(.linuxbrew/bin/brew shellenv)"' >> ${HOME}/.profile
eval "$(.linuxbrew/bin/brew shellenv)"
brew install --force-bottle binutils
brew install --force-bottle gcc
brew install zsh

cd ${HOMEBREW_PREFIX}/bin
ln -s gcc-11 gcc 
ln -s g++-11 g++ 
ln -s cpp-11 cpp 
ln -s c++-11 c++

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
curl -fsSL https://raw.githubusercontent.com/STAOJ/sta-setup/master/.zshrc > .zshrc

if [ -f "${HOME}/.p10k.zsh" ]; then
  P10K_BACKUP="${HOME}/.p10k.zsh.backup"
  while [ -f "${P10K_BACKUP}" ]; do
    P10K_BACKUP="${P10K_BACKUP}.backup"
  done
    P10K_BACKUP_REL=$(realpath --relative-to="${HOME}" "${P10K_BACKUP}")
    echo "~/.p10k.zsh exists, moving it to ~/${P10K_BACKUP_REL}"
    mv ${HOME}/.p10k.zsh ${P10K_BACKUP}
fi
curl -fsSL https://raw.githubusercontent.com/STAOJ/sta-setup/master/.p10k.zsh > .p10k.zsh

if [ "$NO_SHELL" = true ]; then
  echo "Install successful, you don't seem to be using either bash or zsh so I can't figure out how to change your shell to zsh. Using zsh is not necessary, but it has some nice things installed like syntax highlighting and auto completion"
fi
