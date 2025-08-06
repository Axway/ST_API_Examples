@echo off
REM ==============================================================================
REM Script Name: 07_servers_POST.bat
REM Author: Plamen Milenkov
REM Created: 2025-08-06
REM Location: Sofia
REM ==============================================================================
REM Description:
REM This batch script creates new server entries using the /servers endpoint.
REM It demonstrates:
REM - Creating a minimal server with name and protocol
REM - Duplicating an existing server by modifying its configuration
REM
REM Usage:
REM call 07_servers_POST.bat
REM
REM Notes:
REM - Ensure that set_variables.bat is called beforehand to set required variables.
REM - Requires curl and PowerShell.
REM ==============================================================================

echo Loading variables into our context...
call ..\set_variables.bat

REM Create a minimal SSH server
set NAME=SSH_TEST_SERVER_1
curl -k -u "%USER%:%PWD%" -X POST "https://%SERVER%:%PORT%/api/v2.0/servers" ^
  -H "accept: application/json" -H "Content-Type: application/json" ^
  -d "{ \"serverName\": \"%NAME%\", \"protocol\": \"ssh\" }"

REM Duplicate an existing server with modifications
set NEW_NAME=SSH_TEST_SERVER_2
for /f %%i in ('powershell -Command "Get-Random -Minimum 8022 -Maximum 8032"') do set NEW_PORT=%%i

echo Creating a new server with the name: %NEW_NAME% and port: %NEW_PORT%...

REM Retrieve existing server config
curl -k -u "%USER%:%PWD%" -X GET "https://%SERVER%:%PORT%/api/v2.0/servers/%NAME%" ^
  -H "accept: application/json" -H "Content-Type: application/json" > tmp.json

REM Modify serverName and port using PowerShell
powershell -Command ^
  "$json = Get-Content -Raw 'tmp.json' | ConvertFrom-Json; " ^
  "$json.serverName = '%NEW_NAME%'; $json.port = %NEW_PORT%; " ^
  "$json.clientPasswordAuth = 'default'; " ^
  "$json | ConvertTo-Json -Depth 10 | Set-Content 'tmp_modified.json'"

REM Create new server with modified config
curl -k -u "%USER%:%PWD%" -X POST "https://%SERVER%:%PORT%/api/v2.0/servers" ^
  -H "accept: application/json" -H "Content-Type: application/json" ^
  -d @tmp_modified.json

REM Clean up
del tmp.json >nul 2>&1
del tmp_modified.json >nul 2>&1
