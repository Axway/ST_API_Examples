@echo off
REM ==============================================================================
REM Script Name: 10.servers_name_PUT.bat
REM Author: Plamen Milenkov
REM Created: 2025-08-06
REM Location: Sofia
REM ==============================================================================
REM Description:
REM This script updates an SSH server configuration using the PUT method via curl.
REM It demonstrates:
REM - A direct update with a new port
REM - A full update using retrieved server data with modified fields
REM
REM Usage:
REM update_ssh_server.bat
REM
REM Notes:
REM - Ensure that set_variables.bat is correctly configured and called.
REM - The PUT method replaces the entire object, so all required fields must be included.
REM ==============================================================================

CALL ..\set_variables.bat

SET NAME=SSH_TEST_SERVER_1
SET /A NEW_PORT=8022 + %RANDOM% %% 10

curl -k -u "%USER%:%PWD%" -X PUT "https://%SERVER%:%PORT%/api/v2.0/servers/%NAME%" ^
-H "accept: application/json" -H "Content-Type: application/json" ^
-d "{ \"serverName\": \"%NAME%\", \"protocol\": \"ssh\", \"port\": %NEW_PORT% }"

SET /A NEW_PORT=8022 + %RANDOM% %% 10
curl -k -u "%USER%:%PWD%" -X GET "https://%SERVER%:%PORT%/api/v2.0/servers/%NAME%" ^
-H "accept: application/json" -H "Content-Type: application/json" > tmp.json

powershell -Command "(Get-Content tmp.json) -replace '\"port\": \\d+', '\"port\": %NEW_PORT%' | Set-Content tmp.json"
powershell -Command "(Get-Content tmp.json) -replace '\"clientPasswordAuth\" : .*', '\"clientPasswordAuth\": \"default\",' | Set-Content tmp.json"

curl -k -u "%USER%:%PWD%" -X PUT "https://%SERVER%:%PORT%/api/v2.0/servers/%NAME%" ^
-H "accept: application/json" -H "Content-Type: application/json" -d @tmp.json
