@echo off
REM Script Name: Acknowledgment.bat
REM Description: This script sends ACK/NACK for PeSIT transfers based on the provided CORE_ID.
REM Author: pmilenkov@axway.com
REM Version: 1.0.0
REM Date: 2025-08-DD

SETLOCAL ENABLEDELAYEDEXPANSION

REM Exit codes
SET EXIT_CODE_SUCCESS=0
SET EXIT_CODE_ERROR=1
SET EXIT_CODE_RETRY=2

REM Parse Input Parameters
SET CORE_ID=%1
SET HOST=%2
IF "%HOST%"=="" SET HOST=localhost

SET TYPE_OF_OUTBOUND_TRANSFER=%3
IF "%TYPE_OF_OUTBOUND_TRANSFER%"=="" SET TYPE_OF_OUTBOUND_TRANSFER=MIX

SET NUMBER_OF_EXPECTED_OUTBOUND_TRANSFERS=%4
IF "%NUMBER_OF_EXPECTED_OUTBOUND_TRANSFERS%"=="" SET NUMBER_OF_EXPECTED_OUTBOUND_TRANSFERS=1

SET SEND_NACK_IF_NOT_FOUND=%5
IF "%SEND_NACK_IF_NOT_FOUND%"=="" SET SEND_NACK_IF_NOT_FOUND=TRUE

SET ROOT_FOLDER=%6
IF "%ROOT_FOLDER%"=="" SET ROOT_FOLDER=C:\Temp

SET CLEAR_API_OUTPUT_FILES=%7
IF "%CLEAR_API_OUTPUT_FILES%"=="" SET CLEAR_API_OUTPUT_FILES=FALSE

SET NUMBER_OF_RETRIES=%8
IF "%NUMBER_OF_RETRIES%"=="" SET NUMBER_OF_RETRIES=1

SET SLEEP_BETWEEN_RETRIES=%9
IF "%SLEEP_BETWEEN_RETRIES%"=="" SET SLEEP_BETWEEN_RETRIES=1

IF "%CORE_ID%"=="" (
    echo Usage: %~nx0 CORE_ID
    EXIT /B %EXIT_CODE_ERROR%
)

REM Set script variables
FOR /F "tokens=1-2 delims= " %%A IN ('powershell -Command "Get-Date -Format yyyyMMdd HHmm"') DO (
    SET YYYYMMDD=%%A
    SET HH=%%B
)

SET MAIN_DIR=%ROOT_FOLDER%\acks
SET LOG_DIR=%MAIN_DIR%\%YYYYMMDD%-%HH%
SET API_OUTPUTS_DIR=%LOG_DIR%\API
SET FILELOG=%LOG_DIR%\COREID_%CORE_ID%.log

SET API_URL=https://%HOST%:444/api/v2.0
SET ADMIN_USER=admin
SET ADMIN_PWD=1

REM Create necessary directories
IF NOT EXIST "%API_OUTPUTS_DIR%" (
    mkdir "%API_OUTPUTS_DIR%"
)
echo All log files will be saved in: %LOG_DIR%

REM Logging function
CALL :log_message INFO "##############################################################"
CALL :log_message INFO "Starting script execution..."
CALL :log_message INFO "CORE_ID: %CORE_ID%"

REM --- Find the corresponding inbound transfer ---
CALL :log_message INFO "Looking for the corresponding PeSIT inbound transfer..."
SET GET_PROCESSED_INBOUND_TRANSFER=%API_OUTPUTS_DIR%\FIND_PESIT_INBOUND_%CORE_ID%.txt
CALL :execute_API GET "%API_URL%/logs/transfers?protocol=pesit&incoming=true&status=Processed&coreId=%CORE_ID%" "%GET_PROCESSED_INBOUND_TRANSFER%"

FOR /F "tokens=2 delims=:" %%A IN ('findstr "returnCount" "%GET_PROCESSED_INBOUND_TRANSFER%"') DO SET InReturnCount=%%A
SET InReturnCount=%InReturnCount: =%
IF "%InReturnCount%"=="0" (
    CALL :log_message ERROR "Cannot find PeSIT inbound transfer corresponding to the given Core ID: %CORE_ID%."
    EXIT /B %EXIT_CODE_ERROR%
)
CALL :log_message INFO "Found the corresponding PeSIT inbound transfer."

REM --- Checking outbound transfer ---
SET OUTBOUND_TYPE_REQUEST=
IF /I "%TYPE_OF_OUTBOUND_TRANSFER%"=="MIX" (
    SET OUTBOUND_TYPE_REQUEST=direction=Outgoing
) ELSE IF /I "%TYPE_OF_OUTBOUND_TRANSFER%"=="PUSH" (
    SET OUTBOUND_TYPE_REQUEST=direction=Outgoing&serverInitiated=true
) ELSE IF /I "%TYPE_OF_OUTBOUND_TRANSFER%"=="DOWNLOAD" (
    SET OUTBOUND_TYPE_REQUEST=direction=Outgoing&serverInitiated=false
) ELSE (
    CALL :log_message ERROR "Invalid TYPE_OF_OUTBOUND_TRANSFER: %TYPE_OF_OUTBOUND_TRANSFER%. Valid options are: MIX, PUSH, DOWNLOAD."
    EXIT /B %EXIT_CODE_ERROR%
)

