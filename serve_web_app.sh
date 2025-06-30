#!/bin/bash

# Ensure this script is run from the project root or adjust cd command
# cd "$(dirname "$0")"

if [ -d "build/web" ]; then
    echo "Serving web app from build/web (http://localhost:8000)..."
    cd build/web
    python3 -m http.server 8000
else
    echo "Error: build/web directory not found. Please run ./build_web.sh first."
fi
