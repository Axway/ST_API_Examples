#! /usr/bin/python2
#
#
# V1.00 Ian Percival   02-Jul-2021
#
#
# APIs used - /myself ( ST login and logout )
#             /routes ( GET , PUT)
#
# Description:
#    This script is designed to add NEW steps to a simple route that already contains
#     a number of existing steps.  
#    Using V2 APIS this means that the only way of accomplishing this is to use a PUT and to replace 
#     the whole simple route.
#
# Inputs:
#    1. JSON file containing the step to be added.
#    2. Step Offeset to insert the new step - 0 means that the new step shoule be at the begining of the steps, etc
#    3. Simple Route ID 
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


# This routine fetches ALL Composite routes on your system
# For any Composite routes that contain the name RP_OB_
# Scan the Simple Routes 
def stProcessCompositeRoutes(apiCounter):
    global referer
    global stTimeout
    global stUrl
    global stepTypeToUpdate

    url = stUrl + 'routes/type=SIMPLE'

    entry=0
    numberToFetchEachTime = 200
    keepLooping = True

    while keepLooping:
        url = stUrl + 'routes?type=COMPOSITE&offset=' + str(entry) + '&limit=' + str(numberToFetchEachTime)
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
                name = item.get("name")
                if 'RP_OB_FROM_CITI' not in name:
                    continue
                account = item.get("account")
                if 'citiconnect' == account:
                    continue
                
                profileIdArray = name.split('_')
                try:
                    profileId = profileIdArray[6]
                except IndexError:
                    print('No ProfileId on Route name for Account: ' + account)
                    continue
                # We get here with a Composite Route that matches our naming convention
                # Now get the Steps Array
                steps = item.get("steps")
                for item2 in steps:
                    type = item2.get("type")
                    if 'ExecuteRoute' not in type:
                        continue
                    sId = item2.get("executeRoute")
                    stUpdateSimpleRoute(sId, apiCounter, profileId)
                     
                    
 
        entry+=numberToFetchEachTime            

def stUpdateSimpleRoute(sId, apiCounter, profileId):
 
    global referer
    global sentinelPort
    global sentinelHost
    global stTimeout
    global stUrl



# Before we do anything, Check that the first step on the simple route is a 'Rename'
# Abort if not....


    url = stUrl + 'routes/' + str(sId)

    request5 = urllib2.Request(url)

    request5.add_header('Referer', referer)
    request5.add_header('Accept', 'application/json')

    try:
        response5 = urllib2.urlopen(request5, timeout=stTimeout)
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
        results5 = response5.read()
        jsonSimpleRoute5 = json.loads(results5)




        jsonSteps5 = jsonSimpleRoute5['steps']
     
        for step in jsonSteps5:
            stepType = step.get('type')
            # only proces if rename is the first step
            if stepType != 'Rename':
                return
            else:
                break



    
# Adding new steps 
# This is non trivial with V2.0 APIs.  We'll revert to V1.4 APIS as these allow the creation 
#  of individual steps.  
# 

            

    # We can reuse all the session settings 
    stUrlV14 = stUrl.replace('v2.0','v1.4')
    url = stUrlV14 + 'routes/' + str(sId) + '/steps'
  

    request2 = urllib2.Request(url)

    request2.get_method = lambda: 'POST'
    request2.add_header('Referer', referer)
    request2.add_header('Accept', 'application/json')
    request2.add_header('Content-Type', 'application/json')

    try:
        response2 = urllib2.urlopen(request2, json.dumps(jsonAdd3), timeout=stTimeout)
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
        results2 = response2.read()
        jsonStep1 = json.loads(results2)
        step1Id = jsonStep1['id']
       
# Great - Now we have created the first step and more importantly have the id - Now rinse and repest!

    request3 = urllib2.Request(url)

    request3.get_method = lambda: 'POST'
    request3.add_header('Referer', referer)
    request3.add_header('Accept', 'application/json')
    request3.add_header('Content-Type', 'application/json')

    try:
        response3 = urllib2.urlopen(request3, json.dumps(jsonAdd4), timeout=stTimeout)
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

    results3 = response3.read()
    jsonStep2 = json.loads(results3)
    step2Id = jsonStep2['id']
    print ('Step2 Id = ' + step2Id )

