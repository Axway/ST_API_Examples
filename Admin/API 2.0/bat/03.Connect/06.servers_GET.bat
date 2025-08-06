@echo off
REM ==============================================================================
REM Script Name: 06_servers_GET.bat
REM Author: Plamen Milenkov
REM Created: 2025-08-06
REM Location: Sofia
REM ==============================================================================
REM Description:
REM This batch script queries the /servers endpoint to retrieve server information.
REM It demonstrates how to:
REM - Get all servers
REM - Filter by specific fields
REM - Filter by protocol
REM - Use common filters like serverName, isActive, isFipsEnabled
REM - Use protocol-specific filters like isScpEnabled
REM
REM Usage:
REM call 06_servers_GET.bat
REM
REM Notes:
REM - Ensure that set_variables.bat is called beforehand to set required variables.
REM - Requires curl.
REM ==============================================================================

echo Loading variables into our context...
call ..\set_variables.bat

REM Get all servers
curl -k -u "%USER%:%PWD%" -X GET "https://%SERVER%:%PORT%/api/v2.0/servers" -H "accept: application/json"

REM Get only serverName and isActive fields
curl -k -u "%USER%:%PWD%" -X GET "https://%SERVER%:%PORT%/api/v2.0/servers?fields=id,serverName,isActive" -H "accept: application/json"

REM Filter by protocol: AS2
set PROTOCOL=as2
curl -k -u "%USER%:%PWD%" -X GET "https://%SERVER%:%PORT%/api/v2.0/servers?protocol=%PROTOCOL%&fields=id,serverName,isActive" -H "accept: application/json"

REM Filter by common fields
curl -k -u "%USER%:%PWD%" -X GET "https://%SERVER%:%PORT%/api/v2.0/servers?limit=1&offset=0&serverName=Ssh%%20Default&isActive=true&isFipsEnabled=false" -H "accept: application/json"

REM Filter by protocol-specific field
curl -k -u "%USER%:%PWD%" -X GET "https://%SERVER%:%PORT%/api/v2.0/servers?fields=isScpEnabled&protocol=ssh" -H "accept: application/json"
