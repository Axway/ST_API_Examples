#!/bin/bash
# ==============================================================================
# Script Name: 08.servers_name_HEAD.sh
# Author: Plamen Milenkov
# Created: 2025-08-06
# Location: Sofia
# ==============================================================================
# Description:
# This script checks whether a specific server exists using the HTTP HEAD method.
# It uses curl's `--head` option to retrieve only the response headers.
# A 200 response code indicates the server exists; 404 means it does not.
#
# Usage:
# ./08.servers_name_HEAD.sh
#
# Notes:
# - Ensure that `set_variables.sh` is correctly configured and sourced.
# - HEAD requests are efficient for existence checks without retrieving full content.
# ==============================================================================

echo "Loading variables into our context..."
source "../set_variables.sh"

NAME="SSH_TEST_SERVER_1"

# Perform HEAD request
curl -k -u "${USER}:${PWD}" --head "https://${SERVER}:${PORT}/api/v2.0/servers/${NAME}" -H "accept: */*"

# Check response code
RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}\n" -k -u "${USER}:${PWD}" --head "https://${SERVER}:${PORT}/api/v2.0/servers/${NAME}" -H "accept: */*")
if [ "${RESPONSE_CODE}" == "200" ]; then
  echo "Server exists."
else
  echo "Server does not exist."
fi
