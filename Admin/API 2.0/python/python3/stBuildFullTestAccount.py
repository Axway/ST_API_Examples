#! /usr/bin/python3
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
# V2.00 Ian Percival   21-Jun-2023   Fix errors + csrf compliant 
#                                    This code assumes that Webservices.Admin.CsrfToken.enabled is set to 'true' which is the default 
#                                    for ST after and including the 20230525 release.
# V1.00 Ian Percival   23-Nov-2021
#
# This script will Build a Single Test account on SecureTransport
#
# It is single threaded - issuing APIs in a similar way you would onboard a user process, so is useful to demonstrate
#   onboarding principles.
#
# APIs used - /myself ( ST login and logout ) POST, DELETE
#             /accounts  POST
#             /certificates POST
#             /sites POST
#             /routes GET, POST
#             /subscriptions POST
#
# Usage: python3 stBuildFullTestAccount.py
#
# Outputs:
#
#
# Start of Program is 'main' below.
#   Configuration section is there for you to tailor to your env...
#

# All functions are defined below


# This is the ST logout session management
#
# This is the ST /myself DELETE method

def stLogout(session, csrftoken):

    url = stUrl + 'myself'

    headers =  {'Referer': referer,
                'csrfToken': csrftoken,
                'Accept': 'application/json'}
    try:
        response = session.delete(url, headers=headers, verify=False, timeout=stTimeout)
    except requests.ConnectionError as ec:
        print('I cannot connect to ' + stUrl + ' ' + str(ec))
        sys.exit(1)
    except requests.exceptions.HTTPError as eh:
        print('HTTP Error')
        sys.exit(1)
    except requests.exceptions.Timeout as et:
        print('Timeout Error:' + str(et))
        sys.exit(1)
    except requests.exceptions.RequestException as e:
        print('Unknown Error: ' + str(e))
        sys.exit(1)
    else:
        apiCount.value += 1
        print('\nSession Mgt Logged Out')
        return True

        # Successful logout response

        # {
        #     "message" : "Logged out"
        # }


# Login to ST using session management
#
# This is the ST /myself POST method
#
def stLogin(basicAuth, session):

    url = stUrl + 'myself'

    authString = 'Basic ' + basicAuth

    headers = {'Referer': referer,
               'Accept': 'application/json',
               'Authorization': authString}

    try:
        response = session.post(url, headers=headers, verify=False, timeout=stTimeout)
    except requests.ConnectionError as ec:
        print('I cannot connect to ' + stUrl + ' ' + str(ec))
        sys.exit(1)
    except requests.exceptions.HTTPError as eh:
        print('HTTP Error ' + str(eh))
        sys.exit(1)
    except requests.exceptions.Timeout as et:
        print('Timeout Error:' + str(et))
        sys.exit(1)
    except requests.exceptions.RequestException as e:
        print('Unknown Error ' + str(e))
        sys.exit(1)
    else:
        apiCount.value += 1
        if response.status_code != 200:
            print("Cannot login ", response.status_code)
            sys.exit(1)
        jsonResponse = response.json()
        csrftoken = response.headers.get('csrfToken')
        message = jsonResponse.get("message")
        if 'Logged in' == message:
            print('Session Login', 'INFORMATION')
            return csrftoken
        else:
            print("Login Failure ",response.status_code)
            sys.exit(0)

        # Successful login

        # {
        #     "message" : "Logged in"
        # }


def stCreateAccount(token):

    url = stUrl + 'accounts'

    headers = {'Referer': referer,
               'csrfToken': token,
               'Content-Type' :'application/json',
               'Accept': 'application/json'}



    # Minimum JSON required to create an account.  Add other fields as required
    jsonIn = { "type" : "user",
                "uid": "1000",
                "gid": "1000",
                "name": accName,
                "homeFolder": homeFolder,
                "user": { "name": accName,
                          "passwordCredentials": {"password": "axway"}
                        }
              }

    try:
        response = sessionMgt.post(url, json=jsonIn, headers=headers, verify=False, timeout=stTimeout)
    except requests.ConnectionError as ec:
        print('I cannot connect to ' + urlrl + ' ' + str(ec))
        sys.exit(1)
    except requests.exceptions.HTTPError as eh:
        print('HTTP Error' + str(eh))
        sys.exit(1)
    except requests.exceptions.Timeout as et:
        print('Timeout Error:' + str(et))
        sys.exit(1)
    except requests.exceptions.RequestException as e:
        print('Unknown Error' + str(e))
        sys.exit(1)
    else:
        apiCount.value+=1
        return True
    return False

