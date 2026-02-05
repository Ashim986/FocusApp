#!/bin/bash

# SwiftLint Build Phase Script for FocusApp
# Add this as a "Run Script" build phase in Xcode

# Exit on error in CI environments
if [ "$CI" = "true" ]; then
    set -e
fi

# Find SwiftLint
if command -v swiftlint &> /dev/null; then
    SWIFTLINT_PATH="swiftlint"
elif [ -f "/opt/homebrew/bin/swiftlint" ]; then
    SWIFTLINT_PATH="/opt/homebrew/bin/swiftlint"
elif [ -f "/usr/local/bin/swiftlint" ]; then
    SWIFTLINT_PATH="/usr/local/bin/swiftlint"
elif [ -f "${PODS_ROOT}/SwiftLint/swiftlint" ]; then
    SWIFTLINT_PATH="${PODS_ROOT}/SwiftLint/swiftlint"
elif [ -f "${BUILD_DIR%Build/*}SourcePackages/checkouts/SwiftLint/swiftlint" ]; then
    SWIFTLINT_PATH="${BUILD_DIR%Build/*}SourcePackages/checkouts/SwiftLint/swiftlint"
else
    echo "warning: SwiftLint not found. Install with: brew install swiftlint"
    exit 0
fi

# Run SwiftLint
cd "${SRCROOT}"

# Keep SwiftLint caches and temp files inside the workspace to avoid permission issues.
SWIFTLINT_HOME="${SRCROOT}/.swiftlint-home"
SWIFTLINT_CACHE_DIR="${SWIFTLINT_HOME}/Library/Caches"
SWIFTLINT_TMPDIR="${SRCROOT}/.swiftlint-tmp"
mkdir -p "$SWIFTLINT_CACHE_DIR" "$SWIFTLINT_TMPDIR"
export HOME="$SWIFTLINT_HOME"
export XDG_CACHE_HOME="$SWIFTLINT_CACHE_DIR"
export TMPDIR="$SWIFTLINT_TMPDIR"

# Use --fix in debug builds for auto-correction (optional)
if [ "$CONFIGURATION" = "Debug" ] && [ "$SWIFTLINT_AUTOFIX" = "1" ]; then
    echo "Running SwiftLint with auto-fix..."
    "$SWIFTLINT_PATH" --fix --config .swiftlint.yml --cache-path "$SWIFTLINT_CACHE_DIR"
fi

# Always run lint check
echo "Running SwiftLint..."
"$SWIFTLINT_PATH" lint --config .swiftlint.yml --cache-path "$SWIFTLINT_CACHE_DIR"

OUTPUT_FILE="${DERIVED_FILE_DIR}/swiftlint.stamp"
touch "$OUTPUT_FILE"

exit $?
