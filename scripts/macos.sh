#!/bin/bash

# Trackpad settings
defaults write -g com.apple.trackpad.scaling 3

# Keyboard settings
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
