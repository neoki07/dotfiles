#!/bin/bash

if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "Homebrew already installed."
fi

if ! command -v gh &>/dev/null; then
  echo "Installing GitHub CLI..."
  brew install gh
else
  echo "GitHub CLI already installed."
fi

if gh auth status 2>&1 | grep -q "You are not logged into any GitHub hosts."; then
  gh auth login -w
else
  echo "You are already logged in to GitHub."
fi

if [ -d "$HOME/dotfiles" ]; then
  echo "Dotfiles already cloned."
else
  echo "Cloning dotfiles..."
  gh repo clone neokidev/dotfiles "$HOME/dotfiles"
fi

cd "$HOME/dotfiles" || exit

# source "setup.sh"
