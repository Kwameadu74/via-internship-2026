#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task5_crud_app.sh
# @author       Kwame Adu
# @index        <Your Index Number>
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Menu-driven Todo List CRUD app. Stores records in a
#               CSV file next to the script, with backups before any
#               destructive change.
# @date         September 14, 2026
# -----------------------------------------------------------------

usage() {
  echo "Usage: $0"
  echo "  No arguments needed - run it and use the on-screen menu."
  echo "  Data is stored in 'todos.csv' next to this script."
  exit 1
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
fi

DATA_FILE="todos.csv"
BACKUP_FILE="todos.csv.bak"

# Make sure the data file exists so reads never fail on a missing file
[ -f "$DATA_FILE" ] || touch "$DATA_FILE"

# Backs up the data file before any destructive change (update/delete)
backup_data() {
  cp "$DATA_FILE" "$BACKUP_FILE"
  if [ $? -ne 0 ]; then
    echo "Error: could not create backup before modifying data." >&2
    return 1
  fi
  return 0
}

# Finds the next available ID by looking at the highest existing one
next_id() {
  local max_id
  max_id=$(cut -d',' -f1 "$DATA_FILE" | sort -n | tail -1)
  if [ -z "$max_id" ]; then
    echo 1
  else
    echo $((max_id + 1))
  fi
}

add_task() {
  local description status due_date id

  read -rp "Task description: " description
  if [ -z "$description" ]; then
    echo "Error: description cannot be empty." >&2
    return 1
  fi

  read -rp "Status (pending/done) [pending]: " status
  status=${status:-pending}

  read -rp "Due date (optional): " due_date

  id=$(next_id)
  echo "$id,$description,$status,$due_date" >> "$DATA_FILE"
  if [ $? -eq 0 ]; then
    echo "Task added with ID $id."
  else
    echo "Error: failed to add task." >&2
    return 1
  fi
}

list_tasks() {
  if [ ! -s "$DATA_FILE" ]; then
    echo "No tasks found."
    return 0
  fi
  echo "----- All Tasks -----"
  printf "%-5s %-30s %-10s %-12s\n" "ID" "Description" "Status" "Due Date"
  while IFS=',' read -r id description status due_date; do
    printf "%-5s %-30s %-10s %-12s\n" "$id" "$description" "$status" "$due_date"
  done < "$DATA_FILE"
  echo "----------------------"
}

search_tasks() {
  local keyword
  read -rp "Search keyword: " keyword
  if [ -z "$keyword" ]; then
    echo "Error: search keyword cannot be empty." >&2
    return 1
  fi

  local matches
  matches=$(grep -i "$keyword" "$DATA_FILE")
  if [ -z "$matches" ]; then
    echo "No matching tasks found."
  else
    echo "----- Matching Tasks -----"
    echo "$matches"
    echo "---------------------------"
  fi
}

update_task() {
  local id_to_update found=0
  read -rp "Enter ID of task to update: " id_to_update

  if ! grep -q "^$id_to_update," "$DATA_FILE"; then
    echo "Task with ID $id_to_update not found."
    return 1
  fi

  backup_data || return 1

  local new_description new_status new_due_date
  read -rp "New description: " new_description
  if [ -z "$new_description" ]; then
    echo "Error: description cannot be empty." >&2
    return 1
  fi
  read -rp "New status (pending/done): " new_status
  read -rp "New due date (optional): " new_due_date

  local tmp_file
  tmp_file=$(mktemp)
  while IFS=',' read -r id description status due_date; do
    if [ "$id" == "$id_to_update" ]; then
      echo "$id,$new_description,$new_status,$new_due_date" >> "$tmp_file"
      found=1
    else
      echo "$id,$description,$status,$due_date" >> "$tmp_file"
    fi
  done < "$DATA_FILE"

  mv "$tmp_file" "$DATA_FILE"
  if [ $found -eq 1 ]; then
    echo "Task $id_to_update updated."
  else
    echo "Error: something went wrong updating task $id_to_update." >&2
    return 1
  fi
}

delete_task() {
  local id_to_delete confirm
  read -rp "Enter ID of task to delete: " id_to_delete

  if ! grep -q "^$id_to_delete," "$DATA_FILE"; then
    echo "Task with ID $id_to_delete not found."
    return 1
  fi

  read -rp "Are you sure you want to delete task $id_to_delete? (y/n): " confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Delete cancelled."
    return 0
  fi

  backup_data || return 1

  grep -v "^$id_to_delete," "$DATA_FILE" > "${DATA_FILE}.tmp"
  mv "${DATA_FILE}.tmp" "$DATA_FILE"
  if [ $? -eq 0 ]; then
    echo "Task $id_to_delete deleted."
  else
    echo "Error: failed to delete task $id_to_delete." >&2
    return 1
  fi
}

show_menu() {
  echo ""
  echo "===== Todo List Menu ====="
  echo "1) Add task"
  echo "2) View/List tasks"
  echo "3) Search tasks"
  echo "4) Update task"
  echo "5) Delete task"
  echo "6) Exit"
  echo "==========================="
}

# Main menu loop
while true; do
  show_menu
  read -rp "Choose an option (1-6): " choice
  case "$choice" in
    1) add_task ;;
    2) list_tasks ;;
    3) search_tasks ;;
    4) update_task ;;
    5) delete_task ;;
    6)
      echo "Goodbye."
      exit 0
      ;;
    *)
      echo "Invalid option. Please choose 1-6." >&2
      ;;
  esac
done
