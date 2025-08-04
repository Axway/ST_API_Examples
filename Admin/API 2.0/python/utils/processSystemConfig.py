#! /usr/bin/python2
#
# V1.00 Ian Percival    27-Feb-2021
#
# Exrtact userclasses in XML format from the systemConfiguration.xml exported file
# User V2.0 APIs to create on a target ST 5.5 system
# 
# Usage: ./extractUserClasses.py systemConfiguration.xml.521
# Output will be the <UserClass> section in uclass.xml converted to 5.5 format 



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


def stLogin(url, refHeader, basicAuthBase64):

    urlfinal = url + '/myself'

    request = urllib2.Request(urlfinal)
    request.add_header('Accept', 'application/json')
    request.add_header('Authorization', 'Basic %s' % basicAuthBase64)
    request.add_header('Referer', refHeader)
    request.get_method = lambda: 'POST'

    try:
        response = urllib2.urlopen(request, timeout=120)
    except HTTPError as e:
        ot= 'Error code in login: ' + str(e.code) + ' ' +  str(e.reason) + ' ' + str(e.read())
        print ot
        quit()

    except URLError as e:
        ot= 'Failed to Connect: '+ str(e.reason)
        print ot
        quit()
    else:

        # Succesful login
        result = response.read()
        # {
        #     "message" : "Logged in"
        # }
        jsonResponse = json.loads(result)
        message = jsonResponse.get("message")
        if 'Logged in' == message:
            return True
        else:
            return False


def stLogout(url, refHeader):

    urlfinal = url + '/myself'

    request = urllib2.Request(urlfinal)
    request.add_header('Accept', 'application/json')
    request.add_header('Referer', refHeader)
    request.get_method = lambda: 'DELETE'

    try:
        response = urllib2.urlopen(request, timeout=120)
    except HTTPError as e:
        ot= 'Error code in logout: ' + str(e.code) + ' ' +  str(e.reason) + ' ' + str(e.read())
        print ot
        quit()

    except URLError as e:
        ot= 'Failed to Connect: '+ str(e.reason)
        print ot
        quit()
    else:

        # Succesful logout
        result = response.read()
        # {
        #     "message" : "Logged out"
        # }
        jsonResponse = json.loads(result)
        message = jsonResponse.get("message")
        if 'Logged out' == message:
            return True
        else:
            return False


