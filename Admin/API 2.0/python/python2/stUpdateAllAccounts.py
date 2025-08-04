#! /usr/bin/python
#
#
# V1.00 Ian Percival   22-Feb-2021
#
# This script scans all user accounts and updates a single field in that account
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
    print logString


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
        print 'Problem writing to log'
        return

    return


def stProcessAllTemplates(stUrl, apiCounter):

    entry = 0
    numberToFetchEachTime = 200
    keepLooping = True

    numberOfUserAccounts = 0

    while keepLooping:
        
        url = stUrl + 'accounts?type=template&offset=' + str(entry) + '&limit=' + str(numberToFetchEachTime)

        request = urllib2.Request(url)
        request.add_header('Referer', referer)
        request.add_header('Accept', 'application/json')

        try:
            response = urllib2.urlopen(request, timeout=stTimeout)
        except HTTPError as e:
            errText = 'Error trying to GET user accounts ' + str(e.code) + ' ' + str(e.read())
            writeLog(errText, 'FAIL')
            return False

        except URLError as e:
            errText = 'Failed Connecting to GET user Accounts: ' + str(e.reason)
            writeLog(errText, 'FAIL')
            print 'I Cannot connect to ST'
            return False

        else:
            apiCounter.value+=1
            results = response.read()
            jsonResponse = json.loads(results)
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
                stUpdateAccount( stUrl, apiCounter, stUserAccount, modify)
                
                numberOfUserAccounts+=1
            entry+=numberToFetchEachTime

    infoText = 'Number of User Accounts: ' + str(numberOfUserAccounts)
    writeLog(infoText, 'INFORMATION')
    return


# Update a field in the account
def stUpdateAccount( stUrl, apiCounter, accName, modify):
    url = stUrl + 'accounts/' + str(accName)
    
    if modify:
        jsonIn =  [ 
                    { 
                      'op': 'replace',
                      'path': '/enrolledWithExternalPass',
                      'value': True
                    }
                  ]
    else:
        jsonIn =  [
                    {
                      'op': 'add',
                      'path': '/enrolledWithExternalPass',
                      'value': True
                    }
                  ]
             


    request = urllib2.Request(url)

    request.get_method = lambda: 'PATCH'
    request.add_header('Referer', referer)
    request.add_header('Accept', 'application/json')
    request.add_header('Content-Type', 'application/json') 
        
    try:
        response = urllib2.urlopen(request, json.dumps(jsonIn), timeout=stTimeout)
    except HTTPError as e:
        errText = 'Error trying to Patch account: ' + str(accName) + ' ' + str(e.code) + ' ' + str(e.read())
        writeLog(errText, 'FAIL')
        return False

    except URLError as e:
        errText = 'Failed Connecting: ' + str(e.reason)
        writeLog(errText, 'FAIL')
        print 'I Cannot connect to ST'
        return False
    else:
        apiCounter.value+=1
        t='Updated account: ' + str(accName)
        return True





# Login to ST using session management
#
# This is the ST api/v1.4/myself POST method
#
def stLogin(basicAuth):

    global referer
    global stTimeout
    global stUrl

    url = stUrl + 'myself'

    request = urllib2.Request(url)
    request.get_method = lambda: 'POST'
    request.add_header('Referer', referer)
    request.add_header('Accept', 'application/json')

    if basicAuth == None:
        # Nothing to do - using certs defined in ssl Context
        infoText = 'Not Using Basic Auth'
        writeLog(infoText, 'INFORMATION')
    else:
        # add the auth header
        request.add_header("Authorization", "Basic %s" % basicAuth)

    try:
        response = urllib2.urlopen(request, timeout=stTimeout)
    except HTTPError as e:
        errText = 'Error trying to Login: ' + str(e.code) + ' ' + str(e.read())
        writeLog(errText, 'FAIL')
        return False

    except URLError as e:
        errText = 'Failed Connecting to Login: ' + str(e.reason)
        writeLog(errText, 'FAIL')
        print 'I Cannot connect to ST'
        return False
    else:
        # Succesful login
        result = response.read()
        # {
        #     "message" : "Logged in"
        # }
        jsonResponse = json.loads(result)
        message = jsonResponse.get("message")
        if 'Logged in' == message:
            writeLog('Session Login', 'INFORMATION')
            return True
        else:
            return False


# This is the ST logout session management
#
# This is the ST api/v1.4/myself DELETE method
#
def stLogout():

    global referer
    global stTimeout
    global stUrl

    url = stUrl + 'myself'

    request = urllib2.Request(url)
    request.get_method = lambda: 'DELETE'
    request.add_header('Referer', referer)


    try:
        response = urllib2.urlopen(request, timeout=stTimeout)
    except HTTPError as e:
        errText = 'Error trying to Logout: ' + str(e.code) + ' ' + str(e.read())
        writeLog(errText, 'FAIL')
        return False

    except URLError as e:
        errText = 'Failed Connecting to Logout: ' + str(e.reason)
        writeLog(errText, 'FAIL')
        print 'I Cannot connect to ST'
        return False
    else:
        writeLog('Session Logout', 'INFORMATION')
        return True



#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# MAIN = Start of Program....
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#====================================================================================

if __name__ == "__main__":

    import cookielib
    import datetime
    import httplib
    import json
    import multiprocessing
    import ssl
    import string
    import sys
    import urllib2
    import xml.etree.ElementTree as ET

    from urllib2 import HTTPError
    from urllib2 import URLError
    from multiprocessing import Queue
    from multiprocessing import Process
    from multiprocessing import Value


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
    stUrl = 'https://10.129.128.45:444/api/v2.0/'
    #basicAuth = 'YWRtaW46YWRtaW4=' # from echo -n user:pass | base64
    basicAuth = 'YXh3YXlhZG1pbjpheHdheWFkbWlu' 
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
    # Doing this saves a LOT of overhead and time.
    stCookies = cookielib.CookieJar()

    # setup our ssl stuff - if you are using certs then remove the comment to load the certificates...
    # If you are only accessing a single ST environment - then we can install the opener as a global setting
    sslContext = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
    #sslContext.load_cert_chain(clientCertificateWithCA, clientCertificatePrivateKey)
    httpsOpener = urllib2.build_opener(urllib2.HTTPSHandler(context=sslContext),urllib2.HTTPCookieProcessor(stCookies))
    urllib2.install_opener(httpsOpener)



    # Now use Session Management

    if not stLogin(basicAuth):
        print "Something nasty! Couldn't login to ST"
        sys.exit(0)
    APICounter.value+=1


    # We won't use multiprocessing here as we are not doing too much
    # STEP 1 - loop through all accounts
    stProcessAllTemplates(stUrl, APICounter)

    # Completion Section

    stLogout()
    APICounter.value+=1
    infoText = 'Completed Run. Number of APIs issued: ' + str(APICounter.value)
    writeLog( infoText, 'INFORMATION')



#------------------------------------------------------------------------------------
#

