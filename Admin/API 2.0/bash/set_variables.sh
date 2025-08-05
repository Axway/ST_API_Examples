#!/bin/bash
# ==============================================================================
# Script Name: set_variables.sh
# Author: Plamen Milenkov
# Created: 2025-08-05
# Location: Sofia
# ==============================================================================
# Description:
# This script sets environment variables required for API authentication and
# connectivity. It is intended to be sourced by other scripts that rely on
# SERVER, PORT, USER, and PWD values.
#
# Usage:
# source ./set_variables.sh
#
# Notes:
# - Ensure this script is sourced, not executed, to preserve environment variables.
# - Values should be securely managed and updated as needed.
# ==============================================================================

export SERVER=""
export PORT=""
export USER=""
export PWD=""
