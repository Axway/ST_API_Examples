#! /bin/bash

#
# Ensure the defined variables are loaded in our context
#
source "../set_variables.sh"

MAIN_URL="https://${SERVER}:${PORT}/api/v2.0/applications"
NAME="AccountFilePurge%20Application"

curl -k -u "${USER}:${PWD}" -X "GET" "${MAIN_URL}/${NAME}" -H "accept: application/json"

RESPONSE=$(curl -k -u "${USER}:${PWD}" -X "GET" "${MAIN_URL}/${NAME}" -H "accept: application/json" | jq ."businessUnits")
NUMBER_OF_ASSIGNED_BU=$(echo "${RESPONSE}" | jq '. | length')

if [ "${NUMBER_OF_ASSIGNED_BU}" -eq 0 ]; then
    echo "No business units assigned to the application."
else
    echo "Business units assigned to the application: ${RESPONSE}"
fi