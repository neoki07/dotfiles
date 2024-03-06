#!/bin/bash

echo "Setting up Rust..."
if ! command -v rustup &>/dev/null; then
  echo "Installing Rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  source $HOME/.cargo/env
else
  echo "Rustup is already installed"
fi

if ! command -v rustc &>/dev/null; then
  echo "Installing Rust..."
  rustup install stable
  rustup install nightly
else
  echo "Rust is already installed"
fi
