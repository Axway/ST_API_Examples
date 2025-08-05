@echo off
REM ==============================================================================
REM Script Name: 02_version_GET.bat
REM Author: Plamen Milenkov
REM Created: 2025-08-05
REM Location: Sofia
REM ==============================================================================
REM Description:
REM This batch script performs a basic authentication request to retrieve the
REM current product version from the API. It stores the full response in a variable
REM and filters specific fields such as version, server type, and operating system.
REM
REM Usage:
REM call 02_version_GET.bat
REM
REM Notes:
REM - Ensure that set_variables.bat is called beforehand to set required variables.
REM - This script demonstrates how to parse and filter JSON responses using findstr.
REM ==============================================================================

echo Loading variables into our context...
call ..\set_variables.bat

REM Store full response in a temporary file
curl -s -k -u "%USER%:%PWD%" -X GET "https://%SERVER%:%PORT%/api/v2.0/version" ^
  -H "accept: application/json" > version_response.txt

REM Uncomment to see full response
REM type version_response.txt

REM Extract version
echo.
echo grep for the version...
findstr "version" version_response.txt

REM Filter specific SPI version
echo.
echo grep for version.*5.5...
findstr "version.*5.5" version_response.txt

REM Extract server type
echo.
echo grep for serverType...
findstr "serverType" version_response.txt

REM Extract operating system
echo.
echo grep for os...
findstr "os" version_response.txt

REM Clean up
del version_response.txt >nul 2>&1
