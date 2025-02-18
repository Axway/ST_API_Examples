#! /bin/bash

#
# Ensure the defined variables are loaded in our context
#
source "../set_variables.sh"

#
# This is the general request to get all servers.
# The response will be a list of all servers.
# 
curl -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/servers" -H "accept: application/json"

#
# Above request will print everything about the available servers.
# Let's say we are only interested in the server's name and its status.
# We can specify the fields we want to see in the response.
# Pay attention that 'protocol' will always be in the response and can't be used with the fields filtration.
# 

curl -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/servers?fields=id,serverName,isActive" -H "accept: application/json"

#
# Let's say we are only interested in the servers that are using the AS2 protocol.
# We can filter the servers by the protocol they are using.
# 
PROTOCOL="as2"
curl -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/servers?protocol=${PROTOCOL}&fields=id,serverName,isActive" -H "accept: application/json"

#
# There are fields that are common to all types of servers.
# When you want to filter by a common field, you can use them directly 
# To understand which filters are common, check the API documentation.
# For example: limit, offset, serverName, isActive, isFipsEnabled, etc.
# fields can also be used with all types of servers, but the used values depends on the type.
# Note: %20 is a space character.
#

curl -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/servers?limit=1&offset=0&serverName=Ssh%20Default&isActive=true&isFipsEnabled=false" -H "accept: application/json"

# 
# When you want to filter by a field that is specific to a protocol, let's say 'isScpEnabled', you must use the protocol parameter.
# 
curl -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/servers?fields=isScpEnabled&protocol=ssh" -H "accept: application/json"
