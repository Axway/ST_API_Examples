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
# V2.00 Ian Percival   16-Jun-2023   Fix errors + csrf compliant 
#                                    This code assumes that Webservices.Admin.CsrfToken.enabled is set to 'true' which is the default 
#                                    for ST after and including the 20230525 release.
# V1.01 Ian Percival   20-Jul-2021   Python3 version
# V1.00 Ian Percival   28-Oct-2020
#
# This script will read all the system configuration settings from a system and will create a file
#  containing baseline data.  Subsequent runs will compare the live system with the saved file and
#  will identify any discrepancies.  Useful for checking after a PATCH, etc.
#
# APIs used - /myself ( ST login and logout )
#             /configurations/options  GET
#
# Usage: ./stConfigScan.py MAKEBASELINE
#        ./stConfigScan.py COMPAREBASELINE
#
# Outputs:
#    A logfile provides run time information
#    A file is used to store baseline config info
#
# Start of Program is 'main' below.
#   Configuration section is there for you to tailor to your env...
#
# All functions are defined first below this header.


# ---------------------
# Supporting Functions
# ---------------------

# Use a commin logFile in case running in batch etc
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


def stGetConfig(counter, session, token):
    global referer
    global stTimeout
    global stUrl

    windowSize = 100
    offset = 0
    getMore = True

    liveConfigs = {}

    headers = {'Referer': referer,
               'csrfToken': token,
               'Accept': 'application/json'}

    while getMore:

        url = stUrl + 'configurations/options?offset=' + str(offset) + '&limit=' + str(windowSize)

        try:
            response = session.get(url, headers=headers, verify=False, timeout=stTimeout)
        except requests.ConnectionError as ec:
            writelog('I cannot connect to ' + stURL,'FATAL')
            writeLog(str(ec),'FATAL')
            sys.exit(1)
        except requests.exceptions.HTTPError as eh:
            writeLog('HTTP Error','FATAL')
            raise SystemExit(eh)
        except requests.exceptions.Timeout as et:
            writeLog('Timeout Error:' + str(et),'FATAL')
        except requests.exceptions.RequestException as e:
            raise SystemExit(e)
        else:
            counter.value+=1
            configs = response.json()

            resultSet = configs['resultSet']
            returnCount = resultSet['returnCount']

            if returnCount < windowSize:
                getMore = False

            results = configs['result']

            for item in results:
                parameterName =  item.get('name')
                parameterValue = item.get('values')
                liveConfigs[parameterName] = parameterValue

            offset += windowSize

    return liveConfigs


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
    headers = {'Referer': referer,
              'Accept': 'application/json',
              'Authorization': authString}

    try:
        response = session.post(url, headers=headers, verify=False, timeout=stTimeout)
    except requests.ConnectionError as ec:
        writelog('I cannot connect to ' + stURL,'FATAL')
        writeLog(str(ec),'FATAL')
        sys.exit(1)
    except requests.exceptions.HTTPError as eh:
        writeLog('HTTP Error','FATAL')
        sys.exit(1)
    except requests.exceptions.Timeout as et:
        writeLog('Timeout Error:' + str(et),'FATAL')
    except requests.exceptions.RequestException as e:
        sys.exit(1)
    else:
        if response.status_code != 200:
            print("Cannot login ", response.status_code)
            sys.exit(1)
        jsonResponse = response.json()
        csrftoken = response.headers.get('csrfToken')
        message = jsonResponse.get("message")
        if 'Logged in' == message:
            writeLog('Session Login', 'INFORMATION')
            return csrftoken
        else:
            print("Login Failure ",response.status_code)
            sys.exit(0)

        # Successful login

        # {
        #     "message" : "Logged in"
        # }



