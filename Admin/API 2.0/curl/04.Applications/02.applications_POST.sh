#! /bin/bash

#
# Ensure the defined variables are loaded in our context
#
source "../set_variables.sh"

#
# List of all application types
#
FLOW_APPLICATIONS=(AdvancedRouting Basic HumanSystem MBFT SharedFolder SiteMailbox StandardRouter)
MAINTENANCE_APPLICATIONS=(AccountFilePurge AccountTTL ArchiveMaint AuditLogMaint LogEntryMaint LoginThresholdMaintenance PackageRetentionMaint SentinelLinkDataMaint TransferLogMaint UnlicensedAccountMaint)

#
# Check if a random application exists
# Change the number of the array to get a different application
#
RANDOM_APP=${FLOW_APPLICATIONS[2]}
printf "Get the name of an application of type '%s'...\n" "${RANDOM_APP}"
NAME_OF_APP=$(curl -s -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/applications?fields=name&type=${RANDOM_APP}" -H "accept: application/json" | jq .result[0].name)
echo "Name of the application: ${NAME_OF_APP}"

if [ "${NAME_OF_APP}" == "null" ]; then
    echo "No application of type '${RANDOM_APP}' found."
    #
    # Create an application of the selected type
    #
    printf "Create an application of type '%s'...\n\n" "${RANDOM_APP}"
    curl -s -k -u "${USER}:${PWD}" -X "POST" "https://${SERVER}:${PORT}/api/v2.0/applications" -H 'accept: */*' -H 'Content-Type: application/json' -d "{ \
    \"type\": \"${RANDOM_APP}\",
    \"name\": \"${RANDOM_APP} Application\",
    \"notes\": \"This is a ${RANDOM_APP} application\"
    }"
else
    printf "Application of type '%s' found.\n\n" "${RANDOM_APP}"
fi



#
# To create of an application of type Maintenance you must check their schema as they differ.
# The flow ones are easier as they all have similar schema.
#

RANDOM_APP=${MAINTENANCE_APPLICATIONS[0]}
printf "Create an application of type '%s'...\n" "${RANDOM_APP}"
curl -s -k -u "${USER}:${PWD}" -X "POST" "https://${SERVER}:${PORT}/api/v2.0/applications" -H 'accept: */*' -H 'Content-Type: application/json' -d "{ \
\"type\": \"${RANDOM_APP}\",
\"name\": \"${RANDOM_APP} Application\",
\"notes\": \"This is a ${RANDOM_APP} application\",
\"deleteFilesDays\": 90,
\"pattern\": \"*.txt\",
\"expirationPeriod\": true,
\"removeFolders\": true,
\"notifyDays\": \"90\",
\"sendSentinelAlert\": false,
\"warnNotifyAccount\": false,
\"deletionNotifications\": false,
\"deletionNotifyAccount\": false,
\"schedules\": [ {
    \"tag\": \"${RANDOM_APP}\",
    \"type\": \"ONCE\",
    \"executionTimes\": [\"00:00\"],
    \"startDate\": \"2025-02-11T00:00:00Z\",
    \"skipHolidays\": false
    }]
}"


# Complate schema of the AccountFilePurge application
#
# {
#   "name": "Test",
#   "type": "AccountFilePurge",
#   "notes": "string",
#   "managedByCG": false,
#   "additionalAttributes": {
#     "additionalProp1": "string",
#     "additionalProp2": "string",
#     "additionalProp3": "string"
#   },
#   "businessUnits": [
#     "string"
#   ],
#   "deleteFilesDays": 0,
#   "pattern": "string",
#   "expirationPeriod": false,
#   "removeFolders": false,
#   "warningNotifications": false,
#   "notifyDays": "string",
#   "sendSentinelAlert": false,
#   "warnNotifyAccount": false,
#   "warningNotificationsTemplate": "FileMaintenanceNotification.xhtml",
#   "warnNotifyEmails": "string",
#   "deletionNotifications": false,
#   "deletionNotificationsTemplate": "FileMaintenanceNotification.xhtml",
#   "deletionNotifyAccount": false,
#   "deletionNotifyEmails": "string",
#   "schedules": [
#     {
#       "tag": "string",
#       "type": "ONCE",
#       "executionTimes": [
#         "string"
#       ],
#       "startDate": {},
#       "skipHolidays": false
#     }
#   ]
# }