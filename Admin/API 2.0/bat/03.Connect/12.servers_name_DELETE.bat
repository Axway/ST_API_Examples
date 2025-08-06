@echo off
REM ==============================================================================
REM Script Name: 12.servers_name_DELETE.bat
REM Author: Plamen Milenkov
REM Created: 2025-08-06
REM Location: Sofia
REM ==============================================================================
REM Description:
REM This script deletes a server using the `/servers/{name}` endpoint.
REM It demonstrates:
REM - A direct DELETE request for a server by name
REM - A conditional DELETE request after checking server existence
REM
REM Usage:
REM 12.servers_name_DELETE.bat
REM
REM Notes:
REM - Ensure that `set_variables.bat` is correctly configured and called.
REM - The server name must be valid and exist in the system.
REM ==============================================================================

CALL ..\set_variables.bat

SET NAME=SSH_TEST_SERVER_1
echo Deleting server '%NAME%'...
curl -s -o nul -w "%{http_code}\n" -k -u "%USER%:%PWD%" -X DELETE "https://%SERVER%:%PORT%/api/v2.0/servers/%NAME%" ^
-H "accept: application/json" -H "Content-Type: application/json"
echo Done

SET NAME=SSH_TEST_SERVER_2
FOR /F %%C IN ('curl -s -o nul -w "%%{http_code}\n" -k -u "%USER%:%PWD%" --head "https://%SERVER%:%PORT%/api/v2.0/servers/%NAME%" ^
-H "accept: */*"') DO SET RESPONSE_CODE=%%C

IF "%RESPONSE_CODE%"=="200" (
    echo Server exists. Deleting server '%NAME%'...
    curl -s -o nul -w "%{http_code}\n" -k -u "%USER%:%PWD%" -X DELETE "https://%SERVER%:%PORT%/api/v2.0/servers/%NAME%" ^
    -H "accept: application/json" -H "Content-Type: application/json"
    echo.
    echo Done
) ELSE (
    echo Server does not exist.
)