SET CHECK_CORE_ID=%API_OUTPUTS_DIR%\CHECK_CORE_ID_%CORE_ID%.txt
CALL :log_message INFO "Checking for %NUMBER_OF_EXPECTED_OUTBOUND_TRANSFERS% processed outbound transfer(s) with Core ID %CORE_ID%..."
CALL :execute_API GET "%API_URL%/logs/transfers?%OUTBOUND_TYPE_REQUEST%&status=Processed&coreId=%CORE_ID%" "%CHECK_CORE_ID%"

FOR /F "tokens=2 delims=:" %%A IN ('findstr "returnCount" "%CHECK_CORE_ID%"') DO SET RETURN_COUNT=%%A
SET RETURN_COUNT=%RETURN_COUNT: =%
IF %RETURN_COUNT% LSS %NUMBER_OF_EXPECTED_OUTBOUND_TRANSFERS% (
    IF /I "%SEND_NACK_IF_NOT_FOUND%"=="TRUE" (
        CALL :log_message INFO "Sending NACK for Core ID '%CORE_ID%' due to insufficient transfers."
        SET ACK_TYPE=NACK
    ) ELSE (
        CALL :log_message ERROR "Expected %NUMBER_OF_EXPECTED_OUTBOUND_TRANSFERS% transfers, found %RETURN_COUNT%. Skipping acknowledgment."
        EXIT /B %EXIT_CODE_RETRY%
    )
) ELSE (
    CALL :log_message INFO "Transfer with Core ID '%CORE_ID%' was found."
    SET ACK_TYPE=ACK
)

REM --- Build ACK/NACK link ---
CALL :log_message INFO "Building the Acknowledgment link..."
FOR /F "tokens=2 delims=:" %%A IN ('findstr "self" "%GET_PROCESSED_INBOUND_TRANSFER%"') DO SET ACK_LINK=%%A
SET ACK_LINK=%ACK_LINK:"=%
SET ACK_LINK=%ACK_LINK:/operations.*=%
SET ACK_LINK=%ACK_LINK%/operations?operation=ack
IF "%ACK_TYPE%"=="NACK" (
    SET ACK_NACK_LINK=%ACK_LINK:ack=nack%
) ELSE (
    SET ACK_NACK_LINK=%ACK_LINK%
)

CALL :log_message INFO "ACK_TYPE: %ACK_TYPE%"
CALL :log_message INFO "ACK/NACK Link: %ACK_NACK_LINK%"

REM --- Send ACK/NACK with Retry ---
SET ACK_NACK_OUTPUT=%API_OUTPUTS_DIR%\ACK_NACK_OUTPUT_%CORE_ID%.txt
CALL :log_message INFO "Sending Acknowledgment..."

SET SUCCESS_CODE=HTTPC=200
SET ALREADY_SENT_CODE=HTTPC=422

FOR /L %%i IN (1,1,%NUMBER_OF_RETRIES%) DO (
    CALL :log_message DEBUG "Retry count: %%i"
    curl -k -s -u "%ADMIN_USER%:%ADMIN_PWD%" -w "\nHTTPC=%%{http_code}" -X POST "%ACK_NACK_LINK%" ^
      -H "accept: application/json" -H "Referer: %API_URL%" > "%ACK_NACK_OUTPUT%"

    FOR /F "usebackq delims=" %%A IN ("%ACK_NACK_OUTPUT%") DO (
        SET line=%%A
        IF "!line!"=="%SUCCESS_CODE%" (
            CALL :log_message INFO "ACK/NACK sent successfully"
            GOTO :done
        ) ELSE IF "!line!"=="%ALREADY_SENT_CODE%" (
            CALL :log_message WARNING "Attempt %%i/%NUMBER_OF_RETRIES% failed - HTTPC: !line!"
            CALL :log_message INFO "Acknowledgment already sent."
            GOTO :done
        ) ELSE (
            CALL :log_message WARNING "Attempt %%i/%NUMBER_OF_RETRIES% failed - HTTPC: !line!"
            TIMEOUT /T %SLEEP_BETWEEN_RETRIES% >nul
        )
    )
)

:done
IF /I "%CLEAR_API_OUTPUT_FILES%"=="TRUE" (
    DEL /Q "%API_OUTPUTS_DIR%\*_%CORE_ID%.txt"
)
CALL :log_message INFO "End of script execution"
EXIT /B %EXIT_CODE_SUCCESS%

REM --- Functions ---
:log_message
SET level=%1
SET msg=%2
FOR /F "tokens=*" %%A IN ('powershell -Command "Get-Date -Format yyyy-MM-dd HH:mm:ss"') DO SET timestamp=%%A
echo %timestamp% - %CORE_ID% - %level% - %msg% >> "%FILELOG%"
EXIT /B

:execute_API
SET method=%1
SET url=%2
SET output_file=%3
curl -k -s -u "%ADMIN_USER%:%ADMIN_PWD%" -w "\nHTTPC=%%{http_code}" -X %method% "%url%" ^
  -H "accept: application/json" -H "Referer: %API_URL%" > "%output_file%"
EXIT /B
