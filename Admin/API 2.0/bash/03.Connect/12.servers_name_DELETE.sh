#! /bin/bash

#
# Ensure the defined variables are loaded in our context
#
source "../set_variables.sh"

#
# Here is the curl command to delete a server.
# The server name is the only parameter needed.
# 
NAME="SSH_TEST_SERVER_1"
printf "Deleting server '${NAME}'...\n"
curl -s -o /dev/null -w "%{http_code}\n" -k -u "${USER}:${PWD}" -X "DELETE" "https://${SERVER}:${PORT}/api/v2.0/servers/${NAME}" -H "accept: application/json" -H "Content-Type: application/json"
printf "Done\n"

#
# Here is an example of a DELETE request to remove a server with a bit more work in advance.
# First we will check if the server exists, then we will delete it.
#

NAME="SSH_TEST_SERVER_2"
RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}\n" -k -u "${USER}:${PWD}" --head "https://${SERVER}:${PORT}/api/v2.0/servers/${NAME}" -H "accept: */*")
if [ "${RESPONSE_CODE}" == "200" ]; then
    printf "Server exists. Deleting server '${NAME}'...\n"
    curl -s -o /dev/null -w "%{http_code}\n" -k -u "${USER}:${PWD}" -X "DELETE" "https://${SERVER}:${PORT}/api/v2.0/servers/${NAME}" -H "accept: application/json" -H "Content-Type: application/json"
    printf "\nDone\n"
else
  echo "Server does not exist."
fi