# This is the ST logout session management
#
# This is the ST api/v1.4/myself DELETE method
#
def stLogout(session, token):

    global referer
    global stTimeout
    global stUrl

    url = stUrl + 'myself'

    headers = {'Referer': referer,
               'csrfToken': token,
              'Accept': 'application/json'}
    try:
        response = session.delete(url, headers=headers, verify=False, timeout=stTimeout)
    except requests.ConnectionError as ec:
        writeLog('I cannot connect to ' + stURL,'FATAL')
        writeLog(ec, 'FATAL')
        sys.exit(1)
    except requests.exceptions.HTTPError as eh:
        writeLog('HTTP Error','FATAL')
        raise SystemExit(eh)
    except requests.exceptions.Timeout as et:
        writeLog('Timeout Error:' + et,'FATAL')
    except requests.exceptions.RequestException as e:
        raise SystemExit(e)
    else:
        writeLog('Session Mgt Logged Out','SUCCESS')
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
    import pickle
    import requests
    import ssl
    import string
    import sys

    from multiprocessing import Queue
    from multiprocessing import Process
    from multiprocessing import Value

    from requests.auth import HTTPBasicAuth
    from requests.packages.urllib3.exceptions import InsecureRequestWarning

    global logFile
    global referer
    global stTimeout
    global stUrl

    # --------------------------------------------------------------------------------
    # BEGIN Configuration Section
    # --------------------------------------------------------------------------------
    # Please modify the below to match your environment

    # define how many parallel procs we will create
    numberParallelProcs = 10
    stTimeout = 120

    baselineFile = '/home/axway/stConfig-10.129.61.87.baseline'
    logFile = 'checkConfig.log'

    referer = 'PippinTheCat'
    #stUrl = 'https://dogco.axway.university:8444/api/v2.0/'
    #basicAuth = 'QVBJYWRtaW46QXh3YXkxMjM='  # from echo -n user:pass | base64

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
        print('I cannot find the configuration file called config')
        sys.exit(0)

    # -------------------------------------------------------------------------------
    # END Configuration Section
    # -------------------------------------------------------------------------------


    APICounter = Value('i', 0)

    try:
        mode = sys.argv[1]
    except IndexError:
        errText = 'Please provide argument 1 - either MAKEBASELINE or COMPAREBASELINE'
        print(errText)
        sys.exit(0)

    if 'MAKEBASELINE' in mode or 'COMPAREBASELINE' in mode:
        t = 'Program called with argument ' + mode
        writeLog(t, 'INFORMATION')
    else:
        errText = 'Please provide argument 1 - either MAKEBASELINE or COMPAREBASELINE'
        print(errText)
        sys.exit(0)

    outputString = 'Starting at ' + str(datetime.datetime.now())
    writeLog(outputString, 'INFORMATION')

    logEntry = 'Number of CPUs available to this server: ' + str(multiprocessing.cpu_count())
    writeLog(logEntry, 'INFORMATION')

    logEntry = 'Commencing Run Using ' + str(numberParallelProcs) + ' threads\n'
    writeLog(logEntry, 'INFORMATION')

    # Before we do anything, lets authenticate to ST
    # We'll use session management as this avoids having to authenticate on every API call
    #  and we plan to issue potentially millions of APIs!
    # Doing this saves a LOT of overhead and time.

    # We are turning off Cert validation - stop the warning messages
    requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

    # Now create our session....
    sessionMgt = requests.Session()



    # Now use Session Management

    csrftoken = stLogin(basicAuth, sessionMgt)
    APICounter.value += 1


    # We won't use multiprocessing here as we are not doing too much
    # STEP 1 -
    # Read in the System Configs
    cConfigs = stGetConfig(APICounter, sessionMgt, csrftoken)

    # See if we need to create a new baseline file containing all parameters.
    if mode == 'MAKEBASELINE':
        pickle.dump(cConfigs, open(baselineFile, 'wb'))
    elif mode == 'COMPAREBASELINE':
        baselineConfig = pickle.load( open(baselineFile, 'rb'))
        # cConfigs are the live system configs
        # compare these to what was there before
        for key, value in cConfigs.items():
            # Does this key exist in the baseline?
            if key in baselineConfig:
                # As the Key IS there - compare the values
                if value == baselineConfig[key]:
                    continue
                else:
                    # We have a difference in values
                    t = key + ' has changed from ' +  str(baselineConfig[key]) + '  to ' + str(value)
                    writeLog(t, 'WARNING')
                    continue
            else:
                t = key + ' with value ' + str(value) + ' does not exist in the baseline'
                writeLog(t, 'WARNING')
                continue



    # Completion Section

    stLogout(sessionMgt, csrftoken)
    APICounter.value += 1
    infoText = 'Completed Run. Number of APIs issued: ' + str(APICounter.value)
    writeLog(infoText, 'INFORMATION')

# ------------------------------------------------------------------------------------
#

