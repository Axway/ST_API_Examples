#!/usr/bin/sh
#
# V1.0 Ian Percival  12-Jun-2022
#
#
# Curl command to create an account in SecureTransport
#
#
# A config file is used as input to define the base URL
#
# It is assumed a session login took place prior to this via ./stLogin.sh
#  Session cookies are read from a file called myCookie.jsr...
#
# NOTE if you are only creating a subset of objects - ST responds with HTTP 100
#
#  openssl req -x509 -newkey rsa:2048 -keyout keyx509.pem -out certx509.pem -days 720
source ../../config
#
# 
result=$(curl -s -u admin:admin -k -w "%{http_code}" -X POST 'https://fm1:8444/api/v2.0/accountSetup' \
-H 'Referer: Ian' \
-H 'Content-Type: multipart/mixed; boundary=demoBoundary' \
--data '--demoBoundary
Content-Type: application/json

    {"accountSetup":
      {
        "account": {
            "type": "user",
            "name": "AxwayTest999",
            "homeFolder": "/usrdata/BU/clients/AxwayTest999",
            "uid": "7001",
            "gid": "7000",
            "notes": "Created By AccountSetup API",
            "businessUnit": "clients",
            "user": {
                "name": "AxwayTest999",
                "authExternal": false,
                "passwordCredentials": { "password": "axway",
                                       "forcePasswordChange": false
                                      }
            }
          },
        "certificates": {
            "login": [
                {
                  "type": "ssh",
                  "alias": "floki",
                  "validity": 1000,
                  "accessLevel": "PRIVATE",
                  "account": "AxwayTest999",
                  "generate": false,
                  "subject" : "EMAILADDRESS=no-reply@axway.int, CN=floki, OU=Axway University, O=Axway, L=PHX, ST=AZ, C=US",
                  "keyName":"flokiskey"}
            ]
        }
    }
  }

--demoBoundary
Content-Type: application/octet-stream
keyName: flokiskey

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/gE66qlwhvCO2GebsAZy/nxMpiXpX7K3daFhvhS30zM+QIEIO7n8tBv6aM4LtQS5D1gLxDJSZnp+K2CkCv8lOb7PiXuvHZD4ZnpQpMAoM2VjGwbw+pRXTt75SrXGkB43MNgpyiPlRgvW5GY0YRLAZEU73x3O6TXEtxIaF/O2Bk9/wYas4G1djNnphIepyQkQ4h+ERS36kAcYYPkBdxDk8e+doiXrD0OhcDjGJ/0EU5LhhVUL66AM47/Xx2RggSONQC92+oDzIj71txdvpM96VP43b83F3kCKz7RkYiTDXgqMuY/nLIOAkklx5Jdq7uGZieuZlcajjRA89gM9n2LJH pippin@SL3CSOAPP3237
--demoBoundary--
')
http_status=${result: -3}               # remove all but the last 3 characters
json=$(echo ${result} | head -c -4)     # return all but the last 3 characters
#
if [[ $http_status -ne 100 ]] ; then
    if [[ $http_status -ne 200 ]] ; then
        echo "Create Account failure: $http_status"
        echo $json
        exit
    fi
fi
echo $json
# 


