@echo off
REM ==============================================================================
REM Script Name: 01.applications_GET.bat
REM Author: Plamen Milenkov
REM Created: 2025-08-06
REM Location: Sofia
REM ==============================================================================
REM Description:
REM This script retrieves application data using the `/applications` endpoint.
REM It demonstrates:
REM - A full GET request for all applications
REM - A filtered GET request based on application type
REM - A GET request for application types only
REM
REM Usage:
REM 01.applications_GET.bat
REM
REM Notes:
REM - Ensure that set_variables.bat is correctly configured and called.
REM - The type filter uses a predefined list of application types.
REM ==============================================================================
CALL ..\set_variables.bat

echo Get all applications...
curl -k -u "%USER%:%PWD%" -X GET "https://%SERVER%:%PORT%/api/v2.0/applications" -H "accept: application/json"

SET ALL_TYPES=AccountFilePurge,AccountTTL,AdvancedRouting,ArchiveMaint,AuditLogMaint,Basic,HumanSystem,LogEntryMaint,LoginThresholdMaintenance,MBFT,PackageRetentionMaint,SentinelLinkDataMaint,SharedFolder,SiteMailbox,StandardRouter,TransferLogMaint,UnlicensedAccountMaint
FOR /F "tokens=1 delims=," %%A IN ("%ALL_TYPES%") DO SET RANDOM_TYPE=%%A

echo From all applications get one based on the type '%RANDOM_TYPE%'...
curl -k -u "%USER%:%PWD%" -X GET "https://%SERVER%:%PORT%/api/v2.0/applications?type=%RANDOM_TYPE%" -H "accept: application/json"

echo Get only the type of the available applications...
curl -s -k -u "%USER%:%PWD%" -X GET "https://%SERVER%:%PORT%/api/v2.0/applications?fields=type" -H "accept: application/json"
