#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task3_pipes_redirection.sh
# @author       Kwame Adu
# @index        <Your Index Number>
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Generates sample log data, then uses pipes and text
#               tools to summarize line counts, log levels, top IPs,
#               and error lines. Redirects output to results.txt and
#               errors.log.
# @date         September 14, 2026
# -----------------------------------------------------------------

usage() {
  echo "Usage: $0"
  echo "  No arguments needed - this script generates its own sample data."
  exit 1
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
fi

LOG_FILE="sample.log"
RESULTS_FILE="results.txt"
ERROR_FILE="errors.log"

# Step 1: generate sample log data with a heredoc
cat > "$LOG_FILE" << 'EOF'
2026-09-11 10:00:01 INFO 192.168.1.10 User login successful
2026-09-11 10:00:15 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:00:30 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:00:45 INFO 192.168.1.15 File uploaded successfully
2026-09-11 10:01:00 ERROR 192.168.1.23 Database connection failed
2026-09-11 10:01:15 INFO 192.168.1.10 User logout
2026-09-11 10:01:30 WARN 192.168.1.30 Memory usage high
2026-09-11 10:01:45 INFO 192.168.1.15 User login successful
2026-09-11 10:02:00 ERROR 192.168.1.10 Permission denied
2026-09-11 10:02:15 INFO 192.168.1.23 Page loaded
2026-09-11 10:02:30 WARN 192.168.1.15 Disk usage above 80%
2026-09-11 10:02:45 INFO 192.168.1.30 User login successful
2026-09-11 10:03:00 ERROR 192.168.1.30 Connection timeout
2026-09-11 10:03:15 INFO 192.168.1.10 File uploaded successfully
2026-09-11 10:03:30 WARN 192.168.1.23 CPU usage high
2026-09-11 10:03:45 INFO 192.168.1.15 User logout
2026-09-11 10:04:00 ERROR 192.168.1.10 Database connection failed
2026-09-11 10:04:15 INFO 192.168.1.30 Page loaded
2026-09-11 10:04:30 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:04:45 INFO 192.168.1.23 User login successful
2026-09-11 10:05:00 ERROR 192.168.1.15 Permission denied
2026-09-11 10:05:15 INFO 192.168.1.10 File uploaded successfully
2026-09-11 10:05:30 WARN 192.168.1.30 Memory usage high
2026-09-11 10:05:45 INFO 192.168.1.23 User logout
2026-09-11 10:06:00 ERROR 192.168.1.10 Connection timeout
2026-09-11 10:06:15 INFO 192.168.1.15 Page loaded
2026-09-11 10:06:30 WARN 192.168.1.10 CPU usage high
2026-09-11 10:06:45 INFO 192.168.1.30 User login successful
2026-09-11 10:07:00 ERROR 192.168.1.23 Permission denied
2026-09-11 10:07:15 INFO 192.168.1.10 File uploaded successfully
2026-09-11 10:07:30 WARN 192.168.1.15 Disk usage above 80%
2026-09-11 10:07:45 INFO 192.168.1.23 User logout
2026-09-11 10:08:00 ERROR 192.168.1.30 Database connection failed
2026-09-11 10:08:15 INFO 192.168.1.10 Page loaded
2026-09-11 10:08:30 WARN 192.168.1.23 Memory usage high
2026-09-11 10:08:45 INFO 192.168.1.15 User login successful
2026-09-11 10:09:00 ERROR 192.168.1.10 Permission denied
2026-09-11 10:09:15 INFO 192.168.1.30 File uploaded successfully
2026-09-11 10:09:30 WARN 192.168.1.10 CPU usage high
2026-09-11 10:09:45 INFO 192.168.1.23 User logout
2026-09-11 10:10:00 ERROR 192.168.1.15 Connection timeout
2026-09-11 10:10:15 INFO 192.168.1.10 Page loaded
2026-09-11 10:10:30 WARN 192.168.1.30 Disk usage above 80%
2026-09-11 10:10:45 INFO 192.168.1.23 User login successful
2026-09-11 10:11:00 ERROR 192.168.1.10 Database connection failed
2026-09-11 10:11:15 INFO 192.168.1.15 File uploaded successfully
2026-09-11 10:11:30 WARN 192.168.1.23 Memory usage high
2026-09-11 10:11:45 INFO 192.168.1.10 User logout
2026-09-11 10:12:00 ERROR 192.168.1.30 Permission denied
2026-09-11 10:12:15 INFO 192.168.1.15 Page loaded
2026-09-11 10:12:30 WARN 192.168.1.10 CPU usage high
2026-09-11 10:12:45 INFO 192.168.1.23 User login successful
2026-09-11 10:13:00 ERROR 192.168.1.15 Connection timeout
EOF

if [ $? -eq 0 ]; then
  echo "Sample log file '$LOG_FILE' generated (50 lines)."
else
  echo "Error: could not generate log file." >&2
  exit 1
fi

# Step 2: compute stats, sending real errors to errors.log instead of the screen
{
  echo "===== Log Summary Report ====="
  echo ""

  echo "Total lines:"
  wc -l < "$LOG_FILE"
  echo ""

  echo "Lines per log level:"
  awk '{print $3}' "$LOG_FILE" | sort | uniq -c | sort -rn
  echo ""

  echo "Top 3 most frequent IP addresses:"
  awk '{print $4}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -3
  echo ""

  echo "All ERROR lines:"
  grep "ERROR" "$LOG_FILE"

} > "$RESULTS_FILE" 2> "$ERROR_FILE"

if [ $? -eq 0 ]; then
  echo "Report written to '$RESULTS_FILE'."
else
  echo "Error: something went wrong generating the report - check '$ERROR_FILE'." >&2
  exit 1
fi

echo "----- Preview of $RESULTS_FILE -----"
cat "$RESULTS_FILE"

exit 0
