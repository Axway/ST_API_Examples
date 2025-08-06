#!/bin/bash
# ==============================================================================
# Script Name: 01.applications_GET.sh
# Author: Plamen Milenkov
# Created: 2025-08-06
# Location: Sofia
# ==============================================================================
# Description:
# This script retrieves application data using the `/applications` endpoint.
# It demonstrates:
# - A full GET request for all applications
# - A filtered GET request based on application type
# - A GET request for application types only
#
# Usage:
# ./01.applications_GET.sh
#
# Notes:
# - Ensure that `set_variables.sh` is correctly configured and sourced.
# - The type filter uses a predefined list of application types.
# ==============================================================================

source "../set_variables.sh"

printf "Get all applications...\n"
curl -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/applications" -H "accept: application/json"

ALL_TYPES="AccountFilePurge,AccountTTL,AdvancedRouting,ArchiveMaint,AuditLogMaint,Basic,HumanSystem,LogEntryMaint,LoginThresholdMaintenance,MBFT,PackageRetentionMaint,SentinelLinkDataMaint,SharedFolder,SiteMailbox,StandardRouter,TransferLogMaint,UnlicensedAccountMaint"
RANDOM_TYPE=$(echo $ALL_TYPES | awk -F ',' '{print $1}')
printf "From all applications get one based on the type '${RANDOM_TYPE}'...\n"
curl -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/applications?type=${RANDOM_TYPE}" -H "accept: application/json"

printf "Get only the type of the available applications...\n"
curl -s -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/applications?fields=type" -H "accept: application/json"
