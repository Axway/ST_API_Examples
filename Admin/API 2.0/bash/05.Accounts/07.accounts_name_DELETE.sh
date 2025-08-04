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

# Let's say that we want to delete an Account.
# For the purpose we will first check if it exists with the HEAD method. 
# If it exists, we will delete it.
# Otherwise will print message that it doesn't exist.


ACCOUNT_TO_CHECK="UserAccount"
HTTP_RESPONSE_CODE=$(curl -k -u ${USER}:${PWD} --head "https://${SERVER}:${PORT}/api/v2.0/accounts/${ACCOUNT_TO_CHECK}" -H "accept: */*" 2>&1 | grep HTTP | awk '{print $2}')

if [[ ${HTTP_RESPONSE_CODE} == "200" ]]; then
	printf "Deleting Account: ${ACCOUNT_TO_CHECK}\n\n"
	curl -k -u ${USER}:${PWD} -X DELETE "https://${SERVER}:${PORT}/api/v2.0/accounts/${ACCOUNT_TO_CHECK}" -H "accept: */*"
else
	echo "Account ${ACCOUNT_TO_CHECK} does not exist."
fi

ACCOUNT_TO_CHECK="ServiceAccount"
HTTP_RESPONSE_CODE=$(curl -k -u ${USER}:${PWD} --head "https://${SERVER}:${PORT}/api/v2.0/accounts/${ACCOUNT_TO_CHECK}" -H "accept: */*" 2>&1 | grep HTTP | awk '{print $2}')

if [[ ${HTTP_RESPONSE_CODE} == "200" ]]; then
	printf "Deleting Account: ${ACCOUNT_TO_CHECK}\n\n"
	curl -k -u ${USER}:${PWD} -X DELETE "https://${SERVER}:${PORT}/api/v2.0/accounts/${ACCOUNT_TO_CHECK}" -H "accept: */*"
else
	echo "Account ${ACCOUNT_TO_CHECK} does not exist."
fi

ACCOUNT_TO_CHECK="TemplateAccount"
HTTP_RESPONSE_CODE=$(curl -k -u ${USER}:${PWD} --head "https://${SERVER}:${PORT}/api/v2.0/accounts/${ACCOUNT_TO_CHECK}" -H "accept: */*" 2>&1 | grep HTTP | awk '{print $2}')
if [[ ${HTTP_RESPONSE_CODE} == "200" ]]; then
	printf "Deleting Account: ${ACCOUNT_TO_CHECK}\n\n"
	curl -k -u ${USER}:${PWD} -X DELETE "https://${SERVER}:${PORT}/api/v2.0/accounts/${ACCOUNT_TO_CHECK}" -H "accept: */*"
else
	echo "Account ${ACCOUNT_TO_CHECK} does not exist."
fi