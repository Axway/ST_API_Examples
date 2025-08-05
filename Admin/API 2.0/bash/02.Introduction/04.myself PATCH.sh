#!/bin/bash
# ==============================================================================
# Script Name: 04.myself_PATCH.sh
# Author: Plamen Milenkov
# Created: 2025-08-05
# Location: Sofia
# ==============================================================================
# Description:
# This script sends a PATCH request to the `/myself` endpoint to update the
# current user's password. It uses basic authentication and a JSON payload
# containing the new password.
#
# Usage:
# ./04.myself_PATCH.sh
#
# Notes:
# - Ensure that `set_variables.sh` is correctly configured and sourced.
# - Be cautious when executing this script, as it will change your password.
# - Replace "TYPE_WHATEVER_YOU_WANT_HERE" with the desired new password.
# ==============================================================================

echo "Loading variables into our context..."
source "../set_variables.sh"

# Send PATCH request to update password
curl -s -k -u "${USER}:${PWD}" -X "PATCH" "https://${SERVER}:${PORT}/api/v2.0/myself" \
  -H "accept: */*" -H "Content-Type: application/json" -d '[{
    "op": "replace",
    "path": "/passwordCredentials/password",
    "value": "TYPE_WHATEVER_YOU_WANT_HERE"
  }]'
