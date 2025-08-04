#! /usr/bin/python3
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
# V1.00 Ian Percival   28-Mar-2022
#
# This script adds a new rule to an existing login restriction policy
#
# APIs used - /myself ( ST login and logout )
#             /loginRestrictionPolicies ( GET and PATCH )
#
# Usage: python3 stAddLoginRestrictionRule.py ruleName
#
# Outputs:
#    A logile provides some information
#
# Start of Program is 'main' below.
#   Configuration section is there for you to tailor to your env...
#
# All functions are defined first below this header.


# ---------------------
# Supporting Functions
# ---------------------

# Use a common logFile in case running in batch etc
def writeLog(logString, severity):
    # This is the logfile for our python script
    global logFile
    print(logString)

    tstamp = datetime.datetime.now()
    if severity == 'SUCCESS':
        inString = str(tstamp) + ' ' + severity + '     ' + logString + '\n'
    elif severity == 'WARNING':
        inString = str(tstamp) + ' ' + severity + '     ' + logString + '\n'
    else:
        inString = str(tstamp) + ' ' + severity + ' ' + logString + '\n'
    try:
        fHandle = open(logFile, 'a+')
        fHandle.write(inString)
        fHandle.close()
    except:
        print('Problem writing to log')
        return

    return








def stPatchLoginRestriction(session, apiCounter, jsonIn, loginRest):
    global referer
    global stTimeout
    global stUrl

    url = stUrl + 'loginRestrictionPolicies/' + quote(loginRest)

    headers = {'Referer': referer,
               'Accept': 'application/json'}

    try:
        response = session.get(url, headers=headers, verify=False, timeout=stTimeout)
    except requests.ConnectionError as ec:
        writelog('I cannot connect to ' + stURL, 'FATAL')
        writeLog(str(ec), 'FATAL')
        sys.exit(1)
    except requests.exceptions.HTTPError as eh:
        writeLog('HTTP Error', 'FATAL')
        sys.exit(1)
    except requests.exceptions.Timeout as et:
        writeLog('Timeout Error:' + str(et), 'FATAL')
        sys.exit(1)
    except requests.exceptions.RequestException as e:
        writeLog('Unknown Error:' + str(e), 'FATAL')
        sys.exit(1)
    else:
        apiCounter.value += 1
        jsonResponse = response.json()

        if jsonResponse['name'] != loginRest:
            t = 'I cannot Find the Login Restriction named: ' + loginRest
            print(t)
            sys.exit(0)

        rules = jsonResponse['rules']
        for item in rules:
            if item.get('name') == jsonIn[0]['value']['name']:
                print ( 'A rule already exists with the provided name' )
                sys.exit(0)


        numRules = len(jsonResponse['rules'])

        # Now that we have identified how many rules are present - we can perform our update and patch
        # the login Restriction.
        path = '/rules/' + str(numRules)
        jsonIn[0]['path'] = path

        headers = {'Referer': referer,
                   'Content-Type' : 'application/json',
                   'Accept': 'application/json'}

        try:
            response2 = session.patch(url, headers=headers, json=jsonIn, verify=False, timeout=stTimeout)
        except requests.ConnectionError as ec:
            writelog('I cannot connect to ' + stURL, 'FATAL')
            writeLog(str(ec), 'FATAL')
            sys.exit(1)
        except requests.exceptions.HTTPError as eh:
            writeLog('HTTP Error', 'FATAL')
            sys.exit(1)
        except requests.exceptions.Timeout as et:
            writeLog('Timeout Error:' + str(et), 'FATAL')
            sys.exit(1)
        except requests.exceptions.RequestException as e:
            writeLog('Unknown Error:' + str(e), 'FATAL')
            sys.exit(1)
        else:
            apiCounter.value += 1
            return True

# Login to ST using session management
#
# This is the ST api/v1.4/myself POST method
#
def stLogin(basicAuth, session):
    global referer
    global stTimeout
    global stUrl

    url = stUrl + 'myself'

    authString = 'Basic ' + basicAuth
    # If using Certiificate auth
    #headers = {'Referer': referer,
    #           'Accept': 'application/json'}

    headers = {'Referer': referer,
              'Accept': 'application/json',
              'Authorization': authString}

    try:
        response = session.post(url, headers=headers, verify=False, timeout=stTimeout)
    except requests.ConnectionError as ec:
        writelog('I cannot connect to ' + stURL, 'FATAL')
        writeLog(str(ec), 'FATAL')
        sys.exit(1)
    except requests.exceptions.HTTPError as eh:
        writeLog('HTTP Error', 'FATAL')
        raise SystemExit(eh)
    except requests.exceptions.Timeout as et:
        writeLog('Timeout Error:' + str(et), 'FATAL')
        raise SystemExit(et)
    except requests.exceptions.RequestException as e:
        raise SystemExit(e)
    else:
        writeLog('Session Mgt Login', 'SUCCESS')

        # print( response.status_code )
        # print( response.json())

        # Successful login

        # {
        #     "message" : "Logged in"
        # }
        return True
    return True


