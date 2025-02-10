#! /bin/bash

#
# Ensure the defined variables are loaded in our context
#
source "../set_variables.sh"


#
# Check if application with the name 'Audit Log Maintenance' exists
#
NAME="Audit Log Maintenance"
NAME=$(echo "${NAME}" | sed 's/ /%20/g')
printf "Check if application with the name '%s' exists...\n" "${NAME}"
curl -k -u "${USER}:${PWD}" --head "https://${SERVER}:${PORT}/api/v2.0/applications/${NAME}" -H "accept: */*"

#
# Check if application with the name 'Transfer Log Maintenance' exists
#
NAME="Transfer Log Maintenance"
NAME=$(echo "${NAME}" | sed 's/ /%20/g')
printf "\nCheck if application with the name '%s' exists...\n" "${NAME}"
RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}\n" -k -u "${USER}:${PWD}" --head "https://${SERVER}:${PORT}/api/v2.0/applications/${NAME}" -H "accept: */*")
if [ "${RESPONSE_CODE}" == "200" ]; then
  echo "Application exists."
else
  echo "Application does not exist."
fi