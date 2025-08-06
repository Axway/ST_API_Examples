#!/bin/bash
# ==============================================================================
# Script Name: 10.servers_name_PUT.sh
# Author: Plamen Milenkov
# Created: 2025-08-06
# Location: Sofia
# ==============================================================================
# Description:
# This script updates an SSH server configuration using the PUT method via curl.
# It demonstrates:
# - A direct update with a new port
# - A full update using retrieved server data with modified fields
#
# Usage:
# ./update_ssh_server.sh
#
# Notes:
# - Ensure that `set_variables.sh` is correctly configured and sourced.
# - The PUT method replaces the entire object, so all required fields must be included.
# ==============================================================================

source "../set_variables.sh"

NAME="SSH_TEST_SERVER_1"
NEW_PORT=$((8022 + RANDOM % 10))

# Direct PUT update
curl -k -u "${USER}:${PWD}" -X "PUT" "https://${SERVER}:${PORT}/api/v2.0/servers/${NAME}" \
-H "accept: application/json" -H "Content-Type: application/json" \
-d "{ \"serverName\": \"${NAME}\", \"protocol\": \"ssh\", \"port\": ${NEW_PORT} }"

# Retrieve and modify server configuration
NEW_PORT=$((8022 + RANDOM % 10))
curl -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/servers/${NAME}" \
-H "accept: application/json" -H "Content-Type: application/json" > tmp.json

sed -i '' "s/\"port\": [0-9]*/\"port\": ${NEW_PORT}/g" tmp.json
sed -i '' "s/\"clientPasswordAuth\" : .*/\"clientPasswordAuth\": \"default\",/g" tmp.json

curl -k -u "${USER}:${PWD}" -X "PUT" "https://${SERVER}:${PORT}/api/v2.0/servers/${NAME}" \
-H "accept: application/json" -H "Content-Type: application/json" -d @tmp.json
