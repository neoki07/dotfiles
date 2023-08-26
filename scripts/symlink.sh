#!/bin/bash

echo "Creating symlinks..."

CONFIG_DIR="$HOME/.config"
if [ ! -d "$CONFIG_DIR" ]; then
    echo "Creating $CONFIG_DIR directory..."
    mkdir -p "$CONFIG_DIR"
fi

for package_dir in "$DOTFILES_DIR/packages"/*; do
    package_name=$(basename "$package_dir")
    echo "Stowing $package_name..."
    stow -v -d "$DOTFILES_DIR/packages" -t ~ "$package_name"
done

source ~/.zshrc
