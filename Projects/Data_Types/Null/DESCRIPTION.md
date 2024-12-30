# Performance - Unterschied zwischen Not Null and Null Spalten

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

### Code für Null
```bash
cd ../../..
cd Tools
./sysbench_script.sh \
  -out "YOUR_PATH_TO_PROJECT/Projects/Data_Types/Output/Null" \
  -len "2,25" \
  -scripts:"YOUR_PATH_TO_PROJECT/Projects/Data_Types/Null/Scripts/null:true" \
  "YOUR_PATH_TO_PROJECT/Projects/Data_Types/Null/Scripts/not_null:false"
```
### Nur Graphen erstellen für Null (log und csv- files müssen schon bestehen)
```bash
cd ../../..
cd Tools
./generate_graph.sh \
  YOUR_PATH_TO_PROJECT/Projects/Data_Types/Output/Null \
  2,25 \
 "YOUR_PATH_TO_PROJECT/Projects/Data_Types/Null/Scripts/null:true" \
 "YOUR_PATH_TO_PROJECT/Projects/Data_Types/Null/Scripts/not_null:false" 
```

#### Notes
Generell bringt es auch Performancegewinne, wenn man NULL vermeidet, wenn es möglich ist.
Viele Tabellen enthalten NULLABLE Spalten, selbst wenn die Anwendung kein NULL (Fehlen eines Wertes) speichern muss, da dies die Standardeinstellung ist.
Daher ist am besten solche Spalten bei der Tabellenerstellung mit dem Identifier NOT NULL zu definieren.
Wenn allerdings NULL-Werte gespeichert werden soll, dann sollte der Identifier nicht genutzt werden und für MySQL ist es dann schwieriger Abfragen zu optimieren, da durch Indizes, Indexstatistiken und Wertevergleiche komplizierter werden.
Dadurch benötigen sie auch mehr Speicherplatz und erfordern eine spezielle Verarbeitung innerhalb von MySQL.
Das liegt daran, dass indizierte nullable Spalten ein zusätzliches Byte pro Eintrag gebrauchen und das kann dazu führen, dass ein Index mit fester Größe in einen variablen Index umgewandelt wird.
Die Leistungsverbesserung, die durch die Änderung von NULL-Spalten in NOT NULL erzielt wird, ist in der Regel gering, aber bei der Verwendung von Indizes sollte besonders darauf geachtet werden.