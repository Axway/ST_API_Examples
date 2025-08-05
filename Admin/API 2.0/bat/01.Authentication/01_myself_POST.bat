@echo off
REM ==============================================================================
REM Script Name: 01_myself_POST.bat
REM Author: Plamen Milenkov
REM Created: 2025-08-05
REM Location: Sofia
REM ==============================================================================
REM Description:
REM This batch script performs a basic authentication request to the API using
REM a username and password. It retrieves user information from the `/myself` endpoint.
REM
REM Usage:
REM call 01_myself_POST.bat
REM
REM Notes:
REM - Ensure that set_variables.bat is called beforehand to set required variables.
REM - This script does not use a cookie jar, so authentication is required for each call.
REM ==============================================================================

echo Loading variables into our context...
call ..\set_variables.bat

echo.
echo Basic authentication...

curl -s -k -u "%USER%:%PWD%" -X GET "https://%SERVER%:%PORT%/api/v2.0/myself"  -H "accept: application/json"
