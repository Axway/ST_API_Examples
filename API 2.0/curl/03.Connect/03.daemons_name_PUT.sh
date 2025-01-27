#! /bin/bash

#
# Ensure the defined variables are loaded in our context
#
source "../set_variables.sh"

NAME="ssh"

#
# First we are going to update the SSH daemon.
# We will change the 'maxConnections' to '10'.
# We will print the response code to confirm the request was successful.
#
curl -s -o /dev/null -w "%{http_code}\n" -k -u "${USER}:${PWD}" -X "PUT" "https://${SERVER}:${PORT}/api/v2.0/daemons/${NAME}" -H "accept: application/json" -H "Content-Type: application/json" \
 -d "{ \"maxConnections\": \"10\",
        \"preferBouncyCastleProvider\": false,
        \"banner\": \"This is a SecureTransport REST API test banner.\" }"


#
# Now we are going to update the SSH daemon.
# We will change the 'maxConnections' to '-10'.
# This is an invalid value, so the request should fail.
# We will check the response code to confirm this.
# 
RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}\n" -k -u "${USER}:${PWD}" -X "PUT" "https://${SERVER}:${PORT}/api/v2.0/daemons/${NAME}" -H "accept: application/json" -H "Content-Type: application/json" \
 -d "{ \"maxConnections\": \"-10\",
        \"preferBouncyCastleProvider\": false,
        \"banner\": \"This is a SecureTransport REST API test banner.\" }")

if [ "${RESPONSE_CODE}" -eq 200 ]; then
    echo "The daemon was successfully updated."
else
    echo "The daemon was not updated. Please check the response code: ${RESPONSE_CODE}"
fi