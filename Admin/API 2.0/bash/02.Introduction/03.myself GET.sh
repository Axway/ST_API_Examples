#! /bin/bash

echo "Loading variables into our context..."
source "../set_variables.sh"

#
# Query the API to get information about the current user.
#
printf "\n\nQuerying the API to get information about the current user...\n"
curl -s -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/myself" -H "accept: application/json"

#
# Query the API again and filter the response to find the last password change time.
#
printf "\n\nQuerying the API again and filtering the response to find the last password change time...\n"
curl -s -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/myself" -H "accept: application/json" | grep "lastPasswordChangeTime"
