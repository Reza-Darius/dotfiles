#!/usr/bin/env bash

# installs fzf tab and zsh completions

mkdir -p "$XDG_CACHE_HOME/zsh/"
mkdir -p "$XDG_STATE_HOME/zsh/"

# prevents the install script from running the shell so the script runs to completion
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

git clone https://github.com/Aloxaf/fzf-tab \
  "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/fzf-tab

git clone https://github.com/zsh-users/zsh-completions.git \
  "${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}"/plugins/zsh-completions

chsh -s /bin/zsh
exec zsh
