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
# V1.10 ian Percival   22-Jul-2021 Converted from python2 to python3
# V1.00 Ian Percival   22-Feb-2021
#
# This script scans all template user accounts and updates a single field in that account
# 
# It uses Certificate based authentication, rather than Basic Auth
#
# APIs used - /myself ( ST login and logout )
#             /accounts ( GET and PATCH )
#
# Outputs:
#    A logile provides some information
#
# Start of Program is 'main' below.
#   Configuration section is there for you to tailor to your env...
#
# All functions are defined first below this header.


#---------------------
# Supporting Functions
#---------------------

# Use a commin logFile in case running in batch etc
def writeLog(logString, severity):
    # This is the logfile for our python script
    global logFile
    print( logString)


    tstamp = datetime.datetime.now()
    if severity == 'SUCCESS':
        inString = str(tstamp) + ' ' +  severity + '     ' + logString + '\n'
    elif severity == 'WARNING':
        inString = str(tstamp) + ' ' +  severity + '     ' + logString + '\n'
    else:
        inString = str(tstamp) + ' ' +  severity + ' ' + logString + '\n'
    try:
        fHandle = open(logFile,'a+')
        fHandle.write(inString)
        fHandle.close()
    except:
        print( 'Problem writing to log' )
        return

    return


def stProcessAllTemplates(stUrl,session, apiCounter):

    global referer
    global stTimeout

    entry = 0
    numberToFetchEachTime = 200
    keepLooping = True

    numberOfUserAccounts = 0

    headers = {'Referer': referer,
               'Accept': 'application/json'}


    while keepLooping:

        url = stUrl + 'accounts?type=template&offset=' + str(entry) + '&limit=' + str(numberToFetchEachTime)

        try:
            response = session.get(url, headers=headers, verify=False, timeout=stTimeout)
        except requests.ConnectionError as ec:
            writelog('I cannot connect to ' + stURL, 'FATAL')
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
            apiCounter.value+=1
            jsonResponse = response.json()
            jsonAccounts = jsonResponse["result"]

            if len(jsonAccounts) == 0:
                keepLooping = False
                continue

            for item in jsonAccounts:
                stUserAccount = item.get("name")
                extenalAuth = item.get("enrolledWithExternalPass")
                modify = True
                if extenalAuth == None:
                    modify = False

                # Now perform the update
                stUpdateAccount( stUrl, session, apiCounter, stUserAccount, modify)

                numberOfUserAccounts+=1
            entry+=numberToFetchEachTime

    infoText = 'Number of Template Accounts: ' + str(numberOfUserAccounts)
    writeLog(infoText, 'INFORMATION')
    return


# Update a field in the account
def stUpdateAccount( stUrl, session, apiCounter, accName, modify):

    global referer
    global stTimeout

    url = stUrl + 'accounts/' + str(accName)

    if modify:
        jsonIn =  [
                    {
                      'op': 'replace',
                      'path': '/enrolledWithExternalPass',
                      'value': False
                    }
                  ]
    else:
        jsonIn =  [
                    {
                      'op': 'add',
                      'path': '/enrolledWithExternalPass',
                      'value': False
                    }
                  ]

    headers = {'Referer': referer,
               'Content-Type':'application/json',
               'Accept': 'application/json'}



    try:
        response = session.patch(url, json=jsonIn, headers=headers, verify=False, timeout=stTimeout)
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
        apiCounter.value+=1
        t='Updated account: ' + str(accName)
        writeLog(t,'INFORMATION')
        return True











