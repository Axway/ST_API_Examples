#! /bin/bash

#
# Ensure the defined variables are loaded in our context
#
source "../set_variables.sh"


#
# Here is the curl command to update an SSH server.
# It is the same we used to create it.
#

NAME="SSH_TEST_SERVER_1"
NEW_PORT=$((8022 + RANDOM % 10))
curl -k -u "${USER}:${PWD}" -X "PUT" "https://${SERVER}:${PORT}/api/v2.0/servers/${NAME}" -H "accept: application/json" -H "Content-Type: application/json" \
-d "{ \"serverName\": \"${NAME}\", \"protocol\": \"ssh\",\"port\": ${NEW_PORT}}"

#
# Because the PUT method makes a full replace of the object, 
# if we miss a mandatory field, we will be reminded about it.
# Antyhing that is not specified in the body will be substituted by the default value.
# 

#
# Here is a real life example, where you want to change the port and the Client Password Authentication at the same time.
# You can use the GET method to retrieve the server's information, and then use it to update the server.
#

NEW_PORT=$((8022 + RANDOM % 10))
curl -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/servers/${NAME}" -H "accept: application/json" -H "Content-Type: application/json" > tmp.json

sed -i '' "s/\"port\": [0-9]*/\"port\": ${NEW_PORT}/g" tmp.json
sed -i '' "s/\"clientPasswordAuth\" : .*/\"clientPasswordAuth\": \"default\",/g" tmp.json

curl -k -u "${USER}:${PWD}" -X "PUT" "https://${SERVER}:${PORT}/api/v2.0/servers/${NAME}" -H "accept: application/json" -H "Content-Type: application/json" -d @tmp.json

