#!/bin/bash

# This script re-enables the internal keyboard by removing the udev rule.
# It MUST be run with root privileges (e.g., "sudo ./enable_keyboard.sh").

# 1. Check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or with sudo."
    exit 1
fi

# 2. Define the rule file path
RULE_FILE="/etc/udev/rules.d/10-disable-internal-keyboard.rules"

if [ ! -f "$RULE_FILE" ]; then
    echo "Rule file not found ($RULE_FILE)."
    echo "Keyboard appears to be already enabled or was disabled by another method."
    exit 0
fi

echo "Removing udev rule at $RULE_FILE..."

# 3. Remove the rule file
rm "$RULE_FILE"

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to remove rule file."
    echo "Please check permissions and try again."
    exit 1
fi

echo "Rule file removed."

# 4. Reload udev rules to apply the change
echo "Reloading udev rules..."
udevadm control --reload-rules

# 5. Trigger the new rules
echo "Applying new rules..."
udevadm trigger

echo "Done. Your internal keyboard should be enabled again."
echo "A reboot may be required for the change to take full effect."
