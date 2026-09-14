#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task2_permissions_sudo.sh
# @author       Kwame Adu
# @index        <Your Index Number>
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Reports a file's permissions, changes them using both
#               numeric and symbolic chmod, attempts chown if run as
#               root, and reports permissions again after changes.
# @date         September 14, 2026
# -----------------------------------------------------------------

usage() {
  echo "Usage: $0 <file-path>"
  echo "  <file-path>  the file to inspect and modify permissions on"
  exit 1
}

# Validate input: need exactly one argument, and it must be a real file
if [[ -z "$1" || "$1" == "-h" || "$1" == "--help" ]]; then
  usage
fi

FILE_PATH="$1"

if [ ! -f "$FILE_PATH" ]; then
  echo "Error: '$FILE_PATH' is not a valid file." >&2
  exit 1
fi

# Function to show permissions in both symbolic and numeric form
show_permissions() {
  local label="$1"
  echo "----- $label -----"
  ls -l "$FILE_PATH"
  # stat -c '%a' gives the numeric permission (e.g. 644)
  local numeric
  numeric=$(stat -c '%a' "$FILE_PATH")
  if [ $? -eq 0 ]; then
    echo "Numeric permissions: $numeric"
  else
    echo "Error: could not read permissions with stat." >&2
    exit 1
  fi
  echo "-------------------------"
}

# Step 1: show current permissions
show_permissions "Permissions BEFORE changes"

# Step 2: demonstrate numeric chmod
chmod 644 "$FILE_PATH"
if [ $? -eq 0 ]; then
  echo "Applied numeric chmod 644."
else
  echo "Error: numeric chmod failed." >&2
  exit 1
fi

# Step 3: demonstrate symbolic chmod
chmod u+x "$FILE_PATH"
if [ $? -eq 0 ]; then
  echo "Applied symbolic chmod u+x."
else
  echo "Error: symbolic chmod failed." >&2
  exit 1
fi

# Step 4: check if running as root, attempt chown if so
CURRENT_UID=$(id -u)
if [ "$CURRENT_UID" -eq 0 ]; then
  echo "Running as root - attempting chown to root:root..."
  chown root:root "$FILE_PATH"
  if [ $? -eq 0 ]; then
    echo "Ownership changed successfully."
  else
    echo "Error: chown failed even though running as root." >&2
  fi
else
  echo "Not running as root (current UID: $CURRENT_UID) - skipping chown."
  echo "Run this script with 'sudo' if you want to test the chown step."
fi

# Step 5: show permissions after changes
show_permissions "Permissions AFTER changes"

exit 0
