#!/bin/bash

#
# Get the directory of the script
#
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# 
# First we will load the variables into our context.
# Ensure that the path is correct and you have made the necessary changes.
#
printf "Loading variables into our context..."
source "${SCRIPT_DIR}/../config"

COOKIE="${SCRIPT_DIR}/../myCookie.jar"
NUMBER_OF_FILES=$1

if [[ -z $NUMBER_OF_FILES ]] ; then
        echo "Please provide the number of files to download."
        exit
fi

# 
# Set the file name to download
#
FILE_NAME_BASE="test.txt"
DOWNLOAD_FOLDER="downloaded_files"


mkdir -p "${DOWNLOAD_FOLDER}"

for i in $(seq 1 "${NUMBER_OF_FILES}") ; do
        FILE_NAME="${FILE_NAME_BASE}_${i}"
        result=$(curl -L -b "${COOKIE}" -w "%{http_code}" -s -k -X GET "$URL/files/${FILE_NAME}" -H "accept: application/json" -H "Referer: Ian")
        http_status=${result: -3}

        if [[ $http_status -ne 200 ]] ; then
                echo "Get File failure: $http_status"
                echo $result
                exit
        fi

        echo "${result}" > "${DOWNLOAD_FOLDER}/${FILE_NAME}"
        echo "File successfully retrieved and saved as ${DOWNLOAD_FOLDER}/${FILE_NAME}"
        
        # Remove the file if you don't need it to keep the system clean.
        rm -f "${DOWNLOAD_FOLDER}/${FILE_NAME}"
done

echo "Files successfully retrieved and saved in ${DOWNLOAD_FOLDER}"