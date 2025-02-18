#!/bin/bash

# 
# First we will load the variables into our context.
# Ensure that the path is correct and you have made the necessary changes.
#
printf "Loading variables into our context..."
source "../config"

COOKIE="../myCookie.jar"

#
# Curl command to list all files under the user's home folder, including the home folder name
# It is assumed a session login took place prior to this via 01.Authenticate/stLogin.sh
# Session cookies are read from a file called myCookie.jar
#
curl -L -b "${COOKIE}" -k -X GET "$URL/files" -H "accept: application/json" -H "Referer: Ian"

printf "Files successfully listed\n"

# 
# As a next step try to filter the results by using the query parameters
# limit - The number of results to return
# offset - The number of results to skip
# sortBy - The field to sort the results by (fileName, lastModifiedTime, size)
# order - The order to sort the results by (ASC, DESC)
# transferMode - The transfer mode of the file (ASCII, BINARY)
# metadata - The metadata to return with the file (true, false)
# showdots - Whether to show hidden files (true, false)
#