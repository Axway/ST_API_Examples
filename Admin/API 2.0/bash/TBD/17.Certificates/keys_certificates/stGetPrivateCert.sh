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
# V1.1 Ian Percival  06-Jun-2023   General Cleanup
# V1.0 Ian Percival  14-Aug-2020
#
# Curl command to get a certficate 
#
# A config file is used as input to define the base URL
#
# It is assumed a session login took place prior to this via ./stLogin.sh
#  Session cookies are read from a file called myCookie.jar...
#
# Inputs:
#          $1 = Certificate ID
#          url = api base uri of format https://<servername>:port/apis/v2.0
#          mycookie.jar file
# Output:
#          pkcs12 format file created called out.pkcs12

#
source ../../config
#
if [ -z "$1" ] ; then
    echo "Please enter the Certificate ID"
    exit
fi
result=$(curl -i -L -b myCookie.jar -s -w "%{http_code}" -o out.pkcs12 -k -X GET "$url/certificates/$1?password=12345678&exportPrivateKey=true" -H "accept: multipart/mixed" -H "Referer: Ian")
#http_status=$(echo $result | grep HTTP | awk '{print $2}')
#
http_status=${result: -3}                  # remove the last 3 characters ie the http status
export mpart=$(echo ${result} | head -c-4 )        # all but the last 3 chars
if [[ $http_status -ne 200 ]] ; then
        echo "Get Certificate Failure: $http_status"
        echo $mpart
        exit
fi
# remove the last line which is --boundary--
sed -i '$d' out.pkcs12
# Determine what the boundary is
export boundary=$(grep -a 'multipart/mixed;boundary=' out.pkcs12 | sed 's/.*boundary=//')
# We will receive towards the end of the file (after headers and json)
# --Boundary
# Content-Type: application/octet-stream
# Content-Disposition: attachment; filename="certname.p12"
# -- so basically we need to extract the binary data.. ie remove from the begining of the file to .p12...
sed -i '1,/p12"/d' out.pkcs12
# Finally - remove the crlf at the beginning and end of the file
sed -i ':a;/\r$/{N;s/\r\n//;b a}' out.pkcs12
echo "The Cert was exported to file out.pkcs12"
# you can validate with 
# openssl pkcs12 -info -in out.pkcs12
