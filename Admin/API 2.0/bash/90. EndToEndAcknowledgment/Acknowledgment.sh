#!/bin/bash
# ==============================================================================
# Script Name: Acknowledgment.sh
# Author: Plamen Milenkov
# Created: 2025-08-05
# Location: Sofia
# ==============================================================================
# Description:
# This script verifies the existence of outbound PeSIT transfers associated with
# a given Core ID and sends an acknowledgment (ACK) or negative acknowledgment (NACK)
# based on the result. It supports retry logic and configurable transfer types.
#
# Key Features:
# - Validates inbound transfer existence before proceeding.
# - Supports MIX, PUSH, and DOWNLOAD outbound transfer types.
# - Sends ACK/NACK with retry and delay options.
# - Logs all operations with timestamps and core identifiers.
# - Optionally clears API output files after execution.
#
# Usage:
# ./PeSIT_Outbound_Transfer_Acknowledgment.sh <CORE_ID> [HOST] [TYPE_OF_OUTBOUND_TRANSFER] [NUMBER_OF_EXPECTED_OUTBOUND_TRANSFERS] [SEND_NACK_IF_NOT_FOUND] [ROOT_FOLDER] [CLEAR_API_OUTPUT_FILES] [NUMBER_OF_RETRIES] [SLEEP_BETWEEN_RETRIES]
#
# Parameters:
# CORE_ID                            - Unique identifier for the transfer.
# HOST                               - API host (default: localhost).
# TYPE_OF_OUTBOUND_TRANSFER          - MIX, PUSH, or DOWNLOAD (default: MIX).
# NUMBER_OF_EXPECTED_OUTBOUND_TRANSFERS - Expected number of outbound transfers (default: 1).
# SEND_NACK_IF_NOT_FOUND             - TRUE to send NACK if expected transfers are missing (default: TRUE).
# ROOT_FOLDER                        - Root directory for logs and outputs (default: /var/tmp).
# CLEAR_API_OUTPUT_FILES             - TRUE to delete API output files after processing (default: FALSE).
# NUMBER_OF_RETRIES                  - Number of retry attempts for ACK/NACK (default: 1).
# SLEEP_BETWEEN_RETRIES              - Delay between retries in seconds (default: 1).
#
# Dependencies:
# - curl
#
# Exit Codes:
# 0 - Success
# 1 - Error (e.g., missing parameters, API failure)
# 2 - Retry suggested (e.g., outbound transfer not yet available)
#
# Notes:
# - Ensure ADMIN_USER and ADMIN_PWD are securely managed.
# - This script is intended for internal use and assumes trusted network access.
# ==============================================================================

set -e
set -o pipefail

# Exit codes
EXIT_CODE_SUCCESS=0
EXIT_CODE_ERROR=1
EXIT_CODE_RETRY=2

log_message() {
    local level="$1"
    local msg="$2"
    local logFile="${3:-$FILELOG}"
    local timestamp
    timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    echo "$timestamp - $CORE_ID - $level - $msg" >> "$logFile"
}

check_API_response() {
    local response_file="$1"
    local expected_code="$2"

    HTTPC=$(grep "HTTPC=" "$response_file" | tr -d '\r')
    log_message "INFO" "HTTPC: $HTTPC"
    
    if [[ "$HTTPC" != "HTTPC=$expected_code" ]]; then
        log_message "ERROR" "API Call Error - HTTPC: $HTTPC"
        exit ${EXIT_CODE_ERROR}
    fi
}

execute_API(){
    local method="$1"
    local url="$2"
    local output_file="$3"

    curl -k -s -u "$ADMIN_USER:$ADMIN_PWD" -w "\nHTTPC=%{http_code}" -X "$method" "$url" \
      -H "accept: application/json" -H "Referer: ${API_URL}" > "$output_file"

    check_API_response "$output_file" "200"
}

