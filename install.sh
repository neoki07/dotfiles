#!/bin/bash

if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "This script is only for macOS."
  exit 1
fi

BREW_WORK_PACKAGE_OPTIONS=("fzf" "git" "mise" "neovim" "starship")
BREW_PERSONAL_PACKAGE_OPTIONS=("golang-migrate" "sqlc" "wasm-pack")

BREW_WORK_CASK_OPTIONS=("brewlet" "figma" "gather" "notion" "orbstack" "raycast" "tableplus" "visual-studio-code" "warp")
BREW_PERSONAL_CASK_OPTIONS=("1password" "arc" "brave-browser" "brewlet" "discord" "figma" "jetbrains-toolbox" "min" "notion" "obsidian" "orbstack" "raycast" "slack" "spotify" "tableplus" "visual-studio-code" "warp")

OTHER_WORK_PACKAGE_OPTIONS=("nodejs" "pnpm")
OTHER_PERSONAL_PACKAGE_OPTIONS=("nodejs" "pnpm" "bun" "go" "rust")

VSCODE_WORK_EXTENSIONS_REMOTE_FILE="https://raw.githubusercontent.com/neokidev/dotfiles/HEAD/vscode/extensions"
VSCODE_PERSONAL_EXTENSIONS_REMOTE_FILE="https://raw.githubusercontent.com/neokidev/dotfiles/HEAD/vscode/extensions-personal"

VSCODE_WORK_EXTENSION_OPTIONS=()
while read -r line; do
  VSCODE_WORK_EXTENSION_OPTIONS+=("$line")
done < <(curl -s "$VSCODE_WORK_EXTENSIONS_REMOTE_FILE")

VSCODE_PERSONAL_EXTENSION_OPTIONS=()
while read -r line; do
  VSCODE_PERSONAL_EXTENSION_OPTIONS+=("$line")
done < <(curl -s "$VSCODE_PERSONAL_EXTENSIONS_REMOTE_FILE")

ESC=$(printf "\033")

STYLE_RESET="${ESC}[m"
STYLE_BOLD="${ESC}[1m"
STYLE_ITALIC="${ESC}[3m"
STYLE_GREEN="${ESC}[32m"
STYLE_YELLOW="${ESC}[33m"
STYLE_CYAN="${ESC}[36m"
STYLE_GRAY="${ESC}[90m"

KEY_ENTER=""
KEY_ESC=$'\x1b'
KEY_SPACE=$'\x20'
KEY_BACKSPACE=$'\x7f'
KEY_A="a"
KEY_H="h"
KEY_J="j"
KEY_K="k"
KEY_L="l"
KEY_CTRL_P=$'\x10'
KEY_CTRL_N=$'\x0e'
KEY_CTRL_F=$'\x06'
KEY_CTRL_B=$'\x02'
KEY_CTRL_A=$'\x01'
KEY_CTRL_E=$'\x05'
KEY_UP_SUFFIX="[A"
KEY_DOWN_SUFFIX="[B"
KEY_RIGHT_SUFFIX="[C"
KEY_LEFT_SUFFIX="[D"

run_command() {
  local command=$1
  local print_stdout=${2:-false}
  local print_stderr=${3:-false}
  local status

  # TODO: Write to log file
  if [ "$print_stdout" = true ] && [ "$print_stderr" = true ]; then
    eval "$command"
  fi

  if [ "$print_stdout" = true ] && [ "$print_stderr" = false ]; then
    eval "$command" 2>/dev/null
  fi

  if [ "$print_stdout" = false ] && [ "$print_stderr" = true ]; then
    eval "$command" >/dev/null
  fi

  if [ "$print_stdout" = false ] && [ "$print_stderr" = false ]; then
    eval "$command" >/dev/null 2>&1
  fi

  status=$?
  if [ "$status" -ne 0 ]; then
    echo "Command failed: $command"
    exit "$status"
  fi
}

run_check_command() {
  local command=$1
  eval "$command" >/dev/null 2>&1
  return $?
}

cursor_blink_on() {
  printf "%s[?25h" "$ESC"
}

cursor_blink_off() {
  printf "%s[?25l" "$ESC"
}

cursor_to() {
  printf "%s[$1;${2:-1}H" "$ESC"
}

cursor_to_line_start() {
  printf "\r"
}

clear_line() {
  printf "\r%s[K" "$ESC"
}

read_key() {
  local key
  IFS= read -rsn1 key 2>/dev/null >&2
  echo "$key"
}

