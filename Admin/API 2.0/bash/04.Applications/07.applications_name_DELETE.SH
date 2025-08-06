#!/bin/bash
# ==============================================================================
# Script Name: 07.applications_name_DELETE.sh
# Author: Plamen Milenkov
# Created: 2025-08-06
# Location: Sofia
# ==============================================================================
# Description:
# This script deletes applications using the `/applications/{name}` endpoint.
# It demonstrates:
# - A direct DELETE request for a known application
# - A conditional DELETE request after verifying existence
#
# Usage:
# ./07.applications_name_DELETE.sh
#
# Notes:
# - Ensure that `set_variables.sh` is correctly configured and sourced.
# - Application names with spaces must be URL-encoded.
# ==============================================================================

source "../set_variables.sh"

NAME="Audit Log Maintenance"
printf "Deleting application '%s'...\n" "${NAME}"
NAME=$(echo "${NAME}" | sed 's/ /%20/g')
curl -s -o /dev/null -w "%{http_code}\n" -k -u "${USER}:${PWD}" -X "DELETE" "https://${SERVER}:${PORT}/api/v2.0/applications/${NAME}" \
-H "accept: application/json" -H "Content-Type: application/json"

NAME="Transfer Log Maintenance"
NAME=$(echo "${NAME}" | sed 's/ /%20/g')
RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}\n" -k -u "${USER}:${PWD}" --head "https://${SERVER}:${PORT}/api/v2.0/applications/${NAME}" \
-H "accept: */*")
if [ "${RESPONSE_CODE}" == "200" ]; then
    printf "Application exists. Deleting application '%s'...\n" "${NAME}"
    curl -s -o /dev/null -w "%{http_code}\n" -k -u "${USER}:${PWD}" -X "DELETE" "https://${SERVER}:${PORT}/api/v2.0/applications/${NAME}" \
    -H "accept: application/json" -H "Content-Type: application/json"
    printf "\nDone\n"
else
  echo "Application does not exist."
fi
