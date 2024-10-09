#!/bin/sh
set -e

# Regular expression for identifying Vbuddy in usbipd device info
VBUDDY_REGEX="[0-9]-[0-9] .* USB-SERIAL CH340"

# Get USB device info using Windows usbipd
USB_INFO=$(powershell.exe /c usbipd list)

if ! echo "$USB_INFO" | grep -q "$VBUDDY_REGEX"; then
    echo "ERROR: Could not find Vbuddy. Is it plugged in?"
    exit 1
elif echo "$USB_INFO" | grep -q "$VBUDDY_REGEX .* Attached"; then
    echo "Vbuddy already attached to WSL"
    exit 0
fi

# Find the correct busid from the usbipd device info
BUS_ID=$(echo "$USB_INFO" | grep "$VBUDDY_REGEX" | awk '{print $1}')

# Share USB device with WSL if not already shared
if echo "$USB_INFO" | grep -q "$VBUDDY_REGEX .* Not shared"; then
    echo "Sharing Vbuddy USB port with WSL. This may require administrator access."
    powershell.exe /c "Start-Process 'usbipd.exe' -Verb runAs -ArgumentList 'bind --busid $BUS_ID'"
fi

# Attach USB device to WSL
powershell.exe /c usbipd attach --wsl --busid $BUS_ID

if powershell.exe /c usbipd list | grep -q "$VBUDDY_REGEX .* Attached"; then
    echo "Vbuddy successfully attached to WSL"
    exit 0
else
    echo "ERROR: Unknown error attaching Vbuddy to WSL"
    exit 1
fi
