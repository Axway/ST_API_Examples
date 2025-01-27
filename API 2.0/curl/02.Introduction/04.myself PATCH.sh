#! /bin/bash

echo "Loading variables into our context..."
source "../set_variables.sh"

#
# With the following request you can change your own password. 
# Be careful when you execute that query, because you will need to provide the new password in the request body.
#
curl -s -k -u "${USER}:${PWD}" -X "PATCH" "https://${SERVER}:${PORT}/api/v2.0/myself" -H "accept: */*" -H "Content-Type: application/json" -d '[{
    "op": "replace",
    "path": "/passwordCredentials/password",
    "value": "TYPE_WHATEVER_YOU_WANT_HERE"
  }
]'