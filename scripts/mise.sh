#!/bin/bash

# Install Node.js
echo "Installing Node.js with mise..."
mise install nodejs@latest
mise global nodejs@latest

# Install pnpm
echo "Installing pnpm with mise..."
if ! mise plugin ls | grep -q 'pnpm'; then
    mise plugin install pnpm -y
fi
mise install pnpm@latest
mise global pnpm@latest
