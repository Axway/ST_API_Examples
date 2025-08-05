@echo off
REM ==============================================================================
REM Script Name: 04_myself_PATCH.bat
REM Author: Plamen Milenkov
REM Created: 2025-08-05
REM Location: Sofia
REM ==============================================================================
REM Description:
REM This batch script sends a PATCH request to the `/myself` endpoint to update
REM the current user's password. It uses basic authentication and a JSON payload
REM containing the new password.
REM
REM Usage:
REM call 04_myself_PATCH.bat
REM
REM Notes:
REM - Ensure that set_variables.bat is called beforehand to set required variables.
REM - Be cautious when executing this script, as it will change your password.
REM - Replace "TYPE_WHATEVER_YOU_WANT_HERE" with the desired new password.
REM ==============================================================================

echo Loading variables into our context...
call ..\set_variables.bat

REM Send PATCH request to update password
curl -s -k -u "%USER%:%PWD%" -X PATCH "https://%SERVER%:%PORT%/api/v2.0/myself" -H "accept: */*" -H "Content-Type: application/json" ^
  -d "[{ \"op\": \"replace\", \"path\": \"/passwordCredentials/password\", \"value\": \"TYPE_WHATEVER_YOU_WANT_HERE\" }]"
