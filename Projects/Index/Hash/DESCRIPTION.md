# Performance - Analyse für Hash - Index

## Beschreibung

Es wird die **Performance vom Hash-Index** (mit Memory Storage Engine) analysiert.

## Datenbankstruktur

Das Projekt verwendet die gleiche Tabelle **KUNDE**, wie auch für den Integer-Fall in Join_Typ.

## Zielsetzung
Untersucht werden:
- Viele Hashkollisionen vs wenige Hashkollisionen erzwingen => unterschiedliche Selektivität
- Performance von Select - Queries
    - Ein Beispiel mit komplettem Index (1) => [full_match.lua](Scripts/query_differences/query_differences_select/full_match.lua)
    - Nur Nachname (2) => [leftmost_prefix.lua](Scripts/query_differences/query_differences_select/leftmost_prefix.lua)
    - Nachname + Vorname mit Range (3) => [partial_match_range_query.lua](Scripts/query_differences/query_differences_select/partial_match_range_query.lua)
    - Nachname + Vorname + BDay als Range (4) => [combined_match_with_range.lua](Scripts/query_differences/query_differences_select/combined_match_with_range.lua)

### Code für Selektivität Vergleich:
```bash
cd ../../..
cd Tools/Shell-Scripts
./sysbench_script.sh \
  -out "YOUR_PATH_TO_PROJECT/Projects/Index/Hash/Output" \
  -var '{"prob":[25,10,5,1]}' \
  -scripts '{
    "YOUR_PATH_TO_PROJECT/Projects/Index/Hash/Scripts/selectivity_changes": {"vars": "prob"}
  }'
```

### Code unterschiedliche Select - Queries
```bash
cd ../../..
cd Tools/Shell-Scripts
./sysbench_script.sh \
  -out "YOUR_PATH_TO_PROJECT/Projects/Index/Hash/Output" \
  -scripts '{
    "YOUR_PATH_TO_PROJECT/Projects/Index/Hash/Scripts/query_differences": {}
  }'
```

### Nur Graphen erstellen für Select - Queries (log und csv- files müssen schon bestehen)
```bash
cd ../../..
cd Tools/Shell-Scripts
./generate_graph.sh \
  YOUR_PATH_TO_PROJECT/Projects/Index/Hash/Output
```