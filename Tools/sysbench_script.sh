which bash

if [ -n "$GITHUB_ACTIONS" ]; then
    ENV_PATH="./db.env"
    PYTHON_PATH="./Tools/Python"
else
    ENV_PATH="YOUR_PATH_TO_PROJECT/db.env"
    PYTHON_PATH="YOUR_PATH_TO_PROJECT/Tools/Python"
fi

# Load environment variables
if [ -z "$DB_HOST" ] || [ -z "$DB_PORT" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASS" ] || [ -z "$DB_NAME" ]; then
    if [ -f "$ENV_PATH" ]; then
        # shellcheck source=/path/to/your/env/file
        source "$ENV_PATH"
    fi
fi

# Display usage instructions
usage() {
    echo "Usage: $0 -out <output_dir> [-len <custom_lengths>] -scripts:<query_info1> <query_info2> ..."
    exit 1
}

# Initialize variables
OUTPUT_DIR=""
CUSTOM_LENGTHS=""
QUERY_INFO=()
NEEDS_CUSTOM_LENGTHS=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -out) OUTPUT_DIR="$2"; shift 2 ;;
        -len) CUSTOM_LENGTHS="$2"; shift 2 ;;
        -scripts:*)
            QUERY_INFO+=("${1#-scripts:}")  # Strip the `-scripts:` prefix
            shift
            while [[ $# -gt 0 && "$1" != -* ]]; do
                QUERY_INFO+=("$1")
                shift
            done
            ;;
        *) usage ;;
    esac
done

echo "DANIEL QUERY_INFO: ${QUERY_INFO[@]}"

# Validate required arguments
if [ -z "$OUTPUT_DIR" ] || [ "${#QUERY_INFO[@]}" -eq 0 ]; then
    usage
fi

# Handle queries with ":true" flag (requires custom lengths)
for INFO in "${QUERY_INFO[@]}"; do
    [[ "$INFO" == *":true"* ]] && NEEDS_CUSTOM_LENGTHS=true
done

if $NEEDS_CUSTOM_LENGTHS && [ -z "$CUSTOM_LENGTHS" ]; then
    echo "Error: -len is required for queries marked with :true"
    exit 1
fi

# Define file paths
OUTPUT_FILE="$OUTPUT_DIR/sysbench_output.csv"
OUTPUT_FILE_INOFFICIAL="$OUTPUT_DIR/sysbench_output_inofficial.csv"
STATISTICS_OUTPUT_FILE="$OUTPUT_DIR/statistics.csv"

# Sysbench configuration
TIME=${TIME:-32}
THREADS=${THREADS:-8}
EVENTS=${EVENTS:-0}
REPORT_INTERVAL=${REPORT_INTERVAL:-4}

# Ensure output directories exist
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Prepare CSV headers
echo "Script,Time (s),Threads,TPS,QPS,Reads,Writes,Other,Latency (ms;95%),ErrPs,ReconnPs" > "$OUTPUT_FILE_INOFFICIAL"
echo "Script,Read,Write,Other,Total,Transactions,Queries,Ignored Errors,Reconnects,Total Time,Total Events,Latency Min,Latency Avg,Latency Max,Latency 95th Percentile,Latency Sum" > "$STATISTICS_OUTPUT_FILE"

run_benchmark() {
  local SCRIPT_PATH="$1"
  local MODE="$2"
  local OUTPUT_FILE="$3"
  local SCRIPT_NAME="$4"

  if [[ -n "$SCRIPT_NAME" ]]; then
      echo "Running $(basename "$SCRIPT_PATH") for $TIME seconds ..."
  fi
  if [[ "$MODE" == "prepare" ]]; then
      length=$(basename "$OUTPUT_FILE" | grep -o '[0-9]*')
      echo "Preparing database for $(basename "$SCRIPT_PATH")${length:+ with length $length}"
  fi
  [[ "$MODE" == "cleanup" ]] && echo -e "Cleaning up database for $(basename "$SCRIPT_PATH")\n"

  run_sysbench "$SCRIPT_PATH" "$MODE" "$OUTPUT_FILE"
  if [ $? -ne 0 ]; then
    echo "Benchmark failed for script $SCRIPT_PATH. Exiting."
    exit 1
  fi

  # Only extract data if the mode is "run"
  if [ "$MODE" == "run" ]; then
    extract_run_data "$RAW_RESULTS_FILE" "$SCRIPT_NAME"
    extract_statistics "$RAW_RESULTS_FILE" "$SCRIPT_NAME"
  fi
}

# Helper function to run sysbench with specified Lua script and mode
run_sysbench() {
  local LUA_SCRIPT_PATH="$1"
  local MODE="$2"
  local LOG_FILE="$3"

  sysbench \
    --db-driver=mysql \
    --mysql-host="$DB_HOST" \
    --mysql-port="$DB_PORT" \
    --mysql-user="$DB_USER" \
    --mysql-password="$DB_PASS" \
    --mysql-db="$DB_NAME" \
    --time=$TIME \
    --threads=$THREADS \
    --events=$EVENTS \
    --report-interval=$REPORT_INTERVAL \
    "$LUA_SCRIPT_PATH" "$MODE" >> "$LOG_FILE" 2>&1

  return $?
}

# Function to extract and save run data
extract_run_data() {
  local RAW_RESULTS_FILE="$1"
  local SCRIPT_NAME="$2"

  grep '^\[ ' "$RAW_RESULTS_FILE" | while read -r line; do
    time=$(echo "$line" | awk '{print $2}' | sed 's/s//')
    threads=$(echo "$line" | awk -F 'thds: ' '{print $2}' | awk '{print $1}')
    tps=$(echo "$line" | awk -F 'tps: ' '{print $2}' | awk '{print $1}')
    qps=$(echo "$line" | awk -F 'qps: ' '{print $2}' | awk '{print $1}')
    read_write_other=$(echo "$line" | sed -E 's/.*\(r\/w\/o: ([0-9.]+)\/([0-9.]+)\/([0-9.]+)\).*/\1,\2,\3/')
    reads=$(echo "$read_write_other" | cut -d',' -f1)
    writes=$(echo "$read_write_other" | cut -d',' -f2)
    other=$(echo "$read_write_other" | cut -d',' -f3)
    latency=$(echo "$line" | awk -F 'lat \\(ms,95%\\): ' '{print $2}' | awk '{print $1}')
    err_per_sec=$(echo "$line" | awk -F 'err/s: ' '{print $2}' | awk '{print $1}')
    reconn_per_sec=$(echo "$line" | awk -F 'reconn/s: ' '{print $2}' | awk '{print $1}')

    echo "$SCRIPT_NAME,$time,$threads,$tps,$qps,$reads,$writes,$other,$latency,$err_per_sec,$reconn_per_sec" >> "$OUTPUT_FILE_INOFFICIAL"
  done
}

# Function to extract statistics from sysbench results
extract_statistics() {
  local RAW_RESULTS_FILE="$1"
  local SCRIPT_NAME="$2"

  # Extract SQL statistics and append to statistics.csv
  read=$(awk '/read:/ {print $2}' "$RAW_RESULTS_FILE")
  write=$(awk '/write:/ {print $2}' "$RAW_RESULTS_FILE")
  other=$(awk '/other:/ {print $2}' "$RAW_RESULTS_FILE")
  total=$(awk '/total:/ {print $2}' "$RAW_RESULTS_FILE")
  transactions=$(awk '/transactions:/ {print $2}' "$RAW_RESULTS_FILE")
  queries=$(awk '/queries:/ {print $2}' "$RAW_RESULTS_FILE")
  ignored_errors=$(awk '/ignored errors:/ {print $3}' "$RAW_RESULTS_FILE")
  reconnects=$(awk '/reconnects:/ {print $2}' "$RAW_RESULTS_FILE")
  total_time=$(awk '/total time:/ {print $3}' "$RAW_RESULTS_FILE")
  total_events=$(awk '/total number of events:/ {print $5}' "$RAW_RESULTS_FILE")
  latency_min=$(awk '/min:/ {print $2}' "$RAW_RESULTS_FILE")
  latency_avg=$(awk '/avg:/ {print $2}' "$RAW_RESULTS_FILE")
  latency_max=$(awk '/max:/ {print $2}' "$RAW_RESULTS_FILE")
  latency_95th=$(awk '/95th percentile:/ {print $3}' "$RAW_RESULTS_FILE")
  latency_sum=$(awk '/sum:/ {print $2}' "$RAW_RESULTS_FILE")

  # Append the extracted data to the statistics output file
  echo "$SCRIPT_NAME,$read,$write,$other,$total,$transactions,$queries,$ignored_errors,$reconnects,$total_time,$total_events,$latency_min,$latency_avg,$latency_max,$latency_95th,$latency_sum" >> "$STATISTICS_OUTPUT_FILE"
}

process_script_benchmark() {
  local QUERY_PATH="$1"
  local LOG_DIR="$2"
  local INSERT_SCRIPT="$3"
  local SELECT_SCRIPT="$4"
  local LENGTH="${5:-}"

  local SCRIPTS=()
  local IS_FROM_SELECT_DIR=false

  if [ -f "$SELECT_SCRIPT.lua" ]; then
    # SELECT_SCRIPT is a Lua file
    SCRIPTS=("$INSERT_SCRIPT" "$SELECT_SCRIPT.lua")
  else
    # SELECT_SCRIPT is a directory
    SCRIPTS=("$INSERT_SCRIPT" "$SELECT_SCRIPT"/*)
    IS_FROM_SELECT_DIR=true
  fi

  for SCRIPT in "${SCRIPTS[@]}"; do
    if [ -f "$SCRIPT" ]; then
      local SCRIPT_NAME
      if [ -n "$LENGTH" ]; then
        if $IS_FROM_SELECT_DIR && [[ "$SCRIPT" == "$SELECT_SCRIPT"/* ]]; then
          SCRIPT_NAME="${QUERY_PATH##*/}_${LENGTH}_select_$(basename "$SCRIPT" .lua)"
        else
          SCRIPT_NAME="${QUERY_PATH##*/}_${LENGTH}_$(basename "$SCRIPT" .lua | sed "s/^${QUERY_PATH##*/}_//")"
        fi
      else
        if $IS_FROM_SELECT_DIR && [[ "$SCRIPT" == "$SELECT_SCRIPT"/* ]]; then
          SCRIPT_NAME="$(basename "$SELECT_SCRIPT")_$(basename "$SCRIPT" .lua)"
        else
          SCRIPT_NAME=$(basename "$SCRIPT" .lua)
        fi
      fi
      local RAW_RESULTS_FILE="$LOG_DIR/${SCRIPT_NAME}.log"
      run_benchmark "$SCRIPT" "run" "$RAW_RESULTS_FILE" "$SCRIPT_NAME"
    fi
  done
}

# Main benchmark loop
for INFO in "${QUERY_INFO[@]}"; do
  IFS=: read -r QUERY_PATH MULTIPLE_LENGTHS <<< "$INFO"

  MAIN_SCRIPT="${QUERY_PATH}/$(basename "$QUERY_PATH").lua"
  INSERT_SCRIPT="${QUERY_PATH}/$(basename "$QUERY_PATH")_insert.lua"
  SELECT_SCRIPT="${QUERY_PATH}/$(basename "$QUERY_PATH")_select"
  LOG_DIR="$OUTPUT_DIR/logs/$(basename "$QUERY_PATH")"

  if [[ "$MULTIPLE_LENGTHS" == "true" ]]; then
    IFS=',' read -r -a LENGTHS <<< "$CUSTOM_LENGTHS"

    for LENGTH in "${LENGTHS[@]}"; do
      export CUSTOM_LENGTH=$((LENGTH - 1))

      LOG_DIR_LENGTH="$LOG_DIR/length_$LENGTH"
      mkdir -p "$LOG_DIR_LENGTH"

      RAW_RESULTS_FILE="${LOG_DIR_LENGTH}/$(basename "$QUERY_PATH")_${LENGTH}_prepare.log"
      run_benchmark "$MAIN_SCRIPT" "prepare" "$RAW_RESULTS_FILE"

      process_script_benchmark "$QUERY_PATH" "$LOG_DIR_LENGTH" "$INSERT_SCRIPT" "$SELECT_SCRIPT" "$LENGTH"

      RAW_RESULTS_FILE="${LOG_DIR_LENGTH}/length_${LENGTH}_cleanup.log"
      run_benchmark "$MAIN_SCRIPT" "cleanup" "$RAW_RESULTS_FILE"
    done
  else
    # Process normally : condition false
    mkdir -p "$LOG_DIR"
    RAW_RESULTS_FILE="$LOG_DIR/$(basename "$QUERY_PATH")_prepare.log"
    run_benchmark "$MAIN_SCRIPT" "prepare" "$RAW_RESULTS_FILE"

    process_script_benchmark "$QUERY_PATH" "$LOG_DIR" "$INSERT_SCRIPT" "$SELECT_SCRIPT" "$LENGTH"

    # Cleanup phase
    RAW_RESULTS_FILE="$LOG_DIR/$(basename "$QUERY_PATH")_cleanup.log"
    run_benchmark "$MAIN_SCRIPT" "cleanup" "$RAW_RESULTS_FILE"
  fi
done

python3 "$PYTHON_PATH/generateCombinedCSV.py" "$OUTPUT_FILE_INOFFICIAL" "$OUTPUT_FILE"
echo "Combined CSV file created at $OUTPUT_FILE"

# Generate plot after all tasks are completed
echo "Generating plots..."
python3 "$PYTHON_PATH/generatePlot.py" "$OUTPUT_FILE"