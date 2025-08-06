#!/bin/bash
# ==============================================================================
# Script Name: 02.daemons_name_GET.sh
# Author: Plamen Milenkov
# Created: 2025-08-06
# Location: Sofia
# ==============================================================================
# Description:
# This script queries the SSH daemon from the `/daemons/{name}` endpoint,
# extracts the banner from the response, checks if it's defined, and simulates
# a fake banner check.
#
# Usage:
# ./02.daemons_name_GET.sh
#
# Notes:
# - Ensure that `set_variables.sh` is correctly configured and sourced.
# - The script uses basic authentication and filters JSON output using grep and cut.
# ==============================================================================

echo "Loading variables into our context..."
source "../set_variables.sh"

NAME="ssh"

# Query the SSH daemon
curl -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/daemons/${NAME}" -H "accept: application/json"

# Extract banner from response
RESPONSE=$(curl -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/daemons/${NAME}" -H "accept: application/json")
BANNER=$(echo "${RESPONSE}" | grep "banner" | cut -d '"' -f 4)

# Check if banner is defined
if [ -z "${BANNER}" ]; then
    echo "There is no banner defined."
else
    echo "There is a banner defined: '${BANNER}'."
fi
# Simulate a fake banner
echo "Setting the banner..."
FAKE_JSON='"banner": "This is a SecureTransport REST API test banner."'
BANNER=$(echo "${FAKE_JSON}" | grep "banner" | cut -d '"' -f 4)

# Check if fake banner is defined
if [ -z "${BANNER}" ]; then
    echo "There is no banner defined."
else
    echo "There is a banner defined: '${BANNER}'."
fi
