#!/bin/bash
# ==============================================================================
# Script Name: IteratePesitInbounds.sh
# Author: Plamen Milenkov
# Created: 2025-08-05
# Location: Sofia
# ==============================================================================
# Description:
# This script automates the retrieval and processing of PeSIT inbound transfers
# from a remote API. It identifies transfers that have not yet received an
# acknowledgment and triggers the acknowledgment process for each.
#
# Key Features:
# - Supports both macOS and Linux date syntax for time range calculation.
# - Encodes timestamps to RFC 2822 format for API compatibility.
# - Logs all operations with timestamps and core identifiers.
# - Optionally clears API output files after processing.
#
# Usage:
# ./PeSIT_Inbound_Transfer_Acknowledgment.sh <START_HOURS_AGO> <END_HOURS_AGO> [HOST] [ROOT_FOLDER] [CLEAR_API_OUTPUT_FILES]
#
# Parameters:
# START_HOURS_AGO         - Number of hours ago to start the time window.
# END_HOURS_AGO           - Number of hours ago to end the time window.
# HOST                    - API host (default: localhost).
# ROOT_FOLDER             - Root directory for logs and outputs (default: /var/tmp).
# CLEAR_API_OUTPUT_FILES  - TRUE to delete API output files after processing (default: FALSE).
#
# Dependencies:
# - curl
# - jq
#
# Exit Codes:
# 0 - Success
# 1 - Error (e.g., missing parameters, API failure)
#
# Notes:
# - Ensure ADMIN_USER and ADMIN_PWD are securely managed.
# - This script is intended for internal use and assumes trusted network access.
# ==============================================================================

set -e
set -o pipefail

log_message() {
    local level="$1"
    local msg="$2"
    local logFile="${3:-$FILELOG}"
    local timestamp
    timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    echo "$timestamp - $CORE_ID - $level - $msg" >> "$logFile"
}

check_API_response() {
    local http_code="$1"
    local expected_code="$2"

    log_message "INFO" "HTTPC: $http_code"
    
    if [[ "$http_code" != "$expected_code" ]]; then
        log_message "ERROR" "API Call Error - HTTPC: $http_code"
        exit ${EXIT_CODE_ERROR}
    fi
}

execute_API(){
    local method="$1"
    local url="$2"
    local output_file="$3"

    local http_code

    # Execute the curl, capturing response and HTTP code separately
    http_code=$(curl -k -s -u "$ADMIN_USER:$ADMIN_PWD" -w "%{http_code}" -X "$method" -H "accept: application/json" -o "$output_file" "$url")
    check_API_response "$http_code" "200"
}

url_encode_rfc2822(){
  local raw="$1"
  local encoded=""
  local i c

  for (( i=0; i<${#raw}; i++ )); do
    c="${raw:$i:1}"
    case "$c" in
      [a-zA-Z0-9.~_-]) encoded+="$c" ;;
      ' ') encoded+="%20" ;;
      ',') encoded+="%2C" ;;
      ':') encoded+="%3A" ;;
      '+') encoded+="%2B" ;;
      *) printf -v hex '%%%02X' "'$c"; encoded+="$hex" ;;
    esac
  done

  echo "$encoded"
}

# Exit codes
EXIT_CODE_SUCCESS=0
EXIT_CODE_ERROR=1

# Parse Input Parameters
START_HOURS_AGO=$1
END_HOURS_AGO=$2
HOST="${3:-localhost}"                              # Default to localhost if not provided
ROOT_FOLDER="${4:-/var/tmp}"                        # Default to /var/tmp if not provided
CLEAR_API_OUTPUT_FILES="${5:-FALSE}"                # Default to FALSE if not provided


if [[ -z "$START_HOURS_AGO" || -z "$END_HOURS_AGO" ]]; then
    echo "Usage: $0 <START_HOURS_AGO> <END_HOURS_AGO> [HOST] [ROOT_FOLDER] [CLEAR_API_OUTPUT_FILES]"
    exit ${EXIT_CODE_ERROR}
