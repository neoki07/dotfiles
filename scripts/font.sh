#!/bin/bash

# Install JetBrains Mono font
FONT_URL="https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip"
DESTINATION_PATH="/tmp/jetbrainsmono.zip"
UNZIP_PATH="/tmp/jetbrainsmono"

echo "Downloading JetBrains Mono font..."
curl --silent -o "$DESTINATION_PATH" -L "$FONT_URL"

echo "Unzipping JetBrains Mono font..."
unzip -q -o "$DESTINATION_PATH" -d "$UNZIP_PATH"

echo "Installing JetBrains Mono font..."
cp "$UNZIP_PATH/fonts/variable/JetBrainsMono[wght].ttf" ~/Library/Fonts/
cp "$UNZIP_PATH/fonts/variable/JetBrainsMono-Italic[wght].ttf" ~/Library/Fonts/

echo "Cleaning up temporary files..."
rm -rf "$UNZIP_PATH"
rm "$DESTINATION_PATH"
