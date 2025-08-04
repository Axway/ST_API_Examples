#!/bin/bash
#
# Get the directory of the script
#
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# 
# First we will load the variables into our context.
# Ensure that the path is correct and you have made the necessary changes.
#
printf "Loading variables into our context..."
source "${SCRIPT_DIR}/../set_variables.sh"

# Create TS
curl -k -u ${USER}:${PASSWORD} -X POST "https://${SERVER}:${PORT}/api/v2.0/sites" -H "accept: */*" -H "Content-Type: application/json" \
-d '{"name":"HTTP","type":"http","protocol":"http","account":"john","host":"${SERVER}","port":"443","downloadPattern":"*","uploadFolder":"/","userName":"john"}'