@echo off
REM ==============================================================================
REM Script Name: 02.applications_POST.bat
REM Author: Plamen Milenkov
REM Created: 2025-08-06
REM Location: Sofia
REM ==============================================================================
REM Description:
REM This script creates applications using the `/applications` endpoint.
REM It demonstrates:
REM - Checking for an existing application of a flow type
REM - Creating a flow application if not found
REM - Creating a maintenance application with a detailed schema
REM
REM Usage:
REM 02.applications_POST.bat
REM
REM Notes:
REM - Ensure that set_variables.bat is correctly configured and called.
REM - Maintenance applications require specific schema fields.
REM ==============================================================================

CALL ..\set_variables.bat

SET FLOW_APPLICATIONS=AdvancedRouting,Basic,HumanSystem,MBFT,SharedFolder,SiteMailbox,StandardRouter
SET MAINTENANCE_APPLICATIONS=AccountFilePurge,AccountTTL,ArchiveMaint,AuditLogMaint,LogEntryMaint,LoginThresholdMaintenance,PackageRetentionMaint,SentinelLinkDataMaint,TransferLogMaint,UnlicensedAccountMaint

FOR /F "tokens=3 delims=," %%A IN ("%FLOW_APPLICATIONS%") DO SET RANDOM_APP=%%A
echo Get the name of an application of type '%RANDOM_APP%'...
curl -s -k -u "%USER%:%PWD%" -X GET "https://%SERVER%:%PORT%/api/v2.0/applications?fields=name&type=%RANDOM_APP%" -H "accept: application/json" > app.json

FOR /F "delims=" %%B IN ('powershell -Command "(Get-Content app.json | ConvertFrom-Json).result[0].name"') DO SET NAME_OF_APP=%%B
echo Name of the application: %NAME_OF_APP%

IF "%NAME_OF_APP%"=="null" (
    echo No application of type '%RANDOM_APP%' found.
    echo Create an application of type '%RANDOM_APP%'...
    curl -s -k -u "%USER%:%PWD%" -X POST "https://%SERVER%:%PORT%/api/v2.0/applications" ^
    -H "accept: */*" -H "Content-Type: application/json" ^
    -d "{ \"type\": \"%RANDOM_APP%\", \"name\": \"%RANDOM_APP% Application\", \"notes\": \"This is a %RANDOM_APP% application\" }"
) ELSE (
    echo Application of type '%RANDOM_APP%' found.
)

FOR /F "tokens=1 delims=," %%C IN ("%MAINTENANCE_APPLICATIONS%") DO SET RANDOM_APP=%%C
echo Create an application of type '%RANDOM_APP%'...
curl -s -k -u "%USER%:%PWD%" -X POST "https://%SERVER%:%PORT%/api/v2.0/applications" ^
-H "accept: */*" -H "Content-Type: application/json" ^
-d "{ \"type\": \"%RANDOM_APP%\", \"name\": \"%RANDOM_APP% Application\", \"notes\": \"This is a %RANDOM_APP% application\", \"deleteFilesDays\": 90, \"pattern\": \"*.txt\", \"expirationPeriod\": true, \"removeFolders\": true, \"notifyDays\": \"90\", \"sendSentinelAlert\": false, \"warnNotifyAccount\": false, \"deletionNotifications\": false, \"deletionNotifyAccount\": false, \"schedules\": [ { \"tag\": \"%RANDOM_APP%\", \"type\": \"ONCE\", \"executionTimes\": [\"00:00\"], \"startDate\": \"2025-02-11T00:00:00Z\", \"skipHolidays\": false } ] }"
