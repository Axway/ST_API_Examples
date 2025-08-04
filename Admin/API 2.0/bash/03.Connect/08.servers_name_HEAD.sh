#! /bin/bash

#
# Ensure the defined variables are loaded in our context
#
source "../set_variables.sh"

#
# To check if a server exists, we can use the HEAD method.
# This method will return the headers of the response, but not the body.
# Pay attention that we do not execute -X HEAD, but --head instead. For more information, check the curl manual.
# 
NAME="SSH_TEST_SERVER_1"
curl -k -u "${USER}:${PWD}" --head "https://${SERVER}:${PORT}/api/v2.0/servers/${NAME}" -H "accept: */*"

#
# The response code will be 200 if the server exists.
# If the server does not exist, the response code will be 404.
# 
RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}\n" -k -u "${USER}:${PWD}" --head "https://${SERVER}:${PORT}/api/v2.0/servers/${NAME}" -H "accept: */*")
if [ "${RESPONSE_CODE}" == "200" ]; then
  echo "Server exists."
else
  echo "Server does not exist."
fi