#!/bin/bash

# This script creates a udev rule to disable the internal laptop keyboard.
# It MUST be run with root privileges (e.g., "sudo ./disable_keyboard.sh").

# 1. Check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or with sudo."
    exit 1
fi

# 2. Define the rule string and file path
# This rule targets the "AT Translated Set 2 keyboard" as you identified.
RULE_STRING='ACTION=="add|change", KERNEL=="event*", ATTRS{name}=="AT Translated Set 2 keyboard", ENV{LIBINPUT_IGNORE_DEVICE}="1"'
RULE_FILE="/etc/udev/rules.d/10-disable-internal-keyboard.rules"

echo "Creating udev rule at $RULE_FILE..."

# 3. Write the rule to the file
# Using 'echo' and 'tee' to ensure we have the correct permissions
echo "$RULE_STRING" >"$RULE_FILE"

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to write rule file."
    echo "Please check permissions and try again."
    exit 1
fi

echo "Rule created successfully."

# 4. Reload udev rules to apply the change
echo "Reloading udev rules..."
udevadm control --reload-rules

# 5. Trigger the new rules to make them take effect
echo "Applying new rules..."
udevadm trigger

echo "Done. Your internal keyboard should now be disabled."
echo "A reboot may be required if it doesn't take effect immediately."

reboot