# Login to ST using session management
#
# This is the ST api/v2.0/myself POST method
#
def stLogin(basicAuth, session):

    global referer
    global stTimeout
    global stUrl

    url = stUrl + 'myself'

    authString = 'Basic ' + basicAuth

    # If using Certiificate auth
    headers = {'Referer': referer,
              'Accept': 'application/json'}

    # If using Basic Auth
    #headers = {'Referer': referer,
    #          'Accept': 'application/json',
    #          'Authorization': authString}

    try:
        response = session.post(url, headers=headers, verify=False, timeout=stTimeout)
    except requests.ConnectionError as ec:
        writeLog('I cannot connect to ' + stURL,'FATAL')
        writeLog(str(ec),'FATAL')
        sys.exit(1)
    except requests.exceptions.HTTPError as eh:
        writeLog('HTTP Error','FATAL')
        raise SystemExit(eh)
    except requests.exceptions.Timeout as et:
        writeLog('Timeout Error:' + str(et), 'FATAL')
        raise SystemExit(et)
    except requests.exceptions.RequestException as e:
        raise SystemExit(e)
    else:
        writeLog('Session Mgt Login','SUCCESS')
        #print( response.status_code )
        #print( response.json())

        # Successful login

        # {
        #     "message" : "Logged in"
        # }
        return True
    return True


# This is the ST logout session management
#
# This is the ST api/v2.0/myself DELETE method
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
        writeLog(ec,'FATAL')
        sys.exit(1)
    except requests.exceptions.HTTPError as eh:
        writeLog('HTTP Error','FATAL')
        raise SystemExit(eh)
    except requests.exceptions.Timeout as et:
        writeLog('Timeout Error:' + et,'FATAL')
        raise SystemExit(et)
    except requests.exceptions.RequestException as e:
        raise SystemExit(e)
    else:
        writeLog('Logged Out','SUCCESS')
        return True

        # Successful logout

        # {
        #     "message" : "Logged out"
        # }




#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# MAIN = Start of Program....
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#====================================================================================

if __name__ == "__main__":

    import datetime
    import json
    import multiprocessing
    import requests
    import ssl
    import string
    import sys

    from multiprocessing import Queue
    from multiprocessing import Process
    from multiprocessing import Value

    from requests.packages.urllib3.exceptions import InsecureRequestWarning

    global logFile
    global referer
    global stTimeout
    global stUrl


    #--------------------------------------------------------------------------------
    # BEGIN Configuration Section
    #--------------------------------------------------------------------------------
    # Please modify the below to match your environment


    # define how many parallel procs we will create
    numberParallelProcs = 10
    stTimeout = 120

    logFile='updateAccounts.log'

    apName = 'AnApp'
    referer = 'PippinTheCat'
    #stUrl = 'https://10.129.61.87:8444/api/v2.0/'
    #basicAuth = 'YWRtaW46YWRtaW4=' # from echo -n user:pass | base64
    certificatePath = './dogco_ST_API_client.pem' # Note that the private key cannot be encrypted - this is the combined private key + cert  


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


    #-------------------------------------------------------------------------------
    # END Configuration Section
    #-------------------------------------------------------------------------------


    APICounter = Value('i',0)


    outputString = 'Starting at ' + str(datetime.datetime.now())
    writeLog(outputString, 'INFORMATION')


    logEntry = 'Number of CPUs available to this server: ' + str(multiprocessing.cpu_count())
    writeLog( logEntry, 'INFORMATION')

    logEntry = 'Commencing Run Using ' + str(numberParallelProcs) + ' threads\n'
    writeLog( logEntry, 'INFORMATION')



    # Before we do anything, lets authenticate to ST
    # We'll use session management as this avoids having to authenticate on every API call
    #  and we plan to issue potentially millions of APIs!
    # Now create our session....
    sessionMgt = requests.Session()

    # If you wish to use Certificate authentication create an unencrypted private key + cert file
    sessionMgt.cert = certificatePath

    # We are turning off Cert validation - stop the warning messages
    requests.packages.urllib3.disable_warnings(InsecureRequestWarning)



    # Now use Session Management

    if not stLogin(basicAuth, sessionMgt):
        print("Something nasty! Couldn't login to ST")
        sys.exit(0)
    APICounter.value += 1





    # We won't use multiprocessing here as we are not doing too much
    # STEP 1 - loop through all accounts
    stProcessAllTemplates(stUrl, sessionMgt, APICounter)

    # Completion Section

    stLogout(sessionMgt)
    APICounter.value+=1
    infoText = 'Completed Run. Number of APIs issued: ' + str(APICounter.value)
    writeLog( infoText, 'INFORMATION')



#------------------------------------------------------------------------------------
#

