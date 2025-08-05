@echo off
REM ==============================================================================
REM Script Name: set_variables.bat
REM Author: Plamen Milenkov
REM Created: 2025-08-05
REM Location: Sofia
REM ==============================================================================
REM Description:
REM This batch script sets environment variables required for API authentication
REM and connectivity. It is intended to be called by other scripts that rely on
REM SERVER, PORT, USER, and PWD values.
REM
REM Usage:
REM call set_variables.bat
REM
REM Notes:
REM - Ensure this script is called from another batch file to retain variables.
REM - Values should be securely managed and updated as needed.
REM ==============================================================================

set SERVER=
set PORT=
set USER=
set PWD=
