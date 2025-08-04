#! /bin/bash

#
# Ensure the defined variables are loaded in our context
#
source "../set_variables.sh"

NAME="HumanSystem Application"
printf "Deleting application '%s'...\n" "${NAME}"
NAME=$(echo "${NAME}" | sed 's/ /%20/g')
curl -k -u "${USER}:${PWD}" -X "DELETE" "https://${SERVER}:${PORT}/api/v2.0/applications/${NAME}" -H "accept: application/json" -H "Content-Type: application/json"
printf "Done\n"


NAME="AccountFilePurge Application"
printf "Deleting application '%s'...\n" "${NAME}"
NAME=$(echo "${NAME}" | sed 's/ /%20/g')
curl -k -u "${USER}:${PWD}" -X "DELETE" "https://${SERVER}:${PORT}/api/v2.0/applications/${NAME}" -H "accept: application/json" -H "Content-Type: application/json"
printf "Done\n"