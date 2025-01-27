#! /bin/bash

#
# Ensure the defined variables are loaded in our context
#
source "../set_variables.sh"


curl -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/daemons" -H "accept: application/json"

# 
# Let's say we want to extract only parts of the response.
# To do so, first we are going to preserve the whole response in a variable.
# Then we will filter it to show us various lines from the response.
#
RESPONSE=$(curl -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/daemons" -H "accept: application/json")
# TODO: remove the output from above line

#
# I am interested in the SSH daemon.
# It is 'hidden' under the key 'sshStatus', so I will grep for it.
#

echo "${RESPONSE}" | grep "sshStatus"

#
# Here is the same request, but with the 'fields' parameter.
# This parameter allows us to specify which fields we want to see in the response.
# In this case, we are only interested in the 'sshStatus' field.
#
RESPONSE=$(curl -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/daemons?fields=sshStatus" -H "accept: application/json")
echo "${RESPONSE}"