#!/bin/bash
# ==============================================================================
# Script Name: 01.daemons_GET.sh
# Author: Plamen Milenkov
# Created: 2025-08-06
# Location: Sofia
# ==============================================================================
# Description:
# This script queries the `/daemons` endpoint to retrieve system daemon statuses.
# It demonstrates how to extract specific fields from the response, such as
# `sshStatus`, using both full and filtered API calls.
#
# Usage:
# ./01.daemons_GET.sh
#
# Notes:
# - Ensure that `set_variables.sh` is correctly configured and sourced.
# - The script uses basic authentication and filters JSON output using grep.
# ==============================================================================

echo "Loading variables into our context..."
source "../set_variables.sh"

# Full response
curl -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/daemons" -H "accept: application/json"

# Store full response in a variable
RESPONSE=$(curl -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/daemons" -H "accept: application/json")

# Extract sshStatus
echo "${RESPONSE}" | grep "sshStatus"

# Filtered response using 'fields' parameter
RESPONSE=$(curl -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/daemons?fields=sshStatus" -H "accept: application/json")
echo "${RESPONSE}"
