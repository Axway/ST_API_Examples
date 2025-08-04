#!/usr/bin/sh
#
# V1.0 Ian Percival  2-May-2021
#
# Pre-Requisite: login to /myself to initiate session management cookies.
#
#                Require Template Route ID
#                may require SSH Certificate ID if using key based auth
#                Require Subscription ID
#                Require Simple ROute ID
#
source ../../config
#

result=$(curl -v -k -i -L -b myCookie.jar -s -X POST "$url/accountSetup" \
-H "Referer: Ian" \
-H "Content-Type: multipart/mixed; boundary=Boundary_26_1846123377_1620061399353" \
-d '--Boundary_26_1846123377_1620061399353
Content-Type: application/json

{
  "accountSetup" : {
    "account" : {
      "type" : "user",
      "name" : "PippinCat",
      "homeFolder" : "/usrdata/NoBU/PippinCat",
      "lastModified" : null,
      "homeFolderAccessLevel" : "PRIVATE",
      "uid" : "7001",
      "gid" : "7000",
      "mappedUser" : null,
      "disabled" : false,
      "skin" : "Default HTML Template",
      "notes" : null,
      "unlicensed" : false,
      "authByEmail" : false,
      "businessUnit" : null,
      "loginRestrictionPolicy" : null,
      "contact" : {
        "email" : null,
        "phone" : null
      },
      "isUnlicensedUserAllowedToReply" : true,
      "accountCreationDate" : 1620052608784,
      "transfersWebServiceAllowed" : false,
      "accountEncryptMode" : "UNSPECIFIED",
      "fileArchivingPolicy" : "DEFAULT",
      "transferType" : "N",
      "routingMode" : "reject",
      "accountSubmitForApprove" : null,
      "rejectReason" : null,
      "accountVerificationStatus" : null,
      "user" : {
        "name" : "PippinCat",
        "authExternal" : false,
        "locked" : false,
        "failedAuthAttempts" : 0,
        "failedSshKeyAuthAttempts" : 0,
        "failedAuthMaximum" : 3,
        "failedSshKeyAuthMaximum" : 3,
        "lastFailedAuth" : null,
        "lastFailedSshKeyAuth" : null,
        "lastLogin" : "Mon, 03 May 2021 16:59:08 +0200",
        "successfulAuthMaximum" : null,
        "successfulLogins" : 1,
        "secretQuestion" : {
          "secretQuestion" : null,
          "secretAnswerGuessFailures" : 0,
          "forceSecretQuestionChange" : false
        },
        "passwordCredentials" : {
          "password" : null,
          "passwordDigest" : "XqNhW2W8zxPDhzqMATYDlQ2tVt9atbsXDTDxyTFNuaXjvAiofj927ln+Dn0oms829Clw55cruZJ4GsAM+I8YWObyQEtpSNsh2pusBrW7vphovh1B4D0LVIyNca2NQlTl0BcL3b6NgsO45mxkbSoEAX3+ITqgMPxhj089Aqe3eF4zMe9ZNlWvJq7c3mjzkCy+Esn2DijQlaMekgKq0ndj02dIGu4Vohs7ZsJR1m94Ij/5jq/yggZIAVSJdAfrw5jo4yVJtP9IAluWPJTV/X44FP0ZxZF9722gEiD5WjKS2FiAb+C6V4MIkqJM2jxFLtiy9vht2VhD3/hicRU5PlYMPw==",
          "forcePasswordChange" : false,
          "lastPasswordChange" : "Mon, 03 May 2021 16:36:49 +0200",
          "lastOwnPasswordChange" : null,
          "passwordExpiryInterval" : null
        }
      },
      "fileMaintenanceSettings" : {
        "policy" : "default",
        "deleteFilesDays" : null,
        "pattern" : null,
        "expirationPeriod" : null,
        "removeFolders" : null,
        "warningNotifications" : null,
        "warnNotifyAccount" : null,
        "warningNotificationsTemplate" : null,
        "notifyDays" : null,
        "sendSentinelAlert" : null,
        "deletionNotifications" : null,
        "deletionNotifyAccount" : null,
        "deletionNotificationsTemplate" : null,
        "reportNotified" : null,
        "warnNotified" : null
      },
      "bandwidthLimits" : {
        "policy" : "default",
        "inboundLimit" : null,
        "outboundLimit" : null
      },
      "additionalAttributes" : { }
    },
    "certificates" : {
      "private" : [ {
        "type" : "ssh",
        "alias" : "PippinPrivateKey",
        "keySize" : 2048,
        "validity" : 777,
        "keyName" : "PippinPrivateKey",
        "accessLevel" : "Private",
        "account" : "PippinCat",
        "certificatePassword" : null,
        "generate" : false,
        "caPassword" : null,
        "signatureAlgorithm" : "SHA256WITHRSA",
        "subject" : "C=US, ST=AZ, L=PHX, O=Axway, OU=Kitten, CN=cats.rule, EMAILADDRESS=no-reply@axway.int"
      } ]
    },
    "sites" : [ {
      "type" : "ssh",
      "name" : "FlokiCatSSH1",
      "account" : "PippinCat",
      "protocol" : "ssh",
      "transferType" : "internal",
      "maxConcurrentConnection" : 0,
      "default" : false,
      "accessLevel" : "PRIVATE",
      "fingerPrint" : null,
      "verifyFinger" : false,
      "host" : "10.129.128.2",
      "port" : "22",
      "alternativeAddresses" : [ ],
      "downloadFolderAdvancedExpressionEnabled" : false,
      "downloadFolder" : null,
      "downloadPatternAdvancedExpressionEnabled" : false,
      "downloadPattern" : null,
      "uploadFolder" : null,
      "uploadFolderOverridable" : false,
      "userName" : "FlokiCat",
      "usePassword" : false,
      "usePasswordExpr" : null,
      "password" : null,
      "clientCertificate" : "8a010082791941bc017932a9084f0424",
      "transferMode" : "AUTO_DETECT",
      "fipsMode" : false,
      "dmz" : "none",
      "socketTimeout" : 300,
      "socketBufferSize" : 65536,
      "socketSendBufferSize" : 65536,
      "downloadPatternType" : "glob",
      "uploadPermissions" : null,
      "bufferSize" : 32768,
      "blockSize" : 32768,
      "tcpNoDelay" : false,
      "cipherSuites" : "aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com",
      "fipsCipherSuites" : "aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com",
      "protocols" : null,
      "allowedMacs" : "hmac-sha256,hmac-sha256@ssh.com,hmac-sha2-256,hmac-sha2-256-etm@openssh.com,hmac-sha512,hmac-sha512@ssh.com,hmac-sha2-512,hmac-sha2-512-etm@openssh.com",
      "fipsAllowedMacs" : "hmac-sha256,hmac-sha256@ssh.com,hmac-sha2-256,hmac-sha2-256-etm@openssh.com,hmac-sha512,hmac-sha512@ssh.com,hmac-sha2-512,hmac-sha2-512-etm@openssh.com",
      "keyExchangeAlgorithms" : "diffie-hellman-group-exchange-sha256,diffie-hellman-group14-sha256,diffie-hellman-group15-sha512,diffie-hellman-group16-sha512,diffie-hellman-group17-sha512,diffie-hellman-group18-sha512,rsa2048-sha256,ecdh-sha2-nistp384",
      "fipsKeyExchangeAlgorithms" : "diffie-hellman-group-exchange-sha256,diffie-hellman-group14-sha256,diffie-hellman-group15-sha512,diffie-hellman-group16-sha512,diffie-hellman-group17-sha512,diffie-hellman-group18-sha512,rsa2048-sha256,ecdh-sha2-nistp384",
      "publicKeys" : "ssh-rsa,x509v3-rsa2048-sha256,rsa-sha2-256,rsa-sha2-512",
      "fipsPublicKeys" : "ssh-rsa,x509v3-rsa2048-sha256,rsa-sha2-256,rsa-sha2-512",
      "postTransmissionActions" : {
        "doAsOut" : null,
        "deleteOnTempFailOut" : null,
        "moveOnTempFailOut" : null,
        "deleteOnPermFailOut" : null,
        "moveOnPermFailOut" : null,
        "moveOnSuccessOut" : null,
        "doMoveOverwriteOut" : null,
        "doAsIn" : null,
        "deleteOnPermFailIn" : null,
        "moveOnPermFailIn" : null,
        "deleteOnSuccessIn" : null,
        "moveOnSuccessIn" : null,
        "doMoveOverwriteIn" : null
      }
    } ],
    "transferProfiles" : [ ],
    "routes" : [ {
      "name" : "CompositeRoute1",
      "description" : null,
      "type" : "COMPOSITE",
      "routeTemplate" : "8a010082791941bc01792cb6c50b01e4",
      "account" : "PippinCat",
      "condition" : null,
      "conditionType" : "MATCH_ALL",
      "failureEmailNotification" : false,
      "failureEmailTemplate" : null,
      "failureEmailName" : null,
      "successEmailNotification" : false,
      "successEmailTemplate" : null,
      "successEmailName" : null,
      "triggeringEmailNotification" : false,
      "triggeringEmailName" : null,
      "triggeringEmailTemplate" : null,
      "businessUnits" : [ ]
    } ],
    "subscriptions" : [ {
      "type" : "AdvancedRouting",
      "folder" : "/toPippinUnix",
      "account" : "PippinCat",
      "application" : "AdvRouting",
      "maxParallelSitPulls" : null,
      "flowAttrsMergeMode" : null,
      "folderMonitorScheduleCheck" : null,
      "flowName" : null,
      "scheduledFolderMonitor" : null,
      "flowAttributes" : { },
      "schedules" : [ ],
      "transferConfigurations" : [ {
        "site" : null,
        "tag" : "PARTNER-IN",
        "outbound" : false,
        "dataTransformations" : [ ],
        "transferProfile" : null
      } ],
      "subscriptionEncryptMode" : "DEFAULT",
      "postClientDownloads" : {
        "postClientDownloadActionType" : null,
        "postClientDownloadActionTypeFailure" : null,
        "postClientDownloadTypeOnFailDoAdvancedRouting" : null,
        "postClientDownloadTypeOnFailDoAdvancedRoutingProcessFailedFile" : null,
        "postClientDownloadTypeOnPermfailDoDelete" : null,
        "postClientDownloadTypeOnSuccessDoAdvancedRouting" : null,
        "postClientDownloadTypeOnSuccessDoAdvancedRoutingProcessFile" : null
      },
      "postProcessingActions" : {
        "ppaOnFailInDoDelete" : null,
        "ppaOnFailInDoMove" : null,
        "ppaOnSuccessInDoDelete" : null,
        "ppaOnSuccessInDoMove" : null
      },
      "postTransmissionActions" : {
        "moveOverwrite" : null,
        "ptaOnPermfailDoAdvancedRouting" : null,
        "ptaOnPermfailInDoAdvancedRoutingFailedFile" : null,
        "ptaOnPermfailInDoAdvancedRoutingWildcardPull" : null,
        "ptaOnPermfailInDoDelete" : null,
        "ptaOnPermfailInDoMove" : null,
        "ptaOnPermfailOutDoDelete" : null,
        "ptaOnPermfailOutDoMove" : null,
        "ptaOnSuccessDoInAdvancedRoutingWildcardPull" : null,
        "ptaOnSuccessInDoDelete" : null,
        "ptaOnSuccessInDoMove" : null,
        "ptaOnSuccessInDoMoveOverwrite" : null,
        "ptaOnSuccessOutDoDelete" : null,
        "ptaOnSuccessOutDoMove" : null,
        "ptaOnSuccessOutDoMoveOverwrite" : null,
        "ptaOnTempfailInDoAdvancedRouting" : null,
        "ptaOnTempfailInDoAdvancedRoutingProcessFailedFile" : null,
        "ptaOnTempfailInDoAdvancedRoutingWildcardPull" : null,
        "ptaOnTempfailInDoDelete" : null,
        "ptaOnTempfailInDoMove" : null,
        "ptaOnTempfailOutDoDelete" : null,
        "ptaOnTempfailOutDoMove" : null,
        "submitFilenamePatternExpression" : null,
        "submitFilterType" : null,
        "triggerFileOption" : "fail",
        "triggerFileRetriesNumber" : 0,
        "triggerFileRetryDelay" : 0,
        "triggerOnConditionEnabled" : null,
        "triggerOnConditionExpression" : null,
        "triggerOnSuccessfulWildcardPull" : null
      }
    } ]
  }
}
--Boundary_26_1846123377_1620061399353
keyName: 8a010082791941bc017932a909140426
encoded: true
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="8a010082791941bc017932a909140426.asc"

LS0tLS1CRUdJTiBQR1AgUFVCTElDIEtFWSBCTE9DSy0tLS0tClZlcnNpb246IEJDUEcgRklQUyAxLjAuMgoKbVFFTkJHQ05zbjhCQ0FEQzJmUFIwTnV5Y1d3ME5GYXJIZ0QvWGx0TG9CVVllUnYwdGg2TE1GMjAvb3g0Q01JUwpnWDBqYk8yQ24zVzIwTXh4ZmRGUkNQTm9HQWdqVkZIWG9lUXRZNndOMFFqWnpzVE9WTzJSR1lHRnF2ckRZcWM4ClpIL0hIOWw2ODdmeUZZdlFWNWVLUTJSYldSb2RpZm8rNjExTVpSQ3pKL0VUd0J3cVl0dlgvVGtlNlR0TEhRM2MKT3FldHpGcDdzQms1QUR1YU01V0RGU1lpL2RhK1Z3R0sreGNBczNRdlBnSW96YjJsS3g5V084TUxiZlFaSGUzRQo5bGNGTjYwRWdpZmpxNGtiQ29mR0ZhTDJmK2Z0WHlITGZuTkVTNmxUZTY2dzZwYU14WWR4ZEduODZMamV1RUQ5CnpNQmNrZlFROU9LajFpWlVrclVaYXV2cnM2eXZZd2crTTFKNUFCRUJBQUcwSFZCcGNIQnBiaUE4Y0dsd2NHbHUKUUdOaGRITjNiM0pzWkM1amIyMCtpUUZPQkJNQkNBQTRGaUVFTVBabTh1Y0dkSXNQSXMvbTl0T0FPOVl6bUJBRgpBbUNOc244Q0d3TUZDd2tJQndJR0ZRb0pDQXNDQkJZQ0F3RUNIZ0VDRjRBQUNna1E5dE9BTzlZem1CQmJTUWdBCnNtVWhRWEdnWXVPbWZ6bThDWkdBR1QydVowSGs1TW9vUEtuZFFvdXMzQ280MzAyQ2V1ZnBVcWpJT3dzMTNnRGsKUzhBdU1Gc3R4M3FOMXh4QU9sYW9MQnpKU3o5RjR0NytwSm5qSzlFNjl5d0wzbUptTkpQMXIvbHN2SEFldUZFawp0OU1vb1lSYWh5dDNRM2VCd1BhQ2VEL1prVTdRc1lJVjRkQVcxdk9uRXR1RWMzNFRCYUo3Zm9qdmU0WHhhMVZmCkE3cG84dm9rSEhadW1JcGRQQmFYdGlOQ3h0UnhPc1FFMGl5U05iUlBwZ2QvYjZFcnJSblJ2UXRSZnRESmh4bzcKQzNyOFltU1daUmVIRmEyUlVlYlJoOXBLQys0MEhCenRPM1UyZ0pwSnZkeWoxVUVDL2NJak5OWTMrTzJSbXZOUQpRaXNGTWl6Q2k3VXJBc3Erd0RRZFJia0JEUVJnamJKL0FRZ0F6VGNzUTh4TnJCcXZkLytDUUNRM0VjSDFuazJqCmhZQUI0bjRNUFluc0p3eUlXbmtGYXZ3eW5oYVFOZ3NKVWw2a2VOUXhtbUNiYXdDUTlwVFV2OXRTTmhYT0RUZkUKTzl4d043eTRETGxCd2RGZU9ob0NHZmdIQktSQlAyYUhaRWlyZkhiUG1vb3JhamRudklUWDZaelBGV1FnbzEzQgptVGVSc0dwRFRUbFlqR2ZnWnhKVCtneVhnVzh4NzJDZUtoZ256SkdiVzFJR0N3YzFGYy9zZVB2ZmV1TjNldlVnCmRuVVFZTUpDYnFJZHZDOVViN0Y4WURTNjcyK0pvRU1ScWp3N2dEcUZkM0l4T0kwVEFSbjR5NWs4SXZVdFc4VS8KRFcwSmtmZ0hGaW9BQ20vWWdzazZDbHk3YUVvWGZKbHdUaWZ2amtBb2FlVmFrRDU5L0hybVRCK2gvd0FSQVFBQgppUUUyQkJnQkNBQWdGaUVFTVBabTh1Y0dkSXNQSXMvbTl0T0FPOVl6bUJBRkFtQ05zbjhDR3d3QUNna1E5dE9BCk85WXptQkNTRVFmL1NTUGNXeWJEb0FSNGtmWWlYaWtHajdFL1d5NGx1V1F3OHUvSE9FSXZhaThBTGhHRUFZeVgKNUZjM2duaUczQWlmNFpTbEJiNnE0dUd0QWpNK2MzNzF5TlR1TlJudm1lYlQ2MjcvOGdEb1RzR3NWZWgydy95UApLUGtrN0l6VHkyS2NEYlVocU9LY3NSZ2RzSFc0THNoYUNtR29lVGtOTUVlY2FJWWlnZHhJU1gzeGEwNnFmNk5PCklqOEdyRFJUUisrcDFlSitVS0FHN3Jrc09lbnU5N3I0eXBRdDU2MTZzL0NYMVY4RVhhTlVNeWdqMDFlckhjWFQKTFd6c3FXVkhlTUw2WHNTVXNEZTF5Y3JnaFZNQzUrUkZHV2w0b3dyZ1pUdElUVWZrbGlYYkgyNTlrQmRlcVBMKwoydnU3M1ZFajFIQ2dzM3JrYnliUjZKekVERVZpMDdOeW9RPT0KPVhRcU0KLS0tLS1FTkQgUEdQIFBVQkxJQyBLRVkgQkxPQ0stLS0tLQoNCi0tLS0tQkVHSU4gUEdQIFBSSVZBVEUgS0VZIEJMT0NLLS0tLS0KVmVyc2lvbjogQkNQRyBGSVBTIDEuMC4yCgpsUVBHQkdDTnNuOEJDQURDMmZQUjBOdXljV3cwTkZhckhnRC9YbHRMb0JVWWVSdjB0aDZMTUYyMC9veDRDTUlTCmdYMGpiTzJDbjNXMjBNeHhmZEZSQ1BOb0dBZ2pWRkhYb2VRdFk2d04wUWpaenNUT1ZPMlJHWUdGcXZyRFlxYzgKWkgvSEg5bDY4N2Z5Rll2UVY1ZUtRMlJiV1JvZGlmbys2MTFNWlJDekovRVR3QndxWXR2WC9Ua2U2VHRMSFEzYwpPcWV0ekZwN3NCazVBRHVhTTVXREZTWWkvZGErVndHSyt4Y0FzM1F2UGdJb3piMmxLeDlXTzhNTGJmUVpIZTNFCjlsY0ZONjBFZ2lmanE0a2JDb2ZHRmFMMmYrZnRYeUhMZm5ORVM2bFRlNjZ3NnBhTXhZZHhkR244NkxqZXVFRDkKek1CY2tmUVE5T0tqMWlaVWtyVVphdXZyczZ5dll3ZytNMUo1QUJFQkFBSCtCd01DK1pWM1VUeGdWV0ZnQTFBcAovLzlwcHZCN21IYlpRdTU1cW5DWlRpLzFIN3JPaU50dmVySmVQMTVuWTJIUS8waUxrcWR3RWFtWHFSSDgxaHhCCjRDNllQMnIzdkU4Y1dyaHgwNFNYQmpzU3VtbUFFd2VkTlhLSTFvQVE0S0hpYnlsRXk1YWluRldLWWtnbGplSnoKMXhQQ2Nzc2JrL1BpOXBIQmgyVUQ4Q2krNkRKNnVQeGd1TnlFbkJORVdoNDBRSGd1SGt0UEdYTllKSVlyODlrdwo2QTlSYXJNdWhBM3JTcllTMU02SFIvbVN3eE94QmZoRW5aTXZOTWVrNnJOMXl1TzFlbFVBSVNIYkE5RGxoc1NtCkM1ajE1QitXUEFBc1hVQXI5bEhYdHJhVHFBWjBpelBOUzVOWklVVm5tVHBUODVZRzF2RDVLdzVWaTV5dmRJMGsKb3lSOGRTbW5IRnJ1blNIakt4Mm5YTjVMb1VsbDdYc00yaHpISlJyVHFmaXJ6SzlQWGJrUnRjQU9Da2lRL1ExTApoaFBzaU1kbzNPU2VhUUJOSjFhVmpISHVHUFk3TXRDYVlsdU5pTktyeTZFcDhFNVE0VFNobndwZkg2WUpkd2hUClNoRElQQ2FlZmhhRjVmU3d0eVM2Ym5Na3A1MlB6engrVTRWeEVad1FTMStzZC9Xd2lKcFRkZUZhVkNoN3FwdVUKa0NxU3o2TVVsY2FYWVNldUw4cXZQZTR3YU5GZWRWaHpySVFsMllzd2ZzeUM0dTVRQW0wajlyL2hxY3F2TFhjRwpaYndOUmhmNFBFa2tRZkZkcUNWQ0p2MVV5bEh0UjZWbVdKb2I4OTloRiswRkgxbVN1QS9xQWVISzBBTTA1RWc3CmtFNU9lRk50aXVPdS9mWHY0VzkxRWljVG80TDUzVTJWUER0QUU0MHdwUnEzd1MwUmxLTHZEa0IycFE4VVJtYUkKbjBxcGpjUGRubU1ZUGo0WE1vaVhUYVd6UjI2MUgyVFRLK1J5RUM4OW9oaHZqR0drRjh1WEJMUm5sZ2hZMDZweApaTTdYbFIwMy9hMzZ4U0x4MEpaM3drNzY2L2tpemRzQW1EcWlma1BZWGg3b3V5S0VrUGxRdGFBTkcxaHlZUGFiCklZSTY5cGpPVVhvS0FHNmxsakNkT1NRUVduQlZhbEJzczlsYXRWWmtqdnBXVjM0WE5KamQrcU1MbWpVNm5pODYKdm1MQ3RHOVVCc0hBdEIxUWFYQndhVzRnUEhCcGNIQnBia0JqWVhSemQyOXliR1F1WTI5dFBva0JUZ1FUQVFnQQpPQlloQkREMlp2TG5CblNMRHlMUDV2YlRnRHZXTTVnUUJRSmdqYkovQWhzREJRc0pDQWNDQmhVS0NRZ0xBZ1FXCkFnTUJBaDRCQWhlQUFBb0pFUGJUZ0R2V001Z1FXMGtJQUxKbElVRnhvR0xqcG44NXZBbVJnQms5cm1kQjVPVEsKS0R5cDNVS0xyTndxT045Tmducm42VktveURzTE5kNEE1RXZBTGpCYkxjZDZqZGNjUURwV3FDd2N5VXMvUmVMZQovcVNaNHl2Uk92Y3NDOTVpWmpTVDlhLzViTHh3SHJoUkpMZlRLS0dFV29jcmQwTjNnY0QyZ25nLzJaRk8wTEdDCkZlSFFGdGJ6cHhMYmhITitFd1dpZTM2STczdUY4V3RWWHdPNmFQTDZKQngyYnBpS1hUd1dsN1lqUXNiVWNUckUKQk5Jc2tqVzBUNllIZjIraEs2MFowYjBMVVg3UXlZY2FPd3Q2L0dKa2xtVVhoeFd0a1ZIbTBZZmFTZ3Z1TkJ3Ywo3VHQxTm9DYVNiM2NvOVZCQXYzQ0l6VFdOL2p0a1pyelVFSXJCVElzd291MUt3TEt2c0EwSFVXZEE4WUVZSTJ5CmZ3RUlBTTAzTEVQTVRhd2FyM2YvZ2tBa054SEI5WjVObzRXQUFlSitERDJKN0NjTWlGcDVCV3I4TXA0V2tEWUwKQ1ZKZXBIalVNWnBnbTJzQWtQYVUxTC9iVWpZVnpnMDN4RHZjY0RlOHVBeTVRY0hSWGpvYUFobjRCd1NrUVQ5bQpoMlJJcTN4Mno1cUtLMm8zWjd5RTErbWN6eFZrSUtOZHdaazNrYkJxUTAwNVdJeG40R2NTVS9vTWw0RnZNZTlnCm5pb1lKOHlSbTF0U0Jnc0hOUlhQN0hqNzMzcmpkM3IxSUhaMUVHRENRbTZpSGJ3dlZHK3hmR0EwdXU5dmlhQkQKRWFvOE80QTZoWGR5TVRpTkV3RVorTXVaUENMMUxWdkZQdzF0Q1pINEJ4WXFBQXB2MklMSk9ncGN1MmhLRjN5WgpjRTRuNzQ1QUtHbmxXcEErZmZ4NjVrd2ZvZjhBRVFFQUFmNEhBd0tlTHZVVkQyMlVnMkJzY2k3Q1V0WXNqMkh6Cmh4WjFuOHFSZVVLY0FkWSsrZFdYWjYrQUh2bUdDRVJzRVowcEFBallPbGhsaXBScGFPS2hvWFRKbHd2L0pHSzYKWWROVGZCQmJBbXJyNVZZdmZCWkx6WStRK1kvT2pUcnJnR0pyRS9rSTQ1Z24zUjA4bjBCNkUxWVZ2TUpxeWdMeApRUFNtZGNOcDllL1BjU1lhWGYya1pnVG5iQ1VoZTdESStaYmxEWmdEZ1ZEQXFvRERLa3VTZzBDd3J6ZDBkSzJmCnpzMGdtK1V2TUVMaFl0WUxiNXFhVFpjMUM4c3psMUlKYkIwNDhmc3hlUnovTmMyaE4wc1V6am04QVRQNEtDR0kKaEVQZHloL2Y3Um10cURwS1dYQW9UeHYvTnBiY2p1T0gxckZZbTMvU2pmUzV6dGlHOXc1WngvU1MzNSs2dmo3dwowNlVYbTR6K0NuUGsyaFA0MWdOS2taMW5DYWpKbk1RK0p3dG9mM3RDRjF4Tm9EMVk4ZWRZYThCUEdmZUNCQ0k5CjV2ZXgydHZTcXpGUEtUVE1WdlVnd0ZCQmFMZWhXWjJmcXZJT2ZDNUZGMEVBWHoxRTlJRXYzMVZTY1BQaWxxMTIKTHdVY2FyMXVrb3NxTlJ4a2ovSUlsdzNmeFI2cmVtZ0FMOTlnU0kyVGIrMU1KcnJHR2dTWHRVdFJHZlI0RitWbwp3cjFHSzJ5cUhXQnhPRGhLK3ZZazBQY0R6Y3VOeERxN3lEeWJqd2ZhcGtBYXh5SmhkOW9FN1JsLzhzR2ZaMnhxCldGbm1HdFZwK2QxeXRkeEQ5ejVIMXErZDE0d3dhaURnb0dqckhsaXB4WElZbmhVQ0RTdzdzTFhBZlY4TUtvdlIKS0IwS0tHbkh0bW41a2FRNSsrOTh0OGVDQ2U3RUc4MnJiZzV0RXVqVVozenFoQTNxYVVESjBXUjdVZEFWeUIwRgo2Ynk4b2F0azBsZmdPbWlxR3dtRVhrMVJPZVlMU21RcHk1QXpjOFcwSkozZTZJbE5oMDAvZXl3TG1tZGFzakp5Cm5IazBkbjNGU0h2Ky9XNWZ2a3AyOGF4b2xaZEkvSFFRVXhRclBtc2VwaGpzQStxaDdoTmsxcmRwRjNMYndTTk8KTFlpZFRSaGVsYmNJdjFOMkZiVS9iVk0zaHorVG9MRWh1TzBZTXE3RFdnTFFxWUhlM2lZaU5SK2RCRGVNVmJOQQpTVStKQVRZRUdBRUlBQ0FXSVFRdzltYnk1d1owaXc4aXorYjIwNEE3MWpPWUVBVUNZSTJ5ZndJYkRBQUtDUkQyCjA0QTcxak9ZRUpJUkIvOUpJOXhiSnNPZ0JIaVI5aUplS1FhUHNUOWJMaVc1WkREeTc4YzRRaTlxTHdBdUVZUUIKakpma1Z6ZUNlSWJjQ0ovaGxLVUZ2cXJpNGEwQ016NXpmdlhJMU80MUdlK1o1dFByYnYveUFPaE93YXhWNkhiRAovSThvK1NUc2pOUExZcHdOdFNHbzRweXhHQjJ3ZGJndXlGb0tZYWg1T1Ewd1I1eG9oaUtCM0VoSmZmRnJUcXAvCm8wNGlQd2FzTkZOSDc2blY0bjVRb0FidXVTdzU2ZTczdXZqS2xDM25yWHF6OEpmVlh3UmRvMVF6S0NQVFY2c2QKeGRNdGJPeXBaVWQ0d3ZwZXhKU3dON1hKeXVDRlV3TG41RVVaYVhpakN1QmxPMGhOUitTV0pkc2ZibjJRRjE2bwo4djdhKzd2ZFVTUFVjS0N6ZXVSdkp0SG9uTVFNUldMVHMzS2gKPTdoZ08KLS0tLS1FTkQgUEdQIFBSSVZBVEUgS0VZIEJMT0NLLS0tLS0K
--Boundary_26_1846123377_1620061399353
keyName: PippinPrivateKey
encoded: true
Content-Type: application/octet-stream
Content-Disposition: attachment;

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
--Boundary_26_1846123377_1620061399353--')
http_status=$(echo $result | grep HTTP | awk '{print $2}')
#
if [[ $http_status -ne 100 ]] ; then
        echo "Create Account failure: $http_status"
        echo $result
        exit
fi
echo $result


