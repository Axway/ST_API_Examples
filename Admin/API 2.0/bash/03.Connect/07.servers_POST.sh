#!/bin/bash
# ==============================================================================
# Script Name: 07.servers_POST.sh
# Author: Plamen Milenkov
# Created: 2025-08-06
# Location: Sofia
# ==============================================================================
# Description:
# This script creates new server entries using the `/servers` endpoint.
# It demonstrates:
# - Creating a minimal server with name and protocol
# - Duplicating an existing server by modifying its configuration
#
# Usage:
# ./07.servers_POST.sh
#
# Notes:
# - Ensure that `set_variables.sh` is correctly configured and sourced.
# - The serverName must be unique.
# - Supported protocols: ftp, ssh, http, as2, pesit.
# ==============================================================================

echo "Loading variables into our context..."
source "../set_variables.sh"

# Create a minimal SSH server
NAME="SSH_TEST_SERVER_1"
curl -k -u "${USER}:${PWD}" -X "POST" "https://${SERVER}:${PORT}/api/v2.0/servers" \
  -H "accept: application/json" -H "Content-Type: application/json" \
  -d "{ \"serverName\": \"${NAME}\", \"protocol\": \"ssh\" }"

# Duplicate an existing server with modifications
NEW_NAME="SSH_TEST_SERVER_2"
NEW_PORT=$((8022 + RANDOM % 10))

printf "Creating a new server with the name: %s and port: %d...\n" "${NEW_NAME}" "${NEW_PORT}"

# Retrieve existing server config
curl -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/servers/${NAME}" \
  -H "accept: application/json" -H "Content-Type: application/json" > tmp.json

# Modify serverName and port
sed -i '' "s/${NAME}/${NEW_NAME}/g" tmp.json
sed -i '' "s/\"port\": [0-9]*/\"port\": ${NEW_PORT}/g" tmp.json
sed -i '' "s/\"clientPasswordAuth\" : .*/\"clientPasswordAuth\": \"default\",/g" tmp.json

# Create new server with modified config
curl -k -u "${USER}:${PWD}" -X "POST" "https://${SERVER}:${PORT}/api/v2.0/servers" \
  -H "accept: application/json" -H "Content-Type: application/json" -d @tmp.json
