@echo off
REM ==============================================================================
REM Script Name: 11.servers_name_PATCH.bat
REM Author: Plamen Milenkov
REM Created: 2025-08-06
REM Location: Sofia
REM ==============================================================================
REM Description:
REM This script demonstrates how to PATCH an SSH server configuration using curl.
REM It performs:
REM - A PATCH to update the port
REM - A PATCH to remove RSA keys from the publicKeys field
REM
REM Usage:
REM patch_ssh_server.bat
REM
REM Notes:
REM - Ensure that set_variables.bat is correctly configured and called.
REM - The PATCH method allows partial updates to specific fields.
REM ==============================================================================

CALL ..\set_variables.bat

SET NAME=SSH_TEST_SERVER_1

echo Patching the server port...
curl -s -o nul -w "%{http_code}\n" -k -u "%USER%:%PWD%" -X PATCH "https://%SERVER%:%PORT%/api/v2.0/servers/%NAME%" ^
-H "accept: application/json" -H "Content-Type: application/json" ^
-d "[{ \"op\": \"replace\", \"path\": \"/port\", \"value\": 8026 }]"

echo Patching the server publicKeys...
curl -s -k -u "%USER%:%PWD%" -X GET "https://%SERVER%:%PORT%/api/v2.0/servers/%NAME%" ^
-H "accept: application/json" -H "Content-Type: application/json" > tmp.json

powershell -Command "$content = Get-Content tmp.json -Raw; $oldKeys = ($content | ConvertFrom-Json).publicKeys; $newKeys = ($oldKeys -split ',') -notmatch 'rsa'; $newKeysStr = $newKeys -join ','; $patch = @{op='replace'; path='/publicKeys'; value=$newKeysStr}; $json = @($patch) | ConvertTo-Json; Set-Content -Path patch.json -Value $json"

curl -k -u "%USER%:%PWD%" -X PATCH "https://%SERVER%:%PORT%/api/v2.0/servers/%NAME%" ^
-H "accept: application/json" -H "Content-Type: application/json" -d @patch.json

echo.
echo Done
echo Retrieve the server information to check the changes...
curl -s -k -u "%USER%:%PWD%" -X GET "https://%SERVER%:%PORT%/api/v2.0/servers/%NAME%" ^
-H "accept: application/json" -H "Content-Type: application/json"