get_cursor_row() {
  stty -echo
  # shellcheck disable=SC2162
  IFS=';' read -sdR -p $'\E[6n' ROW _COL </dev/tty
  echo "${ROW#*[} + 1"
  stty echo
}

print_question() {
  local question=$1
  echo "$STYLE_CYAN?$STYLE_RESET $question"
}

print_warning() {
  local warning=$1
  echo "$STYLE_YELLOW! $warning$STYLE_RESET"
}

print_info() {
  local info=$1
  printf "$STYLE_YELLOW%s$STYLE_RESET $info\n" "!"
}

wait_for_process_to_finish() {
  local pid=$1
  local waiting_message=$2
  local done_message=$3
  local delay=0.05
  local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

  cursor_blink_off
  stty -echo

  while ps -p "$pid" >/dev/null; do
    i=$(((i + 1) % 10))

    printf "%s%s%s %s..." "$STYLE_CYAN" "${spinstr:$i:1}" "$STYLE_RESET" "$waiting_message"
    sleep $delay

    cursor_to_line_start
  done

  clear_line
  printf "$STYLE_GREEN%s$STYLE_RESET $done_message\n" "✓"

  cursor_blink_on
  stty echo
}

text_prompt() {
  print_input() {
    local input=$1
    printf "%s❯%s %s" "$STYLE_GREEN" "$STYLE_RESET" "$input"
  }

  print_placeholder() {
    local placeholder=$1
    printf "%s❯%s %s%s%s" "$STYLE_GREEN" "$STYLE_RESET" "$STYLE_GRAY" "$placeholder" "$STYLE_RESET"
  }

  key_to_command() {
    local key=$1
    if [[ $key == "$KEY_ENTER" ]]; then
      echo "enter"
    elif [[ $key == "$KEY_BACKSPACE" ]]; then
      echo "backspace"
    else
      echo "input"
    fi
  }

  local retval=$1
  local input
  local placeholder
  local default

  if [[ -z "$2" ]]; then
    placeholder=""
  else
    placeholder="$2"
  fi

  if [[ -z "$3" ]]; then
    default=""
  else
    default="$3"
  fi

  trap "printf '\n'; cursor_blink_on; stty echo; exit" 2
  cursor_blink_off
  stty -echo

  while :; do
    clear_line

    if [[ -z "$input" ]]; then
      print_placeholder "$placeholder"
    else
      print_input "$input"
    fi

    key=$(read_key)
    case $(key_to_command "$key") in
    enter) break ;;
    backspace) input="${input%?}" ;;
    input) input+="$key" ;;
    esac
  done

  clear_line

  cursor_blink_on
  stty echo

  if [[ -z "$input" ]]; then
    input="$default"
  fi

  if [[ -z "$input" ]]; then
    printf "%s❯%s %sNone%s\n" "$STYLE_GREEN" "$STYLE_RESET" "$STYLE_GRAY" "$STYLE_RESET"
  else
    printf "%s❯%s %s%s%s\n" "$STYLE_GREEN" "$STYLE_RESET" "$STYLE_GRAY" "$input" "$STYLE_RESET"
  fi

  eval "$retval=$input"
}

password_prompt() {
  key_to_command() {
    local key=$1
    if [[ $key == "$KEY_ENTER" ]]; then
      echo "enter"
    elif [[ $key == "$KEY_BACKSPACE" ]]; then
      echo "backspace"
    else
      echo "input"
    fi
  }

  local retval=$1
  local input

  trap "printf '\n'; cursor_blink_on; stty echo; exit" 2
  cursor_blink_off
  stty -echo

  printf "%s❯%s" "$STYLE_GREEN" "$STYLE_RESET"
  while :; do
    key=$(read_key)
    case $(key_to_command "$key") in
    enter) break ;;
    backspace) input="${input%?}" ;;
    input) input+="$key" ;;
    esac
  done

  clear_line

  cursor_blink_on
  stty echo

  printf "%s❯%s %s%sSecret%s\n" "$STYLE_GREEN" "$STYLE_RESET" "$STYLE_GRAY" "$STYLE_ITALIC" "$STYLE_RESET"

  eval "$retval=$input"
}

