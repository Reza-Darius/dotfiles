#! /bin/bash

# installs all the essentials

packages=(
  zsh
  eza
  zoxide
  fd
  ripgrep
  bat
  fzf
  tealdeer
  git-delta
  dust
  zellij
  alacritty
  neovim
)

# --needed prevents reinstalling packages that are already present.
sudo yay -S --needed "${packages[@]}"
