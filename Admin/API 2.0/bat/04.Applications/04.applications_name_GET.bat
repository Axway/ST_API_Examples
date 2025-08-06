@echo off
REM ==============================================================================
REM Script Name: 04.applications_name_GET.bat
REM Author: Plamen Milenkov
REM Created: 2025-08-06
REM Location: Sofia
REM ==============================================================================
REM Description:
REM This script retrieves information about a specific application using the
REM `/applications/{name}` endpoint. It also checks whether business units are
REM assigned to the application.
REM
REM Usage:
REM 04.applications_name_GET.bat
REM
REM Notes:
REM - Ensure that `set_variables.bat` is correctly configured and called.
REM - Application names with spaces must be URL-encoded.
REM ==============================================================================

CALL ..\set_variables.bat

SET MAIN_URL=https://%SERVER%:%PORT%/api/v2.0/applications
SET NAME=AccountFilePurge%%20Application

curl -k -u "%USER%:%PWD%" -X GET "%MAIN_URL%/%NAME%" -H "accept: application/json"

curl -k -u "%USER%:%PWD%" -X GET "%MAIN_URL%/%NAME%" -H "accept: application/json" > response.json

FOR /F %%R IN ('powershell -Command "(Get-Content response.json | ConvertFrom-Json).businessUnits.Count"') DO SET NUMBER_OF_ASSIGNED_BU=%%R

IF "%NUMBER_OF_ASSIGNED_BU%"=="0" (
    echo No business units assigned to the application.
) ELSE (
    powershell -Command "Write-Output 'Business units assigned to the application:'; (Get-Content response.json | ConvertFrom-Json).businessUnits"
)
