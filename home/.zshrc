### ZSH HOME
export ZSH=$HOME/.zsh
export ANDROID_USER_HOME=$HOME/.android/
export ANDROID_HOME=~/Android/Sdk
export JAVA_HOME=/usr/lib/jvm/default

# Edit ZSH
alias openzs='hx ~/.zshrc'

# Load ZSH
alias loadzs='source ~/.zshrc'

# AI GPU Config
export HSA_OVERRIDE_GFX_VERSION=10.3.0

### ---- history config -------------------------------------
export HISTFILE=$ZSH/.zsh_history

# How many commands zsh will load to memory.
export HISTSIZE=10000

# How many commands history will save on file.
export SAVEHIST=10000

# History won't save duplicates.
setopt HIST_IGNORE_ALL_DUPS

# History won't show duplicates on search.
setopt HIST_FIND_NO_DUPS

export PATH=~/.local/bin:$PATH

# Credentials live outside the dotfiles, in ~/.zshrc.secrets (not tracked).
[[ -f ~/.zshrc.secrets ]] && source ~/.zshrc.secrets

# Git
export GIT_EDITOR=hx #Helix editor
export GIT_DEFAULT_BRANCH=main

alias hx='helix'
alias search='pacman -Ss'
alias install='sudo pacman -S'
alias up='sudo pacman -Syu'


# Clear terminal
alias c='clear'
alias cls='clear'
alias CLS='clear'

# fetch
fetch() {
    fastfetch -c "examples/$1"
}
alias neofetch='fastfetch -c examples/31'
alias ffetch='fastfetch -c examples/13'
alias nitch='nitchrevived'
alias zj='zellij'


# Changing "ls" to "eza" from reddit comment
alias ls='eza --icons --color=always --group-directories-first'
alias ll='eza -alF --icons --color=always --group-directories-first'
alias la='eza -a --icons --color=always --group-directories-first'
alias l='eza -F --icons --color=always --group-directories-first'
alias l.='eza -a | egrep "^\."'

# https://www.lekoarts.de/garden/replacing-ls-with-eza
alias lt='eza --tree --level=2' # tree
alias lS='eza -1' # one column, just names
alias lx='eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale' # all + extended list
alias lA='eza -lbhHigUmuSa --time-style=long-iso --git --color-scale' # all list
alias llm='eza -lbGd --git --sort=modified' # long list, modified date sort

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Created by newuser for 5.9
source ~/powerlevel10k/powerlevel10k.zsh-theme

source $ZSH/zsh-autosuggestions/zsh-autosuggestions.zsh

source $ZSH/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

source $ZSH/zsh-completions/zsh-completions.plugin.zsh

source $ZSH/key-bindings.zsh

source $ZSH/directories.zsh

source $ZSH/git.plugin.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

source /usr/share/nvm/init-nvm.sh
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

eval "$(zoxide init zsh)"

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"
# End of LM Studio CLI section



# Added by Antigravity CLI installer
export PATH="$HOME/.local/bin:$PATH"

# mimocode
export PATH=$HOME/.mimocode/bin:$PATH
