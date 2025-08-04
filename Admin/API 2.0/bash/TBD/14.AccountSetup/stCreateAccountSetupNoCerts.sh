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
# V1.2 Ian Percival  06-Jun-2023   General Cleanup
# V1.1 Ian Percival  12-Jun-2022  better HTTP status handling
# V1.0 Ian Percival  14-Aug-2020
#
# Curl command to create an account in SecureTransport
#
#
# A config file is used as input to define the base URL
#
# It is assumed a session login took place prior to this via ./stLogin.sh
#  Session cookies are read from a file called myCookie.jar...
#
# Usage: ./stCreateAccountSetupNoCerts.sh filename
#
# NOTE if you are only creating a subset of objects - ST responds with HTTP 100
#
#  openssl req -x509 -newkey rsa:2048 -keyout keyx509.pem -out certx509.pem -days 720
source ../../config
CSRFTOKEN=$(cat csrf.token)
#
result=$(curl -v -i -L -b myCookie.jar -s -k -w "%{http_code}" -X POST "$url/accountSetup" -H "csrfToken: $CSRFTOKEN" -H "accept: application/json" -H "Referer: Ian" -H "Content-Type: application/json" --data @$1)
#result=$(curl -i -L -b myCookie.jar -s -k -X POST "$url/accountSetup" -H "accept: application/json" -H "Referer: Ian" -H "Content-Type: application/json" --data-binary @stCreateAccountSetup.json)
http_status=${result: -3}              # remove the last 3 characters ie the HTTP status
json=$(echo ${result} | head -c-4)     # all but the last 3 characters
#
if [[ $http_status -ne 100 ]] ; then
    if [[ $http_status -ne 201 ]] ; then
        echo "Create Account failure: $http_status"
        echo $json
        exit
    fi
fi
echo $json
# 
