#! /bin/bash

#
# Ensure the defined variables are loaded in our context
#
source "../set_variables.sh"

#
# The generic request to search for a server based on the name.
# The response will be the full body of the server, if found, otherwise an error message will be thrown.
# 
SERVER_NAME="SSH_TEST_SERVER_1"
printf "\nGetting ${SERVER_NAME}...\n"
curl -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/servers/${SERVER_NAME}" -H "accept: application/json"

# 
# As the resource is primarily created to get a single server based on its name,
# the only available parameters are 'fields' and 'protocol'.
# If you want to filter by using the fields parameter, you must set also the protocol.
#
printf "\nGetting ${SERVER_NAME} with applied fields...\n"
curl -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/servers/${SERVER_NAME}?fields=isActive,port&protocol=ssh" -H "accept: application/json"