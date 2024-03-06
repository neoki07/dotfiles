#!/bin/bash

# Install Homebrew
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "Homebrew already installed."
fi

# Install Homebrew packages
echo "Installing Homebrew packages..."
brew bundle --file="$DOTFILES_DIR/scripts/Brewfile"
