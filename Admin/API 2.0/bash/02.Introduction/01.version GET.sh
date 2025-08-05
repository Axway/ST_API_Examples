#!/bin/bash
# ==============================================================================
# Script Name: 01.version_GET.sh
# Author: Plamen Milenkov
# Created: 2025-08-05
# Location: Sofia
# ==============================================================================
# Description:
# This script performs a basic authentication request to retrieve the current
# product version from the API. It uses username and password credentials and
# sends a GET request to the `/version` endpoint.
#
# Usage:
# ./01.version_GET.sh
#
# Notes:
# - Ensure that `set_variables.sh` is correctly configured and sourced.
# - This script uses basic authentication and will be updated to token-based
#   authentication in future iterations.
# ==============================================================================
# Load environment variables
source "../set_variables.sh"

# Perform GET request to retrieve product version
curl -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/version" \
  -H "accept: application/json"

# End of script