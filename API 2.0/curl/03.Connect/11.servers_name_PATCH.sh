#! /bin/bash

#
# Ensure the defined variables are loaded in our context
#
source "../set_variables.sh"

NAME="SSH_TEST_SERVER_1"
printf "Patching the server port...\n"
curl -s -o /dev/null -w "%{http_code}\n" -k -u "${USER}:${PWD}" -X "PATCH" "https://${SERVER}:${PORT}/api/v2.0/servers/${NAME}" -H "accept: application/json" -H "Content-Type: application/json" \
 -d "[{
        \"op\": \"replace\",
        \"path\": \"/port\",
        \"value\": 8026 }
    ]"

#
# Here is an example of a PATCH request to remove rsa keys from the publicKeys.
# First we will get the current value of the publicKeys, then we will remove the rsa key.
# Because the publicKeys is a comma separated list of values where some are containing rsa, we will remove the rsa key from the list.
#
printf "Patching the server publicKeys...\n"

OLD_PUBLIC_KEYS=$(curl -s -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/servers/${NAME}" -H "accept: application/json" -H "Content-Type: application/json" \
| grep "publicKeys" | awk -F ':' '{print $2}' | sed 's/",/"/g' | sed 's/"//g')
echo "Public keys before removing rsa: ${OLD_PUBLIC_KEYS}"

NEW_PUBLIC_KEYS=$(echo "${OLD_PUBLIC_KEYS}" | sed 's/[a-zA-Z0-9-]*rsa[a-zA-Z0-9-]*//g' | sed 's/,,//g' )
echo "Public keys after removal: ${NEW_PUBLIC_KEYS}"

curl -k -u "${USER}:${PWD}" -X "PATCH" "https://${SERVER}:${PORT}/api/v2.0/servers/${NAME}" -H "accept: application/json" -H "Content-Type: application/json" \
 -d "[{
        \"op\": \"replace\",
        \"path\": \"/publicKeys\",
        \"value\": \"${NEW_PUBLIC_KEYS}\"
    }]"
printf "\nDone\n"

printf "Retrieve the server information to check the changes...\n"
curl -s -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/servers/${NAME}" -H "accept: application/json" -H "Content-Type: application/json"