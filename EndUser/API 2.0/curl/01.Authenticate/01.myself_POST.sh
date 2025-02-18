#!/bin/bash

# 
# First we will load the variables into our context.
# Ensure that the path is correct and you have made the necessary changes.
#
printf "Loading variables into our context..."
source "../config"

# Remove any existing cookie jar file
COOKIE="../myCookie.jar"
rm -f "${COOKIE}"

#
# We will start with the basic authentication. 
# This is a simple combination of username and password.
# The server will check if the provided credentials are correct.
# If they are, the server will respond with the requested data.
# If not, the server will respond with an error message.
# Check 02.myself_DELETE.sh for log out.
# 
printf "\n\nBasic authentication...\n"
result=$(curl -H "Authorization: Basic $PWD" --cookie-jar "${COOKIE}" -w "%{http_code}" -k -s -X POST "$URL/myself" -H "accept: application/json" -H "Referer: Ian")
http_status=${result: -3}

if [[ $http_status -ne 200 ]] ; then
        echo "Login failure: $http_status"
        exit
fi
echo "$result"
echo "Successfully Authenticated to SecureTransport"

#
# Then we will see the same request, but with the cookie jar.
# The cookie jar is a file that stores the session information.
# This way, we can make multiple requests without the need to authenticate every time.
#
# printf "\n\nBasic authentication with cookie jar to reduce further authentications...\n"
# REFERER_HEADER="Referer: Ian"
# curl -k --cookie "${COOKIE}" -X GET "$URL/myself" -H "accept: application/json" -H "${REFERER_HEADER}"