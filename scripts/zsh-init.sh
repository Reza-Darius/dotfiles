#!/usr/bin/env bash

# installs fzf tab and zsh completions

mkdir -p "$XDG_CACHE_HOME/zsh/"
mkdir -p "$XDG_STATE_HOME/zsh/"
# touch "$XDG_STATE_HOME/zsh/history"

PLUGINS_DIR="$HOME/.oh-my-zsh/custom/plugins"

git clone https://github.com/Aloxaf/fzf-tab \
  "${PLUGINS_DIR}/fzf-tab"

git clone https://github.com/zsh-users/zsh-completions.git \
  "${PLUGINS_DIR}/zsh-completions"

