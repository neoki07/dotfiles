#!/bin/bash

ESC=$(printf "\033")

STYLE_RESET="${ESC}[m"
STYLE_BOLD="${ESC}[1m"
STYLE_GREEN="${ESC}[32m"
STYLE_CYAN="${ESC}[36m"
STYLE_GRAY="${ESC}[90m"

KEY_ENTER=""
KEY_ESC=$'\x1b'
KEY_SPACE=$'\x20'
KEY_BACKSPACE=$'\x7f'
KEY_A="a"
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

exit_if_last_command_failed() {
  local status=$?
  if [ "$status" -ne 0 ]; then
    exit "$status"
  fi
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

text_prompt() {
  print_input() {
    local input=$1
    printf "%s" "$input"
  }

  print_placeholder() {
    local placeholder=$1
    printf "%s%s%s" "$STYLE_GRAY" "$placeholder" "$STYLE_RESET"
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
    printf "%sNone%s\n" "$STYLE_GRAY" "$STYLE_RESET"
  else
    printf "%s%s%s\n" "$STYLE_GRAY" "$input" "$STYLE_RESET"
  fi

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

  cursor_to "$lastrow"
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

  cursor_to "$lastrow"
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

trap "printf 'uwa-\n'; exit" 2

print_question "Where should we clone the dotfiles?"
DOTFILES_PARENT_DIR=$HOME
text_prompt DOTFILES_PARENT_DIR "$HOME (\$HOME)" "$HOME"
printf "\n"

print_question "Which brew packages do you want to install?"
BREW_PACKAGES=()
multiselect_prompt BREW_PACKAGES "fzf;git;golang-migrate;mise;neovim;sqlc;starship;wasm-pack" true
printf "\n"

print_question "Which brew applications do you want to install?"
BREW_CASKS=()
multiselect_prompt BREW_CASKS "1password;arc;brave-browser;brewlet;discord;figma;jetbrains-toolbox;min;notion;obsidian;orbstack;raycast;slack;spotify;tableplus;visual-studio-code;warp" true
printf "\n"

print_question "Whether to reboot the system after installation?"
yes_no_prompt SHOULD_REBOOT
printf "\n"

if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  exit_if_last_command_failed

  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "Homebrew already installed."
fi

if ! command -v gh &>/dev/null; then
  echo "Installing GitHub CLI..."
  brew install gh
  exit_if_last_command_failed
else
  echo "GitHub CLI already installed."
fi

if gh auth status 2>&1 | grep -q "You are not logged into any GitHub hosts."; then
  gh auth login -w
  exit_if_last_command_failed
else
  echo "You are already logged in to GitHub."
fi

DOTFILES_DIR="$DOTFILES_PARENT_DIR/dotfiles"
if [ -d "$DOTFILES_DIR" ]; then
  echo "The dotfiles already cloned."
else
  echo "Cloning dotfiles..."
  gh repo clone neokidev/dotfiles "$DOTFILES_DIR"
fi

cd "$DOTFILES_DIR" || exit

# source "setup.sh"
