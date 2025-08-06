#!/bin/bash
# ==============================================================================
# Script Name: 11.servers_name_PATCH.sh
# Author: Plamen Milenkov
# Created: 2025-08-06
# Location: Sofia
# ==============================================================================
# Description:
# This script demonstrates how to PATCH an SSH server configuration using curl.
# It performs:
# - A PATCH to update the port
# - A PATCH to remove RSA keys from the publicKeys field
#
# Usage:
# ./patch_ssh_server.sh
#
# Notes:
# - Ensure that `set_variables.sh` is correctly configured and sourced.
# - The PATCH method allows partial updates to specific fields.
# ==============================================================================

source "../set_variables.sh"

NAME="SSH_TEST_SERVER_1"

printf "Patching the server port...\n"
curl -s -o /dev/null -w "%{http_code}\n" -k -u "${USER}:${PWD}" -X "PATCH" "https://${SERVER}:${PORT}/api/v2.0/servers/${NAME}" \
-H "accept: application/json" -H "Content-Type: application/json" \
-d "[{ \"op\": \"replace\", \"path\": \"/port\", \"value\": 8026 }]"

printf "Patching the server publicKeys...\n"
OLD_PUBLIC_KEYS=$(curl -s -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/servers/${NAME}" \
-H "accept: application/json" -H "Content-Type: application/json" | \
grep "publicKeys" | awk -F ':' '{print $2}' | sed 's/",/"/g' | sed 's/"//g')
echo "Public keys before removing rsa: ${OLD_PUBLIC_KEYS}"

NEW_PUBLIC_KEYS=$(echo "${OLD_PUBLIC_KEYS}" | sed 's/[a-zA-Z0-9-]*rsa[a-zA-Z0-9-]*//g' | sed 's/,,//g')
echo "Public keys after removal: ${NEW_PUBLIC_KEYS}"

curl -k -u "${USER}:${PWD}" -X "PATCH" "https://${SERVER}:${PORT}/api/v2.0/servers/${NAME}" \
-H "accept: application/json" -H "Content-Type: application/json" \
-d "[{ \"op\": \"replace\", \"path\": \"/publicKeys\", \"value\": \"${NEW_PUBLIC_KEYS}\" }]"

printf "\nDone\n"
printf "Retrieve the server information to check the changes...\n"
curl -s -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/servers/${NAME}" \
-H "accept: application/json" -H "Content-Type: application/json"
