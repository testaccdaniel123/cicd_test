#!/bin/bash
# ./extract_count_from_logs.sh YOUR_PATH_TO_PROJECT/Projects/Index/B_Tree/Output/b-tree-query-differences

# Überprüfen, ob Outputordner übergeben wurde
[ -z "$1" ] && { echo "Bitte geben Sie einen Ordner an."; exit 1; }

# Definitionen
base_folder="$1"
log_folder="$base_folder/logs"
result_file="$base_folder/count_results.csv"
temp_file=$(mktemp)

# Alle Logfiles (auch in Unterordnern) durchsuchen und Count-Werte extrahieren
find "$log_folder" -type f -name "*.log" | while read -r file; do
    filename=$(basename "$file" .log)
    if [[ "$filename" == *select* ]]; then
        # Extrahiere den COUNT-Wert
        count_value=$(awk '/COUNT\(\*\)/ {getline; print $0}' "$file")
        echo "$filename,$count_value" >> "$temp_file"
    fi
done

# Aufsteigend nach CountValue sortieren
echo "LogFile,CountValue" > "$result_file"
sort -t, -k2,2n "$temp_file" >> "$result_file"
rm "$temp_file"
echo "Result CSV created at $result_file"
