#! /usr/bin/python
#
#
# V1.00 Ian Percival    13-Apr-2021
#
# Tool to count the number of Certificates and to indicate expirations
#
#
# APIs used - None - this is an XML processor.
#
#
# Usage:
#
# Outputs:
#    A logile provides some information
#
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

def extractXMLparams(config, sourceFile):

    xmlTree = ET.parse(sourceFile)
    # ConfigurationModel
    root1 = xmlTree.getroot()

    for opt in root1.findall('options'):
        for opt2 in opt.findall('option'):
            for opt3 in opt2.findall('optionItem'):
                optValue = None
                for child in opt3:
                    if child.tag == 'name':
                        optName = child.text
                    if child.tag == 'value':
                        optValue = child.text
                if optValue == None:
                    config[optName] = 'Not Specified'
                else:
                    config[optName] = optValue
                



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


    logFile='/home/axway/certificateXML.log'


    #-------------------------------------------------------------------------------
    # END Configuration Section
    #-------------------------------------------------------------------------------


    APICounter = Value('i',0)


    # READ in the command line arguments
    try:
        sourceFile1 = sys.argv[1]
    except:
        print 'Please enter the Filename of the first exported XML'
        sys.exit(0)




    outputString = 'Starting at ' + str(datetime.datetime.now())
    writeLog(outputString, 'INFORMATION')


    logEntry = 'Number of CPUs available to this server: ' + str(multiprocessing.cpu_count())
    writeLog( logEntry, 'INFORMATION')

    #logEntry = 'Commencing Run Using ' + str(numberParallelProcs) + ' threads\n'
    #writeLog( logEntry, 'INFORMATION')




    #for name, value in config1.items():
    #    print('{} {}'.format(name, value))


    # which has more params?
    if len(config1) > len(config2):
        for name,value in config1.items():
            # Check to see if config2 had the paramater
            # if so compare values
            if name in config2:
                val2 = config2[name]
                if value == val2:
                    # values are the same
                    continue
                else:
                    t = name + ' has value: ' + str(value) + ' and value: ' + str(val2)
                    print t
            else:
                t = name + ' is not present in the second file'
                #print t
    else:
        print 'Please issue this command again - reversing the order of the comparison files'
    # Completion Section

    infoText = 'Completed Run.'
    writeLog( infoText, 'INFORMATION')



#------------------------------------------------------------------------------------
#

