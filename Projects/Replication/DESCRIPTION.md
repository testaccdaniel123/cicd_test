# Performance von Replikation
## Beschreibung

## Datenbankstruktur

## Zielsetzung
Untersucht werden:
- **Join-Performance**: Wie beeinflusst der FK-Datentyp die Geschwindigkeit von Join-Abfragen?
- **Insert-Performance**: Wie wirken sich FK-Typen auf die Geschwindigkeit von Insert-Operationen aus?

Die Ergebnisse helfen, fundierte Entscheidungen zur Datenbankgestaltung zu treffen.

## Durchführung: Ausführung des Benchmarks

Führe das folgende Script aus, um die Benchmarks mit den korrekten Pfaden und Parametern auszuführen.

### Code für Replikation vs No Replikation:
```bash
cd ../..
cd Tools/Shell-Scripts
./sysbench_script.sh \
  -out "YOUR_PATH_TO_PROJECT/Projects/Replication/Output" \
  -scripts '{
    "YOUR_PATH_TO_PROJECT/Projects/Replication/Scripts/replication": {
      "db": ["mysql_master_slave","mysql"]
    }
  }'
```

### Code für Replikation vs No Replikation (Threads auf Master-Replica aufgeteilt):
```bash
cd ../..
cd Tools/Shell-Scripts
./sysbench_script.sh \
  -out "YOUR_PATH_TO_PROJECT/Projects/Replication/Output" \
  -var '{"sel_thr":[8,16,32]}' \
  -scripts '{
    "YOUR_PATH_TO_PROJECT/Projects/Replication/Scripts/replication": {
      "vars": "sel_thr",
      "db": ["mysql_master_slave","mysql"],
      "prefixes": "replication_db_mysql_master_slave_comb_sel_thr_8_select,replication_db_mysql_master_slave_comb_sel_thr_16_select,replication_db_mysql_master_slave_comb_sel_thr_32_select"
    }
  }'
```

### Code für Replikation mit unterschiedlichen Formaten:
```bash
cd ../..
cd Tools/Shell-Scripts
./sysbench_script.sh \
  -out "YOUR_PATH_TO_PROJECT/Projects/Replication/Output" \
  -var '{"format":["statement","row","mixed"]}' \
  -scripts '{
    "YOUR_PATH_TO_PROJECT/Projects/Replication/Scripts/replication": {
      "vars": "format",
      "db": ["mysql_master_slave_less_replicas"]
    }
  }'
```

```bash
cd ../..
cd Tools/Shell-Scripts
./generate_graph.sh \
  YOUR_PATH_TO_PROJECT/Projects/Replication/Output
```