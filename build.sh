#!/bin/bash

# Build script for DeepStream-Yolo
# This script builds the nvdsinfer_custom_impl_Yolo library and creates a DEB package

set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/nvdsinfer_custom_impl_Yolo/build"

echo "Building DeepStream-Yolo..."
echo "Script directory: ${SCRIPT_DIR}"

# Navigate to nvdsinfer_custom_impl_Yolo directory
cd "${SCRIPT_DIR}/nvdsinfer_custom_impl_Yolo"

# Create build directory if it doesn't exist
if [ ! -d "build" ]; then
    echo "Creating build directory..."
    mkdir -p build
fi

# Navigate to build directory
cd build

# Run cmake
echo "Running cmake..."
cmake ..

# Build the project
echo "Building with make..."
make

# Create DEB package with cpack
echo "Creating DEB package with cpack..."
cpack -G DEB

echo "Build complete!"
echo "DEB package should be in: ${BUILD_DIR}"