fi


# Set script variables
YYYYMMDD=$(date +%Y%m%d)
HH=$(date +%H%M)

MAIN_DIR="${ROOT_FOLDER}/acks"
LOG_DIR="${MAIN_DIR}/${YYYYMMDD}-${HH}"
API_OUTPUTS_DIR="${LOG_DIR}/API"
FILELOG="$LOG_DIR/All_PeSIT_Inbound_${START_HOURS_AGO}_${END_HOURS_AGO}.log"

API_URL="https://${HOST}:444/api/v2.0"
ADMIN_USER="admin"
ADMIN_PWD="admin"  # Ensure this is securely managed

# Create necessary directories
mkdir -p "$API_OUTPUTS_DIR"
echo "All log files will be saved in: $LOG_DIR"


log_message "INFO" "##############################################################"
log_message "INFO" "Starting script execution..."
log_message "INFO" "CORE_ID: $CORE_ID"

#
# --- Find all transfers ---
#
log_message "INFO" "Looking for all PeSIT inbound transfers..."
ALL_PESIT_INBOUND="$API_OUTPUTS_DIR/ALL_PESIT_INBOUND.txt"

if date -v -1H >/dev/null 2>&1; then
    # macOS syntax
    START_TIME=$(date -u -v-"${START_HOURS_AGO}"H +"%a, %d %b %Y %H:%M:%S %z")
    END_TIME=$(date -u -v-"${END_HOURS_AGO}"H +"%a, %d %b %Y %H:%M:%S %z")
else
    # Linux syntax
    START_TIME=$(date -u -d "${START_HOURS_AGO} hours ago" +"%a, %d %b %Y %H:%M:%S %z")
    END_TIME=$(date -u -d "${END_HOURS_AGO} hours ago" +"%a, %d %b %Y %H:%M:%S %z")
fi

START_TIME_ENCODED=$(url_encode_rfc2822 "$START_TIME")
END_TIME_ENCODED=$(url_encode_rfc2822 "$END_TIME")
log_message "INFO" "Start time (${START_HOURS_AGO} hours ago): $START_TIME. Encoded: $START_TIME_ENCODED"
log_message "INFO" "End time (${END_HOURS_AGO} hours ago): $END_TIME. Encoded: $END_TIME_ENCODED"
execute_API "GET" "${API_URL}/logs/transfers?protocol=pesit&direction=Incoming&status=Processed&endTimeAfter=${START_TIME_ENCODED}&endTimeBefore=${END_TIME_ENCODED}&fields=coreId,pesitAckStatus" "$ALL_PESIT_INBOUND"

# Extract matching urlrepresentation values into a Bash array
tmpfile=$(mktemp)
jq -r '.result[] | select(.pesitAckStatus == null) | .coreId' "$ALL_PESIT_INBOUND" > "$tmpfile"

ids=()
while IFS= read -r line; do
  [ -n "$line" ] && ids+=("$line")
done < "$tmpfile"

rm -f "$tmpfile"

log_message "INFO" "Found ${#ids[@]} PeSIT inbound transfers."
for CORE_ID in "${ids[@]}"; do
    log_message "INFO" "Processing Core ID: $CORE_ID"
    # Call the Acknowledgment script for each Core ID
    ./Acknowledgment.sh "$CORE_ID" "$HOST" "MIX" 1 FALSE
done

if [[ "${CLEAR_API_OUTPUT_FILES}" == "TRUE" && -d "$API_OUTPUTS_DIR" ]]; then
    log_message "INFO" "Clearing API output files in directory: $API_OUTPUTS_DIR"
    rm -f "$API_OUTPUTS_DIR"/*_"$CORE_ID".txt    
fi

log_message "INFO" "End of script execution"
exit ${EXIT_CODE_SUCCESS}