#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task4_return_codes_error_handling.sh
# @author       Kwame Adu
# @index        <Your Index Number>
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Runs a sequence of system checks (host reachability,
#               disk space, config file, required command), exits
#               with a specific documented code on failure, and
#               cleans up temp files with a trap.
# @date         September 14, 2026
# -----------------------------------------------------------------

# Exit codes:
#   0 = all checks passed
#   1 = missing required argument
#   2 = host unreachable
#   3 = insufficient disk space
#   4 = required file not found
#   5 = required command not found

usage() {
  echo "Usage: $0 <hostname>"
  echo "  <hostname>  a host to test reachability against (e.g. github.com)"
  exit 1
}

if [[ -z "$1" || "$1" == "-h" || "$1" == "--help" ]]; then
  usage
fi

HOST="$1"
CONFIG_FILE="config.txt"
TMP_FILE=$(mktemp)

# Clean up the temp file no matter how the script ends (success, failure, Ctrl+C)
trap 'rm -f "$TMP_FILE"; echo "Cleaned up temporary file."' EXIT

# Helper function: takes a description, the result of $?, and the exit
# code to use if it failed. Logs a pass/fail message either way.
check_status() {
  local description="$1"
  local result="$2"
  local fail_code="$3"

  if [ "$result" -eq 0 ]; then
    echo "[PASS] $description"
  else
    echo "Error: [FAIL] $description" >&2
    exit "$fail_code"
  fi
}

# Check 1: is the host reachable?
echo "Checking if host '$HOST' is reachable..."
ping -c 1 -W 2 "$HOST" > "$TMP_FILE" 2>&1
check_status "Host '$HOST' is reachable" $? 2

# Check 2: is there enough free disk space? (require at least 1GB free on /)
echo "Checking free disk space..."
AVAILABLE_KB=$(df --output=avail / | tail -n 1 | tr -d ' ')
if [ "$AVAILABLE_KB" -ge 1048576 ]; then
  DISK_CHECK_RESULT=0
else
  DISK_CHECK_RESULT=1
fi
check_status "At least 1GB free disk space on /" $DISK_CHECK_RESULT 3

# Check 3: does the config/data file exist and is it readable?
echo "Checking config file..."
# create a dummy config file for demonstration if it doesn't exist
[ -f "$CONFIG_FILE" ] || echo "sample_setting=true" > "$CONFIG_FILE"
[ -r "$CONFIG_FILE" ]
check_status "Config file '$CONFIG_FILE' exists and is readable" $? 4

# Check 4: is a required command installed? (using 'curl' as the example)
echo "Checking for required command 'curl'..."
command -v curl > /dev/null 2>&1
check_status "'curl' is installed" $? 5

echo ""
echo "All checks passed."
exit 0
