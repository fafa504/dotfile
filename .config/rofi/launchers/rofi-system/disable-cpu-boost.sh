#!/usr/bin/env bash

RULE_FILE="/sys/devices/system/cpu/intel_pstate/no_turbo"
VALUE="1"

# Use pkexec to elevate privileges for the file write operation
pkexec sh -c "echo \"$VALUE\" > \"$RULE_FILE\""
echo "Intel CPU Turbo Boost disabled (wrote '$VALUE' to $RULE_FILE)."
exit 0
