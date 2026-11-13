#!/bin/bash

# Get IDs
SWAP_ID=$(wpctl status | grep "headphone_swap_sink" | grep -oP '\d+' | head -n 1)
# HW_ID should be the physical headphones if available, otherwise speakers
HW_ID=$(wpctl status | grep -E "Headphones|Speaker" | grep -v "headphone_swap_sink" | grep -v "Swapped" | grep -oP '\d+' | head -n 1)

# Use pactl info for reliable default sink detection (asterisk parsing is fragile)
CURRENT_DEFAULT=$(pactl info | grep "Default Sink:" | awk '{print $NF}')

if [ -z "$SWAP_ID" ]; then
    notify-send "Audio" "Error: Swapped sink not found. Restarting PipeWire..."
    systemctl --user restart pipewire
    exit 1
fi

if [[ "$CURRENT_DEFAULT" == *"headphone_swap_sink"* ]]; then
    # Currently swapped, switch to normal hardware
    wpctl set-default "$HW_ID"
    notify-send -t 2000 "Audio" "Normal Mode (Swap OFF) 🔊"
else
    # Currently normal, switch to swapped
    wpctl set-default "$SWAP_ID"
    notify-send -t 2000 "Audio" "Swapped Mode (Swap ON) 🔄"
fi
