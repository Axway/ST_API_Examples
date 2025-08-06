@echo off
REM ==============================================================================
REM Script Name: 05_daemons_operations_POST.bat
REM Author: Plamen Milenkov
REM Created: 2025-08-06
REM Location: Sofia
REM ==============================================================================
REM Description:
REM This batch script performs operations on system daemons using the
REM /daemons/operations endpoint. It demonstrates how to stop daemons both
REM forcefully and gracefully, including setting a timeout for graceful shutdowns.
REM
REM Usage:
REM call 05_daemons_operations_POST.bat
REM
REM Notes:
REM - Ensure that set_variables.bat is called beforehand to set required variables.
REM - Requires curl.
REM ==============================================================================

echo Loading variables into our context...
call ..\set_variables.bat

REM Stop HTTP daemon forcefully
set NAME=http
set OPERATION=stop
set GRACEFUL=false

echo.
echo Performing '%OPERATION%' on the '%NAME%' daemon...
curl -s -o nul -w "%%{http_code}\n" -k -u "%USER%:%PWD%" -X POST ^
  "https://%SERVER%:%PORT%/api/v2.0/daemons/operations?operation=%OPERATION%&daemon=%NAME%&graceful=%GRACEFUL%" ^
  -H "accept: application/json" -H "Content-Type: application/json"

REM Gracefully stop SSH daemon with timeout
set NAME=ssh
set OPERATION=stop
set GRACEFUL=true
set TIMEOUT=600

echo.
echo Gracefully shutting down '%NAME%' with timeout '%TIMEOUT%'...
curl -s -o nul -w "%%{http_code}\n" -k -u "%USER%:%PWD%" -X POST ^
  "https://%SERVER%:%PORT%/api/v2.0/daemons/operations?operation=%OPERATION%&daemon=%NAME%&graceful=%GRACEFUL%&timeout=%TIMEOUT%" ^
  -H "accept: application/json" -H "Content-Type: application/json"
