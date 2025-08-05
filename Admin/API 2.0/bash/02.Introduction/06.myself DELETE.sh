#!/bin/bash
# ==============================================================================
# Script Name: 06.myself_DELETE.sh
# Author: Plamen Milenkov
# Created: 2025-08-05
# Location: Sofia
# ==============================================================================
# Description:
# This script demonstrates how to log in using basic authentication and a cookie jar,
# then log out by sending a DELETE request to the `/myself` endpoint.
# It also verifies session status before and after logout.
#
# Usage:
# ./06.myself_DELETE.sh
#
# Notes:
# - Ensure that `set_variables.sh` is correctly configured and sourced.
# - The cookie jar is used to persist session state across requests.
# ==============================================================================

echo "Loading variables into our context..."
source "../set_variables.sh"

REFERER_HEADER="Referer: THIS_IS_A_RANDOM_TEXT"

# Authenticate and store session
curl -k --cookie-jar cookie.jar -u "${USER}:${PWD}" -X POST "https://${SERVER}:${PORT}/api/v2.0/myself" -H "accept: application/json" -H "${REFERER_HEADER}"

# Verify session is active
curl -k --cookie cookie.jar -X GET "https://${SERVER}:${PORT}/api/v2.0/myself" -H "accept: application/json" -H "${REFERER_HEADER}"

# Log out
curl -k -L --cookie cookie.jar -X DELETE "https://${SERVER}:${PORT}/api/v2.0/myself" -H "accept: application/json" -H "${REFERER_HEADER}"

# Verify session is terminated
curl -k --cookie cookie.jar -X GET "https://${SERVER}:${PORT}/api/v2.0/myself" -H "accept: application/json" -H "${REFERER_HEADER}"