yes_no_prompt() {
  print_options() {
    local selected=$1

    if [[ $selected == true ]]; then
      printf "%s●%s %sYes%s%s / ○ No%s" "$STYLE_GREEN" "$STYLE_RESET" "$STYLE_BOLD" "$STYLE_RESET" "$STYLE_GRAY" "$STYLE_RESET"
    else
      printf "%s○ Yes / %s●%s %sNo%s" "$STYLE_GRAY" "$STYLE_GREEN" "$STYLE_RESET" "$STYLE_BOLD" "$STYLE_RESET"
    fi
  }

  key_to_command() {
    local key=$1
    if [[ $key == "$KEY_ENTER" ]]; then echo "enter"; fi
    if [[ $key == "$KEY_H" ]]; then echo "toggle"; fi
    if [[ $key == "$KEY_J" ]]; then echo "toggle"; fi
    if [[ $key == "$KEY_K" ]]; then echo "toggle"; fi
    if [[ $key == "$KEY_L" ]]; then echo "toggle"; fi
    if [[ $key == "$KEY_CTRL_F" ]]; then echo "toggle"; fi
    if [[ $key == "$KEY_CTRL_B" ]]; then echo "toggle"; fi
    if [[ $key == "$KEY_CTRL_P" ]]; then echo "toggle"; fi
    if [[ $key == "$KEY_CTRL_N" ]]; then echo "toggle"; fi
    if [[ $key == "$KEY_CTRL_A" ]]; then echo "yes"; fi
    if [[ $key == "$KEY_CTRL_E" ]]; then echo "no"; fi
    if [[ $key == "$KEY_ESC" ]]; then
      read -rsn2 key
      if [[ $key == "$KEY_UP_SUFFIX" ]]; then echo "toggle"; fi
      if [[ $key == "$KEY_DOWN_SUFFIX" ]]; then echo "toggle"; fi
      if [[ $key == "$KEY_RIGHT_SUFFIX" ]]; then echo "toggle"; fi
      if [[ $key == "$KEY_LEFT_SUFFIX" ]]; then echo "toggle"; fi
    fi
  }

  local retval=$1

  trap "printf '\n'; cursor_blink_on; stty echo; exit" 2
  cursor_blink_off
  stty -echo

  local selected=true
  while true; do
    clear_line
    print_options $selected

    key=$(read_key)
    case $(key_to_command "$key") in
    enter) break ;;
    toggle) if [[ $selected == true ]]; then selected=false; else selected=true; fi ;;
    yes) selected=true ;;
    no) selected=false ;;
    esac
  done

  printf "\n"
  cursor_blink_on
  stty echo

  eval "$retval=$selected"
}

