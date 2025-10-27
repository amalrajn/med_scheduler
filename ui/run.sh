#!/bin/bash

# Check if an argument was provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <device>"
    exit 1
fi

DEVICE=$1

flutter run -d "$DEVICE"
