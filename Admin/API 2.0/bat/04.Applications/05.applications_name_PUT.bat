@echo off
REM ==============================================================================
REM Script Name: 05.applications_name_PUT.bat
REM Author: Plamen Milenkov
REM Created: 2025-08-06
REM Location: Sofia
REM ==============================================================================
REM Description:
REM This script updates an application using the `/applications/{name}` endpoint.
REM It demonstrates:
REM - Retrieving the full application object
REM - Modifying the notes field with a timestamp
REM - Sending a PUT request to update the application
REM
REM Usage:
REM 05.applications_name_PUT.bat
REM
REM Notes:
REM - Ensure that set_variables.bat is correctly configured and called.
REM - PUT replaces the entire object, so all required fields must be preserved.
REM ==============================================================================

CALL ..\set_variables.bat

SET MAIN_URL=https://%SERVER%:%PORT%/api/v2.0/applications
SET NAME=AccountFilePurge%%20Application

curl -k -u "%USER%:%PWD%" -X GET "%MAIN_URL%/%NAME%" -H "accept: application/json" -H "Content-Type: application/json" > tmp.json

FOR /F %%D IN ('powershell -Command "Get-Date -Format o"') DO SET DATE=%%D
powershell -Command "(Get-Content tmp.json) -replace '\"notes\"\\s*:\\s*\"[^\"]*\"', '\"notes\": \"New note %DATE%\"' | Set-Content tmp.json"

curl -k -u "%USER%:%PWD%" -X PUT "%MAIN_URL%/%NAME%" -H "accept: application/json" -H "Content-Type: application/json" -d @tmp.json
