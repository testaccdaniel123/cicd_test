#!/bin/bash

# ./extract_pngs_and_csv.sh YOUR_PATH_TO_PROJECT/Tools/combined-output

# Überprüfen, ob ein Ordner übergeben wurde
[ -z "$1" ] && { echo "Bitte geben Sie einen Ordner an."; exit 1; }

# Eingabe- und Zielordner
base_folder="$1"
target_folder_pngs="YOUR_PATH_TO_PROJECT/Latex/Arbeit/PNGs/Script"
target_folder_csv_results="YOUR_PATH_TO_PROJECT/Latex/Arbeit/Scripts/General/Count_Results"

# Alle count_results.csv in einem Ordner und nach Parent benennen
mkdir -p "$target_folder_csv_results"
find "$base_folder" -type f -name "count_results.csv" | while read file; do
  parent_dir=$(basename "$(dirname "$file")")
  new_name="$parent_dir.csv"
  mv "$file" "$target_folder_csv_results/$new_name"
done

# Bilder finden und verschieben
find "$base_folder" -type d | while read -r folder; do
    [ ! -d "$folder" ] && continue
    stats_file=$(find "$folder" -maxdepth 1 -type f -name "statistics.png" 2>/dev/null)

    # Wenn "statistics.png" gefunden wird
    if [ -n "$stats_file" ]; then
        stats_dir=$(dirname "$stats_file")
        # Verschieben in Parent
        for file in "Writes.png" "Reads.png" "statistics.png"; do
            src_file=$(find "$folder" -type f -name "$file" 2>/dev/null)
            [ -n "$src_file" ] && mv "$src_file" "$stats_dir/../"
        done
        rmdir "$stats_dir" 2>/dev/null
    fi

    # Löschen aller anderen Dateien und aller leeren Unterordner
    find "$folder" -type f ! \( -name "statistics.png" -o -name "Writes.png" -o -name "Reads.png" \) -exec rm {} + 2>/dev/null
    find "$folder" -type d -empty -delete 2>/dev/null
done

rm -rf "$target_folder_pngs"
mv "$base_folder" "$target_folder_pngs"
echo "Fertig!"