# This will import a private key stored as a file
# It demonstrates using multipart/mixed format payloads which are used by ST 
#
def stImportKey(token):
    url = stUrl + 'certificates'
    boundary = 'FlokiKat'
    contT = 'multipart/mixed; boundary=' + boundary

    headers = {'Referer': referer,
               'Content-Type': contT,
               'csrfToken': token,
               'Accept': 'application/json'}

    jsonIn = {"name": "PrivateSSHKey",
            "subject": "C=US,CN=sshKey",
            "caPassword": "Axway123",
            "account" : "TestAccount1",
            "type" : "ssh",
            "password": "12345678",
            "usage": "private",
            "keySize": "2048",
            "validityPeriod": "720"
           }


    # We need to build our multipart content as a byte stream to transmit to ST
    # Now generate the JSON part of our multipart
    jsonsection = '--' + boundary + '\n'
    jsonsection += 'Content-Type: application/json\n\n'
    jsonsection += json.dumps(jsonIn)
    jsonsection += '\n\n'

    certBeginSection = '--' + boundary + '\n'
    certBeginSection += 'Content-Type: application/octet-stream\n\n'
    certEndSection = '\n--' + boundary + '--\n'
    certEndSection = certEndSection.encode()

    multipart = jsonsection + certBeginSection
    multipart = multipart.encode()


    with open('testsshkey', mode='rb') as file:
        binaryCert = file.read()

    multipartBytes = multipart + binaryCert + certEndSection

    try:
        response = sessionMgt.post(url, data=multipartBytes, headers=headers, verify=False, timeout=stTimeout)
    except requests.ConnectionError as ec:
        print('I cannot connect to ' + urlrl + ' ' + str(ec))
        sys.exit(1)
    except requests.exceptions.HTTPError as eh:
        print('HTTP Error' + str(eh))
        sys.exit(1)
    except requests.exceptions.Timeout as et:
        print('Timeout Error:' + str(et))
        sys.exit(1)
    except requests.exceptions.RequestException as e:
        print('Unknown Error' + str(e))
        sys.exit(1)
    else:
        apiCount.value += 1
        if response.status_code != 200:
            print("Certificate Import failure ", response.status_code)
            sys.exit(1) 
        return True
        # Python / ST bug - location header not visible! We should be able to simply do 

        #a = re.search('[^/]+$',response.headers['location'])
        #certId = a.group(0)
        #return certId

def stGetKeyId():

    # As location header is missing - do another GET to find the id
    url = stUrl + 'certificates?usage=private&account=TestAccount1&name=PrivateSSHKey'   
    headers = {'Referer': referer,
               'Accept': 'application/json'}

    try:
        response = sessionMgt.get(url, headers=headers, verify=False, timeout=stTimeout)   
    except requests.ConnectionError as ec:
        print('I cannot connect to ' + urlrl + ' ' + str(ec))
        sys.exit(1)
    except requests.exceptions.HTTPError as eh:
        print('HTTP Error' + str(eh))
        sys.exit(1)
    except requests.exceptions.Timeout as et:
        print('Timeout Error:' + str(et))
        sys.exit(1)
    except requests.exceptions.RequestException as e:
        print('Unknown Error' + str(e))
        sys.exit(1)
    else:
        apiCount.value += 1
        if response.status_code != 200:
            print("Certificate Find failure ", response.status_code)
            sys.exit(1)
        rJson = response.json()

        resultSet = rJson['resultSet']
        returnCount = resultSet['returnCount']
        if returnCount != 1:
            print('I cannot find the Certificate')
            sys.exit(1)

        # should only be the 1 result as the name is unique
        results = rJson['result']
        certId = results[0]['id']
        print(certId)
        return certId


