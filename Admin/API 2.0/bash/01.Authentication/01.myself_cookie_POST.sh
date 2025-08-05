#!/bin/bash
# ==============================================================================
# Script Name: 01.myself_cookie_POST.sh
# Author: Plamen Milenkov
# Created: 2025-08-05
# Location: Sofia
# ==============================================================================
# Description:
# This script performs basic authentication against the API using a cookie jar
# to persist session information. It reduces the need for repeated authentication
# across multiple requests.
#
# Usage:
# ./01.myself_cookie_POST.sh
#
# Notes:
# - Ensure that `set_variables.sh` is correctly configured and sourced.
# - The cookie jar file will store session data for reuse.
# ==============================================================================

printf "Loading variables into our context..."
source "../set_variables.sh"

printf "\n\nBasic authentication with cookie jar to reduce further authentications...\n"
REFERER_HEADER="Referer: THIS_IS_A_RANDOM_TEXT"

# Authenticate and store session in cookie jar
curl -k --cookie-jar cookie.jar -u "${USER}:${PWD}" -X POST "https://${SERVER}:${PORT}/api/v2.0/myself" \
  -H "accept: application/json" -H "${REFERER_HEADER}"

# Reuse session to make a GET request
curl -k --cookie cookie.jar -X GET "https://${SERVER}:${PORT}/api/v2.0/myself" \
  -H "accept: application/json" -H "${REFERER_HEADER}"
