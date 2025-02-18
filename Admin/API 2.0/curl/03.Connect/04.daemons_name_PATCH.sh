#! /bin/bash

#
# Ensure the defined variables are loaded in our context
#
source "../set_variables.sh"

NAME="ssh"

printf "Patching the daemon maxConnections...\n"
curl -s -o /dev/null -w "%{http_code}\n" -k -u "${USER}:${PWD}" -X "PATCH" "https://${SERVER}:${PORT}/api/v2.0/daemons/${NAME}" -H "accept: application/json" -H "Content-Type: application/json" \
 -d "[{
        \"op\": \"replace\",
        \"path\": \"/maxConnections\",
        \"value\": 4 }
    ]"

printf "Patching the daemon preferBouncyCastleProvider...\n"
curl -s -o /dev/null -w "%{http_code}\n" -k -u "${USER}:${PWD}" -X "PATCH" "https://${SERVER}:${PORT}/api/v2.0/daemons/${NAME}" -H "accept: application/json" -H "Content-Type: application/json" \
 -d "[{
        \"op\": \"replace\",
        \"path\": \"/preferBouncyCastleProvider\",
        \"value\": true }
    ]"

printf "Patching the daemon banner...\n"
curl -s -o /dev/null -w "%{http_code}\n" -k -u "${USER}:${PWD}" -X "PATCH" "https://${SERVER}:${PORT}/api/v2.0/daemons/${NAME}" -H "accept: application/json" -H "Content-Type: application/json" \
 -d "[{
        \"op\": \"replace\",
        \"path\": \"/banner\",
        \"value\": \"New banner\" }
    ]"