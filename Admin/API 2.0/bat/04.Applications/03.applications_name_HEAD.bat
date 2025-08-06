@echo off
REM ==============================================================================
REM Script Name: 03.applications_name_HEAD.bat
REM Author: Plamen Milenkov
REM Created: 2025-08-06
REM Location: Sofia
REM ==============================================================================
REM Description:
REM This script checks if specific applications exist using the `/applications/{name}` endpoint.
REM It demonstrates:
REM - A HEAD request to verify existence of an application by name
REM - Conditional logic based on HTTP response code
REM
REM Usage:
REM 03.applications_name_HEAD.bat
REM
REM Notes:
REM - Ensure that set_variables.bat is correctly configured and called.
REM - Application names with spaces must be URL-encoded.
REM ==============================================================================

CALL ..\set_variables.bat

SET NAME=Audit Log Maintenance
SET NAME=%NAME: =%%20%
echo Check if application with the name '%NAME%' exists...
curl -k -u "%USER%:%PWD%" --head "https://%SERVER%:%PORT%/api/v2.0/applications/%NAME%" -H "accept: */*"

SET NAME=Transfer Log Maintenance
SET NAME=%NAME: =%%20%
echo.
echo Check if application with the name '%NAME%' exists...
FOR /F %%C IN ('curl -s -o nul -w "%%{http_code}\n" -k -u "%USER%:%PWD%" --head "https://%SERVER%:%PORT%/api/v2.0/applications/%NAME%" -H "accept: */*"') DO SET RESPONSE_CODE=%%C

IF "%RESPONSE_CODE%"=="200" (
    echo Application exists.
) ELSE (
    echo Application does not exist.
)
