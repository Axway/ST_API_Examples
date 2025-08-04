#!/usr/bin/sh
#
# V1.0 Ian Percival  20-Oct-2020
#
# Pre-Requisite: login to /myself to initiate session management cookies.
#
#                Require Template Route ID
#                Require Subscription ID
#                Require Simple ROute ID
#
source ../../config
#

result=$(curl -v -k -i -L -b myCookie.jar -s -X POST "$url/accountSetup" \
-H "Referer: Ian" \
-H "Content-Type: multipart/mixed; boundary=demoBoundary" \
--data '--demoBoundary
Content-Type: application/json

    {"accountSetup":
      {
        "account": {
            "type": "user",
            "name": "AxwayTest999",
            "homeFolder": "/usrdata/NoBU/AxwayTest999",
            "uid": "7001",
            "gid": "7000",
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
                  "alias": "mykey",
                  "validity": 666,
                  "accessLevel": "PRIVATE",
                  "caPassword": "Axway123",
                  "account": "AxwayTest999",
                  "generate": false,
                  "subject" : "EMAILADDRESS=no-reply@axway.int, CN=pippin, OU=Axway University, O=Axway, L=PHX, ST=AZ, C=US",
                  "keyName":"mykey"}
            ]
        },
        "sites": [
                  {
                    "type": "ssh",
                    "name": "PippinCatSSH1",
                    "host": "fm1",
                    "account": "AxwayTest999",
                    "accessLevel": "PUBLIC",
                    "port": "22",
                    "protocol": "ssh",
                    "uploadFolder": "/tmp",
                    "dmz": "none",
                    "transferType": "internal",
                    "usePassword": true,
                    "password": "axway",
                    "userName": "axway"
                  }
                 ],
        "subscriptions": [
                          {
                           "type": "AdvancedRouting",
                           "application": "AdvRouting",
                           "folder": "/inbound",
                           "account": "AxwayTest999",
                           "transferConfigurations": [
                                                      {
                                                       "tag": "PARTNER-IN",
                                                       "outbound": false
                                                      }
                                                     ], 
                         "postProcessingActions": {
                                                   "ppaOnSuccessInDoDelete": true
                                                  }
                         }
                         ],
        "routes": [
                    {
                      "name": "CompositeRoute1",
                      "type": "COMPOSITE",
                      "routeTemplate": "4028b8b37f7e586b017f7fa1047a0045",
                      "account": "AxwayTest999",
                      "conditionType": "MATCH_ALL"
                    }
                  ]  
    }            
  }

--demoBoundary
Content-Type: application/octet-stream
Content-Disposition: attachment;
keyname: mykey
encoded: false

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDB7nWsckERFOg2xJclW6yNaPZTZ0xZzn4vHTWckWJ/qy39p5HV3nu3B2a/HbF9leHgbrBUBAkrlnIZWs89zJMj720ZatNW+Q/tMgngoXBC/sWdH/NONe0ddmIPwN7FsZgnRQMLrOUqafQBoy7wxV5T0LzaEU0hnksw6vuqNnE91Wu9L9ydCnoUVWzWgF4xHpCmcCswND2tDpHqJYFUPeyROZZEHWUvw/3PjiDaUXXb7hLie4IanlpkEbwxF707xFhluv6/YJ4TrWEuTWhUk3GIJDjcibZHvGFM7i5ecYso1R/Agz8MlYb2PFKwHVSJ+AjYZPABNnqIbDIcL/qZyU6V axway@SLNXPHXSHVRA251
--demoBoundary--')
http_status=$(echo $result | grep HTTP | awk '{print $2}')
#
if [[ $http_status -ne 100 ]] ; then
        echo "Create Account failure: $http_status"
        echo $result
        exit
fi
echo $result


