#! /usr/bin/python
#
#
# V1.00 Ian Percival   08-Apr-2021
#
#
# APIs used - /myself ( ST login and logout )
#             /routes ( GET , PATCH)
#
# Description:
#    This script processes ALL simple routes on a system - searching the Steps
#    for a particular type of step.
#    This is a special case - we are changing a custom step's old fields to new
#    
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


# This routine fetches ALL simple routes on your system
def stProcessSimpleRoutes(apiCounter):
    global referer
    global stTimeout
    global stUrl
    global stepTypeToUpdate

    url = stUrl + 'routes/type=SIMPLE'

    entry=0
    numberToFetchEachTime = 200
    keepLooping = True

    while keepLooping:
        url = stUrl + 'routes?type=SIMPLE&offset=' + str(entry) + '&limit=' + str(numberToFetchEachTime)
        request = urllib2.Request(url)
        request.add_header('Referer', referer)
        request.add_header('Accept', 'application/json')

        try:
            response = urllib2.urlopen(request, timeout=stTimeout)
        except HTTPError as e:
            errText = 'Error trying to GET Simple Routess ' + str(e.code) + ' ' + str(e.read())
            writeLog(errText, 'FAIL')
            return False

        except URLError as e:
            errText = 'Failed Connecting to GET Simple Routes: ' + str(e.reason)
            writeLog(errText, 'FAIL')
            print 'I Cannot connect to ST'
            return False

        else:
            apiCounter.value+=1
            results = response.read()
            jsonResponse = json.loads(results)
            jsonRoutes = jsonResponse["result"]

            if len(jsonRoutes) == 0:
                keepLooping = False
                continue

            for item in jsonRoutes:
                id = item.get("id")
                simpleName = item.get("name")
                
                if '_' not in simpleName:
                    continue
                splitProfileId = simpleName.rsplit('_', 1)
                profileId = splitProfileId[1]

                if profileId.isnumeric() == False:
                    continue
                
                jsonSteps = item.get("steps")
                stepIndex=0
                for step in jsonSteps:
                    type = step.get("type")
                    
                    # Is this the step type you are looking for?
                    if stepTypeToUpdate not in type:   
                        stepIndex+=1
                        continue
                   
                    # We get here with a matching step type that we wish to process
                    properties = step.get("customProperties")

                    mEndPoint = properties.get("mEndPoint")  # https://10.129.61.240:8065/citiconnect/v1.0/internal/sequencenumber
                    mUsername = properties.get("mUsername")
                    mPassword = properties.get("mPassword")
                    mProfileId = properties.get("mProfileId")   # EXPLANGUAGE1
                    mProfileIdChecked = properties.get("mProfileIdChecked") # "true"
                    mProfileIdExp = properties.get("mProfileIdExp") # 777899 etc

                    # Update this step field
                    stUpdateStep(id, stepIndex, apiCounter, profileId)
                    stepIndex+=1
 
            
        entry+=numberToFetchEachTime            

def stUpdateStep(id, stepIndex, apiCounter, profileid):
 
    global referer
    global stTimeout
    global stUrl

    env = 'TEST'

    print 'Updating ProfileID: ' + profileid

    url = stUrl + 'routes/' + str(id)
     
    path1 = '/steps/' + str(stepIndex) + '/customProperties/mProfileId'
    path2 = '/steps/' + str(stepIndex) + '/customProperties/mEndPoint'
    path3 = '/steps/' + str(stepIndex) + '/customProperties/mUsername'
    path4 = '/steps/' + str(stepIndex) + '/customProperties/mPassword'
    path5 = '/steps/' + str(stepIndex) + '/customProperties/mProfileIdChecked'
    path6 = '/steps/' + str(stepIndex) + '/customProperties/mProfileIdExp'

    if env == 'DEV':    
        jsonIn = [
                    {
                      'op': 'add',
                      'path': path1,
                      'value': 'EXPLANGUAGE1'
                    },
                    {
                      'op': 'add',
                      'path': path2,
                      'value': 'https://10.129.61.240:8065/citiconnect/v1.0/internal/sequencenumber'
                    },
                    {
                      'op': 'add',
                      'path': path3,
                      'value': '1b7827e5-e7b8-4f77-9eec-81c578802ff0'
                    },
                    {
                      'op': 'add',
                      'path': path4,
                      'value': 'd877e2e1-8835-41d4-b07c-0c126a0fd616'
                    },
                    {
                      'op': 'add',
                      'path': path5,
                      'value': 'true'
                    },
                  {
                      'op': 'add',
                      'path': path6,
                      'value': profileid
                    }
                  ]
    elif env == 'TEST':
        jsonIn = [
                    {
                      'op': 'add',
                      'path': path1,
                      'value': 'EXPLANGUAGE1'
                    },
                    {
                      'op': 'add',
                      'path': path2,
                      'value': 'https://api-back.test.citi.na.axway.cloud:8065/citiconnect/v1.0/internal/sequencenumber'
                    },
                    {
                      'op': 'add',
                      'path': path3,
                      'value': 'a2497c22-b0a8-4cc1-b270-9192ef69a72a'
                    },
                    {
                      'op': 'add',
                      'path': path4,
                      'value': '5b2aba5d-0a3b-4b53-a104-a16b04ca51eb'
                    },
                    {
                      'op': 'add',
                      'path': path5,
                      'value': 'true'
                    },
                  {
                      'op': 'add',
                      'path': path6,
                      'value': profileid
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
        errText = 'Error trying to Patch Route: ' + str(e.code) + ' ' + str(e.read())
        writeLog(errText, 'FAIL')
        return False

    except URLError as e:
        errText = 'Failed Connecting: ' + str(e.reason)
        writeLog(errText, 'FAIL')
        print 'I Cannot connect to ST'
        return False
    else:
        apiCounter.value+=1





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
    global stepTypeToUpdate

    #--------------------------------------------------------------------------------
    # BEGIN Configuration Section
    #--------------------------------------------------------------------------------
    # Please modify the below to match your environment


    # define how many parallel procs we will create
    numberParallelProcs = 10
    stTimeout = 120

    logFile='/home/axway/UpdateSteps.log'

    referer = 'PippinTheCat'
    stUrl = 'https://10.129.61.87:8444/api/v2.0/'                             #<- Put your URL here
    basicAuth = 'YWRtaW46YWRtaW4=' # from echo -n user:pass | base64          # username:password
    stepTypeToUpdate = 'CustomSequenceNumber'                                 #<- Change to the tyoe of step you wish to update - 
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
    # STEP 1 - 
    # Process all Simple Routes on the system

    stProcessSimpleRoutes(APICounter)   

    # Completion Section

    stLogout()
    APICounter.value+=1
    infoText = 'Completed Run. Number of APIs issued: ' + str(APICounter.value)
    writeLog( infoText, 'INFORMATION')



#------------------------------------------------------------------------------------
#

