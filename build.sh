#!/bin/bash

# Exit on error
set -e

# Print commands as they are executed
set -x

# Check if we're in a conda environment
if [ -z "$CONDA_PREFIX" ]; then
    echo "Error: Not in a conda environment. Please activate your conda environment first."
    exit 1
fi

# Create build directory
mkdir -p build
cd build

# Configure with CMake
cmake \
    -DCMAKE_INSTALL_PREFIX=$CONDA_PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DARGPARSE_BUILD_SAMPLES=ON \
    -DARGPARSE_BUILD_TESTS=ON \
    ..

# Build with multiple cores if available
if command -v nproc &> /dev/null; then
    make -j$(nproc)
else
    make -j$(sysctl -n hw.ncpu)
fi

# Run tests
if [ -f "./test/tests" ]; then
    ./test/tests
else
    echo "Warning: Test executable not found. Skipping tests."
fi

# Install the library
make install