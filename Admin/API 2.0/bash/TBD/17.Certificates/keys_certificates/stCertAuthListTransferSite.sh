#!/usr/bin/sh
#
##################################################################################
#  IMPORTANT NOTE: The included software is provided AS-IS, with no implied or   #
#  expressed warranty, and is not covered under any Axway service level          #
#  agreements (SLAs). This software tool is intended to meet certain specific    #
#  functional requirements, and extensive testing outside of the expected and    #
#  documented use cases has not been performed, and it may contain errors.       #
#  Customers are advised to perform appropriate backups prior to using this      #
#  tool, and perform ample testing after execution to assure that data has not   #
#  been lost and data integrity has not been jeopardized. Axway will not         #
#  be responsible for any loss or damage to data that is a result of this tool.  #
##################################################################################
#
#
# V1.0 Ian Percival  15-Sep-2023  Certificate Based Authentication, called as external 
#                                 advanced routing script to list TS folder.
#
# Inputs:
#          url = api base uri of format https://<servername>:port/apis/v2.0
#          pwd = base64 representation of user:password ( use linux command line echo -n 'user:password' | base64 )
#
# 
# A config file is used as input to define the base URL
#
# Create a file called .secrets
#
#
set -x
source ../../config
#
result=$(curl -i --key ./dogcoAPIscriptKey.pem --cert ./dogcoAPIscriptCert.crt -k -s -w "%{http_code}" -X POST "$url/sites/operations?operation=listRemoteFolder&folderToList=downloadFolder" -H "accept: application/json" -H "Referer: Ian" -H "Content-Type: application/json" -d @stCertAuthListTransferSite.json >csrf.token 2>&1)
# result=$(curl -i -E keyAndCert.pem -k -s -w "%{http_code}" -X POST "$url/sites/operations?operation=listRemoteFolder&folderToList=downloadFolder" -H "accept: application/json" -H "Referer: Ian")
json=$(cat csrf.token | head -c-4 )         # all but the last 3 chars
http_status=$(tail -c 3 csrf.token)
if [[ $http_status -ne 200 ]] ; then
        echo "Login failure: $http_status"
        cat csrf.token
        exit
fi
echo $https_status
echo $json
# Good sample return
#{
#  "connectionStatus" : "success",
#  "remoteFolder" : "/toST",
#  "sessionId" : "386d582b2b6954367130735a4b5771652f4e2b383056744553764345754e6e763873732f576e4c54784c383d",
#  "errorDetails" : "",
#  "resultSet" : {
#    "returnCount" : 1,
#    "totalCount" : 1
#  },
#  "result" : [ {
#    "fileName" : "aFileForYouToPull.txt",
#    "fileSize" : "6.00 bytes",
#    "filePermissions" : "-rw-rw-r--",
#    "lastModifiedTime" : "Tue Sep 12 10:25:48 EDT 2023"
#  } ]
#}
