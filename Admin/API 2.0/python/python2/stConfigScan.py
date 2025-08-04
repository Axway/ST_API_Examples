#! /usr/bin/python2
#
#
# V1.01 Ian Percival   16-Jun-2023	Fix typo in print output
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
#    A logile provides run time information
#    A file is used to store baseline config info
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


def stGetConfig(counter):

    global referer
    global stTimeout
    global stUrl

    windowSize = 100
    offset = 0
    getMore = True

    liveConfigs = {}

    while getMore:

        url = stUrl + 'configurations/options?offset='+ str(offset)+ '&limit=' + str(windowSize)
        request = urllib2.Request(url)
        request.add_header('Referer', referer)
        request.add_header('Accept', 'application/json')

        try:
            response = urllib2.urlopen(request, timeout=stTimeout)
        except HTTPError as e:
            errText = 'Error trying to GET Configs' + str(e.code) + ' ' + str(e.read())
            writeLog(errText, 'FAIL')
            return False

        except URLError as e:
            errText = 'Failed Connecting to GET configs ' + str(e.reason)
            writeLog(errText, 'FAIL')
            print 'I Cannot connect to ST'
            return False

        else:
            counter.value += 1
            rts = response.read()
            jsonResponse = json.loads(rts)
            resultSet = jsonResponse['resultSet']
            returnCount = resultSet['returnCount']

            if returnCount < windowSize:
                getMore = False

            results = jsonResponse['result']


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
    import pickle
    import ssl
    import string
    import sys
    import urllib2

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

    baselineFile = '/home/axway/stConfig-10.129.61.87.baseline'
    logFile='/home/axway/updateConfig.log'

    referer = 'PippinTheCat'
    stUrl = 'https://dogco.axway.university:8444/api/v2.0/'
    basicAuth = 'QVBJYWRtaW46QXh3YXkxMjM=' # from echo -n user:pass | base64

    #-------------------------------------------------------------------------------
    # END Configuration Section
    #-------------------------------------------------------------------------------


    APICounter = Value('i',0)


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
    # Read in the Composite Route

    cConfigs = stGetConfig(APICounter)

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

    stLogout()
    APICounter.value+=1
    infoText = 'Completed Run. Number of APIs issued: ' + str(APICounter.value)
    writeLog( infoText, 'INFORMATION')



#------------------------------------------------------------------------------------
#

