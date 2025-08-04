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

SCO="StatisticsSummaryReport"

#
# Those relate to the User and Environment you want to use from the Axway Platform
# You can find those in the Axway Platform UI
# https://platform.axway.com/
#
CLIENT_ID="<PUT YOUR CLIENT ID HERE>"
CLIENT_SECRET="<PUT YOUR CLIENT_SECRET HERE>"
ENVIRONMENT_ID="<PUT YOUR ENVIRONMENT_ID HERE>"
ENVIRONMENT_NAME="<PUT YOUR ENVIRONMENT_NAME HERE>"

#
# In case you have an edge through which the connection must pass to reach the platform, define it here.
#
NETWORK_ZONE="<PUT YOUR NETWORK_ZONE HERE>"

# Set the default values for the configuration options
# In newer product versions, those are set by default.
PLATFORM_API="https://platform.axway.com/api/v1/usage/automatic"
PLATFORM_AUTHENTICATION="https://login.axway.com/auth/realms/Broker/protocol/openid-connect/token"
SCHEMA_ID="https://platform.axway.com/schemas/report.json"

PATH_TO_REPORTS="/tmp/"
DAYS_TO_INCLUDE="3"

CONFIGURATION_OPTIONS=("${SCO}.ClientId" "${SCO}.ClientSecret" "${SCO}.EnvironmentId" "${SCO}.EnvironmentName" "${SCO}.FilePath" "${SCO}.NetworkZone" "${SCO}.Platform.API" "${SCO}.Platform.Authentication" "${SCO}.SchemaId" "${SCO}.AutomaticReport.DaysToInclude")
CONFIGURATION_VALUES=("${CLIENT_ID}" "${CLIENT_SECRET}" "${ENVIRONMENT_ID}" "${ENVIRONMENT_NAME}" "${PATH_TO_REPORTS}" "${NETWORK_ZONE}" "${PLATFORM_API}" "${PLATFORM_AUTHENTICATION}" "${SCHEMA_ID}" "${DAYS_TO_INCLUDE}")

# Update the configuration options
for i in "${!CONFIGURATION_OPTIONS[@]}"; do
  printf "Updating %s to %s", "${CONFIGURATION_OPTIONS[$i]}", "${CONFIGURATION_VALUES[$i]}"
  curl -k -u "${USER}:${PWD}" -X PATCH "https://${SERVER}:${PORT}/api/v2.0/configurations/options/StatisticsSummaryReport.EnvironmentId" -H 'accept: */*' -H 'Content-Type: application/json'\
   -d '[{"op": "replace", "path": "/values", "value": ["${CONFIGURATION_VALUES[$i]}"]}]'
done