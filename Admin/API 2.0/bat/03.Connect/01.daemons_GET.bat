@echo off
REM ==============================================================================
REM Script Name: 01_daemons_GET.bat
REM Author: Plamen Milenkov
REM Created: 2025-08-06
REM Location: Sofia
REM ==============================================================================
REM Description:
REM This batch script queries the `/daemons` endpoint to retrieve system daemon
REM statuses. It demonstrates how to extract specific fields from the response,
REM such as `sshStatus`, using both full and filtered API calls.
REM
REM Usage:
REM call 01_daemons_GET.bat
REM
REM Notes:
REM - Ensure that set_variables.bat is called beforehand to set required variables.
REM - The script uses basic authentication and filters JSON output using findstr.
REM ==============================================================================

echo Loading variables into our context...
call ..\set_variables.bat

REM Full response
curl -k -u "%USER%:%PWD%" -X GET "https://%SERVER%:%PORT%/api/v2.0/daemons" -H "accept: application/json"

REM Store full response in a temporary file
curl -k -u "%USER%:%PWD%" -X GET "https://%SERVER%:%PORT%/api/v2.0/daemons" -H "accept: application/json" > full_daemons_response.txt

REM Extract sshStatus
echo.
echo Extracting sshStatus from full response...
findstr "sshStatus" full_daemons_response.txt

REM Filtered response using 'fields' parameter
echo.
echo Filtered response with only sshStatus field...
curl -k -u "%USER%:%PWD%" -X GET "https://%SERVER%:%PORT%/api/v2.0/daemons?fields=sshStatus" -H "accept: application/json"

REM Clean up
del full_daemons_response.txt >nul 2>&1
