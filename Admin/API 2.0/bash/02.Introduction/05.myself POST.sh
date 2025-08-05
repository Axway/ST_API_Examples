#!/bin/bash
# ==============================================================================
# Script Name: 05.myself_POST.sh
# Author: Plamen Milenkov
# Created: 2025-08-05
# Location: Sofia
# ==============================================================================
# Description:
# This script performs a POST request to the `/myself` endpoint, which is related
# to user authentication. It initiates a session or validates credentials depending
# on the API implementation.
#
# Usage:
# ./05.myself_POST.sh
#
# Notes:
# - For complete documentation, refer to folder 01.Authentication.
# - Ensure that `set_variables.sh` is correctly configured and sourced.
# ==============================================================================

source "../set_variables.sh"

curl -s -k -u "${USER}:${PWD}" -X POST "https://${SERVER}:${PORT}/api/v2.0/myself" -H "accept: application/json"
