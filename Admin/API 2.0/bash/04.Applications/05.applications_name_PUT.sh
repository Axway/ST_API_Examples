#!/bin/bash
# ==============================================================================
# Script Name: 05.applications_name_PUT.sh
# Author: Plamen Milenkov
# Created: 2025-08-06
# Location: Sofia
# ==============================================================================
# Description:
# This script updates an application using the `/applications/{name}` endpoint.
# It demonstrates:
# - Retrieving the full application object
# - Modifying the notes field with a timestamp
# - Sending a PUT request to update the application
#
# Usage:
# ./05.applications_name_PUT.sh
#
# Notes:
# - Ensure that `set_variables.sh` is correctly configured and sourced.
# - PUT replaces the entire object, so all required fields must be preserved.
# ==============================================================================

source "../set_variables.sh"

MAIN_URL="https://${SERVER}:${PORT}/api/v2.0/applications"
NAME="AccountFilePurge%20Application"

curl -k -u "${USER}:${PWD}" -X "GET" "${MAIN_URL}/${NAME}" -H "accept: application/json" -H "Content-Type: application/json" > tmp.json
DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
sed -i '' "s/\\\"notes\\\" *: *\\\"[^\\\"]*\\\"/\\\"notes\\\": \\\"New note $DATE\\\"/g" tmp.json
curl -k -u "${USER}:${PWD}" -X "PUT" "${MAIN_URL}/${NAME}" -H "accept: application/json" -H "Content-Type: application/json" -d @tmp.json