# This is the ST logout session management
#
# This is the ST api/v1.4/myself DELETE method
#
def stLogout(session):
    global referer
    global stTimeout
    global stUrl

    url = stUrl + 'myself'

    headers = {'Referer': referer,
               'Accept': 'application/json'}
    try:
        response = session.delete(url, headers=headers, verify=False, timeout=stTimeout)
    except requests.ConnectionError as ec:
        writeLog('I cannot connect to ' + stURL, 'FATAL')
        writeLog(ec, 'FATAL')
        sys.exit(1)
    except requests.exceptions.HTTPError as eh:
        writeLog('HTTP Error', 'FATAL')
        raise SystemExit(eh)
    except requests.exceptions.Timeout as et:
        writeLog('Timeout Error:' + et, 'FATAL')
        raise SystemExit(et)
    except requests.exceptions.RequestException as e:
        raise SystemExit(e)
    else:
        writeLog('Logged Out', 'SUCCESS')
        return True

        # Successful logout

        # {
        #     "message" : "Logged out"
        # }


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# MAIN = Start of Program....
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ====================================================================================

if __name__ == "__main__":

    import datetime
    import json
    import multiprocessing
    import requests
    import ssl
    import string
    import sys
    import urllib

    from multiprocessing import Queue
    from multiprocessing import Process
    from multiprocessing import Value

    from requests.packages.urllib3.exceptions import InsecureRequestWarning
    from urllib.parse import quote

    global logFile
    global referer
    global stTimeout
    global stUrl

    # Open the config file which should have the following format:
    #url="https://fm1:8444/api/v2.0"
    #pwd="YWRtaW46YWRtaW4="
    #
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
        print('I cannot find the configuration file')
        sys.exit(0)

    #if basicAuth == None or stUrl == None:
    #    print('The config file does not contain a url or pwd')
    #    sys.exit(0)

    try:
        loginRest = sys.argv[1]
    except IndexError:
        errText = 'Please provide argument 1 - The name of your login Restriction'
        print(errText)
        sys.exit(0)

    # --------------------------------------------------------------------------------
    # BEGIN Configuration Section
    # --------------------------------------------------------------------------------
    # Please modify the below to match your environment

    # define how many parallel procs we will create
    numberParallelProcs = 10
    stTimeout = 120

    logFile = 'updateLoginRestrictions.log'

    referer = 'PippinTheCat'
    #stUrl = 'https://fm1:8444/api/v2.0/' #read from config
    #basicAuth = 'YWRtaW46YWRtaW4=' # from echo -n user:pass | base64 read from config

    # please modify the json "value" key  here to match your new rule
    jsonIn = [
        {
            "op": "add",
            "path": "/rules/",
            "value": {"name": "sessions fewer than 4",
                      "isEnabled": True,
                      "type": "ALLOW",
                      "clientAddress": "*",
                      "expression": "${currentSessions <= 3}",
                      "description": "Only allow if less than 4 sessions"
                      }
        }
    ]

    # -------------------------------------------------------------------------------
    # END Configuration Section
    # -------------------------------------------------------------------------------

    APICounter = Value('i', 0)

    outputString = 'Starting at ' + str(datetime.datetime.now())
    writeLog(outputString, 'INFORMATION')

    logEntry = 'Number of CPUs available to this server: ' + str(multiprocessing.cpu_count())
    writeLog(logEntry, 'INFORMATION')

    logEntry = 'Commencing Run Using ' + str(numberParallelProcs) + ' threads\n'
    writeLog(logEntry, 'INFORMATION')

    # Before we do anything, lets authenticate to ST
    # We'll use session management as this avoids having to authenticate on every API call
    #  and we plan to issue potentially millions of APIs!
    # Now create our session....
    sessionMgt = requests.Session()

    # We are turning off Cert validation - stop the warning messages
    requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

    # Now use Session Management

    if not stLogin(basicAuth, sessionMgt):
        print("Something nasty! Couldn't login to ST")
        sys.exit(0)
    APICounter.value += 1
    #print( sessionMgt.cookies.get_dict())

    # We won't use multiprocessing here as we are not doing too much
    # STEP 1 
    if not stPatchLoginRestriction(sessionMgt, APICounter, jsonIn, loginRest):
        writelog('Something nasty happened on the update', 'FATAL')
        sys.exit(0)

    # Completion Section

    stLogout(sessionMgt)
    APICounter.value += 1
    infoText = 'Completed Run. Number of APIs issued: ' + str(APICounter.value)
    writeLog(infoText, 'INFORMATION')

# ------------------------------------------------------------------------------------
#
