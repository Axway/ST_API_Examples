#!/bin/bash

# 
# First we will load the variables into our context.
# Ensure that the path is correct and you have made the necessary changes.
#
printf "Loading variables into our context..."
source "../config"

COOKIE="../myCookie.jar"
NUMBER_OF_FILES=$1

if [[ -z $NUMBER_OF_FILES ]] ; then
        echo "Please provide the number of files to upload."
        exit
fi

#
# Set the file name to upload
#
FILE_NAME="test.txt"
printf "File name: ${NUMBER_OF_FILES}\n"

for i in $(seq 1 "${NUMBER_OF_FILES}") ; do
    
    # Copy the file to a new file with a different name.
    cp "${FILE_NAME}" "${FILE_NAME}_${i}"
    
    # Curl command to push a file to SecureTransport.
    curl -b "${COOKIE}" -s -k -X POST "${URL}/files" -H "Content-Type: multipart/form-data" -F "file=@${FILE_NAME}_${i}" -H "accept: application/json" -H "Referer: Ian"
    
    # Remove the file.
    rm -f "${FILE_NAME}_${i}"
done