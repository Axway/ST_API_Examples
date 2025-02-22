#!/bin/bash

#
# Get the directory of the script
#
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# 
# First we will load the variables into our context.
# Ensure that the path is correct and you have made the necessary changes.
#
printf "Loading variables into our context...\n\n"
source "${SCRIPT_DIR}/../set_variables.sh"

ACCOUNT_TO_CHECK="UserAccount"
curl -k -u ${USER}:${PWD} --head "https://${SERVER}:${PORT}/api/v2.0/accounts/${ACCOUNT_TO_CHECK}" -H "accept: */*"

# Or you can achieve the same thing with the '-I' option
# curl -k -u ${USER}:${PASSWORD} -I "https://${SERVER}:${PORT}/api/v2.0/accounts/${ACCOUNT_TO_CHECK}" -H "accept: */*"

# If you want to parse the response code, here is an example how to do it
# The ${HTTP_RESPONSE_CODE} variable will contain our HTTP Response code
HTTP_RESPONSE_CODE=$(curl -k -u ${USER}:${PWD} --head "https://${SERVER}:${PORT}/api/v2.0/accounts/${ACCOUNT_TO_CHECK}" -H "accept: */*" 2>&1 | grep HTTP | awk '{print $2}')

# And this is the if statement that we will use to print "Account Exists" if the HTTP Reponse Code is equal to 200
if [[ ${HTTP_RESPONSE_CODE} == "200" ]]; then
	echo "Account Exists"
fi

# An alternative version with if-else contruction
if [[ ${HTTP_RESPONSE_CODE} == "200" ]]; then
	echo "Account Exists"
else
	echo "Account does not exist"
fi