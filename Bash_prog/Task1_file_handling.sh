#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task1_file_handling.sh
# @author       Kwame Adu
# @index        <Your Index Number>
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Creates a directory and file, writes/appends content,
#               reads it, backs it up, then safely deletes the original.
# @date         September 14, 2026
# -----------------------------------------------------------------

usage() {
  echo "Usage: $0 <target-directory>"
  echo "  <target-directory>  the folder to create and work inside"
  exit 1
}

# If no argument was given, or user asked for help, show usage and stop
if [[ -z "$1" || "$1" == "-h" || "$1" == "--help" ]]; then
  usage
fi

TARGET_DIR="$1"
FILE_PATH="$TARGET_DIR/notes.txt"
BACKUP_PATH="$FILE_PATH.bak"

# Step 1: create the directory if missing
if [ -d "$TARGET_DIR" ]; then
  echo "Directory '$TARGET_DIR' already exists."
else
  mkdir -p "$TARGET_DIR"
  if [ $? -eq 0 ]; then
    echo "Created directory '$TARGET_DIR'."
  else
    echo "Error: could not create directory '$TARGET_DIR'." >&2
    exit 1
  fi
fi

# Step 2: create the file and write content
echo "This is the first line of the file." > "$FILE_PATH"
if [ $? -eq 0 ]; then
  echo "File created and written to."
else
  echo "Error: could not write to '$FILE_PATH'." >&2
  exit 1
fi

# Step 3: append more content
echo "This is an appended line." >> "$FILE_PATH"
if [ $? -eq 0 ]; then
  echo "Content appended."
else
  echo "Error: could not append to '$FILE_PATH'." >&2
  exit 1
fi

# Step 4: read and display the file
echo "----- File contents -----"
cat "$FILE_PATH"
echo "--------------------------"

# Step 5: copy to a .bak version
cp "$FILE_PATH" "$BACKUP_PATH"
if [ $? -eq 0 ]; then
  echo "Backup created at '$BACKUP_PATH'."
else
  echo "Error: backup failed." >&2
  exit 1
fi

# Step 6: delete the original, only after confirming it exists
if [ -f "$FILE_PATH" ]; then
  echo "About to delete '$FILE_PATH' (backup already exists)."
  rm "$FILE_PATH"
  if [ $? -eq 0 ]; then
    echo "Original file deleted successfully."
  else
    echo "Error: could not delete '$FILE_PATH'." >&2
    exit 1
  fi
else
  echo "Error: '$FILE_PATH' does not exist, nothing to delete." >&2
  exit 1
fi

exit 0
