# =========================================================
# Path
# =========================================================

# Keep paths unique
typeset -U path PATH

# Golang
export PATH="$HOME/go/bin:$PATH"
export PATH=$PATH:$GOPATH/bin
export PATH=/usr/local/go/bin:$PATH

# Rust/Cargo
export PATH="$HOME/.cargo/bin:$PATH"

export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export PATH="$HOME/dotfiles/scripts:$PATH"
export ZSH="$HOME/.oh-my-zsh"

fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
fpath=($HOME/.zsh-complete $fpath)

# =========================================================
# History
# =========================================================

HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=100000
SAVEHIST=100000
HISTORY_IGNORE="(cd|pwd|exit|cd)*"

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS

# =========================================================
# Shell behaviour
# =========================================================

setopt AUTOCD
setopt NOBEEP
setopt NUMERIC_GLOB_SORT  # sort file10 after file9, not after file1

# =========================================================
# Completion
# =========================================================

# Load completion system
autoload -U compinit 

# Initialize completion with cached metadata file
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"

# Enable interactive completion menu selection
zstyle ':completion:*' menu select

# Make completion case-insensitive
# Example: "doc" can complete to "Documents"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'  # lowercase input matches upper and lower

# colorful tab complete
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# =========================================================
# Plugins
# =========================================================

plugins=(
  # zsh-vi-mode
  docker
  fzf-tab
)

source $ZSH/oh-my-zsh.sh

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# Overwrites to use fd
FZF_FD_OPTS="--hidden --follow --strip-cwd-prefix --exclude '.git'"
export FZF_DEFAULT_COMMAND="fd ${FZF_FD_OPTS}"
export FZF_CTRL_T_COMMAND="fd ${FZF_FD_OPTS}"
export FZF_ALT_C_COMMAND="fd --type d ${FZF_FD_OPTS}"

_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

# Set up zoxide
eval "$(zoxide init zsh)"

# Set up try
eval "$(try init ~/src/tries)"

# Set man pages to use bat
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
# export MANPAGER='nvim +Man!'
export MANROFFOPT="-c"

# =========================================================
# oh-my-zsh configs
# =========================================================

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# =========================================================
# Aliases
# =========================================================

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

eval "$(starship init zsh)"

# git aliases
alias gc="git commit -am"
alias gp="git push"
alias ga="git add -A"

# alias to use ls alternative
alias ls="eza --icons"
alias ll="eza -lah --icons --git"
alias la="eza -a"
alias tree="eza --tree --icons"
compdef eza=ls

alias zed="zeditor"
alias nvimc="nvim ~/dotfiles/.config/nvim"
alias zshc="nvim ~/.zshrc"
alias zellijc="nvim ~/.config/zellij"
alias za="zellij a"
alias nvimo="nvim /mnt/project-drive/Obsidian Vault/"

# =========================================================
# Env variables
# =========================================================

export BAT_THEME="ansi"
export RUST_LOG="info"
export TERM="alacritty"

