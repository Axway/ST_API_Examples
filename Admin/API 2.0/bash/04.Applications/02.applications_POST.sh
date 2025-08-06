#!/bin/bash
# ==============================================================================
# Script Name: 02.applications_POST.sh
# Author: Plamen Milenkov
# Created: 2025-08-06
# Location: Sofia
# ==============================================================================
# Description:
# This script creates applications using the `/applications` endpoint.
# It demonstrates:
# - Checking for an existing application of a flow type
# - Creating a flow application if not found
# - Creating a maintenance application with a detailed schema
#
# Usage:
# ./02.applications_POST.sh
#
# Notes:
# - Ensure that `set_variables.sh` is correctly configured and sourced.
# - Maintenance applications require specific schema fields.
# ==============================================================================

source "../set_variables.sh"

FLOW_APPLICATIONS=(AdvancedRouting Basic HumanSystem MBFT SharedFolder SiteMailbox StandardRouter)
MAINTENANCE_APPLICATIONS=(AccountFilePurge AccountTTL ArchiveMaint AuditLogMaint LogEntryMaint LoginThresholdMaintenance PackageRetentionMaint SentinelLinkDataMaint TransferLogMaint UnlicensedAccountMaint)

RANDOM_APP=${FLOW_APPLICATIONS[2]}
printf "Get the name of an application of type '%s'...\n" "${RANDOM_APP}"
NAME_OF_APP=$(curl -s -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/applications?fields=name&type=${RANDOM_APP}" -H "accept: application/json" | jq .result[0].name)
echo "Name of the application: ${NAME_OF_APP}"

if [ "${NAME_OF_APP}" == "null" ]; then
    echo "No application of type '${RANDOM_APP}' found."
    printf "Create an application of type '%s'...\n\n" "${RANDOM_APP}"
    curl -s -k -u "${USER}:${PWD}" -X "POST" "https://${SERVER}:${PORT}/api/v2.0/applications" -H 'accept: */*' -H 'Content-Type: application/json' -d "{ \
    \"type\": \"${RANDOM_APP}\",
    \"name\": \"${RANDOM_APP} Application\",
    \"notes\": \"This is a ${RANDOM_APP} application\" }"
else
    printf "Application of type '%s' found.\n\n" "${RANDOM_APP}"
fi

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
