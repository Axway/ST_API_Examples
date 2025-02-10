#! /bin/bash

#
# Ensure the defined variables are loaded in our context
#
source "../set_variables.sh"

MAIN_URL="https://${SERVER}:${PORT}/api/v2.0/applications"
NAME="AccountFilePurge%20Application"

printf "Patching the application '%s' to change the notes...\n" "${NAME}"
curl -s -o /dev/null -w "%{http_code}\n" -k -u "${USER}:${PWD}" -X "PATCH" "${MAIN_URL}/${NAME}" -H "accept: application/json" -H "Content-Type: application/json" \
 -d "[{
        \"op\": \"replace\",
        \"path\": \"/notes\",
        \"value\": \"Patched note\" }
    ]"

printf "Patching the application '%s' to change the startDate...\n" "${NAME}"
curl -s -o /dev/null -w "%{http_code}\n" -k -u "${USER}:${PWD}" -X "PATCH" "${MAIN_URL}/${NAME}" -H "accept: application/json" -H "Content-Type: application/json" \
 -d "[{
        \"op\": \"replace\",
        \"path\": \"/schedules/0/startDate\",
        \"value\": \"2025-02-21T02:30:00Z\" }
    ]"