select_prompt() {
  print_option() {
    local option=$1
    local selected=$2
    local prefix
    local style

    if [[ $selected == true ]]; then
      prefix="${STYLE_GREEN}●${STYLE_RESET}"
      style="${STYLE_BOLD}"
    else
      prefix="${STYLE_GRAY}○${STYLE_RESET}"
      style="${STYLE_GRAY}"
    fi

    printf "%s %s%s%s" "$prefix" "$style" "$option" "$STYLE_RESET"
  }

  key_to_command() {
    local key=$1
    if [[ $key = "$KEY_ENTER" ]]; then echo "enter"; fi
    if [[ $key = "$KEY_SPACE" ]]; then echo "space"; fi
    if [[ $key = "$KEY_H" ]]; then echo "prev"; fi
    if [[ $key = "$KEY_J" ]]; then echo "next"; fi
    if [[ $key = "$KEY_K" ]]; then echo "prev"; fi
    if [[ $key = "$KEY_L" ]]; then echo "next"; fi
    if [[ $key == "$KEY_CTRL_F" ]]; then echo "next"; fi
    if [[ $key == "$KEY_CTRL_B" ]]; then echo "prev"; fi
    if [[ $key = "$KEY_CTRL_P" ]]; then echo "prev"; fi
    if [[ $key = "$KEY_CTRL_N" ]]; then echo "next"; fi
    if [[ $key == "$KEY_CTRL_A" ]]; then echo "top"; fi
    if [[ $key == "$KEY_CTRL_E" ]]; then echo "bottom"; fi
    if [[ $key = "$KEY_ESC" ]]; then
      read -rsn2 key
      if [[ $key = "$KEY_UP_SUFFIX" ]]; then echo "prev"; fi
      if [[ $key = "$KEY_DOWN_SUFFIX" ]]; then echo "next"; fi
      if [[ $key = "$KEY_RIGHT_SUFFIX" ]]; then echo "next"; fi
      if [[ $key = "$KEY_LEFT_SUFFIX" ]]; then echo "prev"; fi
    fi
  }

  local retval=$1
  local options

  IFS=';' read -r -a options <<<"$2"

  printf "\n%.0s" $(seq 1 $((${#options[@]} - 1)))

  local lastrow
  lastrow=$(get_cursor_row)

  local startrow=$((lastrow - ${#options[@]}))

  trap "printf '\n'; cursor_blink_on; stty echo; exit" 2
  cursor_blink_off
  stty -echo

  local selected_idx=0
  while true; do
    local idx=0

    for option in "${options[@]}"; do
      cursor_to $((startrow + idx))

      local active=false
      if [ $idx -eq $selected_idx ]; then
        active=true
      fi

      print_option "$option" "$active"

      ((idx++))
    done

    key=$(read_key)
    case $(key_to_command "$key") in
    enter) break ;;
    prev)
      ((selected_idx--))
      if [ $selected_idx -lt 0 ]; then selected_idx=$((${#options[@]} - 1)); fi
      ;;
    next)
      ((selected_idx++))
      if [ $selected_idx -ge ${#options[@]} ]; then selected_idx=0; fi
      ;;
    top) selected_idx=0 ;;
    bottom) selected_idx=$((${#options[@]} - 1)) ;;
    esac
  done

  printf "\n"
  cursor_blink_on
  stty echo

  eval "$retval"="${options[$selected_idx]}"
}

multiselect_prompt() {
  print_option() {
    local option=$1
    local selected=$2
    local active=$3
    local prefix
    local style

    if [[ $selected == true ]]; then
      prefix="${STYLE_GREEN}◼${STYLE_RESET}"
    else
      prefix="${STYLE_GRAY}◻${STYLE_RESET}"
    fi

    if [[ $active == true ]]; then
      style="${STYLE_BOLD}"
    else
      style="${STYLE_GRAY}"
    fi

    printf "%s %s%s%s" "$prefix" "$style" "$option" "$STYLE_RESET"
  }

  key_to_command() {
    local key=$1
    if [[ $key = "$KEY_ENTER" ]]; then echo "enter"; fi
    if [[ $key = "$KEY_A" ]]; then echo "all"; fi
    if [[ $key = "$KEY_SPACE" ]]; then echo "space"; fi
    if [[ $key = "$KEY_H" ]]; then echo "prev"; fi
    if [[ $key = "$KEY_J" ]]; then echo "next"; fi
    if [[ $key = "$KEY_K" ]]; then echo "prev"; fi
    if [[ $key = "$KEY_L" ]]; then echo "next"; fi
    if [[ $key == "$KEY_CTRL_F" ]]; then echo "next"; fi
    if [[ $key == "$KEY_CTRL_B" ]]; then echo "prev"; fi
    if [[ $key = "$KEY_CTRL_P" ]]; then echo "prev"; fi
    if [[ $key = "$KEY_CTRL_N" ]]; then echo "next"; fi
    if [[ $key == "$KEY_CTRL_A" ]]; then echo "top"; fi
    if [[ $key == "$KEY_CTRL_E" ]]; then echo "bottom"; fi
    if [[ $key = "$KEY_ESC" ]]; then
      read -rsn2 key
      if [[ $key = "$KEY_UP_SUFFIX" ]]; then echo "prev"; fi
      if [[ $key = "$KEY_DOWN_SUFFIX" ]]; then echo "next"; fi
      if [[ $key = "$KEY_RIGHT_SUFFIX" ]]; then echo "next"; fi
      if [[ $key = "$KEY_LEFT_SUFFIX" ]]; then echo "prev"; fi
    fi
  }

  toggle_option() {
    local arr_name=$1
    local option=$2
    eval "local arr=(\"\${${arr_name}[@]}\")"
    if [[ ${arr[option]} == true ]]; then
      arr[option]=
    else
      arr[option]=true
    fi
    eval "$arr_name"='("${arr[@]}")'
  }

  toggle_all_options() {
    local arr_name=$1
    eval "local arr=(\"\${${arr_name}[@]}\")"
    local all_selected=true
    for val in "${arr[@]}"; do
      if [[ $val != true ]]; then
        all_selected=false
        break
      fi
    done
    for ((i = 0; i < ${#arr[@]}; i++)); do
      arr[i]=$([[ $all_selected == false ]] && echo true || echo "")
    done
    eval "$arr_name"='("${arr[@]}")'
  }

  local retval=$1
  local options
  local selected=()
  local checked_initially=$3

  IFS=';' read -r -a options <<<"$2"

  for ((i = 0; i < ${#options[@]}; i++)); do
    if [[ $checked_initially == true ]]; then
      selected+=(true)
    else
      selected+=(false)
    fi
  done

  printf "\n%.0s" $(seq 1 $((${#options[@]} - 1)))

  local lastrow
  lastrow=$(get_cursor_row)

  local startrow=$((lastrow - ${#options[@]}))

  trap "printf '\n'; cursor_blink_on; stty echo; exit" 2
  cursor_blink_off
  stty -echo

  local active_idx=0
  while true; do
    local idx=0

    for option in "${options[@]}"; do
      cursor_to $((startrow + idx))

      local active=false
      if [ $idx -eq $active_idx ]; then
        active=true
      fi

      print_option "$option" "${selected[idx]}" "$active"

      ((idx++))
    done

    key=$(read_key)
    case $(key_to_command "$key") in
    space) toggle_option selected $active_idx ;;
    all) toggle_all_options selected ;;
    enter) break ;;
    prev)
      ((active_idx--))
      if [ $active_idx -lt 0 ]; then active_idx=$((${#options[@]} - 1)); fi
      ;;
    next)
      ((active_idx++))
      if [ $active_idx -ge ${#options[@]} ]; then active_idx=0; fi
      ;;
    top) active_idx=0 ;;
    bottom) active_idx=$((${#options[@]} - 1)) ;;
    esac
  done

  printf "\n"
  cursor_blink_on
  stty echo

  local result=()
  for i in "${!selected[@]}"; do
    if [ "${selected[$i]}" == true ]; then
      result+=("${options[$i]}")
    fi
  done

  eval "$retval"='("${result[@]}")'
}

# ========================================
# Questions
# ========================================

print_question "Where should we clone the dotfiles?"
DOTFILES_PARENT_DIR=$HOME
text_prompt DOTFILES_PARENT_DIR "$HOME (\$HOME)" "$HOME"
printf "\n"

print_question "What is your account password?"

sudo -k
while true; do
  password_prompt PASSWORD
  printf "\n"

  if echo "$PASSWORD" | sudo -S -v 2>/dev/null; then
    break
  else
    print_warning "The password is incorrect. Please try again."
  fi
done

print_question "Which mode do you want to use for the installation?"
# select_prompt INSTALL_MODE "Personal;Work;Custom"
select_prompt INSTALL_MODE "Personal;Work"
printf "\n"

BREW_PACKAGES=()
BREW_CASKS=()
OTHER_PACKAGES=()
VSCODE_EXTENSIONS=()

if [ "$INSTALL_MODE" = "Personal" ]; then
  BREW_PACKAGES=("${BREW_PERSONAL_PACKAGE_OPTIONS[@]}")
  BREW_CASKS=("${BREW_PERSONAL_CASK_OPTIONS[@]}")
  OTHER_PACKAGES=("${OTHER_PERSONAL_PACKAGE_OPTIONS[@]}")
  VSCODE_EXTENSIONS=("${VSCODE_PERSONAL_EXTENSION_OPTIONS[@]}")
elif [ "$INSTALL_MODE" = "Work" ]; then
  BREW_PACKAGES=("${BREW_WORK_PACKAGE_OPTIONS[@]}")
  BREW_CASKS=("${BREW_WORK_CASK_OPTIONS[@]}")
  OTHER_PACKAGES=("${OTHER_WORK_PACKAGE_OPTIONS[@]}")
  VSCODE_EXTENSIONS=("${VSCODE_WORK_EXTENSION_OPTIONS[@]}")
# elif [ "$INSTALL_MODE" = "Custom" ]; then
#   ...

#   print_question "Which brew packages do you want to install?"
#   multiselect_prompt BREW_PACKAGES "$BREW_WORK_PACKAGE_OPTIONS_STRING" true
#   printf "\n"

#   print_question "Which brew applications do you want to install?"
#   multiselect_prompt BREW_CASKS "$BREW_WORK_CASK_OPTIONS_STRING" true
#   printf "\n"

#   print_question "Which other packages do you want to install?"
#   multiselect_prompt OTHER_PACKAGES "$OTHER_WORK_PACKAGE_OPTIONS_STRING" true
#   printf "\n"

#   print_question "Which VSCode extensions do you want to install?"
#   multiselect_prompt VSCODE_EXTENSIONS "$VSCODE_WORK_EXTENSION_OPTIONS_STRING" true
#   printf "\n"
else
  echo "Invalid mode: $INSTALL_MODE"
  exit 1
fi

# ========================================
# Login to GitHub
# ========================================

GH_DISTRIBUTE_URL="https://github.com/cli/cli/releases/download/v2.45.0/gh_2.45.0_macOS_arm64.zip"
GH_EXTRACTED_DIR=$TMPDIR/$(basename "$GH_DISTRIBUTE_URL" .zip)
GH_ZIP_FILE=$GH_EXTRACTED_DIR.zip
GH_COMMAND_PATH=$GH_EXTRACTED_DIR/bin/gh

(run_command "curl -L $GH_DISTRIBUTE_URL -o $GH_ZIP_FILE && unzip -o $GH_ZIP_FILE -d $TMPDIR") &
PID=$!
wait_for_process_to_finish "$PID" "Downloading GitHub CLI" "GitHub CLI downloaded."
wait "$PID"

if run_check_command "'$GH_COMMAND_PATH' auth status 2>&1 | grep -q 'You are not logged into any GitHub hosts.'"; then
  run_command "'$GH_COMMAND_PATH' auth login -w" true true
else
  print_info "You are already logged in to GitHub."
fi

# ========================================
# Install Xcode Command Line Tools
# ========================================

if ! run_check_command "xcode-select -p"; then
  touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  PROD=$(softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | sed 's/^[^C]* //')
  (run_command "softwareupdate -i '$PROD'") &
  PID=$!
  wait_for_process_to_finish "$PID" "Installing Xcode Command Line Tools" "Xcode Command Line Tools installed."
  wait "$PID"
else
  print_info "Xcode Command Line Tools already installed."
fi

# ========================================
# Clone the dotfiles
# ========================================

DOTFILES_DIR="$DOTFILES_PARENT_DIR/dotfiles"
if [ -d "$DOTFILES_DIR" ]; then
  print_info "The dotfiles already cloned."
else
  (GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no" "${GH_COMMAND_PATH}" repo clone neokidev/dotfiles "$DOTFILES_DIR") &
  PID=$!
  wait_for_process_to_finish "$PID" "Cloning dotfiles" "Dotfiles cloned."
  wait "$PID"
fi

# ========================================
# Clean up gh files
# ========================================

rm -rf "$GH_ZIP_FILE"
rm -rf "$GH_EXTRACTED_DIR"

# ========================================
# Set up macOS preferences
# ========================================

echo "Setting up macOS preferences..."

# Trackpad settings
defaults write -g com.apple.trackpad.scaling 3

# Mouse settings
defaults write -g com.apple.mouse.scaling 3
defaults write -g com.apple.scrollwheel.scaling 5

# Keyboard settings
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true

defaults -currentHost write -g "com.apple.keyboard.modifiermapping.$(ioreg -c AppleEmbeddedKeyboard -r | grep -Eiw "VendorID|ProductID" | awk '{ print $4 }' | paste -s -d'-\n' -)-0" -array "
<dict>
  <key>HIDKeyboardModifierMappingDst</key><integer>30064771129</integer>
  <key>HIDKeyboardModifierMappingSrc</key><integer>30064771296</integer>
</dict>
" "
<dict>
  <key>HIDKeyboardModifierMappingDst</key><integer>30064771296</integer>
  <key>HIDKeyboardModifierMappingSrc</key><integer>30064771129</integer>
</dict>
"

# Scrollbar settings
defaults write NSGlobalDomain AppleShowScrollBars -string "WhenScrolling"

# Disable spotlight shortcuts
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "
<dict>
  <key>enabled</key><false/>
  <key>value</key><dict>
    <key>parameters</key><array>
      <integer>65535</integer>
      <integer>49</integer>
      <integer>1048576</integer>
    </array>
    <key>type</key><string>standard</string>
  </dict>
</dict>"

defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 65 "
<dict>
  <key>enabled</key><false/>
  <key>value</key><dict>
    <key>parameters</key><array>
      <integer>65535</integer>
      <integer>49</integer>
      <integer>1572864</integer>
    </array>
    <key>type</key><string>standard</string>
  </dict>
</dict>"

# Finder settings
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"
defaults write com.apple.Finder "AppleShowAllFiles" -bool "true"
defaults write com.apple.finder ShowPathbar -bool "true"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

# Dock settings
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock "tilesize" -int "36"
defaults write com.apple.dock "show-recents" -bool "false"

# Feedback settings
defaults write com.apple.appleseed.FeedbackAssistant "Autogather" -bool "false"
defaults write com.apple.CrashReporter DialogType -string "none"

# ========================================
# Install Homebrew
# ========================================

if ! run_check_command "command -v brew"; then
  (NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >/dev/null 2>&1) &
  PID=$!
  wait_for_process_to_finish "$PID" "Installing Homebrew" "Homebrew installed."
  wait "$PID"

  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  print_info "Homebrew already installed."
fi

# ========================================
# Install brew packages
# ========================================

echo "Installing Homebrew packages..."

INSTALLED_BREW_PACKAGES=$(brew list)

for package in "${BREW_PACKAGES[@]}"; do
  if echo "$INSTALLED_BREW_PACKAGES" | grep -q "^$package\$"; then
    print_info "$package already installed."
  else
    (run_command "brew install '$package'") &
    PID=$!
    wait_for_process_to_finish "$PID" "Installing $STYLE_BOLD$package$STYLE_RESET" "$STYLE_BOLD$package$STYLE_RESET installed."
    wait "$PID"
  fi
done

for cask in "${BREW_CASKS[@]}"; do
  if brew list --cask | grep -q "^$cask\$"; then
    print_info "$cask already installed."
  else
    (run_command "brew install --cask '$cask'") &
    PID=$!
    wait_for_process_to_finish "$PID" "Installing $STYLE_BOLD$cask$STYLE_RESET" "$STYLE_BOLD$cask$STYLE_RESET installed."
    wait "$PID"
  fi
done

# ========================================
# Install packages with mise
# ========================================

echo "Installing packages with mise..."

# Install Node.js
if [[ "${OTHER_PACKAGES[*]}" =~ "nodejs" ]]; then
  (run_command "mise install nodejs@latest && mise global nodejs@latest") &
  PID=$!
  wait_for_process_to_finish "$PID" "Installing ${STYLE_BOLD}Node.js$STYLE_RESET" "${STYLE_BOLD}Node.js$STYLE_RESET installed."
  wait "$PID"
fi

# Install pnpm
if [[ "${OTHER_PACKAGES[*]}" =~ "pnpm" ]]; then
  if ! mise plugin ls | grep -q pnpm; then
    (run_command "mise plugin install pnpm -y") &
    PID=$!
    wait_for_process_to_finish "$PID" "Installing ${STYLE_BOLD}mise pnpm plugin${STYLE_RESET}" "${STYLE_BOLD}mise pnpm plugin${STYLE_RESET} installed."
    wait "$PID"
  fi
  (run_command "mise install pnpm@latest && mise global pnpm@latest") &
  PID=$!
  wait_for_process_to_finish "$PID" "Installing ${STYLE_BOLD}pnpm${STYLE_RESET}" "${STYLE_BOLD}pnpm${STYLE_RESET} installed."
  wait "$PID"
fi

# Install Bun
if [[ "${OTHER_PACKAGES[*]}" =~ "bun" ]]; then
  (run_command "mise install bun@latest && mise global bun@latest") &
  PID=$!
  wait_for_process_to_finish "$PID" "Installing ${STYLE_BOLD}Bun${STYLE_RESET}" "${STYLE_BOLD}Bun${STYLE_RESET} installed."
  wait "$PID"
fi

# Install Go
if [[ "${OTHER_PACKAGES[*]}" =~ "go" ]]; then
  (run_command "mise install go@latest && mise global go@latest") &
  PID=$!
  wait_for_process_to_finish "$PID" "Installing ${STYLE_BOLD}Go${STYLE_RESET}" "${STYLE_BOLD}Go${STYLE_RESET} installed."
  wait "$PID"
fi

# ========================================
# Install Rust
# ========================================

if [[ "${OTHER_PACKAGES[*]}" =~ "rust" ]]; then
  if ! run_check_command "command -v rustup"; then
    (run_command "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y") &
    PID=$!
    wait_for_process_to_finish "$PID" "Installing ${STYLE_BOLD}Rustup${STYLE_RESET}" "${STYLE_BOLD}Rustup${STYLE_RESET} installed."
    wait "$PID"

    # shellcheck source=/dev/null
    source "$HOME/.cargo/env"
  else
    print_info "${STYLE_BOLD}Rustup${STYLE_RESET} already installed."
  fi

  if ! run_check_command "command -v rustc"; then
    (run_command "rustup install stable") &
    PID=$!
    wait_for_process_to_finish "$PID" "Installing ${STYLE_BOLD}Rust stable${STYLE_RESET}" "${STYLE_BOLD}Rust stable${STYLE_RESET} installed."
    wait "$PID"

    (run_command "rustup install nightly") &
    PID=$!
    wait_for_process_to_finish "$PID" "Installing ${STYLE_BOLD}Rust nightly${STYLE_RESET}" "${STYLE_BOLD}Rust nightly${STYLE_RESET} installed."
    wait "$PID"
  else
    print_info "${STYLE_BOLD}Rust${STYLE_RESET} is already installed."
  fi
fi

# ========================================
# Set up VSCode
# ========================================

echo "Setting up VSCode..."

# Enable key repeat
# Reference: https://marketplace.visualstudio.com/items?itemName=vscodevim.vim
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false

if ! run_check_command "command -v stow"; then
  (run_command "brew install stow") &
  PID=$!
  wait_for_process_to_finish "$PID" "Installing ${STYLE_BOLD}stow${STYLE_RESET}" "${STYLE_BOLD}Stow${STYLE_RESET} installed."
  wait "$PID"
else
  print_info "${STYLE_BOLD}Stow${STYLE_RESET} already installed."
fi

VSCODE_CONFIG_DIR="$HOME/Library/Application Support/Code/User"
if [ ! -d "$VSCODE_CONFIG_DIR" ]; then
  mkdir -p "$VSCODE_CONFIG_DIR"
fi
(run_command "stow -v -d '$DOTFILES_DIR/vscode' -t '$VSCODE_CONFIG_DIR' config") &
PID=$!
wait_for_process_to_finish "$PID" "Stowing VSCode configuration" "VSCode configuration stowed."
wait "$PID"

echo "Installing VSCode extensions..."
for extension in "${VSCODE_EXTENSIONS[@]}"; do
  (run_command "code --install-extension '$extension'") &
  PID=$!
  wait_for_process_to_finish "$PID" "Installing $STYLE_BOLD$extension$STYLE_RESET" "$STYLE_BOLD$extension$STYLE_RESET installed."
  wait "$PID"
done

if [ "$INSTALL_MODE" = "Personal" ]; then
  for extension in "${VSCODE_PERSONAL_EXTENSION_OPTIONS[@]}"; do
    (run_command "code --install-extension '$extension'") &
    PID=$!
    wait_for_process_to_finish "$PID" "Installing $STYLE_BOLD$extension$STYLE_RESET" "$STYLE_BOLD$extension$STYLE_RESET installed."
    wait "$PID"
  done
fi

# ========================================
# Create symlinks
# ========================================

echo "Installing stow for creating symlinks..."

if ! run_check_command "command -v stow"; then
  (run_command "brew install stow") &
  PID=$!
  wait_for_process_to_finish "$PID" "Installing ${STYLE_BOLD}stow${STYLE_RESET}" "${STYLE_BOLD}Stow${STYLE_RESET} installed."
  wait "$PID"
else
  print_info "${STYLE_BOLD}Stow${STYLE_RESET} already installed."
fi

echo "Creating symlinks..."

CONFIG_DIR="$HOME/.config"
if [ ! -d "$CONFIG_DIR" ]; then
  mkdir -p "$CONFIG_DIR"
fi

for package_dir in "$DOTFILES_DIR/packages"/*; do
  package_name=$(basename "$package_dir")

  if [ "$package_name" = "git" ]; then
    GIT_CONFIG_DIR="$HOME/.config/git"
    (run_command "stow -v -d '$DOTFILES_DIR/packages' -t $GIT_CONFIG_DIR $package_name") &
    PID=$!
  else
    (run_command "stow -v -d '$DOTFILES_DIR/packages' -t ~ '$package_name'") &
    PID=$!
  fi

  wait_for_process_to_finish "$PID" "Creating symlinks for $STYLE_BOLD$package_name$STYLE_RESET" "Symlinks for $STYLE_BOLD$package_name$STYLE_RESET created."
  wait "$PID"
done

# ========================================
# Reboot the system
# ========================================

printf "\n"
print_question "Installation is complete! Do you want to reboot the system?"
yes_no_prompt SHOULD_REBOOT
printf "\n"

if [ "$SHOULD_REBOOT" = true ]; then
  echo "Rebooting the system..."
  echo "$PASSWORD" | sudo -S reboot 2>/dev/null
else
  print_warning "Please reboot the system to apply the changes."
fi
