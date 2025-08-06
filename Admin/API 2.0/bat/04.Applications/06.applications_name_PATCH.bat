@echo off
REM ==============================================================================
REM Script Name: 06.applications_name_PATCH.bat
REM Author: Plamen Milenkov
REM Created: 2025-08-06
REM Location: Sofia
REM ==============================================================================
REM Description:
REM This script performs partial updates to an application using the
REM `/applications/{name}` endpoint with the PATCH method.
REM It demonstrates:
REM - Updating the notes field
REM - Updating the startDate of the first schedule
REM
REM Usage:
REM 06.applications_name_PATCH.bat
REM
REM Notes:
REM - Ensure that set_variables.bat is correctly configured and called.
REM - PATCH allows partial updates without replacing the entire object.
REM ==============================================================================

CALL ..\set_variables.bat

SET MAIN_URL=https://%SERVER%:%PORT%/api/v2.0/applications
SET NAME=AccountFilePurge%%20Application

echo Patching the application '%NAME%' to change the notes...
curl -s -o nul -w "%{http_code}\n" -k -u "%USER%:%PWD%" -X PATCH "%MAIN_URL%/%NAME%" ^
-H "accept: application/json" -H "Content-Type: application/json" ^
-d "[{ \"op\": \"replace\", \"path\": \"/notes\", \"value\": \"Patched note\" }]"

echo Patching the application '%NAME%' to change the startDate...
curl -s -o nul -w "%{http_code}\n" -k -u "%USER%:%PWD%" -X PATCH "%MAIN_URL%/%NAME%" ^
-H "accept: application/json" -H "Content-Type: application/json" ^
-d "[{ \"op\": \"replace\", \"path\": \"/schedules/0/startDate\", \"value\": \"2025-02-21T02:30:00Z\" }]"
