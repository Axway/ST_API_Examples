@echo off
REM ==============================================================================
REM Script Name: 01_myself_cookie_POST.bat
REM Author: Plamen Milenkov
REM Created: 2025-08-05
REM Location: Sofia
REM ==============================================================================
REM Description:
REM This batch script performs basic authentication against the API using a cookie
REM jar to persist session information. It reduces the need for repeated
REM authentication across multiple requests.
REM
REM Usage:
REM call 01_myself_cookie_POST.bat
REM
REM Notes:
REM - Ensure that set_variables.bat is called beforehand to set required variables.
REM - The cookie jar file will store session data for reuse.
REM ==============================================================================

echo Loading variables into our context...
call ..\set_variables.bat

echo.
echo Basic authentication with cookie jar to reduce further authentications...

set REFERER_HEADER=Referer: THIS_IS_A_RANDOM_TEXT

REM Authenticate and store session in cookie jar
curl -k --cookie-jar cookie.jar -u "%USER%:%PWD%" -X POST "https://%SERVER%:%PORT%/api/v2.0/myself" ^
  -H "accept: application/json" -H "%REFERER_HEADER%"

REM Reuse session to make a GET request
curl -k --cookie cookie.jar -X GET "https://%SERVER%:%PORT%/api/v2.0/myself" ^
  -H "accept: application/json" -H "%REFERER_HEADER%"
