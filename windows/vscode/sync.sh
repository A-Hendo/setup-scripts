#!/bin/bash

# Define the base output directory (relative to the script's location or project root)
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Check if SCRIPT_DIR contains "/windows" and "/vscode"
if [[ "$SCRIPT_DIR" == *"/windows"* && "$SCRIPT_DIR" == *"/vscode"* ]]; then
    BASE_OUTPUT_DIR="$SCRIPT_DIR"
elif [[ "$SCRIPT_DIR" == *"/windows"* && "$SCRIPT_DIR" != *"/vscode"* ]]; then
    BASE_OUTPUT_DIR="$SCRIPT_DIR/vscode"
else
    # Default to windows/vscode in the project root if those directories aren’t in the path
    BASE_OUTPUT_DIR="$SCRIPT_DIR/windows/vscode"
fi

# Define arrays for input and output paths (relative to the base output directory)
IN_PATHS=(
    "/mnt/c/Users/adamh/AppData/Roaming/Code/User/settings.json"
    "/mnt/c/Users/adamh/.vscode/extensions/abusayem.night-owl-theme-nocturnal-0.0.6/themes/Night Owl Theme-color-theme.json"
)

OUT_PATHS=(
    "settings.json"
    "theme.json"
)

# Check that the two arrays have the same length
if [ "${#IN_PATHS[@]}" -ne "${#OUT_PATHS[@]}" ]; then
    echo "Error: IN_PATHS and OUT_PATHS arrays must have the same length."
    exit 1
fi

# Loop through the arrays and sync each pair of paths
for i in "${!IN_PATHS[@]}"; do
    in_path="${IN_PATHS[$i]}"
    out_path="$BASE_OUTPUT_DIR/${OUT_PATHS[$i]}"

    # Check if the input path exists and is a file
    if [ ! -f "$in_path" ]; then
        echo "Source file does not exist: $in_path"
        continue
    fi

    # Copy the file from the input path to the output path
    echo "Copying file from $in_path to $out_path..."
    cp "$in_path" "$out_path"
done

echo "All file copy operations completed."
