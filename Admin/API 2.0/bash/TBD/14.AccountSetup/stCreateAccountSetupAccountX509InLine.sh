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
                  "type": "x509",
                  "alias": "pippin",
                  "validity": 1000,
                  "accessLevel": "PRIVATE",
                  "account": "AxwayTest999",
                  "generate": false,
                  "subject" : "EMAILADDRESS=no-reply@axway.int, CN=pippin, OU=Axway University, O=Axway, L=PHX, ST=AZ, C=US",
                  "keyName":"pippinskey"}
            ]
        }
    }
  }

--demoBoundary
Content-Type: application/octet-stream
keyName: pippinskey

-----BEGIN CERTIFICATE-----
MIID2TCCAsGgAwIBAgIIBdS5YnPjn0kwDQYJKoZIhvcNAQELBQAwgZMxCzAJBgNV
BAYTAlVTMQswCQYDVQQIEwJBWjEMMAoGA1UEBxMDUEhYMQ4wDAYDVQQKEwVBeHdh
eTEQMA4GA1UECxMHU3VwcG9ydDEkMCIGA1UEAxMbcmluY2V3aW5kLmxhYi5waHgu
YXh3YXkuaW50MSEwHwYJKoZIhvcNAQkBFhJuby1yZXBseUBheHdheS5pbnQwHhcN
MjAwNTI2MjAzMDAwWhcNMzAwNTI0MjAzMDAwWjCBkzELMAkGA1UEBhMCVVMxCzAJ
BgNVBAgTAkFaMQwwCgYDVQQHEwNQSFgxDjAMBgNVBAoTBUF4d2F5MRAwDgYDVQQL
EwdTdXBwb3J0MSQwIgYDVQQDExtyaW5jZXdpbmQubGFiLnBoeC5heHdheS5pbnQx
ITAfBgkqhkiG9w0BCQEWEm5vLXJlcGx5QGF4d2F5LmludDCCASIwDQYJKoZIhvcN
AQEBBQADggEPADCCAQoCggEBAPcEZIPALS2haX3u0bqZpJ0UqPe/HaZPAkdibCMk
F4kccF8e0tjTp25WMNHh/JQ3RLwMf+D3q3XEm30ar4mSYRiGQqZJekAL6ntsJY+3
CXcJbyiOf+BYQ3xACaDxfG1ScV3B1laWPnTCz/8qoEOQh5CO5WCFiy8iAxwv8grY
TXPpdon5OASvfxoUfZptPWWO6dWKyY91x0hc9BjmG+U2Kdnh/7FpoL21AVHutqWa
ogVEUQGRHqByXlMzrf87JmTFk2waEiT08+shMV1RzrYGHt2o3nbqtFVOI9HM2Cw0
kTnP60KNCOdZFv3AKZYrjdrc2GDE4Mb6XouRBPgbD3qlbycCAwEAAaMvMC0wCwYD
VR0PBAQDAgSwMB4GCWCGSAGG+EIBDQQRFg94Y2EgY2VydGlmaWNhdGUwDQYJKoZI
hvcNAQELBQADggEBAD7ArFB/NJ/zBj4xa2Jy9Z6jJGdQSWa9WEEKJr3LEW+wsRVO
xMfHg7rIj+w9vZ3v+Oy+IomaFRUyRwaC4cJFNRWUj9bC9gbYJjsaI5kMTdcwH/n7
lmNaoIL6bxBaZuhi50L7rKW2GlRHGv1NGMZ83HahjUH+ZLz3Q7uRsHwMxS6+e7J7
Sq/R8+4VjTqyy1N0KsBuJe13pIsiPTmApOjGXYFvuOe0i1tBj2Bx9Gy9LTrsHlMq
psNqL+kfJdAm3MykqIjC3D49mMVfgaa+JYQaF9VqvP7D4rQG+3xyLqFlPn0eupGG
bFyrkXQN5LgnjAe+c+dW5d7DHYGfvwmKv5V1yXE=
-----END CERTIFICATE-----
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


