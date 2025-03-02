# Performance von Replikation

## Beschreibung

Es wird der Performance - Unterschied von dem Replikationsansatz Master-Replica analysiert.
Auch der Einfluss der Binlog-Formate wird untersucht

## Datenbankstruktur

Das Projekt verwendet zwei Tabellen: **KUNDE** und **BESTELLUNG**.
Außerdem wird das Binlog-Format bei einem Benchmark verändert.

## Zielsetzung
Untersucht werden:
- **Replikation vs No Replikation**: Wie ist die Performance zwischen dem Master-Replica- und dem Single-Server-Ansatz bei je einem Thread?
- **Replikation vs No Replikation v2**: Wie ist die Performance mit 8 (bzw. 16 oder 32) Threads auf den Single-Server und die Aufteilung der entsprechender auf den Master und alle Replicas?
- **Binlog-Format**: Wie wirken sich die Binlog-Formate auf die Performance der Operationen aus?

## Durchführung: Ausführung des Benchmarks
Führe die folgenden Scripts aus, um die Benchmarks mit den korrekten Pfaden und Parametern zu starten.

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