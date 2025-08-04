#!/bin/bash

#
# Get the directory of the script
#
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# 
# First we will load the variables into our context.
# Ensure that the path is correct and you have made the necessary changes.
#
printf "Loading variables into our context...\n\n"
source "${SCRIPT_DIR}/../set_variables.sh"


# Composite Routes are a type of route that allows you to inherit a Route Template and extend it with additional routes if needed.
# The following example shows how to create a composite route in SecureTransport using the API.
# The first route will inherit a route template without extending it.
# The second route will inherit a route template and extend it with additional routes.


# First, get the ID of the Route Template we need
ROUTE_TEMPLATE_NAME="RouteFromAccountant"
ROUTE_TEMPLATE_ID=$(curl --silent --show-error -k -u ${USER}:${PWD} -X 'GET' "https://${SERVER}:${PORT}/api/v2.0/routes?fields=id&name=RouteFromAccountant" -H 'accept: application/json' | grep "id" | sed 's/.*: "\(.*\)".*/\1/' | tr -d '"' | tr -d ' ')

if [ -z "${ROUTE_TEMPLATE_ID}" ]; then
    echo "Error: Could not retrieve Route Template ID for '${ROUTE_TEMPLATE_NAME}'. Please check if the route template exists."
    exit 1
fi
echo "Route Template ID for '${ROUTE_TEMPLATE_NAME}': ${ROUTE_TEMPLATE_ID}\n"



# ===========================================================================================
# Example 1 without extension.
# Simple POST to create a package route in SecureTransport
printf "Creating a composite route without extension...\n\n"
curl -k -u ${USER}:${PWD} -X POST "https://${SERVER}:${PORT}/api/v2.0/routes" -H "accept: application/json" -H "Content-Type: application/json" -d "{
   \"account\" : \"john\",
   \"name\" : \"CompositeRoute_WithoutExtension\",
   \"type\": \"COMPOSITE\",
   \"conditionType\": \"MATCH_ALL\",
   \"routeTemplate\": \"${ROUTE_TEMPLATE_ID}\"
}"


# ===========================================================================================
# Example 2 with extension
# To create a composite route with an extension, we will first create a simple route that will be used as an extension.
printf "Creating a simple route...\n\n"

# Create a temporary file to store the response headers
response_headers=$(mktemp)

curl -s -D "$response_headers" -o /dev/null -k -u ${USER}:${PWD} -X POST "https://${SERVER}:${PORT}/api/v2.0/routes" -H "accept: application/json" -H "Content-Type: application/json" -d "{
  \"name\": \"SimpleRouteName\",
  \"type\": \"SIMPLE\",
  \"conditionType\": \"ALWAYS\",
  \"steps\": [{
      \"type\": \"EncodingConversion\",
      \"status\": \"ENABLED\",
      \"conditionType\": \"ALWAYS\",
      \"usePrecedingStepFiles\": false,
      \"fileFilterExpression\": \"string\",
      \"fileFilterExpressionType\": \"GLOB\",
      \"inputCharset\": \"UTF-8\",
      \"outputCharset\": \"UTF-8\",
      \"postTransformationActionRenameAsExpression\": \"string\",
       \"actionOnStepFailure\" : \"PROCEED\"
    }]
}"

LOCATION=$(grep -i '^Location:' "$response_headers" | awk '{print $2}' | tr -d '\r')
echo "Resource created at: $LOCATION"

# Extract the ID from the Location URL
SIMPLE_ROUTE_ID=$(basename "$LOCATION")
echo "New resource ID: $SIMPLE_ROUTE_ID"

rm "$response_headers"


printf "Creating a composite route with extension...\n\n"
curl -k -u ${USER}:${PWD} -X POST "https://${SERVER}:${PORT}/api/v2.0/routes" -H "accept: application/json" -H "Content-Type: application/json" -d "{
   \"account\" : \"john\",
   \"name\" : \"CompositeRoute_WithExtension\",
   \"type\": \"COMPOSITE\",
   \"conditionType\": \"MATCH_ALL\",
   \"routeTemplate\": \"${ROUTE_TEMPLATE_ID}\",
   \"steps\": [{
        \"type\": \"ExecuteRoute\",
        \"status\": \"ENABLED\",
        \"executeRoute\": \"${SIMPLE_ROUTE_ID}\",
        \"autostart\": false}]
}"

