# Performance von Replikation (WIP)
## Beschreibung

## Datenbankstruktur

## Zielsetzung
Untersucht werden:
- **Join-Performance**: Wie beeinflusst der FK-Datentyp die Geschwindigkeit von Join-Abfragen?
- **Insert-Performance**: Wie wirken sich FK-Typen auf die Geschwindigkeit von Insert-Operationen aus?

Die Ergebnisse helfen, fundierte Entscheidungen zur Datenbankgestaltung zu treffen.

## Durchführung: Ausführung des Benchmarks

Führe das folgende Script aus, um die Benchmarks mit den korrekten Pfaden und Parametern auszuführen.

### Code für Join Type - Vergleich:

```bash
cd ../..
cd Tools
./sysbench_script.sh \
  -out "YOUR_PATH_TO_PROJECT/Projects/Replication/Output" \
  -scripts '{
    "YOUR_PATH_TO_PROJECT/Projects/Replication/Scripts/int_queries": {
      "db": ["mysql","mysql_master_slave","postgres"]
    }
  }'
```

```bash
cd ../..
cd Tools
./generate_graph.sh \
  YOUR_PATH_TO_PROJECT/Projects/Join_Typ/Output
```