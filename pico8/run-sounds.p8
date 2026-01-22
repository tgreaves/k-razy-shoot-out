#!/bin/bash
# Launch K-Razy Shoot-Out in PICO-8

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CART_PATH="$SCRIPT_DIR/sounds.p8"

# Check if PICO-8 is installed
if [ -d "/Applications/PICO-8.app" ]; then
    echo "Launching K-Razy Shoot-Out in PICO-8..."
    open -a "PICO-8" "$CART_PATH"
else
    echo "Error: PICO-8 not found in /Applications/"
    echo "Please install PICO-8 or update the path in this script."
    exit 1
fi