def stCreateSiteFolder(token):

    url = stUrl + 'sites'

    headers = {'Referer': referer,
               'csrfToken': token,
               'Content-Type': 'application/json',
               'Accept': 'application/json'}

    # Minimum JSON required to create a folder monitor.  Add other fields as required
    jsonIn = {"type": "folder",
              "name": "FolderMonitor",
              "account" : accName,
              "protocol": "folder",
              "downloadFolder": "/tmp",
              "downloadPattern": "nofiles",
              "uploadFolder": "/tmp"
              }

    try:
        response = sessionMgt.post(url, json=jsonIn, headers=headers, verify=False, timeout=stTimeout)
    except requests.ConnectionError as ec:
        print('I cannot connect to ' + urlrl + ' ' + str(ec))
        sys.exit(1)
    except requests.exceptions.HTTPError as eh:
        print('HTTP Error' + str(eh))
        sys.exit(1)
    except requests.exceptions.Timeout as et:
        print('Timeout Error:' + str(et))
        sys.exit(1)
    except requests.exceptions.RequestException as e:
        print('Unknown Error' + str(e))
        sys.exit(1)
    else:
        apiCount.value += 1
        # No JSON is returned by the create.
        #
        # To find the id of the newly created object:
        # Search the returned location header for all after the last occurrence of /
        # match at least one of anything not a slash folowed by end of string
        # location header looks like this:
        # https://10.129.129.22:8444/api/v2.0/sites/8a0101967d2e236c017d766239902d02

        a = re.search('[^/]+$',response.headers['location'])
        folderId = a.group(0)
        return True
    return False

def stCreateSiteSFTP(keyId,token):

    url = stUrl + 'sites'

    headers = {'Referer': referer,
               'csrfToken': token,
               'Content-Type': 'application/json',
               'Accept': 'application/json'}

    # Minimum JSON required to create an SFTP site.  Add other fields as required
    jsonIn = {"type": "ssh",
              "name": "SFTPsite",
              "account" : accName,
              "protocol": "ssh",
              "downloadFolder": "/tmp",
              "downloadPattern": "nofiles",
              "uploadFolder": "/tmp",
              "host": "10.129.129.22",
              "port": "22",
              "userName": "stapp",
              "password": "Alfisreal132$",
              "usePassword": True
              }
    # Use this to add Key based access
    jsonIn = {"type": "ssh",
              "name": "SFTPsite",
              "account" : accName,
              "protocol": "ssh",
              "downloadFolder": "/tmp",
              "downloadPattern": "nofiles",
              "uploadFolder": "/tmp",
              "host": "10.129.129.22",
              "port": "22",
              "userName": "stapp",
              "usePassword": False,
              "clientCertificate": keyId
              }


    try:
        response = sessionMgt.post(url, json=jsonIn, headers=headers, verify=False, timeout=stTimeout)
    except requests.ConnectionError as ec:
        print('I cannot connect to ' + urlrl + ' ' + str(ec))
        sys.exit(1)
    except requests.exceptions.HTTPError as eh:
        print('HTTP Error' + str(eh))
        sys.exit(1)
    except requests.exceptions.Timeout as et:
        print('Timeout Error:' + str(et))
        sys.exit(1)
    except requests.exceptions.RequestException as e:
        print('Unknown Error' + str(e))
        sys.exit(1)
    else:
        apiCount.value += 1
        # No JSON is returned by the create.
        #
        # To find the id of the newly created object:
        # Search the returned location header for all after the last occurrence of /
        # match at least one of anything not a slash folowed by end of string
        # location header looks like this:
        # https://10.129.129.22:8444/api/v2.0/sites/8a0101967d2e236c017d766239902d02

        a = re.search('[^/]+$',response.headers['location'])
        sftpSiteId = a.group(0) # ie return the match value
        return True
    return False

def stCreateSubscription(token):
    url = stUrl + 'subscriptions'

    headers = {'Referer': referer,
               'csrfToken': token,
               'Content-Type': 'application/json',
               'Accept': 'application/json'}

    jsonIn = {
              "type": "AdvancedRouting",
              "application": "AdvRouting",
              "folder": "/inbound",
              "account": accName,
              "transferConfigurations": [{
                                           "tag": "PARTNER-IN",
                                           "outbound": False
                                         }
                                         ],
              "postProcessingActions": {
                                           "ppaOnSuccessInDoDelete": True
                                       }
              }
    try:
        response = sessionMgt.post(url, json=jsonIn, headers=headers, verify=False, timeout=stTimeout)
    except requests.ConnectionError as ec:
        print('I cannot connect to ' + urlrl + ' ' + str(ec))
        sys.exit(1)
    except requests.exceptions.HTTPError as eh:
        print('HTTP Error' + str(eh))
        sys.exit(1)
    except requests.exceptions.Timeout as et:
        print('Timeout Error:' + str(et))
        sys.exit(1)
    except requests.exceptions.RequestException as e:
        print('Unknown Error' + str(e))
        sys.exit(1)
    else:
        apiCount.value += 1
        # No JSON is returned by the create.
        #
        # To find the id of the newly created object:
        # Search the returned location header for all after the last occurrence of /
        # match at least one of anything not a slash folowed by end of string
        # location header looks like this:
        # https://10.129.129.22:8444/api/v2.0/sites/8a0101967d2e236c017d766239902d02

        a = re.search('[^/]+$', response.headers['location'])
        subId = a.group(0)
        print(subId)
        return subId
    return None


