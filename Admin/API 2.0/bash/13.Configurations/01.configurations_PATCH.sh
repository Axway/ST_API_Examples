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

# Change Server Configuration Options
curl -k -u ${USER}:${PWD} -X PATCH "https://${SERVER}:${PORT}/api/v2.0/configurations/options/AddressBook.Enabled" -H "accept: */*" -H "Content-Type: application/json" \
-d '[{"op":"replace","path":"/values/0","value":"true"}]'