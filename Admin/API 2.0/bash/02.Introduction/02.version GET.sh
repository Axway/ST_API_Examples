#! /bin/bash

echo "Loading variables into our context..."
source "../set_variables.sh"

#
# Let's say we want to extract only parts of the response.
# To do so, first we are going to preserve the whole response in a variable.
# Then we will filter it to show us various lines from the response.
# Check the curl manual for information about the used options.
#

RESPONSE=$(curl -s -k -u "${USER}:${PWD}" -X "GET" "https://${SERVER}:${PORT}/api/v2.0/version" -H "accept: application/json")

#
# Uncomment this to see what is the full output of the RESPONSE variable.
#
# echo "${RESPONSE}"

#
# I am interested in my current product's version.
# It is 'hidden' under the key 'version', so I will grep for it.
#
printf "grep for the version...\n"
echo "${RESPONSE}" | grep "version"

#
# But under version there are other numbers that represent the SPIs versions. 
# Don't worry if you don't know what SPI is, we will cover that later.
# Now, let's remove the extra lines.
#

printf "grep for version.*5.5...\n"
echo "${RESPONSE}" | grep "version.*5.5"

#
# Extract the server type from the response.
#

printf "grep for serverType...\n"
echo "${RESPONSE}" | grep "serverType"

#
# Extract the operating system from the response.
#

printf "grep for os...\n"
echo "${RESPONSE}" | grep "os"

#
# You can further filter the results to get the exact data you need.
#