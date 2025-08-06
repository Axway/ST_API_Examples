#!/bin/bash
# ==============================================================================
# Script Name: 03.applications_name_HEAD.sh
# Author: Plamen Milenkov
# Created: 2025-08-06
# Location: Sofia
# ==============================================================================
# Description:
# This script checks if specific applications exist using the `/applications/{name}` endpoint.
# It demonstrates:
# - A HEAD request to verify existence of an application by name
# - Conditional logic based on HTTP response code
#
# Usage:
# ./03.applications_name_HEAD.sh
#
# Notes:
# - Ensure that `set_variables.sh` is correctly configured and sourced.
# - Application names with spaces must be URL-encoded.
# ==============================================================================

source "../set_variables.sh"

NAME="Audit Log Maintenance"
NAME=$(echo "${NAME}" | sed 's/ /%20/g')
printf "Check if application with the name '%s' exists...\n" "${NAME}"
curl -k -u "${USER}:${PWD}" --head "https://${SERVER}:${PORT}/api/v2.0/applications/${NAME}" -H "accept: */*"

NAME="Transfer Log Maintenance"
NAME=$(echo "${NAME}" | sed 's/ /%20/g')
printf "\nCheck if application with the name '%s' exists...\n" "${NAME}"
RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}\n" -k -u "${USER}:${PWD}" --head "https://${SERVER}:${PORT}/api/v2.0/applications/${NAME}" -H "accept: */*")
if [ "${RESPONSE_CODE}" == "200" ]; then
  echo "Application exists."
else
  echo "Application does not exist."
fi
