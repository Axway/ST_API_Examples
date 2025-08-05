@echo off
REM ==============================================================================
REM Script Name: 01_version_GET.bat
REM Author: Plamen Milenkov
REM Created: 2025-08-05
REM Location: Sofia
REM ==============================================================================
REM Description:
REM This batch script performs a basic authentication request to retrieve the
REM current product version from the API. It uses username and password credentials
REM and sends a GET request to the `/version` endpoint.
REM
REM Usage:
REM call 01_version_GET.bat
REM
REM Notes:
REM - Ensure that set_variables.bat is called beforehand to set required variables.
REM - This script uses basic authentication and will be updated to token-based
REM   authentication in future iterations.
REM ==============================================================================

REM Load environment variables
call ..\set_variables.bat

REM Perform GET request to retrieve product version
curl -k -u "%USER%:%PWD%" -X GET "https://%SERVER%:%PORT%/api/v2.0/version" ^
  -H "accept: application/json"

REM End of script
