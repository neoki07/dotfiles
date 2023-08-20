#!/bin/bash

# Install Node.js
echo "Installing Node.js with asdf..."
if ! asdf plugin-list | grep -q 'nodejs'; then
    asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
fi
asdf install nodejs latest
asdf global nodejs latest

# Install pnpm
echo "Installing pnpm with asdf..."
if ! asdf plugin-list | grep -q 'pnpm'; then
    asdf plugin add pnpm https://github.com/jonathanmorley/asdf-pnpm.git
fi
asdf install pnpm latest
asdf global pnpm latest
