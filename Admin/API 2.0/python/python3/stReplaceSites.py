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
# V1.00 Ian Percival   10-Nov-2021
#
# This script will scan all ssh transfer sites, looking to see if the cipher
# suites need to be updated.
#
# APIs used - /myself POST DELETE ( ST login and logout )
#             /sites  GET, PUT
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
#
def stLogout(session, token):

    url = stUrl + 'myself'

    headers = {'Referer': referer,
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
        print('Session Mgt Logged Out')
        numAPIs.value+=1
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
        numAPIs.value+=1
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
            sys.exit(1)

        # Successful login response
        # {
        #     "message" : "Logged in"
        # }

def stProcessSites(session, csrftoken):

    entry = 0
    numberObjectsToFetchPerCall = 400
    keepLooping = True

    numberOfSSHSites = 0

    headers = {'Referer': referer,
               'csrfToken': csrftoken,
               'Accept': 'application/json'}

    while keepLooping:

        url = stUrl + 'sites?protocol=ssh&offset=' + str(entry) + '&limit=' + str(numberObjectsToFetchPerCall)

        try:
            response = session.get(url, headers=headers, verify=False, timeout=stTimeout)
        except requests.ConnectionError as ec:
            print('I cannot connect to ' + url + ' ' + str(ec))
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
            numAPIs.value+=1
            sites = response.json()

            resultSet = sites['resultSet']
            returnCount = resultSet['returnCount']

            if returnCount < numberObjectsToFetchPerCall:
                keepLooping = False

            results = sites['result']

            for item in results:
                numberOfSSHSites += 1
                kex = item.get('keyExchangeAlgorithms')
                account = item.get('account')
                siteId = item.get('id')
                if kex != masterKexAlg:
                    print('Account ' + str(account) +' has a site with ' + str(kex))
                    print('It should have ' + str(masterKexAlg))
                    #item.pop('metadata')
                    item['keyExchangeAlgorithms'] = masterKexAlg

                    updateSite(session,siteId,item, csrftoken)

            entry += numberObjectsToFetchPerCall

    return numberOfSSHSites

def updateSite(session,id,jsonin, csrftoken):

    headers = {'Referer': referer,
               'csrfToken': csrftoken,
               'Content-Type': 'application/json',
               'Accept': 'application/json'}
    url = stUrl + 'sites/' + str(id)


    try:
        response = session.put(url, headers=headers, json=jsonin, verify=False, timeout=stTimeout)
    except requests.ConnectionError as ec:
        print('I cannot connect to ' + url + ' ' + str(ec))
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
        if response.status_code != 204:
            print('HTTP response is ' + str(response.status_code))
            print(response.json())
        numAPIs.value += 1
        print('Successfully patched Site with ID: ' + str(id))

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# MAIN = Start of Program....
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ====================================================================================

if __name__ == "__main__":

    # import datetime
    import json
    import multiprocessing
    import pickle
    import requests
    # import ssl
    # import string
    import sys

    from multiprocessing import Value
    from requests.packages.urllib3.exceptions import InsecureRequestWarning



    # --------------------------------------------------------------------------------
    # BEGIN Configuration Section
    # --------------------------------------------------------------------------------
    # Please modify the below to match your environment


    #logFile = 'stUpdateSites.log'  # We won't use a logFile for this example
    stTimeout = 120  # in seconds
    referer = 'PippinTheCat'
    #stUrl = 'https://10.129.129.22:8444/api/v2.0/'
    #basicAuth = "YWRtaW46YWRtaW4="  # from echo -n user:pass | base64
    masterKexAlg = 'diffie-hellman-group14-sha256,diffie-hellman-group-exchange-sha256,curve25519-sha256@libssh.org,diffie-hellman-group15-sha512,diffie-hellman-group17-sha512,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512'

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

    numAPIs = Value('i', 0)                  # counter to see how many APIS we sent

    # We are turning off Cert validation - stop the warning messages
    requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

    # Now create our session....
    sessionMgt = requests.Session()

    # We'll use session management and login to ST via /myself
    csrftoken = stLogin(basicAuth, sessionMgt)

    numSites = stProcessSites(sessionMgt,csrftoken)
    print('I processed: ' + str(numSites) + ' SSH sites')
    # Completion Section

    stLogout(sessionMgt,csrftoken)
    print('Completed Run, number of APIs issued: ' + str(numAPIs.value))