# Now we have the 2 new steps added to the end of the STEP list.
# Step 2 has Step1 is the Previous STEP. Now we have to reorder the steps....       
# Easiest way to do that is patch the simple Route now it contains all we need
# Lets get the simple Route and all steps first...    

    url = stUrl + 'routes/' + str(sId)
    print sId

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
        jsonSimpleRoute = json.loads(results)
        



        jsonSteps = jsonSimpleRoute['steps']
        stepIndex=0
        try:
            for step in jsonSteps:
                precedingStep = step.get("precedingStep")
                stepType = step.get('type')
                if stepIndex == 0 and precedingStep == None and stepType == 'Rename':
                    renameId = step.get('id')
                    # Preceding step was null - now make it point to our new steps
                    jsonSimpleRoute['steps'][0]['precedingStep'] = step2Id
                    break
                else:
                    print ('Non Standard Route')
                    return
        except:
            print ('Non Standard Step layout')
            return   

        
        stepIndex=0
        try:
            for step1 in jsonSteps:
                precedingStep = step1.get("precedingStep")
                stepType = step1.get('type')
                if stepType != 'CustomStepTracking':
                    stepIndex+=1
                    continue
                props = step1.get('customProperties')
                if props['mStageId'] != '38':
                    stepIndex+=1
                    continue
                if props['mState'] != 'STARTED':
                    stepIndex+=1
                    continue
                # Get here with the new STARTED step tracking.
                jsonSimpleRoute['steps'][stepIndex]['precedingStep'] = None
                break
        except:
            print ('Again Non Standard Step layout')
            return


        if len(jsonSteps) == stepIndex:
            print ('Something messed up')
            return

# patch does not seem to be doing what we need - so lets try and replace the route....
# jsonSimpleRoute is what was returned to us.  We have changed the ids that the rename points to 
# along with the ID that the first custom step tracking points to ie Null
# All that remains is to re-order the Steps Which we'll do via string manipulation

    

    SimpleRouteString = json.dumps(jsonSimpleRoute)      
   

    preSteps = SimpleRouteString[0:SimpleRouteString.find("steps")-1]

    
    stepsToEnd = SimpleRouteString[SimpleRouteString.find("steps")-1:]
    # We are lucky in that no step contains an array []

    postSteps = ',' + stepsToEnd[stepsToEnd.find("],")+2:]
    # This is ], blah blah

   

    steps = stepsToEnd[stepsToEnd.find("steps"): stepsToEnd.find("],")]
    steps = '{"' + steps
    steps += ']}'
    # This is now valid json
    stepsJson = json.loads(steps)


    stepsReorder = {}
    stepsReorder["steps"] = [{},{},{},{},{},{},{},{},{},{},{},{}]  # There will always be 12 steps in this use case
    
    
    # This will create the First Entry of our new steps 
    try:
        for item in stepsJson['steps']:
            if item.get('id') == step1Id:
                for key in item:
                    if key == 'metadata':
                        continue
                    elif key == 'customProperties':
                        stepsReorder["steps"][0][key] = {}
                        props = item.get('customProperties')
                        for key2, value2 in props.iteritems():
                            stepsReorder["steps"][0][key][key2] = value2
                    else:
                        stepsReorder["steps"][0][key] = item.get(key)
            else:
                continue
    except:
        print ('Non Standard Array case 3 - ignoring')
        return

    # This will create the Second Entry of our new steps
    try:
        for item in stepsJson['steps']:
            if item.get('id') == step2Id:
                for key in item:
                    if key == 'metadata':
                        continue
                    elif key == 'customProperties':
                        stepsReorder["steps"][1][key] = {}
                        props = item.get('customProperties')
                        for key2, value2 in props.iteritems():
                            stepsReorder["steps"][1][key][key2] = value2
                    else:
                        stepsReorder["steps"][1][key] = item.get(key)
            else:
                continue
    except:
        print('Non Standard Step array case 4 - Ignoring')
        return

    # Now copy all other Steps to the new array.
    index = 2
    try:
        for item in stepsJson['steps']:
            if item.get('id') == step1Id or item.get('id') == step2Id :
                continue 
            for key in item:
                    if key == 'metadata':
                        continue
                    elif key == 'customProperties':
                        stepsReorder["steps"][index][key] = {}
                        props = item.get('customProperties')
                        for key2, value2 in props.iteritems():
                            stepsReorder["steps"][index][key][key2] = value2
                    else:
                        stepsReorder["steps"][index][key] = item.get(key)
            index+=1
    except:
        print('Ignoring Non Standard Step array case 5')
        return

    # Now we have manipulated everything - Lets put it all back together and update!


    ps = json.dumps(stepsReorder)
    ps1 = ps[1:-1]
   

    

    replacementSimpleRoute = preSteps + ps1 + postSteps
    

    url = stUrl + 'routes/' + str(sId)


    request4 = urllib2.Request(url)

    request4.get_method = lambda: 'PUT'
    request4.add_header('Referer', referer)
    request4.add_header('Accept', 'application/json')
    request4.add_header('Content-Type', 'application/json')

    try:
        response2 = urllib2.urlopen(request4, replacementSimpleRoute, timeout=stTimeout)
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
    
     
    exit









         

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


