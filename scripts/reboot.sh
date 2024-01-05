#!/bin/bash

read -p "Do you want to restart your PC? (yes/no) " answer
if [ "$answer" == "yes" ]; then
    sudo reboot
else
    echo "Please restart your PC to apply all changes."
fi
