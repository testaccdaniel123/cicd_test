# Performance - Unterschied zwischen Int und Char

## Beschreibung

Es wird der Performance - Unterschied zwischen **Int und Char** analysiert.

## Datenbankstruktur

Das Projekt verwendet die gleiche Tabelle **KUNDE**, wie auch für den Integer-Fall in Join_Typ.
Dieses Mal wird einmal die Spalte **KUNDEN_ID** als [**INT**](Scripts/int_column) definiert und eine andere als [**CHAR**](Scripts/char_column).

## Zielsetzung
Untersucht werden:
- Performance – Unterschied zwischen Int und Char Spalten
- Veranschaulichung der Performanceunterschiede für unterschiedliche **Select-Queries**:
  - Desc Sort
  - Range Compare

### Code für Int/Char - Vergleich:
```bash
cd ../../..
cd Tools/Shell-Scripts
./sysbench_script.sh \
  -out "YOUR_PATH_TO_PROJECT/Projects/Data_Types/Simpler/Output" \
  -scripts '{
    "YOUR_PATH_TO_PROJECT/Projects/Data_Types/Simpler/Scripts/int_column": {},
    "YOUR_PATH_TO_PROJECT/Projects/Data_Types/Simpler/Scripts/char_column": {}
  }'
```

### Nur Graphen erstellen für Int/Char - Vergleich: (log und csv- files müssen schon bestehen)
```bash
cd ../../..
cd Tools/Shell-Scripts
./generate_graph.sh \
  YOUR_PATH_TO_PROJECT/Projects/Data_Types/Simpler/Output
```
