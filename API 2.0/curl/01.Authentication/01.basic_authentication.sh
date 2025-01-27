#! /bin/bash

# 
# First we will load the variables into our context.
# Ensure that the path is correct and you have made the necessary changes.
#
printf "Loading variables into our context..."
source "../set_variables.sh"

#
# We will start with the basic authentication. 
# This is a simple combination of username and password.
# The server will check if the provided credentials are correct.
# If they are, the server will respond with the requested data.
# If not, the server will respond with an error message.
# 
printf "\n\nBasic authentication...\n"
curl -s -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/myself" -H "accept: application/json"

#
# Then we will see the same request, but with the cookie jar.
# The cookie jar is a file that stores the session information.
# This way, we can make multiple requests without the need to authenticate every time.
#
printf "\n\nBasic authentication with cookie jar to reduce further authentications...\n"
REFERER_HEADER="Referer: THIS_IS_A_RANDOM_TEXT"
curl -k --cookie-jar cookie.jar -u "${USER}:${PWD}" -X POST "https://${SERVER}:${PORT}/api/v2.0/myself" -H "accept: application/json" -H "${REFERER_HEADER}"
curl -k --cookie cookie.jar -X GET "https://${SERVER}:${PORT}/api/v2.0/myself" -H "accept: application/json" -H "${REFERER_HEADER}"