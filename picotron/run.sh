#!/bin/bash
# Run K-Razy Shoot-Out in Picotron

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Path to Picotron application (adjust if needed)
PICOTRON_APP="/Applications/Picotron.app/Contents/MacOS/picotron"

# Check if Picotron exists
if [ ! -f "$PICOTRON_APP" ]; then
    echo "Error: Picotron not found at $PICOTRON_APP"
    echo "Please edit this script and set the correct path to Picotron"
    exit 1
fi

# Run Picotron with the cartridge folder
echo "Starting K-Razy Shoot-Out in Picotron..."
"$PICOTRON_APP" "$SCRIPT_DIR/krazy_shootout.p64"