# Parse Input Parameters
CORE_ID="${1}"
HOST="${2:-localhost}"                              # Default to localhost if not provided
TYPE_OF_OUTBOUND_TRANSFER="${3:-MIX}"               # Default to MIX if not provided. Valid options: MIX, PUSH, DOWNLOAD
NUMBER_OF_EXPECTED_OUTBOUND_TRANSFERS="${4:-1}"     # Default to 1 if not provided
SEND_NACK_IF_NOT_FOUND="${5:-TRUE}"                 # Default to TRUE if not provided
ROOT_FOLDER="${6:-/var/tmp}"                        # Default to /var/tmp if not provided
CLEAR_API_OUTPUT_FILES="${7:-FALSE}"                # Default to FALSE if not provided
NUMBER_OF_RETRIES="${8:-1}"                         # Default to 1 if not provided
SLEEP_BETWEEN_RETRIES="${9:-1}"                     # Default to 1 second if not provided

if [[ -z "$CORE_ID" ]]; then
    echo "Usage: $0 <CORE_ID>"
    exit ${EXIT_CODE_ERROR}
fi


# Set script variables
YYYYMMDD=$(date +%Y%m%d)
HH=$(date +%H%M)

MAIN_DIR="${ROOT_FOLDER}/acks"
LOG_DIR="${MAIN_DIR}/${YYYYMMDD}-${HH}"
API_OUTPUTS_DIR="${LOG_DIR}/API"
FILELOG="$LOG_DIR/COREID_${CORE_ID}.log"

API_URL="https://${HOST}:444/api/v2.0"
ADMIN_USER="admin"
ADMIN_PWD="admin"

# Create necessary directories
mkdir -p "$API_OUTPUTS_DIR"
echo "All log files will be saved in: $LOG_DIR"


log_message "INFO" "##############################################################"
log_message "INFO" "Starting script execution..."
log_message "INFO" "CORE_ID: $CORE_ID"

#
# --- Find the corresponding inbound transfer ---
#
log_message "INFO" "Looking for the corresponding PeSIT inbound transfer..."
GET_PROCESSED_INBOUND_TRANSFER="$API_OUTPUTS_DIR/FIND_PESIT_INBOUND_${CORE_ID}.txt"
execute_API "GET" "${API_URL}/logs/transfers?protocol=pesit&incoming=true&status=Processed&coreId=$CORE_ID" "$GET_PROCESSED_INBOUND_TRANSFER"


InReturnCount=$(grep "returnCount" "$GET_PROCESSED_INBOUND_TRANSFER" | awk -F ':' '{print $2}' | tr -dc '0-9')
if [[ "$InReturnCount" -eq 0 ]]; then
    log_message "ERROR" "Cannot find PeSIT inbound transfer corresponding to the given Core ID: ${CORE_ID}."
    exit ${EXIT_CODE_ERROR}
fi
log_message "INFO" "Found the corresponding PeSIT inbound transfer."


#
# --- Checking if there is a processed outbound transfer with Core ID ${CORE_ID} ---
#
OUTBOUND_TYPE_REQUEST=""
if [[ "${TYPE_OF_OUTBOUND_TRANSFER}" == "MIX" ]]; then
    OUTBOUND_TYPE_REQUEST="direction=Outgoing"
elif [[ "${TYPE_OF_OUTBOUND_TRANSFER}" == "PUSH" ]]; then
    OUTBOUND_TYPE_REQUEST="direction=Outgoing&serverInitiated=true"
elif [[ "${TYPE_OF_OUTBOUND_TRANSFER}" == "DOWNLOAD" ]]; then
    OUTBOUND_TYPE_REQUEST="direction=Outgoing&serverInitiated=false"
else
    log_message "ERROR" "Invalid TYPE_OF_OUTBOUND_TRANSFER: ${TYPE_OF_OUTBOUND_TRANSFER}. Valid options are: MIX, PUSH, DOWNLOAD."
    exit ${EXIT_CODE_ERROR}
fi

PLURAL_FORM=$(if [[ "$NUMBER_OF_EXPECTED_OUTBOUND_TRANSFERS" -gt 1 ]]; then echo "are"; else echo "is"; fi)
log_message "INFO" "Checking if there ${PLURAL_FORM} ${NUMBER_OF_EXPECTED_OUTBOUND_TRANSFERS} processed outbound transfer with Core ID ${CORE_ID}..."
CHECK_CORE_ID="$API_OUTPUTS_DIR/CHECK_CORE_ID_${CORE_ID}.txt"
execute_API "GET" "${API_URL}/logs/transfers?${OUTBOUND_TYPE_REQUEST}&status=Processed&coreId=$CORE_ID" "$CHECK_CORE_ID"

