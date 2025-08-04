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
# V1.01 ian Percival   20-Jun-2023 Fix typo on first line!
# V1.00 Ian Percival   21-Jul-2022
#
# This script will output all accounts created after an input date...
#
#
# APIs used - /myself ( ST login and logout ) POST DELETE
#             /accounts  GET
#
# Usage: python3
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

def stLogout(session):

    url = stUrl + 'myself'

    headers =  {'Referer': referer,
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
        print('Session Mgt Login using /myself: SUCCESS')
        # print( response.status_code )
        # print( response.json())

        # Successful login response

        # {
        #     "message" : "Logged in"
        # }
        return True


def stGetAccounts(stUrl, session, count, fromDate):

    global referer
    global stTimeout

    entry = 0
    numberToFetchEachTime = 200
    keepLooping = True

    numberOfUserAccounts = 0

    headers = {'Referer': referer,
               'Accept': 'application/json'}


    while keepLooping:

        url = stUrl + 'accounts?type=user&offset=' + str(entry) + '&limit=' + str(numberToFetchEachTime)

        try:
            response = session.get(url, headers=headers, verify=False, timeout=stTimeout)
        except requests.ConnectionError as ec:   
            writelog('I cannot connect to ' + stURL, 'FATAL')
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
            count.value+=1
            jsonResponse = response.json()
            jsonAccounts = jsonResponse["result"]

            if len(jsonAccounts) == 0:
                keepLooping = False
                continue

            for item in jsonAccounts:
                stUserAccount = item.get("name")
                createDate = item.get("accountCreationDate")  
                createDate = datetime.datetime.fromtimestamp(float(createDate)/1000.)

                if createDate < fromDate:
                    continue
                print(stUserAccount," has creation date: ", createDate)
                numberOfUserAccounts+=1

            entry+=numberToFetchEachTime

    print("There were: ", numberOfUserAccounts, " created in this time period")
    return
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# MAIN = Start of Program....
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ====================================================================================

if __name__ == "__main__":

    import datetime
    import json
    import multiprocessing
    import os
    import requests
    # import ssl
    # import string
    import sys

    from multiprocessing import Process, Value, Queue
    #from requests.auth import HTTPBasicAuth
    from requests.packages.urllib3.exceptions import InsecureRequestWarning

    global referer
    global stTimeout


    # --------------------------------------------------------------------------------
    # BEGIN Configuration Section
    # --------------------------------------------------------------------------------
    # Please modify the below to match your environment

    #logFile = 'updateConfig.log'  # We won't use a logFile for this example
    stTimeout = 60  # in seconds
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

    try:
        fromDate = sys.argv[1]
    except IndexError:
        errText = 'Please provide argument 1 to list all accounts created after date X in format YYYY-MM-DD'
        print(errText)
        sys.exit(0)
    fromDate = datetime.datetime.strptime(fromDate, "%Y-%m-%d")
    

    print('Running on a system with: ' + str(multiprocessing.cpu_count()) + ' CPUs')
    if os.name == 'posix':
        print('We can use: ' + str(os.sched_getaffinity(0)) + ' of these')
    outputString = 'Starting at: ' + str(datetime.datetime.now())
    print(outputString)

    # Counter of how many APIs get issued
    apiCount = Value('i', 0)

    # We are turning off Cert validation - stop the warning messages
    requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

    # Now create our session....
    sessionMgt = requests.Session()

    # We'll use session management and login to ST via /myself
    if not stLogin(basicAuth, sessionMgt):
        print("Something nasty! Couldn't login to ST")
        sys.exit(1)

    stGetAccounts(stUrl, sessionMgt, apiCount, fromDate)





    stLogout(sessionMgt)
    print('I issued: ' + str(apiCount.value) + ' APIs')
    outputString = 'Ending at: ' + str(datetime.datetime.now())
    print(outputString)
