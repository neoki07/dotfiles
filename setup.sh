#!/bin/zsh
set -e

# Set dotfiles directory environment variable
export DOTFILES_DIR
DOTFILES_DIR="$( cd "$( dirname "$0" )" && pwd )"

# Install Homebrew
if ! command -v brew &> /dev/null
then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Homebrew already installed."
fi

# Install Homebrew packages
echo "Installing Homebrew packages..."
brew bundle --file="$DOTFILES_DIR/Brewfile"
