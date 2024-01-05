# dotfiles

There are my dotfiles for macOS.

## Package overview

- General settings for macOS
  - Speed up trackpad scaling
  - Speed up mouse scaling
  - Speed up scroll wheel scaling
  - Speed up keyboard repeat
  - Speed up initial key repeat
  - Enable function keys
  - Show scroll bars when scrolling
  - Swap caps lock and control
- Install tools with Homebrew
  - git
  - mise
  - Neovim
  - Starship
  - 1Password
  - Raycast
  - Visual Studio Code
  - etc.
- Install programming languages and related tools
  - Node.js
  - pnpm
  - Bun
  - Go
  - Rust
- Set up zsh
  - Install zsh plugins
    - zsh-autosuggestions
    - zsh-completions
    - fast-syntax-highlighting
    - enhancd
- Setup Neovim
  - Change keymaps
  - Install plugins
    - vim-surround
    - CamelCaseMotion

## Installation

### 1. Prepare

Install Xcode Command Line Tools.

```sh
xcode-select --install
```

### 2. Clone this repository and run setup script

```sh
git clone https://github.com/ot07/dotfiles.git
cd dotfiles
sh setup.sh
```
