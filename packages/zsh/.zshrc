# Setup general settings
alias vi="nvim"
alias vim="nvim"

setopt no_beep
setopt auto_pushd
setopt pushd_ignore_dups
setopt auto_cd
setopt hist_ignore_dups
setopt share_history
setopt inc_append_history

export HISTSIZE=100000
export SAVEHIST=100000

# Setup zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

zinit wait lucid light-mode for \
    zsh-users/zsh-autosuggestions \
    zsh-users/zsh-completions \
    zdharma-continuum/fast-syntax-highlighting \
    b4b4r07/enhancd

# Setup other tools
eval "$(starship init zsh)"

eval "$(mise activate zsh)"

export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"

export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

if [ -f ~/.ssh/.ssh-agent ]; then
    source ~/.ssh/.ssh-agent
fi
