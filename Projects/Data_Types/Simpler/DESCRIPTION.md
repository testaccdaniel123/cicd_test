# Performance - Unterschied zwischen Int und Char

## Beschreibung

Es wird der Performance - Unterschied zwischen **Int und Char** analysiert.

## Datenbankstruktur

Das Projekt verwendet die gleiche Tabelle **KUNDE**, wie auch für den Integer-Fall in Join_Typ.

## Zielsetzung
Untersucht werden:
- Performance – Unterschied mit **unterschiedlichen Zeilenanzahl** insbesondere um die Geschwindigkeit für die Einfügeoperationen zu analysieren.
- Veranschaulichung der Performanceunterschiede für unterschiedliche **Select-Queries**:
  - Simple Where
  - With Sorting

### Code für Int/Char - Vergleich:
```bash
cd ../../..
cd Tools
./sysbench_script.sh \
  -out "YOUR_PATH_TO_PROJECT/Projects/Data_Types/Output/Simpler" \
  -scripts:"YOUR_PATH_TO_PROJECT/Projects/Data_Types/Simpler/Scripts/int_column" \
  "YOUR_PATH_TO_PROJECT/Projects/Data_Types/Simpler/Scripts/char_column"
```

### Nur Graphen erstellen für Int/Char - Vergleich: (log und csv- files müssen schon bestehen)
```bash
cd ../../..
cd Tools
./generate_graph.sh \
  YOUR_PATH_TO_PROJECT/Projects/Data_Types/Output/Simpler \
  "YOUR_PATH_TO_PROJECT/Projects/Data_Types/Simpler/Scripts/int_column:false" \
  "YOUR_PATH_TO_PROJECT/Projects/Data_Types/Simpler/Scripts/char_column:false"
```


#### Notes
Ein weiterer allgemeiner Leitsatz ist, dass ein einfacherer Datentyp gut ist, denn es werden weniger CPU-Zyklen benötigt, um Operationen auf einfacheren Datentypen zu verarbeiten.
Beispielweise ist Integer einfacher zu verarbeiten als Character, da Character Sets und Sortierregeln den Character-Vergleich erschweren.