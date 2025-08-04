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
# V2.00 Ian Percival   16-Jun-2023   csrf compliant 
#                                    This code assumes that Webservices.Admin.CsrfToken.enabled is set to 'true' which is the default 
#                                    for ST after and including the 20230525 release.
# V1.00 Ian Percival   23-Nov-2021
#
# This script will Build a number of Test accounts on SecureTransport
#
# It uses multiprocessing - to create 1000 accounts using 3 procs
#  takes around 6 mins.
#
# APIs used - /myself ( ST login and logout ) POST DELETE
#             /accounts  POST
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

def stLogout(session,token):

    url = stUrl + 'myself'

    headers =  {'Referer': referer,
                'csrfToken': token,
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

        # Successful login response

        # {
        #     "message" : "Logged in"
        # }

def stCreateBusinessUnit(session,timeout,counter,token):

    url = stUrl + 'businessUnits'

    authString = 'Basic ' + basicAuth

    headers = {'Referer': referer,
               'csrfToken': token,
               'Accept': 'application/json',
               'Content-Type': 'application/json'
              }

    jsonIn = { 
               'name': 'CatFoodCorporation',
               'baseFolder' : '/usrdata/CatFoodCo'              
             } 

    try:
        response = session.post(url, json=jsonIn, headers=headers, verify=False, timeout=timeout)
    except requests.ConnectionError as ec:
        print('I cannot connect to ' + stUrl + ' ' + str(ec))
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
        counter.value+=1
        if response.status_code != 201:
            print("Create BU issue ", response.status_code)
            sys.exit(1)

        return True





def stCreateAccount(accNumQ, referer, stUrl, session, timeout, count, auth):
    # This is created as a separate process - so no memory inheritance takes place
    # Parallel procs cannot use the same web socket so we need to create one per process

    import queue
    import requests
    # turn off annoying messages
    from requests.packages.urllib3.exceptions import InsecureRequestWarning
    requests.packages.urllib3.disable_warnings(InsecureRequestWarning)
    sessionMgt = requests.Session()

    # We'll use session management and login to ST via /myself
    csrftoken = stLogin(auth, sessionMgt)

    url = stUrl + 'accounts'
    
    headers = {
               'Referer': 'PippinTheCat',
               'csrfToken': csrftoken,
               'Content-Type' :'application/json',
               'Accept': 'application/json'}
   
    while True:
        try:
            numAcc = accNumQ.get(block=False, timeout=timeout)
            accName = 'ZZ' + str(numAcc)
        except queue.Empty:
            # Nothing left to process
            break
        else:
            homeFolder = '/tmp/' + accName
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
                response = sessionMgt.post(url, json=jsonIn, headers=headers, verify=False, timeout=timeout)
            except requests.ConnectionError as ec:
                print('I cannot connect to ' + stUrl + ' ' + str(ec))
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
                if response.status_code != 201:
                    print('Problem Creating account: ' + str(response.status_code))
                    sys.exit(1)
                count.value+=1
                continue
    stLogout(sessionMgt, csrftoken)
    return
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# MAIN = Start of Program....
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ====================================================================================

if __name__ == "__main__":

    import datetime
    # import json
    import multiprocessing
    import os
    import requests
    # import ssl
    # import string
    import sys

    from multiprocessing import Process, Value, Queue
    #from requests.auth import HTTPBasicAuth
    from requests.packages.urllib3.exceptions import InsecureRequestWarning



    # --------------------------------------------------------------------------------
    # BEGIN Configuration Section
    # --------------------------------------------------------------------------------
    # Please modify the below to match your environment


    numberParallelProcesses = 3
    numberAccountsToCreate = 100
    #logFile = 'updateConfig.log'  # We won't use a logFile for this example
    stTimeout = 60  # in seconds
    referer = 'PippinTheCat'
    stUrl = 'https://dogco.axway.university:8444/api/v2.0/'
    basicAuth = 'QVBJYWRtaW46QXh3YXkxMjM='  # from echo -n user:pass | base64

    # -------------------------------------------------------------------------------
    # END Configuration Section
    # -------------------------------------------------------------------------------

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
    csrftoken = stLogin(basicAuth, sessionMgt)

    # Create the business unit that we'll be using with the test accounts
    if not stCreateBusinessUnit(sessionMgt, stTimeout, apiCount, csrftoken):
        print("Something nasty! Couldn't Create a BU")
        sys.exit(1)


    # Create a multiprocessing Queue which will be shared amongst our parallel procs.     
    accNumQ = Queue()
    for i in range(numberAccountsToCreate):
        accNumQ.put(i)

    processes = [Process(target=stCreateAccount, args=(accNumQ, referer, stUrl, sessionMgt, stTimeout, apiCount, basicAuth)) for x in range(numberParallelProcesses)]
    for p in processes:
        p.start()

    for p in processes:
        p.join()

    accNumQ.close()

    stLogout(sessionMgt, csrftoken)
    print('I issued: ' + str(apiCount.value) + ' APIs')
    outputString = 'Ending at: ' + str(datetime.datetime.now())
    print(outputString)
