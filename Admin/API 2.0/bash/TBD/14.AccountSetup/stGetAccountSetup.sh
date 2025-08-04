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
# Curl command to get a user account from SecureTransport along with most associated objects
#
# A config file is used as input to define the base URL
#
# It is assumed a session login took place prior to this via ./stLogin.sh
#  Session cookies are read from a file called myCookie.jar...
#
# Inputs:
#          url = api base uri of format https://<servername>:port/apis/v2.0
#          mycookie.jar file
# Output:
#          choose whether you want the certificates or not by using multipart/mixed instead of plain application/json
#
source ../../config
#
if [ -z "$1" ] ; then
    echo "Please enter the Account to Get"
    exit
fi
#result=$(curl -i -L -b myCookie.jar -s -w "%{http_code}" -k -X GET "$url/accountSetup/$1" -H "accept: application/json" -H "Referer: Ian")
result=$(curl -i -L -b myCookie.jar -s -w "%{http_code}" -k -X GET "$url/accountSetup/$1" -H "accept: multipart/mixed" -H "Referer: Ian")
#http_status=$(echo $result | grep HTTP | awk '{print $2}')
http_status=${result: -3}                  # remove the last 3 characters ie the http status
json=$(echo ${result} | head -c-4 )        # all but the last 3 chars
#
if [[ $http_status -eq 404 ]] ; then
        echo "Account $1 does not Exist in ST"
        echo $result
        exit
fi
if [[ $http_status -eq 200 ]] ; then
        echo "Account $1 Exists in ST"
        echo $result
        exit
fi
if [[ $http_status -ne 200 ]] ; then
        echo "Check Account Exists failure: $http_status"
        echo $result
        exit
fi
echo $json
