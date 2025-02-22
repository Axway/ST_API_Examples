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

# Simple GET to retrieve everything about a specific account
echo "GET /api/v2.0/accounts/UserAccount"
curl -k -u ${USER}:${PWD}  -X GET "https://${SERVER}:${PORT}/api/v2.0/accounts/UserAccount" -H "accept: */*"

# GET only the name, uid, and gid
# Pay attention that the type is also returned no matter that it is not specified in the fields
echo "GET /api/v2.0/accounts/UserAccount?fields=name,uid,gid"
curl -k -u ${USER}:${PWD}  -X GET "https://${SERVER}:${PORT}/api/v2.0/accounts/UserAccount?fields=name,uid,gid" -H "accept: */*"

# If we want to receive fields that are not common to all account types, but are specific to the user one, we have to specify the type
# Let's try with the addressBookSettings and without the type
echo "GET /api/v2.0/accounts/UserAccount?fields=addressBookSettings"
curl -k -u ${USER}:${PWD}  -X GET "https://${SERVER}:${PORT}/api/v2.0/accounts/UserAccount?fields=addressBookSettings" -H "accept: */*"

# And now by specifying the type=user
echo "GET /api/v2.0/accounts/UserAccount?type=user&fields=addressBookSettings"
curl -k -u ${USER}:${PWD}  -X GET "https://${SERVER}:${PORT}/api/v2.0/accounts/UserAccount?type=user&fields=addressBookSettings" -H "accept: */*"