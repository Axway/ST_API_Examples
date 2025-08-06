#!/bin/bash
# ==============================================================================
# Script Name: 06.servers_GET.sh
# Author: Plamen Milenkov
# Created: 2025-08-06
# Location: Sofia
# ==============================================================================
# Description:
# This script queries the `/servers` endpoint to retrieve server information.
# It demonstrates how to:
# - Get all servers
# - Filter by specific fields
# - Filter by protocol
# - Use common filters like serverName, isActive, isFipsEnabled
# - Use protocol-specific filters like isScpEnabled
#
# Usage:
# ./06.servers_GET.sh
#
# Notes:
# - Ensure that `set_variables.sh` is correctly configured and sourced.
# - The script uses basic authentication and GET requests with query parameters.
# ==============================================================================

echo "Loading variables into our context..."
source "../set_variables.sh"

# Get all servers
curl -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/servers" -H "accept: application/json"

# Get only serverName and isActive fields
curl -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/servers?fields=id,serverName,isActive" -H "accept: application/json"

# Filter by protocol: AS2
PROTOCOL="as2"
curl -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/servers?protocol=${PROTOCOL}&fields=id,serverName,isActive" -H "accept: application/json"

# Filter by common fields
curl -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/servers?limit=1&offset=0&serverName=Ssh%20Default&isActive=true&isFipsEnabled=false" -H "accept: application/json"

# Filter by protocol-specific field
curl -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/servers?fields=isScpEnabled&protocol=ssh" -H "accept: application/json"
