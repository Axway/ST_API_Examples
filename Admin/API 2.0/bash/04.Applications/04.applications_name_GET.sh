#!/bin/bash
# ==============================================================================
# Script Name: 04.applications_name_GET.sh
# Author: Plamen Milenkov
# Created: 2025-08-06
# Location: Sofia
# ==============================================================================
# Description:
# This script retrieves information about a specific application using the
# `/applications/{name}` endpoint. It also checks whether business units are
# assigned to the application.
#
# Usage:
# ./04.applications_name_GET.sh
#
# Notes:
# - Ensure that `set_variables.sh` is correctly configured and sourced.
# - Application names with spaces must be URL-encoded.
# ==============================================================================

source "../set_variables.sh"

MAIN_URL="https://${SERVER}:${PORT}/api/v2.0/applications"
NAME="AccountFilePurge%20Application"

curl -k -u "${USER}:${PWD}" -X "GET" "${MAIN_URL}/${NAME}" -H "accept: application/json"

RESPONSE=$(curl -k -u "${USER}:${PWD}" -X "GET" "${MAIN_URL}/${NAME}" -H "accept: application/json" | jq ."businessUnits")
NUMBER_OF_ASSIGNED_BU=$(echo "${RESPONSE}" | jq '. | length')

if [ "${NUMBER_OF_ASSIGNED_BU}" -eq 0 ]; then
    echo "No business units assigned to the application."
else
    echo "Business units assigned to the application: ${RESPONSE}"
fi
