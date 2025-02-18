#!/bin/bash

# 
# First we will load the variables into our context.
# Ensure that the path is correct and you have made the necessary changes.
#
printf "Loading variables into our context..."
source "../config"

COOKIE="../myCookie.jar"

# 
# Curl command to pull a file from SecureTransport.
# It is assumed a session login took place prior to this via 01.Authenticate/stLogin.sh
# Session cookies are read from a file called myCookie.jar
#

# 
# Set the file name to download
#
FILE_NAME="download_file.txt"

#
# Curl command to pull a file from SecureTransport.
#
printf "\n\nPulling file from SecureTransport...\n"
result=$(curl -L -b "${COOKIE}" -w "%{http_code}" -s -k -X GET "$URL/files/${FILE_NAME}" -H "accept: application/json" -H "Referer: Ian")
http_status=${result: -3}

if [[ $http_status -ne 200 ]] ; then
        echo "Get File failure: $http_status"
        echo $result
        exit
fi

echo "${result}" > "${FILE_NAME}"
echo "File successfully retrieved and saved as ${FILE_NAME}"