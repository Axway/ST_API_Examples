#! /bin/bash

#
# Ensure the defined variables are loaded in our context
#
source "../set_variables.sh"

NAME="http"
OPERATION="stop"
GRACEFUL="false"

# 
# Perform the operation on the daemon
# 
printf "Performing '${OPERATION}' on the '${NAME}' daemon...\n"
curl -s -o /dev/null -w "%{http_code}\n" -k -u "${USER}:${PWD}" -X "POST" \
 "https://${SERVER}:${PORT}/api/v2.0/daemons/operations?operation=${OPERATION}&daemon=${NAME}&graceful=${GRACEFUL}" \
 -H "accept: application/json" -H "Content-Type: application/json"

NAME="ssh"
OPERATION="stop"
GRACEFUL="true"
TIMEOUT="600" # 10 minutes

printf "Gracefully shutting down '${NAME}' with timeout '${TIMEOUT}'...\n"
curl -s -o /dev/null -w "%{http_code}\n" -k -u "${USER}:${PWD}" -X "POST" \
 "https://${SERVER}:${PORT}/api/v2.0/daemons/operations?operation=${OPERATION}&daemon=${NAME}&graceful=${GRACEFUL}" \
 -H "accept: application/json" -H "Content-Type: application/json"
