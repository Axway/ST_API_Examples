#!/bin/bash
# ==============================================================================
# Script Name: 06.applications_name_PATCH.sh
# Author: Plamen Milenkov
# Created: 2025-08-06
# Location: Sofia
# ==============================================================================
# Description:
# This script performs partial updates to an application using the
# `/applications/{name}` endpoint with the PATCH method.
# It demonstrates:
# - Updating the notes field
# - Updating the startDate of the first schedule
#
# Usage:
# ./06.applications_name_PATCH.sh
#
# Notes:
# - Ensure that `set_variables.sh` is correctly configured and sourced.
# - PATCH allows partial updates without replacing the entire object.
# ==============================================================================

source "../set_variables.sh"

MAIN_URL="https://${SERVER}:${PORT}/api/v2.0/applications"
NAME="AccountFilePurge%20Application"

printf "Patching the application '%s' to change the notes...\n" "${NAME}"
curl -s -o /dev/null -w "%{http_code}\n" -k -u "${USER}:${PWD}" -X "PATCH" "${MAIN_URL}/${NAME}" \
-H "accept: application/json" -H "Content-Type: application/json" \
-d "[{
        \"op\": \"replace\",
        \"path\": \"/notes\",
        \"value\": \"Patched note\" }]"

printf "Patching the application '%s' to change the startDate...\n" "${NAME}"
curl -s -o /dev/null -w "%{http_code}\n" -k -u "${USER}:${PWD}" -X "PATCH" "${MAIN_URL}/${NAME}" \
-H "accept: application/json" -H "Content-Type: application/json" \
-d "[{
        \"op\": \"replace\",
        \"path\": \"/schedules/0/startDate\",
        \"value\": \"2025-02-21T02:30:00Z\" }]"

#
# Here is an example of adding a new Business Unit to a given application, 
# when there are already other Business Units assigned
#
# printf "Patching the application '%s' to add a new Business Unit...\n" "${NAME}"
# curl -s -o /dev/null -w "%{http_code}\n" -k -u "${USER}:${PWD}" -X "PATCH" "${MAIN_URL}/${NAME}" \
# -H "accept: application/json" -H "Content-Type: application/json" \
# -d "[{
#         \"op\": \"add\",
#         \"path\": \"/businessUnits/-\",
#         \"value\": \"HumanResources\" }]"