# 
# 
def stValidateInputStepFile(APICounter, inputFile):

    # load the JSON as a dict
    f = open(inputFile)
    newStep = json.load(f)   
    f.close()
    newStep = sanitiseStep(newStep)
    # return a string rather than a dict
    return json.dumps(newStep)

# remove id, metadata and preceding step fileds from the input step
def sanitiseStep(inStep):

    if 'metadata' in inStep:
        inStep.pop('metadata',None)
    if 'precedingStep' in inStep:
        inStep.pop('precedingStep',None)
    if 'id' in inStep:
        inStep.pop('id',None)
    return inStep

 
def stGetSimpleRoute(APICounter, simpleId):
    global referer
    global sentinelPort
    global sentinelHost
    global stTimeout
    global stUrl

    url = stUrl + 'routes/' + str(sId)

    request = urllib2.Request(url)

    request.add_header('Referer', referer)
    request.add_header('Accept', 'application/json')

    try:
        response = urllib2.urlopen(request, timeout=stTimeout)
    except HTTPError as e:
        errText = 'Error trying to GET Simple Route ' + str(e.code) + ' ' + str(e.read())
        writeLog(errText, 'FAIL')
        return False

    except URLError as e:
        errText = 'Failed Connecting to GET Simple Routes: ' + str(e.reason)
        writeLog(errText, 'FAIL')
        print 'I Cannot connect to ST'
        return False

    else:
        apiCounter.value+=1
        return response.read()
   
def simpleRouteString = constructNewSimpleRoute(simpleRouteString, inputFile, stepInsertIndex):
    jsonSimpleRoute = json.loads(simpleRouteString)
    jsonSteps = jsonSimpleRoute['steps']
    print len(jsonSteps)


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
    global sentinelPort
    global sentinelHost
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

    logFile='/home/axway/UpdateSimpleRoutes.log'

    referer = 'PippinTheCat'
    stUrl = 'https://10.129.61.87:8444/api/v2.0/'                             #<- Put your URL here
    basicAuth = 'YWRtaW46YWRtaW4=' # from echo -n user:pass | base64          # username:password

    sentinelPort = '1305'                                                     # DEV PSO
    sentinelHost = 'slnxphxshvra312.lab.phx.axway.int'                        # DEV PSO
  

 
    #-------------------------------------------------------------------------------
    # END Configuration Section
    #-------------------------------------------------------------------------------


    #--------------------------------------------------------------------------------
    # BEGIN User Input Section
    #--------------------------------------------------------------------------------
    
    try:
        inputFile = sys.argv[1]
    except:        
        print 'Please provide the filename of a  JSON format step for me to process'
        sys.exit(0) 

    try:
        stepInsertIndex = sys.argv[2]
    except:        
        print 'Please enter a numeric index 0(first), 1, 2 etc for where the step should be inserted'
        sys.exit(0) 

    try:
        simpleId = sys.argv[3]
    except:        
        print 'Please enter the simple route ID'
        sys.exit(0)

    #--------------------------------------------------------------------------------
    # END User Input Section
    #--------------------------------------------------------------------------------

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
    # Read in the new step and sanitise it. Keep in string format

    inputFile = stValidateInputStepFile(APICounter, inputFile)   

    # STEP 2 - 
    # Read in the Simple Route and get all the associated Steps

    simpleRouteString = stGetSimpleRoute(APICounter, simpleId)

    # STEP 3
    # Manipulate the existing Simple Rout and insert the new step
    simpleRouteString = constructNewSimpleRoute(simpleRouteString, inputFile, stepInsertIndex)


    # Completion Section

    stLogout()
    APICounter.value+=1
    infoText = 'Completed Run. Number of APIs issued: ' + str(APICounter.value)
    writeLog( infoText, 'INFORMATION')



#------------------------------------------------------------------------------------
#

