#!/bin/bash

#
# Get the directory of the script
#
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# 
# First we will load the variables into our context.
# Ensure that the path is correct and you have made the necessary changes.
#
printf "Loading variables into our context...\n"
source "${SCRIPT_DIR}/../set_variables.sh"

ACCOUNT="john"
PATCH_FILE="${SCRIPT_DIR}/06.patch_body/stPatchAccount.json"


ELEMENT_TO_BE_CHANGED=$(jq -r '.[] | .path' "${PATCH_FILE}")

printf "Changing '%s' of account '%s'...\n" "${ELEMENT_TO_BE_CHANGED}" "${ACCOUNT}"
HTTP_CODE=$(curl -s -o /dev/null -k -u ${USER}:${PWD} -w "%{http_code}\n" -X PATCH "https://${SERVER}:${PORT}/api/v2.0/accounts/${ACCOUNT}" -H "accept: */*" -H 'Content-Type: application/json' -d "@${PATCH_FILE}")

if [[ "${HTTP_CODE}" == "204" ]]; then
  echo "Account '${ACCOUNT}' has been changed successfully."
else
  echo "Account '${ACCOUNT}' update failed."
  echo "HTTP Code: ${HTTP_CODE}"
fi
