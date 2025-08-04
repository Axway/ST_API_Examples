#! /bin/bash

#
# Ensure the defined variables are loaded in our context
#
source "../set_variables.sh"

#
# The minimum amount of parameters to create a server is the serverName and its protocol type.
# The serverName must be unique.
# The protocol must be one of the following: ftp, ssh, http, as2, or pesit.
# 
NAME="SSH_TEST_SERVER_1"
curl -k -u "${USER}:${PWD}" -X "POST" "https://${SERVER}:${PORT}/api/v2.0/servers" -H "accept: application/json" -H "Content-Type: application/json" \
-d "{ \"serverName\": \"${NAME}\", \"protocol\": \"ssh\"}"


#
# Here is a real life example, where you want to duplicate a server.
# You can use the GET method to retrieve the server's information, and then use it to create a new server.
#
NEW_NAME="SSH_TEST_SERVER_2"
NEW_PORT=$((8022 + RANDOM % 10))

printf "Creating a new server with the name: %s and port: %d...\n" "${NEW_NAME}" "${NEW_PORT}"

curl -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/servers/${NAME}" -H "accept: application/json" -H "Content-Type: application/json" > tmp.json
sed -i '' "s/${NAME}/${NEW_NAME}/g" tmp.json
sed -i '' "s/\"port\": [0-9]*/\"port\": ${NEW_PORT}/g" tmp.json
sed -i '' "s/\"clientPasswordAuth\" : .*/\"clientPasswordAuth\": \"default\",/g" tmp.json

curl -k -u "${USER}:${PWD}" -X "POST" "https://${SERVER}:${PORT}/api/v2.0/servers" -H "accept: application/json" -H "Content-Type: application/json" -d @tmp.json