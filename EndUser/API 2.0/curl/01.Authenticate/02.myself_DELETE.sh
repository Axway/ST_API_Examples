#!/bin/bash

# 
# First we will load the variables into our context.
# Ensure that the path is correct and you have made the necessary changes.
#
printf "Loading variables into our context..."
source "../config"

COOKIE="../myCookie.jar"

result=$(curl -H "Authorization: Basic $PWD" --cookie-jar "${COOKIE}" -w "%{http_code}" -k -s -X DELETE "$URL/myself" -H "accept: application/json" -H "Referer: Ian")
http_status=${result: -3}

if [[ $http_status -ne 200 ]] ; then
        echo "Logout failure: $http_status"
        exit
fi
echo "$result"
echo "Successfully Logged out of SecureTransport"