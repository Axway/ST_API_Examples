#! /bin/bash

#
# Ensure the defined variables are loaded in our context
#
source "../set_variables.sh"

#
# Get all applications
#
printf "Get all applications...\n"
curl -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/applications" -H "accept: application/json"

# 
# Get all applications based on the type
#
ALL_TYPES="AccountFilePurge,AccountTTL,AdvancedRouting,ArchiveMaint,AuditLogMaint,Basic,HumanSystem,LogEntryMaint,LoginThresholdMaintenance,MBFT,PackageRetentionMaint,SentinelLinkDataMaint,SharedFolder,SiteMailbox,StandardRouter,TransferLogMaint,UnlicensedAccountMaint"
RANDOM_TYPE=$(echo $ALL_TYPES | awk -F ',' '{print $1}')
printf "From all applications get one based on the type '${RANDOM_TYPE}'...\n"
curl -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/applications?type=${RANDOM_TYPE}" -H "accept: application/json"

#
# Get only the type of the available applications
#
printf "Get only the type of the available applications...\n"
curl -s -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/applications?fields=type" -H "accept: application/json"