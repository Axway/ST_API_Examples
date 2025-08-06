@echo off
REM ==============================================================================
REM Script Name: 03_daemons_name_PUT.bat
REM Author: Plamen Milenkov
REM Created: 2025-08-06
REM Location: Sofia
REM ==============================================================================
REM Description:
REM This batch script updates the SSH daemon configuration using the /daemons/{name}
REM endpoint. It demonstrates both a valid and an invalid update to the maxConnections
REM field, and checks the HTTP response code to confirm success or failure.
REM
REM Usage:
REM call 03_daemons_name_PUT.bat
REM
REM Notes:
REM - Ensure that set_variables.bat is called beforehand to set required variables.
REM - Requires curl and PowerShell.
REM ==============================================================================

echo Loading variables into our context...
call ..\set_variables.bat

set NAME=ssh

REM Valid update: maxConnections = 10
curl -s -o nul -w "%%{http_code}\n" -k -u "%USER%:%PWD%" -X PUT "https://%SERVER%:%PORT%/api/v2.0/daemons/%NAME%" ^
  -H "accept: application/json" -H "Content-Type: application/json" ^
  -d "{ \"maxConnections\": \"10\", \"preferBouncyCastleProvider\": false, \"banner\": \"This is a SecureTransport REST API test banner.\" }"

REM Invalid update: maxConnections = -10
for /f %%i in ('curl -s -o nul -w "%%{http_code}" -k -u "%USER%:%PWD%" -X PUT "https://%SERVER%:%PORT%/api/v2.0/daemons/%NAME%" ^
  -H "accept: application/json" -H "Content-Type: application/json" ^
  -d "{ \"maxConnections\": \"-10\", \"preferBouncyCastleProvider\": false, \"banner\": \"This is a SecureTransport REST API test banner.\" }"') do (
    set RESPONSE_CODE=%%i
)

REM Check response code
if "%RESPONSE_CODE%"=="200" (
    echo The daemon was successfully updated.
) else (
    echo The daemon was not updated. Please check the response code: %RESPONSE_CODE%
)