def stCreateUserClass( url, refHeader, uclassJson ):

    global apiCounter

    urlfinal = url + '/userClasses'

    request = urllib2.Request(urlfinal)

    request.add_header('Accept', 'application/json')
    request.add_header('Referer', refHeader)
    request.add_header('Content-Type', 'application/json')
    request.get_method = lambda: 'POST'

    try:
        response = urllib2.urlopen(request, json.dumps(uclassJson), timeout=120)
    except HTTPError as e:
        ot= 'Error code in Create User Class: ' + str(e.code) + ' ' + str(e.read())
        print ot
        quit()
    except URLError as e:
        ot= 'Failed to Connect: '+ str(e.reason)
        print ot
        quit()
    else:
        apiCounter+=1
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
    import ssl
    import string
    import sys
    import urllib2
    import xml.etree.ElementTree as ET

    from urllib2 import HTTPError
    from urllib2 import URLError

    global apiCounter 
    global logFile


    # Configurable Inputs
    #----------------------------------------------------------------
    # Edit the values below as appropriate
    #----------------------------------------------------------------
    # This is the target ST system
    destURL = 'https://10.128.132.243:8444/api/v2.0'
    #destURL = 'https://10.129.128.45:444/api/v2.0' # Gilead 5.4/5.5 Lab VM 
    #basicAuth = 'YXh3YXlhZG1pbjpheHdheWFkbWlu'      # echo -n 'user:pass' | base64
    basicAuth = 'YWRtaW46YWRtaW4='
    logFile='extractUserClasses.log'
    xmlFile='new.xml'
  

    # READ in the command line arguments
    try:
        inputFile = sys.argv[1]
    except:        
        print 'Please provide an input XML filename for me to process'
        sys.exit(0)


    
    outputString = 'Starting at ' + str(datetime.datetime.now())
    writeLog(outputString, 'INFORMATION')

    apiCounter = 0
    totalNumUserClass = 0
    gtr32UC = 0


    #----------------------------------
    #STEP 1 Setup ST session Management
    #----------------------------------
    refHeader = destURL + '/PippinCat'
    # add the cookiejar for session management
    cookyJar = cookielib.CookieJar()

    sslContext = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
    sslContext.verify_mode = ssl.CERT_NONE                           # for now no cert validations...
    #sslContext.load_cert_chain(clientCertWithCA, clientPrivateKey)  # If we wish to switch to cert authentication rather than basic - enable this
    httpsOpener = urllib2.build_opener(urllib2.HTTPSHandler(context=sslContext),urllib2.HTTPCookieProcessor(cookyJar))

    # This is now global for all subsequent API calls - we are OK to do this as only referencing one target...
    urllib2.install_opener(httpsOpener)

    #-------------------
    # STEP 2 Login to ST
    #-------------------
    #if not stLogin(destURL, refHeader, basicAuth):
    #   print 'I could not login to ST'
    #   quit()
    apiCounter+=1 

    #---------------------------------
    # STEP 3 - Now load the input File
    #---------------------------------
    xmlTree = ET.parse(inputFile) 
    root = xmlTree.getroot()



    #--------------------------------
    # UserClass from 5.2.1 looks like this:-
    #
    # <UserClass>
    #    <name>GFTS_DEV_IT_SOLUTIONS_DEV_EXT_WORKDAY</name>
    #    <type>*</type>
    #    <order>1</order>
    #    <enabled>true</enabled>
    #    <user>*</user>
    #    <group>*</group>
    #    <host>*</host>
    #    <expression>memberof("CN=GFTS_DEV_IT_SOLUTIONS_DEV_EXT_WORKDAY,OU=DEV,OU=IT_SOLUTIONS_DEV,OU=GFTS Groups,OU=Groups,DC=partners,DC=gilead,DC=com",LDAP_DIR_memberOf$collection)</expression>
    #    <configurationProfile>Default</configurationProfile>
    #</UserClass>
    # 5.2.1 expression format memberof("CN=GFTS_ADMINS,OU=GFTS,OU=Delegated Groups,OU=Groups,OU=FC,DC=na,DC=gilead,DC=com",LDAP_DIR_memberOf$collection)
    # 5.5 format  isset("LDAP_DIR_memberOf") ? memberof("CN=GFTS_ADMINS,OU=GFTS,OU=Delegated Groups,OU=Groups,DC=partners,DC=gilead,DC=com",LDAP_DIR_memberOf$collection) : false


    ofile = 'Uclass.xml'

    uClassXML = ''



    for uclass in root.findall('./UserClass'):
       name = uclass.find('name').text
       type = uclass.find('type').text   
       order = uclass.find('order').text
       enabled = uclass.find('enabled').text
       user = uclass.find('user').text
       group = uclass.find('group').text
       host = uclass.find('host').text
       expression = uclass.find('expression').text
       cProfile = uclass.find('configurationProfile').text
       
       totalNumUserClass += 1

       #className must be 0 - 32 chars if using APIs
       #if len(name) > 45:
       #    t = 'Name Length violation. Name: ' + str(name) + ' is greater than 32 chars - ignoring....'
       #    gtr32UC+=1
       #    writeLog(t, 'FATAL')
       #    continue
     
       #if 'VirtClass' in name:
       #    continue
       #if 'RealClass' in name:
       #    continue

       if expression == None:
           expression55 = None
       elif 'memberof' in expression: 
           expression55 = 'isset("LDAP_DIR_memberOf") ? ' + expression + ' : false'
       else:
           expression55 = expression

       uclassJson = {
                       'className' : name,
                       'userType': type,
                       'order' : order,
                       'group' : group,
                       'userName': user,
                       'address': host,
                       'enabled': enabled,
                       'expression': expression55
                    }      
       uClassXML='<UserClass>'
       uClassXML+='<name>' + str(name) + '</name>\n'
       uClassXML+='<type>' + str(type) + '</type>\n'
       uClassXML+='<order>' + str(order) + '</order>\n'
       uClassXML+='<enabled>' + str(enabled) + '</enabled>\n'
       uClassXML+='<user>' + str(user) + '</user>\n'
       uClassXML+='<group>' + str(group) + '</group>\n'
       uClassXML+='<host>' + str(host) + '</host>\n'
       uClassXML+='<expression>' + expression55 + '</expression>\n'
       uClassXML+='</UserClass>\n'   
      
       xmlHandle = open(xmlFile,'a+')
       xmlHandle.write(uClassXML)
       xmlHandle.close()

       
                    
       #stCreateUserClass( destURL, refHeader, uclassJson )
       #t = 'SUCCESS: created userClass ' + str(name)
       #writeLog(t, 'INFORMATION')


    # Close the session
    
    # stLogout(destURL, refHeader)

    apiCounter+=1

    outputString = 'I issued: ' + str(apiCounter) + ' APIs on this run'
    writeLog(outputString, 'INFORMATION')
    outputString = 'Stopping at ' + str(datetime.datetime.now())
    writeLog(outputString, 'INFORMATION')
    outputString = 'Total Number of UserClasses: ' + str(totalNumUserClass)
    writeLog(outputString, 'INFORMATION')
    outputString = 'name gtr 32 UserClasses: ' + str(gtr32UC)
    writeLog(outputString, 'INFORMATION')