def stCreateSimpleRoute(token):
    url = stUrl + 'routes'

    headers = {'Referer': referer,
               'csrfToken': token,
               'Content-Type': 'application/json',
               'Accept': 'application/json'}

    # Minimum JSON required to create a Simple Route with a Send to Partner Step.  Add other fields as required
    jsonIn = {"type": "SIMPLE",
              "name": "SimpleRouteToSFTPsite",
              "conditionType": "ALWAYS",
              "condition": True,
              "steps" : [ {
                            "type": "SendToPartner",
                            "status": "ENABLED",
                            "autostart" : False,
                            "transferSiteExpressionType": "LIST",
                            "transferSiteExpression": "SFTPsite#!#CVD#!#",
                            "fileFilterExpressionType": "GLOB",
                            "fileFilterExpression": "*",
                            "actionOnStepFailure": "FAIL"
              }]
              }

    try:
        response = sessionMgt.post(url, json=jsonIn, headers=headers, verify=False, timeout=stTimeout)
    except requests.ConnectionError as ec:
        print('I cannot connect to ' + urlrl + ' ' + str(ec))
        sys.exit(1)
    except requests.exceptions.HTTPError as eh:
        print('HTTP Error' + str(eh))
        sys.exit(1)
    except requests.exceptions.Timeout as et:
        print('Timeout Error:' + str(et))
        sys.exit(1)
    except requests.exceptions.RequestException as e:
        print('Unknown Error' + str(e))
        sys.exit(1)
    else:
        apiCount.value += 1
        # No JSON is returned by the create.
        #
        # To find the id of the newly created object:
        # Search the returned location header for all after the last occurrence of /
        # match at least one of anything not a slash folowed by end of string
        # location header looks like this:
        # https://10.129.129.22:8444/api/v2.0/sites/8a0101967d2e236c017d766239902d02

        a = re.search('[^/]+$', response.headers['location'])
        sRouteId = a.group(0)
        print('Simple Route Id: ' + sRouteId)
        return sRouteId
    return None

def stCreatePackageRoute(sRouteId,subId, tRouteId, token):
    url = stUrl + 'routes'

    headers = {'Referer': referer,
               'csrfToken': token,
               'Content-Type': 'application/json',
               'Accept': 'application/json'}

    # Minimum JSON required to create a Package Route.  Add other fields as required
    # Note the use of he executeRoute step to link the Simple Route to the Composite/Package
    jsonIn = {"type": "COMPOSITE",
              "account" : accName,
              "name": "PackageRouteToSFTPsite",
              "conditionType": "MATCH_ALL",
              "routeTemplate" : tRouteId,
              "subscriptions": [ subId ],
              "steps" : [{
                            "type": "ExecuteRoute",
                            "status": "ENABLED",
                            "autostart": False,
                            "executeRoute": sRouteId
    }]}

    try:
        response = sessionMgt.post(url, json=jsonIn, headers=headers, verify=False, timeout=stTimeout)
    except requests.ConnectionError as ec:
        print('I cannot connect to ' + urlrl + ' ' + str(ec))
        sys.exit(1)
    except requests.exceptions.HTTPError as eh:
        print('HTTP Error' + str(eh))
        sys.exit(1)
    except requests.exceptions.Timeout as et:
        print('Timeout Error:' + str(et))
        sys.exit(1)
    except requests.exceptions.RequestException as e:
        print('Unknown Error' + str(e))
        sys.exit(1)
    else:
        apiCount.value += 1
        # No JSON is returned by the create.
        #
        # To find the id of the newly created object:
        # Search the returned location header for all after the last occurrence of /
        # match at least one of anything not a slash folowed by end of string
        # location header looks like this:
        # https://10.129.129.22:8444/api/v2.0/sites/8a0101967d2e236c017d766239902d02

        a = re.search('[^/]+$', response.headers['location'])
        pRouteId = a.group(0)
        print('Package Route Id: ' + pRouteId)
        return pRouteId
    return None

