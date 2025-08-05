#!/bin/bash
# ==============================================================================
# Script Name: 01.myself_POST.sh
# Author: Plamen Milenkov
# Created: 2025-08-05
# Location: Sofia
# ==============================================================================
# Description:
# This script performs a basic authentication request to the API using a
# username and password. It retrieves user information from the `/myself` endpoint.
#
# Usage:
# ./01.myself_POST.sh
#
# Notes:
# - Ensure that `set_variables.sh` is correctly configured and sourced.
# - This script does not use a cookie jar, so authentication is required for each call.
# ==============================================================================
printf "Loading variables into our context..."
source "../set_variables.sh"

printf "\n\nBasic authentication...\n"

curl -s -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/myself" -H "accept: application/json"
