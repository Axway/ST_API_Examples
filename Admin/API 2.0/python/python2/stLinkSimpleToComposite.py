#! /usr/bin/python
#
#
# V1.00 Ian Percival   16-Oct--2020
#
# Script to add a SimpleRoute and Steps to a Composite/Package Route 
#  essentially adds the ExecuteRoute step to the package route
# 
# APIs used - /myself ( ST login and logout )
#             /routes ( GET and PUT )
#
# Usage: ./stLinkSimpleToComposite.py compRouteId simpleRouteId
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


def stGetRoute(routeId, counter):

    global referer
    global stTimeout
    global stUrl

    url = stUrl + 'routes/' + routeId
    request = urllib2.Request(url)
    request.add_header('Referer', referer)
    request.add_header('Accept', 'application/json')

    try:
        response = urllib2.urlopen(request, timeout=stTimeout)
    except HTTPError as e:
        errText = 'Error trying to GET routes' + str(e.code) + ' ' + str(e.read())
        writeLog(errText, 'FAIL')
        return False

    except URLError as e:
        errText = 'Failed Connecting to GET routes: ' + str(e.reason)
        writeLog(errText, 'FAIL')
        print 'I Cannot connect to ST'
        return False

    else:
        counter.value+=1
        rts = response.read()
        jsonResponse = json.loads(rts)
        return jsonResponse

def stUpdateRoute(jsonin, routeId, counter):

    global referer
    global stTimeout
    global stUrl

    url = stUrl + 'routes/' + str(routeId)
    request = urllib2.Request(url)
    request.add_header('Referer', referer)
    request.add_header('Accept', 'application/json')
    request.add_header('Content-Type', 'application/json')
    request.get_method = lambda: 'PUT'

    try:
        response = urllib2.urlopen(request, json.dumps(jsonin), timeout=120)
    except HTTPError as e:
        errText = 'Error trying to update Routes ' + str(e.code) + ' ' + str(e.read())
        writeLog(errText, 'FAIL')
        return False

    except URLError as e:
        errText = 'Failed Connecting to PUT Routes: ' + str(e.reason)
        writeLog(errText, 'FAIL')
        print 'I Cannot connect to ST'
        return False

    else:
        counter.value+=1



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

    logFile='/home/axway/deleteProcess.log'

    apName = 'AnApp'
    referer = 'PippinTheCat'
    stUrl = 'https://10.129.58.129:8444/api/v2.0/'
    basicAuth = 'YWRtaW46YWRtaW4=' # from echo -n user:pass | base64
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

    # READ in the command line arguments
    try:
        compId = sys.argv[1]
    except:
        print 'Please provide an input argument 1 for the Composite Route ID'
        quit()

    try:
        simpleId = sys.argv[2]
    except:
        print 'Please provide an input argument 2 for the Simple Route ID'
        quit()




    # Now use Session Management

    if not stLogin(basicAuth):
        print "Something nasty! Couldn't login to ST"
        sys.exit(0)
    APICounter.value+=1


    # We won't use multiprocessing here as we are not doing too much
    # STEP 1 - 
    # Read in the Composite Route

    cRoute = stGetRoute(compId, APICounter)   

    cRoute['steps'] = [{'type': 'ExecuteRoute',
                        'status': 'ENABLED',
                        'autostart': False,
                        'executeRoute': simpleId}]

    # This works if we INCLUDE metadata as is - but removing it anyway as this is all applied by ST anyway.
    cRoute.pop("metadata")

    stUpdateRoute(cRoute, compId, APICounter)
    

    # Completion Section

    stLogout()
    APICounter.value+=1
    infoText = 'Completed Run. Number of APIs issued: ' + str(APICounter.value)
    writeLog( infoText, 'INFORMATION')



#------------------------------------------------------------------------------------
#

