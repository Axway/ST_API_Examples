#! /bin/bash

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



# Simple GET to retrieve all available Accounts
curl -k -u ${USER}:${PWD}  -X GET "https://${SERVER}:${PORT}/api/v2.0/accounts" -H "accept: */*"


# GET only the Accounts of type user
# You can also try with type=template or type=service
# curl -k -u ${USER}:${PWD}  -X GET "https://${SERVER}:${PORT}/api/v2.0/accounts?type=user" -H "accept: */*"

# GET the User Accounts and receive only the name and home folder in the response
# Pay attention that the type is also returned no matter that it is not specified in the fields
# curl -k -u ${USER}:${PWD}  -X GET "https://${SERVER}:${PORT}/api/v2.0/accounts?type=user&fields=name,homeFolder" -H "accept: */*"

# If the result is still big to analyze, you can use the limit parameter to get the first 5 elements
# curl -k -u ${USER}:${PWD}  -X GET "https://${SERVER}:${PORT}/api/v2.0/accounts?type=user&fields=name,homeFolder&limit=5" -H "accept: */*"