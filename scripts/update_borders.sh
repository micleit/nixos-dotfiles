#!/usr/bin/env bash

# Path to your Noctalia colors
COLOR_FILE="$HOME/nixos-dotfiles/config/noctalia/colors.json"

# Extract colors directly from the top-level keys
# We strip the '#' because Hyprland expects RRGGBB format
PRIMARY=$(jq -r '.mPrimary' "$COLOR_FILE" | sed 's/#//')
SECONDARY=$(jq -r '.mSecondary' "$COLOR_FILE" | sed 's/#//')
TERTIARY=$(jq -r '.mTertiary' "$COLOR_FILE" | sed 's/#//')

# Apply a 3-way gradient to Hyprland borders
# We add 'ff' for 100% opacity
hyprctl keyword general:col.active_border "rgba(${PRIMARY}ff) rgba(${SECONDARY}ff) rgba(${TERTIARY}ff) 45deg"
