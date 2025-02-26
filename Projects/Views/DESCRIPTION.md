# Performance - Analyse für Views

## Beschreibung

Es wird die **Performance** von unterschiedlichen **Relationen und Views** analysiert.

## Datenbankstruktur

Das Projekt verwendet die gleiche Tabelle **KUNDE**, wie auch für den Integer-Fall in Join_Typ. 

## Zielsetzung
Untersucht werden:
- Performance – Unterschied mit **unterschiedlichen Zeilenanzahl**
- Veranschaulichung der Performanceunterschiede, **je nach Sortierung** des Index usw.
  - Index sollte funktionieren für: [column_prefix.lua](Scripts/query_differences/query_differences_select/column_prefix.lua), [combined_match_with_range.lua](Scripts/query_differences/query_differences_select/combined_match_with_range.lua), [exact_with_prefix.lua](Scripts/query_differences/query_differences_select/exact_with_prefix.lua), [full_match.lua](Scripts/query_differences/query_differences_select/full_match.lua),[leftmost_prefix.lua](Scripts/query_differences/query_differences_select/leftmost_prefix.lua), [range_values.lua](Scripts/query_differences/query_differences_select/range_values.lua)
  - Nicht funktionieren für: [not_leftmost.lua](Scripts/query_differences/query_differences_select/not_leftmost.lua), [range_with_like.lua](Scripts/query_differences/query_differences_select/range_with_like.lua), [skip_columns.lua](Scripts/query_differences/query_differences_select/skip_columns.lua)
    
### Code für View-Vergleich:
```bash
cd ../..
cd Tools/Shell-Scripts
./sysbench_script.sh \
  -out "YOUR_PATH_TO_PROJECT/Projects/Views/Output" \
  -scripts '{
   "YOUR_PATH_TO_PROJECT/Projects/Views/Scripts/without_view": {},
    "YOUR_PATH_TO_PROJECT/Projects/Views/Scripts/virtual_view": {},
    "YOUR_PATH_TO_PROJECT/Projects/Views/Scripts/with_trigger": {}
  }'
```

### Code mit Materialized View-Vergleich:
```bash
cd ../..
cd Tools/Shell-Scripts
./sysbench_script.sh \
  -out "YOUR_PATH_TO_PROJECT/Projects/Views/Output" \
  -var '{"refresh":["every","once"]}' \
  -scripts '{
    "YOUR_PATH_TO_PROJECT/Projects/Views/Scripts/with_trigger": {},
    "YOUR_PATH_TO_PROJECT/Projects/Views/Scripts/with_trigger_pg": {
      "db": ["postgres"]
    },
    "YOUR_PATH_TO_PROJECT/Projects/Views/Scripts/mat_view": {
      "vars": "refresh",
      "db": ["postgres"]
    }
  }'
```

### Nur Graphen erstellen für Select - Queries (log und csv- files müssen schon bestehen)
```bash
cd ../..
cd Tools/Shell-Scripts
./generate_graph.sh \
  YOUR_PATH_TO_PROJECT/Projects/Views/Output
```