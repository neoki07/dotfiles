#!/bin/bash

echo "Setting macOS preferences..."

# Trackpad settings
defaults write -g com.apple.trackpad.scaling 3

# Mouse settings
defaults write -g com.apple.mouse.scaling 3
defaults write -g com.apple.scrollwheel.scaling 5

# Keyboard settings
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Scrollbar settings
defaults write NSGlobalDomain AppleShowScrollBars -string "WhenScrolling"
