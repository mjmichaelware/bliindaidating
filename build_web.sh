#!/bin/bash

# Ensure this script is run from the project root or adjust cd command
# cd "$(dirname "$0")"

echo "--- Starting Flutter Web Build (with Manifest Fix) ---"
flutter build web

# Check if the build was successful
if [ $? -eq 0 ]; then
    echo "--- Flutter Web Build Completed Successfully ---"

    # Explicitly copy web/manifest.json to build/web/
    if [ -f web/manifest.json ]; then
        echo "--- Copying web/manifest.json to build/web/ ---"
        cp web/manifest.json build/web/manifest.json
        if [ $? -eq 0 ]; then
            echo "--- manifest.json copied successfully. ---"
        else
            echo "ERROR: Failed to copy manifest.json. Check permissions or file existence."
            exit 1
        fi
    else
        echo "WARNING: Source web/manifest.json not found. Did you delete it?"
    fi

    # Create empty flutter.js.map if it's missing (to silence 404s)
    if [ ! -f build/web/flutter.js.map ]; then
        echo "--- Creating empty build/web/flutter.js.map ---"
        touch build/web/flutter.js.map
    else
        echo "--- build/web/flutter.js.map already exists. ---"
    fi

    echo "--- Build and asset setup complete. ---"
    echo "To serve: cd build/web && python3 -m http.server 8000 (or run ./serve_web_app.sh)"
else
    echo "ERROR: Flutter Web Build FAILED. Check build output above."
    exit 1
fi
