#! /usr/bin/python3
#
# V1.00 Ian Percival    18-Oct-2021
#
#



# Use a common logFile in case running in batch etc

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
    
   
    
def getTransactionManagerStatus(session, stUrl):

    global referer   
    global stTimeout

    url = stUrl + 'transactionManager'
    
    headers = {'Referer': referer,
              'Accept': 'application/json'}
    try:
        response = session.get(url, headers=headers, verify=False, timeout=stTimeout)
    except requests.ConnectionError as ec:
        writelog('I cannot connect to ' + stURL,'FATAL')
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
        writeLog('Get TM status','SUCCESS')
        #print( response.status_code )
        #print( response.json())
        jsonResponse = response.json()
        if "Running" in jsonResponse["status"]:
            return True
        else: 
            return False
                    
def stopClusterServices(session, stUrl, service):

    global referer
    global stTimeout

    url = stUrl + 'clusterServices/operations?operation=stop&serviceName=' + service
    
    headers = {'Referer': referer,
              'Accept': 'application/json'}

    try:
        response = session.post(url, headers=headers, verify=False, timeout=stTimeout)
    except requests.ConnectionError as ec:
        writelog('I cannot connect to ' + stURL,'FATAL')
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
        print(response)
        writeLog('Stop Cluster Services','SUCCESS')
    
# folder monitor and scheduler
def getClusterServiceStatus(session, stUrl, service):

    global referer
    global stTimeout

    url = stUrl + 'clusterServices?serviceName=' + service
    
    headers = {'Referer': referer,
              'Accept': 'application/json'}

    try:
        response = session.get(url, headers=headers, verify=False, timeout=stTimeout)
    except requests.ConnectionError as ec:
        writelog('I cannot connect to ' + stURL,'FATAL')
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
        writeLog('Get Cluster Services','SUCCESS')
        #print( response.status_code )
        print( response.json())
        jsonResponse = response.json()
        if "Running" in jsonResponse["status"]:
            return True
        else: 
            return False
                    
        

def stopDaemon(session, stUrl, protocol,gracefultime):

    global referer
    global stTimeout

    url = stUrl + 'servers?fields=isActive,serverName&protocol=' + protocol
    
    headers = {'Referer': referer,
              'Accept': 'application/json'}    

    try:
        response = session.get(url, headers=headers, verify=False, timeout=stTimeout)
    except requests.ConnectionError as ec:
        writelog('I cannot connect to ' + stURL,'FATAL')
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
        writeLog('Get Daemon Services','SUCCESS')
        #print( response.status_code )
        #print( response.json())
        jsonResponse = response.json()
        dStatus = jsonResponse["result"]
        dSet = jsonResponse["resultSet"]
        docunt = dSet["returnCount"]
        for item in dStatus:
            name = item.get("serverName")
            status = item.get("isActive")   
            if status:
                t = protocol + ' is still running'
                #print(t)
                url2 = stUrl + 'daemons/operations?operation=stop&serverName=' + quote(name) + '&graceful=true&timeout=' + gracefultime

                try:
                    response2 = session.post(url2, headers=headers, verify=False, timeout=stTimeout)
                except requests.exceptions.HTTPError as eh:
                    writeLog('HTTP Error','FATAL')
                    raise SystemExit(eh)
                except requests.exceptions.Timeout as et:
                    writeLog('Timeout Error:' + str(et), 'FATAL')
                    raise SystemExit(et)
                except requests.exceptions.RequestException as e:
                    raise SystemExit(e)
                else:  
                    print(response2)

def getServerDaemonsStatus(session, stUrl, protocol):

    global referer
    global stTimeout

    url = stUrl + 'servers?fields=isActive&protocol=' + protocol
    
    headers = {'Referer': referer,
              'Accept': 'application/json'}    

    try:
        response = session.get(url, headers=headers, verify=False, timeout=stTimeout)
    except requests.ConnectionError as ec:
        writelog('I cannot connect to ' + stURL,'FATAL')
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
        writeLog('Get Daemon Services','SUCCESS')
        #print( response.status_code )
        #print( response.json())
        jsonResponse = response.json()
        dStatus = jsonResponse["result"]
        
        daemonRunning = False
        for item in dStatus:
            protocol = item.get("protocol")
            status = item.get("isActive")   
            if status:
                t = protocol + ' is still running'
                print(t)
                daemonRunning = True

        return daemonRunning

def stopTransactionManager(session, stUrl, gtime):

    global referer
    global stTimeout

    url = stUrl + 'transactionManager/operations?operation=stop&graceful=true&timeout=' + gtime
    
    headers = {'Referer': referer,
              'Accept': 'application/json'}

    try:
        response = session.post(url, headers=headers, verify=False, timeout=stTimeout)
    except requests.ConnectionError as ec:
        writelog('I cannot connect to ' + stURL,'FATAL')
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
        print(response)
        writeLog('Stop Transaction Manager','SUCCESS')


# Login to ST using session management
#
# This is the ST api/v1.4/myself POST method
#

def stLogin(basicAuth, session, stUrl):



    global referer
    global stTimeout


    url = stUrl + 'myself'
    authString = 'Basic ' + basicAuth

    # If using Certiificate auth
    #headers = {'Referer': referer,
    #          'Accept': 'application/json'}

    headers = {'Referer': referer,
              'Accept': 'application/json',
              'Authorization': authString}

    try:
        response = session.post(url, headers=headers, verify=False, timeout=stTimeout)
    except requests.ConnectionError as ec:
        writelog('I cannot connect to ' + stURL,'FATAL')
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
# This is the ST api/v1.4/myself DELETE method
#