RETURN_COUNT=$(grep "\"returnCount\"" "$CHECK_CORE_ID" | awk -F ':' '{print $2}' | tr -dc '0-9')
if [[ "$RETURN_COUNT" -lt ${NUMBER_OF_EXPECTED_OUTBOUND_TRANSFERS} ]]; then
    if [[ "$SEND_NACK_IF_NOT_FOUND" == "TRUE" ]]; then
        log_message "INFO" "Sending NACK for Core ID '${CORE_ID}' as the number of found transfers '${RETURN_COUNT}' does not match the expected number '${NUMBER_OF_EXPECTED_OUTBOUND_TRANSFERS}'."
        ACK_TYPE="NACK"
    else
        log_message "ERROR" "At the moment there are '${RETURN_COUNT}' outbound transfers. As '${NUMBER_OF_EXPECTED_OUTBOUND_TRANSFERS}' are expected, sending acknowledgment will be skipped."
        log_message "INFO" "Try again later."
        exit ${EXIT_CODE_RETRY}
    fi
else
    log_message "INFO" "Transfer with Core ID '${CORE_ID}' was found."
    ACK_TYPE="ACK"
fi

#
# --- Build the ACK LINK ---
#
log_message "INFO" "Building the Acknowledgment link..."
ACK_LINK=$(grep "self" "$GET_PROCESSED_INBOUND_TRANSFER" | head -1 | awk -F '"' '{print $4}')
ACK_LINK="${ACK_LINK}/operations?operation=ack"
ACK_NACK_LINK="${ACK_LINK/ack/nack}" # Replace 'ack' with 'nack' if ACK_TYPE is NACK

[[ "${ACK_TYPE}" == "ACK" ]] && ACK_NACK_LINK="$ACK_LINK"


log_message "INFO" "ACK_TYPE: $ACK_TYPE"
log_message "INFO" "ACK/NACK Link: $ACK_NACK_LINK"

#
# --- Send ACK/NACK with Retry ---
#
ACK_NACK_OUTPUT="$API_OUTPUTS_DIR/ACK_NACK_OUTPUT_${CORE_ID}.txt"
log_message "INFO" "Sending Acknowledgment..."
    
SUCCESS_CODE="HTTPC=200"
ALREADY_SENT_CODE="HTTPC=422"

for ((i=1; i<=NUMBER_OF_RETRIES; i++)); do
    log_message "DEBUG" "Retry count: $i"
    curl -k -s -u "$ADMIN_USER:$ADMIN_PWD" -w "\nHTTPC=%{http_code}" -X "POST" "$ACK_NACK_LINK" \
      -H "accept: application/json" -H "Referer: ${API_URL}" > "$ACK_NACK_OUTPUT"

    while IFS= read -r line; do
        [[ "$line" == HTTPC=* ]] && HTTP_CODE="${line//[$'\r']}"
        [[ "$line" == *"message"* ]] && RESPONSE_MESSAGE=$(echo "$line" | awk -F ':' '{gsub(/[",]/, "", $0); print $2 $3}')
    done < "$ACK_NACK_OUTPUT"

    case "$HTTP_CODE" in
        "$SUCCESS_CODE")
            log_message "INFO" "ACK/NACK sent successfully"
            break
            ;;
        "$ALREADY_SENT_CODE")
            log_message "WARNING" "Attempt $i/${NUMBER_OF_RETRIES} failed - HTTPC: $HTTP_CODE - Message: ${RESPONSE_MESSAGE}"
            log_message "INFO" "Looks like acknowledgment has already been sent for this transfer."
            break
            ;;
        *)
            log_message "WARNING" "Attempt $i/${NUMBER_OF_RETRIES} failed - HTTPC: $HTTP_CODE - Message: ${RESPONSE_MESSAGE}"
            sleep "${SLEEP_BETWEEN_RETRIES}"
            ;;
    esac
done


if [[ "${CLEAR_API_OUTPUT_FILES}" == "TRUE" && -d "$API_OUTPUTS_DIR" ]]; then
    rm -f "$API_OUTPUTS_DIR"/*_"$CORE_ID".txt    
fi
log_message "INFO" "End of script execution"
exit ${EXIT_CODE_SUCCESS}