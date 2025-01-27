#! /bin/bash

#
# Ensure the defined variables are loaded in our context
#
source "../set_variables.sh"

#
# Here we are going to extract the banner from the SSH daemon.
# First we will get the SSH daemon's information.
#
NAME="ssh"
curl -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/daemons/${NAME}" -H "accept: application/json"

#
# Now we are going to extract the banner from the response.
# We will use the 'grep' command to filter the response.
# The 'cut' command will help us to extract the banner.
#
RESPONSE=$(curl -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/daemons/${NAME}" -H "accept: application/json")
BANNER=$(echo "${RESPONSE}" | grep "banner" | cut -d '"' -f 4)

#
# Let's check if the banner is defined.
#
if [ -z "${BANNER}" ]; then
    echo "There is no banner defined."
else
    echo "There is a banner defined: '${BANNER}'."
fi


#
# Now we are going to fake a banner for the SSH daemon.
#
echo "Setting the banner..."
BANNER='"banner": "This is a SecureTransport REST API test banner."'

#
# Repeat the grep, but this time we will use the fake banner.
#
BANNER=$(echo "${BANNER}" | grep "banner" | cut -d '"' -f 4)

if [ -z "${BANNER}" ]; then
    echo "There is no banner defined."
else
    echo "There is a banner defined: '${BANNER}'."
fi