def stGetTemplateRouteId(name):

    url = stUrl + 'routes?type=TEMPLATE&name=' + str(name)

    headers = {'Referer': referer,
               'Accept': 'application/json'}

    try:
        response = sessionMgt.get(url, headers=headers, verify=False, timeout=stTimeout)
    except requests.ConnectionError as ec:
        print('I cannot connect to ' + urlrl + ' ' + str(ec))
        sys.exit(1)
    except requests.exceptions.HTTPError as eh:
        print('HTTP Error' + str(eh))
        sys.exit(1)
    except requests.exceptions.Timeout as et:
        print('Timeout Error:' + str(et))
        sys.exit(1)
    except requests.exceptions.RequestException as e:
        print('Unknown Error' + str(e))
        sys.exit(1)
    else:
        apiCount.value += 1
        rJson = response.json()

        resultSet = rJson['resultSet']
        returnCount = resultSet['returnCount']
        if returnCount != 1:
            print('I cannot find the Route Package Template')
            sys.exit(1)

        # should only be the 1 result as the name is unique
        results = rJson['result']
        templateId = results[0]['id']
        print(templateId)
        return templateId




# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# MAIN = Start of Program....
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ====================================================================================

if __name__ == "__main__":

    import datetime
    import json
    import multiprocessing
    import os
    import re              # Regular Expressions
    import requests
    # import ssl
    # import string
    import sys

    from multiprocessing import Process, Value, Queue
    #from requests.auth import HTTPBasicAuth
    from requests.packages.urllib3.exceptions import InsecureRequestWarning
    from requests import Request


    # --------------------------------------------------------------------------------
    # BEGIN Configuration Section
    # --------------------------------------------------------------------------------
    # Please modify the below to match your environment

    #logFile = 'updateConfig.log'   # We won't use a logFile for this example
    stTimeout = 60                  # in seconds
    referer = 'PippinTheCat'        # Used for Session Managtement - cab be anything so long as always the same
    #stUrl = 'https://10.129.129.22:8444/api/v2.0/'
    #basicAuth = "YWRtaW46YWRtaW4="  # from echo -n user:pass | base64

    stUrl = None
    basicAuth = None
    try:
        with open('../../../config', 'r') as f:
            line = f.readline()
            while line:
                line = ''.join(f.readline().split())  # remove any whitespace
                if len(line) <= 1:
                    continue
                if line[0] == '#':
                    continue
                if line[0:5] == 'url="':
                    stUrl = line[5:-1] + '/'
                if line[0:5] == 'pwd="':
                    basicAuth = line[5:-1]
    except:
        print('I cannot find the configuration file called config')
        sys.exit(0)


    # Parameters used to create an account
    accName = 'TestAccount1'
    homeFolder = '/usrdata/NoBU/' + accName
    templateRouteName = 'Empty'
    # -------------------------------------------------------------------------------
    # END Configuration Section
    # -------------------------------------------------------------------------------

    # Tell the user about our run time environment for multiprocessing
    print('Running on a system with: ' + str(multiprocessing.cpu_count()) + ' CPUs')
    if os.name == 'posix':
        print('We can use: ' + str(os.sched_getaffinity(0)) + ' of these')
    outputString = 'Starting at: ' + str(datetime.datetime.now())
    print(outputString)

    # Counter of how many APIs get issued
    apiCount = Value('i', 0)

    # We are turning off Cert validation - stop the warning messages
    requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

    # Now create our session which will be shared amongst all APIs
    sessionMgt = requests.Session()

    # We'll use session management and login to ST via /myself
    csrftoken = stLogin(basicAuth, sessionMgt)

    # Create the base user account
    if not stCreateAccount(csrftoken):
        print('Failed to Create the User Account')

    # Import an SSH private Key
    if not stImportKey(csrftoken):
        print('Failed to Import the SSH key')

    # Find the ID of the created SSH private key
    sshKeyId = stGetKeyId()

    # Create a Folder Monitor Transfer Site
    if not stCreateSiteFolder(csrftoken):
        print('failed to create a folder monitor')

    # Create an SFTP transfer Site
    if not stCreateSiteSFTP(sshKeyId,csrftoken):
        print('failed to create an SFTP site')

    # Create a Subscription
    subId = stCreateSubscription(csrftoken)
    if subId == None:
        print('Failed to create Subscription')

    # Create a Simple Route
    sRouteId = stCreateSimpleRoute(csrftoken)
    if sRouteId == None:
        print('Failed to create Simple Route')

    # Get Template Route ID
    tRouteId = stGetTemplateRouteId(templateRouteName)

    # Create a Package Route
    pRouteId = stCreatePackageRoute(sRouteId,subId, tRouteId, csrftoken)

    stLogout(sessionMgt, csrftoken)
    print('I issued: ' + str(apiCount.value) + ' APIs')
    outputString = 'Ending at: ' + str(datetime.datetime.now())
    print(outputString)

