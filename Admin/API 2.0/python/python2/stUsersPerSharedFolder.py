#! /usr/bin/python2
#
#
# V1.00 Ian Percival   12-Mar-2021
#
#
# APIs used - /myself ( ST login and logout )
#             /subscriptions ( GET )
#             /applications ( GET )
#
# Description:
#    This script processes ALL subscriptions on a system.
#    It looks for any SharedFolder application subscriptions and 
#    builds a list of accounts that belong to each folder
#    This is a single threaded version so that its easy to see 
#    how it works.
#
# Outputs:
#    A logile provides some information
#
# Start of Program is 'main' below.
#    Configuration section is there for you to tailor to your env...
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

# This routine fetches ALL applicationss on your system
def stReadApplications(apiCounter, sharedFolderApps):
    global referer
    global stTimeout
    global stUrl

    url = stUrl + 'applications'

    entry=0
    numberToFetchEachTime = 200
    keepLooping = True

    while keepLooping:
        url = stUrl + 'applications?offset=' + str(entry) + '&limit=' + str(numberToFetchEachTime)
        request = urllib2.Request(url)
        request.add_header('Referer', referer)
        request.add_header('Accept', 'application/json')

        try:
            response = urllib2.urlopen(request, timeout=stTimeout)
        except HTTPError as e:
            errText = 'Error trying to GET Applications ' + str(e.code) + ' ' + str(e.read())
            writeLog(errText, 'FAIL')
            return False

        except URLError as e:
            errText = 'Failed Connecting to GET Applications: ' + str(e.reason)
            writeLog(errText, 'FAIL')
            print 'I Cannot connect to ST'
            return False

        else:
            apiCounter.value+=1
            results = response.read()
            jsonResponse = json.loads(results)
            jsonApplications = jsonResponse["result"]

            if len(jsonApplications) == 0:
                keepLooping = False
                continue

            for item in jsonApplications:
                type = item.get("type")
                if 'SharedFolder' not in type:
                    continue

                folder = item.get('sharedFolder')
                name = item.get('name')
                sharedFolderApps[name] = folder

        entry+=numberToFetchEachTime


# This routine fetches ALL subscriptions on your system
def stProcessSubscriptions(apiCounter, sharedFolderAccts):
    global referer
    global stTimeout
    global stUrl

    url = stUrl + 'subscriptions'

    entry=0
    numberToFetchEachTime = 200
    keepLooping = True

    while keepLooping:
        url = stUrl + 'subscriptions?offset=' + str(entry) + '&limit=' + str(numberToFetchEachTime)
        request = urllib2.Request(url)
        request.add_header('Referer', referer)
        request.add_header('Accept', 'application/json')

        try:
            response = urllib2.urlopen(request, timeout=stTimeout)
        except HTTPError as e:
            errText = 'Error trying to GET Subscriptions ' + str(e.code) + ' ' + str(e.read())
            writeLog(errText, 'FAIL')
            return False

        except URLError as e:
            errText = 'Failed Connecting to GET Subscriptions: ' + str(e.reason)
            writeLog(errText, 'FAIL')
            print 'I Cannot connect to ST'
            return False

        else:
            apiCounter.value+=1
            results = response.read()
            jsonResponse = json.loads(results)
            jsonSubscriptions = jsonResponse["result"]

            if len(jsonSubscriptions) == 0:
                keepLooping = False
                continue

            for item in jsonSubscriptions:
                id = item.get("id")
                type = item.get("type")
                # ignore any non Shared-Folder Subscriptions
                if 'SharedFolder' not in type:
                    continue

                account = item.get("account")
                # folder would be the folder name seen by the user when they login ie via the web-client
                # The REAL on disk folder name is defined in the application
                folder = item.get("folder")
                application = item.get("application")

                if application not in sharedFolderAccts:
                    sharedFolderAccts[application] = [account]
                else:
                    sharedFolderAccts[application].append(account) 
            
        entry+=numberToFetchEachTime            



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
    import csv
    import datetime
    import httplib
    import json
    import multiprocessing
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
    global stepTypeToUpdate

    #--------------------------------------------------------------------------------
    # BEGIN Configuration Section
    #--------------------------------------------------------------------------------
    # Please modify the below to match your environment


    # define how many parallel procs we will create
    numberParallelProcs = 10
    stTimeout = 120

    logFile='/home/axway/ReadSubscriptions.log'
    outputCSVfile = 'FolderAccts.csv'

    referer = 'PippinTheCat'
    stUrl = 'https://10.128.132.243:8444/api/v2.0/'                             #<- Put your URL here
    basicAuth = 'YWRtaW46YWRtaW4=' # from echo -n user:pass | base64          # username:password
    
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


    # We won't use multiprocessing here for clarity
   
    # STEP 1 -
    # Create a dictionary of folders with the application name as the index
    # To do this just scan the applications and obtain the real foldername from them
    sharedFolderApps = {}
    t = "I'm now Building a list of all SharedFolder applications"
    print t
    stReadApplications(APICounter, sharedFolderApps)


    # STEP 2 - 
    # Process all Subscriptions on the system
    # adding each account that accesses a sharedFolderApplication as a list of accounts
    sharedFolderAccounts = {}
    t = "I'm now scanning ALL subscriptions on your system - This may take some time"
    print t
    stProcessSubscriptions(APICounter, sharedFolderAccounts)   

    t = "Now I'm building your csv file"
    print t
    # STEP 3 - Now generate the output file showing all of this.
    try:
        fHandle1 = open(outputCSVfile,'a+')
        # Write the Header
        t = 'ApplicationName,Folder,Accounts' + '\n'
        fHandle1.write(t)
        for key, values in sharedFolderAccounts.iteritems():
            folder = sharedFolderApps[key]
            s = ','
            for items in values:
                s+=items + ','
            s = s[:-1]   
            t = key + ',' + folder + s + '\n'
            fHandle1.write(t)
        fHandle1.close()
    except:
        print 'Problem writing to csv file'
        
    # Completion Section

    stLogout()
    APICounter.value+=1
    infoText = 'Completed Run. Number of APIs issued: ' + str(APICounter.value)
    writeLog( infoText, 'INFORMATION')



#------------------------------------------------------------------------------------
#

