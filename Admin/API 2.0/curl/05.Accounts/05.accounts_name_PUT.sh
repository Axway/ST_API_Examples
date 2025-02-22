#!/bin/bash

#
# Get the directory of the script
#
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# 
# First we will load the variables into our context.
# Ensure that the path is correct and you have made the necessary changes.
#
printf "Loading variables into our context..."
source "${SCRIPT_DIR}/../set_variables.sh"

# The easiest way to update more than 1 property of an object is through the PUT method.

# For the example here, we will use
# 1. GET method to retrieve the object's content
# 2. Bash commands to modify the parts we want
# 3. PUT method to update the object's content

ACCOUNT="UserAccount"

printf "Getting the account ${ACCOUNT}...\n"
curl -k -u ${USER}:${PWD}  -X GET "https://${SERVER}:${PORT}/api/v2.0/accounts/${ACCOUNT}" -H "accept: */*" > result.json

cat result.json | sed -e "s/\"uid\" : \".*\",/\"uid\" : \"1111\",/" > new_result.json

curl -k -u ${USER}:${PWD}  -X PUT "https://${SERVER}:${PORT}/api/v2.0/accounts/${ACCOUNT}" -H "accept: */*" -H 'Content-Type: application/json'  -d @new_result.json