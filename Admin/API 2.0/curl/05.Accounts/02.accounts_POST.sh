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

# Simple POST to create an Account of type User
printf "Creating an Account of type User...\n\n"
curl -k -u ${USER}:${PWD}  -X POST "https://${SERVER}:${PORT}/api/v2.0/accounts" -H "accept: */*" -H "Content-Type: application/json" \
-d '{"name":"UserAccount","type":"user","homeFolder":"/home/UserAccount","uid":"1001","gid":"1001","user":{"name":"UserAccount","passwordCredentials":{"password":"1"}}}'


# Simple POST to create an Account of type Service
printf "Creating an Account of type Service...\n\n"
curl -k -u ${USER}:${PWD}  -X POST "https://${SERVER}:${PORT}/api/v2.0/accounts" -H "accept: */*" -H "Content-Type: application/json" \
-d '{"name":"ServiceAccount","type":"service","homeFolder":"/home/ServiceAccount","uid":"1001","gid":"1001"}'


# Simple POST to create an Account of type Template
# For the User Class we will select "VirtClass", but you can create your own and use it as a value of the templateClass property
printf "Creating an Account of type Template...\n\n"
curl -k -u ${USER}:${PWD}  -X POST "https://${SERVER}:${PORT}/api/v2.0/accounts" -H "accept: */*" -H "Content-Type: application/json" \
-d '{"name":"TemplateAccount","type":"template","homeFolder":"/home/TemplateAccount","uid":"1001","gid":"1001","templateClass": "VirtClass"}'