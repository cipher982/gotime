#!/bin/bash

# Test different Warp URI formats to see which one works

CONFIG_FILE="$HOME/.warp/launch_configurations/gotime_4443.yaml"
CONFIG_FILENAME="gotime_4443.yaml"

echo "Testing Warp URI formats..."
echo ""

echo "1. Testing with filename only:"
echo "   warp://launch/${CONFIG_FILENAME}"
echo "   Run: open \"warp://launch/${CONFIG_FILENAME}\""
echo ""

echo "2. Testing with full path:"
echo "   warp://launch${CONFIG_FILE}"
echo "   Run: open \"warp://launch${CONFIG_FILE}\""
echo ""

echo "3. Testing with file:// prefix:"
echo "   warp://launch/file://${CONFIG_FILE}"
echo "   Run: open \"warp://launch/file://${CONFIG_FILE}\""
echo ""

echo "4. Testing without launch prefix:"
echo "   warp://${CONFIG_FILE}"
echo "   Run: open \"warp://${CONFIG_FILE}\""
echo ""

echo "Please try each command above and let me know which one works!"
echo ""
echo "You can also check if Warp supports the URI scheme with:"
echo "   open warp://new_window"
echo "   open warp://new_tab"
