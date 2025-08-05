@echo off
REM ==============================================================================
REM Script Name: 06_myself_DELETE.bat
REM Author: Plamen Milenkov
REM Created: 2025-08-05
REM Location: Sofia
REM ==============================================================================
REM Description:
REM This batch script demonstrates how to log in using basic authentication and a
REM cookie jar, then log out by sending a DELETE request to the `/myself` endpoint.
REM It also verifies session status before and after logout.
REM
REM Usage:
REM call 06_myself_DELETE.bat
REM
REM Notes:
REM - Ensure that set_variables.bat is called beforehand to set required variables.
REM - The cookie jar is used to persist session state across requests.
REM ==============================================================================

echo Loading variables into our context...
call ..\set_variables.bat

set REFERER_HEADER=Referer: THIS_IS_A_RANDOM_TEXT

REM Authenticate and store session
curl -k --cookie-jar cookie.jar -u "%USER%:%PWD%" -X POST "https://%SERVER%:%PORT%/api/v2.0/myself" -H "accept: application/json" -H "%REFERER_HEADER%"

REM Verify session is active
curl -k --cookie cookie.jar -X GET "https://%SERVER%:%PORT%/api/v2.0/myself" -H "accept: application/json" -H "%REFERER_HEADER%"

REM Log out
curl -k -L --cookie cookie.jar -X DELETE "https://%SERVER%:%PORT%/api/v2.0/myself" -H "accept: application/json" -H "%REFERER_HEADER%"

REM Verify session is terminated
curl -k --cookie cookie.jar -X GET "https://%SERVER%:%PORT%/api/v2.0/myself" -H "accept: application/json" -H "%REFERER_HEADER%"
