#! /bin/bash

#
# Ensure the defined variables are loaded in our context
#
source "../set_variables.sh"

#
# We will start with Basic Authentication '-u ${USER}:${PWD}' but very soon we will move to a token authentication.
# Our first query is to GET the current product's version.
# The -H option is for passing a header, which in this case is the Media Type - application/json.
#

curl -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/version" -H "accept: application/json"

#
# That was it for the first REST API query.
# Check the next example to see how you can parse that very same request.
#
