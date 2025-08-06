@echo off
REM ==============================================================================
REM Script Name: 07.applications_name_DELETE.bat
REM Author: Plamen Milenkov
REM Created: 2025-08-06
REM Location: Sofia
REM ==============================================================================
REM Description:
REM This script deletes applications using the `/applications/{name}` endpoint.
REM It demonstrates:
REM - A direct DELETE request for a known application
REM - A conditional DELETE request after verifying existence
REM
REM Usage:
REM 07.applications_name_DELETE.bat
REM
REM Notes:
REM - Ensure that set_variables.bat is correctly configured and called.
REM - Application names with spaces must be URL-encoded.
REM ==============================================================================

CALL ..\set_variables.bat

SET NAME=Audit Log Maintenance
SET NAME=%NAME: =%%20%
echo Deleting application '%NAME%'...
curl -s -o nul -w "%{http_code}\n" -k -u "%USER%:%PWD%" -X DELETE "https://%SERVER%:%PORT%/api/v2.0/applications/%NAME%" ^
-H "accept: application/json" -H "Content-Type: application/json"

SET NAME=Transfer Log Maintenance
SET NAME=%NAME: =%%20%
FOR /F %%C IN ('curl -s -o nul -w "%%{http_code}\n" -k -u "%USER%:%PWD%" --head "https://%SERVER%:%PORT%/api/v2.0/applications/%NAME%" -H "accept: */*"') DO SET RESPONSE_CODE=%%C

IF "%RESPONSE_CODE%"=="200" (
    echo Application exists. Deleting application '%NAME%'...
    curl -s -o nul -w "%{http_code}\n" -k -u "%USER%:%PWD%" -X DELETE "https://%SERVER%:%PORT%/api/v2.0/applications/%NAME%" ^
    -H "accept: application/json" -H "Content-Type: application/json"
    echo.
    echo Done
) ELSE (
    echo Application does not exist.
)
