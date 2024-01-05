# Swap caps lock and control keys
hidutil property --set '{"UserKeyMapping":[
    {
        "HIDKeyboardModifierMappingSrc": 0x700000039,
        "HIDKeyboardModifierMappingDst": 0x7000000E0
    },
    {
        "HIDKeyboardModifierMappingSrc": 0x7000000E0,
        "HIDKeyboardModifierMappingDst": 0x700000039
    }
]}' > /dev/null 2>&1

# Setup Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Added by OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
