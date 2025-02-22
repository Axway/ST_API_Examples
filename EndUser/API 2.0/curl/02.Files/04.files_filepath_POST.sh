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
source "${SCRIPT_DIR}/../config"

COOKIE="${SCRIPT_DIR}/../myCookie.jar"

#
# Set the file name to upload
#
FILE_NAME="test.txt"
echo "Append to the file" >> "${FILE_NAME}"

#
# Curl command to push a file to SecureTransport.
#
curl -b "${COOKIE}" -s -k -X POST "${URL}/files" -H "Content-Type: multipart/form-data" -F "file=@${FILE_NAME}" -H "accept: application/json" -H "Referer: Ian"