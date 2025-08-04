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
# V1.2 Ian Percival  06-Jun-2023 General Cleanup
#                                This code assumes Webservices.Admin.CsrfToken.enabled 
#                                 is set to true - which is the default after 20230529  
# V1.1 ian Percival  10-Feb-2022 Add additional parameter and better http_status
# V1.0 Ian Percival  14-Aug-2020
#
# Curl command to add a certificate in SecureTransport
#
#
# A config file is used as input to define the base URL
#
# It is assumed a session login took place prior to this via ./stLogin.sh
#  Session cookies are read from a file called myCookie.jar...
#
# Inputs:
#          url = api base uri of format https://<servername>:port/apis/v2.0
#          mycookie.jar file
#          valid csrfToken
#
# ssh-keygen -t rsa -b 2048 -f stCreateSSHCertificate
# ssh-keygen -e -f stCreateSSHCertificate.pub > stCreateSSHCertificate.pem
source ../../config
CSRFTOKEN=$(cat csrf.token)
#
result=$(curl  -i -L -b myCookie.jar -s -k -w "%{http_code}" -X POST "$url/certificates" -H "csrfToken: $CSRFTOKEN" -H "accept: application/json" -H "Referer: Ian" -H "Content-Type: multipart/mixed; boundary=demoBoundary" --data-binary @stImportSSHPublicKey.multi)
#http_status=$(echo $result | grep HTTP | awk '{print $2}')
#
http_status=${result: -3}                  # remove the last 3 characters ie the http status
json=$(echo ${result} | head -c-4 )        # all but the last 3 chars
# Note: HTTP 100 will be returned first...
#       Then the final status is returned.
if [[ $http_status -ne 200 ]] ; then
        echo "Create SSH Certificate failure: $http_status"
        echo $json
        exit
fi
echo $json

# Certificate Object is returned
#  { "id" : "8a01ba0174b1260c0174c171193a3320", 
#    "name" : null, 
#    "subject" : "CN=SSHKeyTest999, OU=, O=, C=US", 
#    "type" : "ssh", 
#    "usage" : "login", 
#    "expirationTime" : "Sat, 24 Sep 2022 20:47:28 +0200", 
#    "creationTime" : 1600973248000, 
#    "fingerprint" : "0x8BE5801F88B3293270FB22613114BFAF", 
#    "keyAlgorithm" : null, 
#    "issuer" : null, 
#    "serialNumber" : null, 
#    "keySize" : null, 
#    "version" : 3, 
#    "validityPeriod" : 730, 
#    "account" : "AxwayTest999", 
#    "accessLevel" : "PRIVATE", 
#    "caPassword" : null, 
#    "validationStatus" : "Valid", 
#    "password" : null, 
#    "overwrite" : null, 
#    "exportPrivateKey" : null, 
#    "exportSSHPublicKey" : null, 
#    "signAlgorithm" : "SHA256withRSA", 
#    "metadata" : { "links" : { "self" : "https://10.129.58.129:8444/api/v2.0/certificates/8a01ba0174b1260c0174c171193a3320" } } }
