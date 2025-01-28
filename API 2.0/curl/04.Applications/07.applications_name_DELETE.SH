#! /bin/bash

#
# Ensure the defined variables are loaded in our context
#
source "../set_variables.sh"

#
# Here is the curl command to delete a server.
# The server name is the only parameter needed.
# 
NAME="Audit Log Maintenance"
printf "Deleting server '%s'...\n" "${NAME}"
NAME=$(echo "${NAME}" | sed 's/ /%20/g')
curl -s -o /dev/null -w "%{http_code}\n" -k -u "${USER}:${PWD}" -X "DELETE" "https://${SERVER}:${PORT}/api/v2.0/applications/${NAME}" -H "accept: application/json" -H "Content-Type: application/json"

#
# Here is an example of a DELETE request to remove a server with a bit more work in advance.
# First we will check if the server exists, then we will delete it.
#
NAME="Transfer Log Maintenance"
NAME=$(echo "${NAME}" | sed 's/ /%20/g')
RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}\n" -k -u "${USER}:${PWD}" --head "https://${SERVER}:${PORT}/api/v2.0/applications/${NAME}" -H "accept: */*")
if [ "${RESPONSE_CODE}" == "200" ]; then
    printf "Application exists. Deleting application '%s'...\n" "${NAME}"
    curl -s -o /dev/null -w "%{http_code}\n" -k -u "${USER}:${PWD}" -X "DELETE" "https://${SERVER}:${PORT}/api/v2.0/applications/${NAME}" -H "accept: application/json" -H "Content-Type: application/json"
    printf "\nDone\n"
else
  echo "Application does not exist."
fi