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
#                                  This code assumes Webservices.Admin.CsrfToken.enabled 
#                                   is set to true - which is the default after 20230529  
# V1.0 Ian Percival  07-Aug-2021
#
# Curl command to Import an SSH private key  to ST
#
#
# A config file is used as input to define the base URL
#
# It is assumed a session login took place prior to this via ./stLogin.sh
#  Session cookies are read from a file called myCookie.jsr...
#
# This example uses a Content-Type of multipart/mixed 
# 

source ../../config
CSRFTOKEN=$(cat csrf.token)
# 
result=$(curl -i -L -b myCookie.jar -w "%{http_code}" -s -k -X POST "$url/certificates" --trace trace.log -H "csrfToken: $CSRFTOKEN" -H "Referer: ian" -H "Content-Type: multipart/mixed" -F "t1=@stImportPrivateSSHKey.json; type=application/json" -F "t2=@stImportPrivateSSHKey.pem; type=application/octet-stream")
#http_status=$(echo $result | grep HTTP | awk '{print $2}')
http_status=${result: -3}                  # remove the last 3 characters ie the http status
json=$(echo ${result} | head -c-4 )        # all but the last 3 chars
#
if [[ $http_status -ne 200 ]] ; then
        echo "Error in Import Private Certificate: $http_status"
        echo $result
        echo $http_status
        exit
fi
echo $json
# Sample Response
# {
#  "id": "4028b8ce889c092201889cb432600025",
#  "name": "pippinscert",
#  "subject": "ST=AZ, L=Phoenix, C=US, CN=pippin",
#  "type": "x509",
#  "usage": "private",
#  "expirationTime": "Sun, 05 Dec 2021 19:39:39 -0500",
#  "creationTime": 1628368779000,
#  "fingerprint": "0x8ADD2945D6AC8E6BF8700DA51BE419FC",
#  "keyAlgorithm": "RSA",
#  "issuer": "SERIALNUMBER=cc34dd69f50bea35baf3a679ca8a5683b439ce7c5f2d3db71b37f20a20ea1110, ST=AZ, L=Phoenix, C=US, CN=ca",
#  "serialNumber": "1a",
#  "keySize": 2048,
#  "version": 3,
#  "validityPeriod": 120,
#  "account": "AxwayTest000",
#  "accessLevel": "PRIVATE",
#  "caPassword": null,
#  "validationStatus": null,
#  "password": null,
#  "overwrite": null,
#  "exportPrivateKey": null,
#  "exportSSHPublicKey": null,
#  "signAlgorithm": "SHA256WITHRSA",
#  "additionalAttributes": {},
#  "metadata": {
#    "links": {
#      "self": "https://dogco.axway.university:8444/api/v2.0/certificates/4028b8ce889c092201889cb432600025"
#    }
#  }
#}