def stLogout(session, stUrl):

    global referer
    global stTimeout

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
    import os
    import requests
    import ssl
    import string
    import sys
    import time

    from multiprocessing import Value
    from requests.packages.urllib3.exceptions import InsecureRequestWarning
    from urllib.parse import quote
    
    global logFile
    global referer
    global stTimeout

    #--------------------------------------------------------------------------------
    # BEGIN Configuration Section
    #--------------------------------------------------------------------------------
    # Please modify the below to match your environment

    # define how many parallel procs we will create
    numberParallelProcs = 10
    stTimeout = 120
    logFile='my.log'
    referer = 'PippinTheCat'

    stUrlCore = 'https://axway1.training.local:444/api/v2.0/'
    stUrlEdge = 'https://axway3.training.local:444/api/v2.0/'
    basicAuth = 'YWRtaW46YWRtaW4=' # from echo -n user:pass | base64

    #-------------------------------------------------------------------------------
    # END Configuration Section
    #-------------------------------------------------------------------------------





    try:
        gtime = sys.argv[1]
    except IndexError:
        errText = 'Please provide argument 1 - the number of seconds to wait for daemon shutdown'
        print(errText)
        sys.exit(0)




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

    sessionMgtCore = requests.Session()
    sessionMgtEdge = requests.Session()

    # We are turning off Cert validation - stop the warning messages
    requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

    # Now use Session Management
    if not stLogin(basicAuth, sessionMgtCore, stUrlCore):
        print("Something nasty! Couldn't login to ST Core")
        sys.exit(0)

    APICounter.value += 1

    if not stLogin(basicAuth, sessionMgtEdge, stUrlEdge):
        print("Something nasty! Couldn't login to ST Edge")
        sys.exit(0)

    APICounter.value += 1

    
    folderMonitorRunning = True
    while folderMonitorRunning:
        if getClusterServiceStatus(sessionMgtCore, stUrlCore, "FolderMonitor"):
            print('A Folder Monitor is still running')
            APICounter.value += 1
            stopClusterServices(sessionMgtCore, stUrlCore, "FolderMonitor")
            APICounter.value += 1
            time.sleep(5)
        else:
            folderMonitorRunning = False

    schedulerRunning = True
    while schedulerRunning:      
        if getClusterServiceStatus(sessionMgtCore, stUrlCore, "Scheduler"):
            print('A Scheduler is still running')
            APICounter.value += 1
            stopClusterServices(sessionMgtCore, stUrlCore, "Scheduler")
            APICounter.value += 1
            time.sleep(5)
        else:
            schedulerRunning = False
            
    
    # Shutdown Core Daemons
    protocolsC = {"http" : True,
                 "pesit": True,
                 "ssh": True,
                 "ftp": True,
                 "as2": True}
    
            
  
    for key, value in protocolsC.items():
        if getServerDaemonsStatus(sessionMgtCore, stUrlCore, key):
                APICounter.value += 1
                stopDaemon(sessionMgtCore, stUrlCore, key, gtime)
                APICounter.value += 1
                
    # Shutdown Edge Daemons
    protocolsE = {"pesit": True,
                 "ssh": True,
                 "http": True,
                 "ftp": True,
                 "as2": True}
                 
    for key, value in protocolsE.items():
        if getServerDaemonsStatus(sessionMgtEdge, stUrlEdge, key):
                APICounter.value += 1
                stopDaemon(sessionMgtEdge, stUrlEdge, key, gtime)
                APICounter.value += 1
                     
    # Now wait till daemons have gone 
    # Core
    #         
    loopAgain = True
    while loopAgain:
        activeCount = 5
        for key, value in protocolsC.items():
            if value == False:
                activeCount-= 1
                  
            if getServerDaemonsStatus(sessionMgtCore, stUrlCore, key):
                APICounter.value += 1
                stopDaemon(sessionMgtCore, stUrlCore, key, gtime)
                APICounter.value += 1
            else:
                protocolsC[key] = False
                activeCount-=1
                
            if activeCount == 0 :
                loopAgain = False
                break
            time.sleep(5)


    # Now wait till daemons have gone 
    # Edge
    #         
    loopAgain = True
    while loopAgain:
        activeCount = 5
        for key, value in protocolsE.items():
            if value == False:
                activeCount-= 1
                  
            if getServerDaemonsStatus(sessionMgtEdge, stUrlEdge, key):
                APICounter.value += 1
                stopDaemon(sessionMgtEdge, stUrlEdge, key, gtime)
                APICounter.value += 1
            else:
                protocolsE[key] = False
                activeCount-=1
                
            if activeCount == 0 :
                loopAgain = False
                break
            time.sleep(5)


                
        
    if getTransactionManagerStatus(sessionMgtCore, stUrlCore): 
        print('The TM is still running')
        stopTransactionManager(sessionMgtCore, stUrlCore, gtime)   

    # Completion Section
    stLogout(sessionMgtCore, stUrlCore)
    APICounter.value+=1
    
    stLogout(sessionMgtEdge, stUrlEdge)
    APICounter.value+=1

    infoText = 'Completed Run. Number of APIs issued: ' + str(APICounter.value)
    writeLog( infoText, 'INFORMATION')


