# Performance von Partitioning
## Beschreibung

## Datenbankstruktur

## Zielsetzung
Untersucht werden:
- **Join-Performance**: Wie beeinflusst der FK-Datentyp die Geschwindigkeit von Join-Abfragen?
- **Insert-Performance**: Wie wirken sich FK-Typen auf die Geschwindigkeit von Insert-Operationen aus?

Die Ergebnisse helfen, fundierte Entscheidungen zur Datenbankgestaltung zu treffen.

## Durchführung: Ausführung des Benchmarks

Führe das folgende Script aus, um die Benchmarks mit den korrekten Pfaden und Parametern auszuführen.

### Code für Range-Partitionierung:
```bash
cd ../..
cd Tools
./sysbench_script.sh \
  -out "YOUR_PATH_TO_PROJECT/Projects/Partition/Output" \
  -scripts '{
    "YOUR_PATH_TO_PROJECT/Projects/Partition/Scripts/without_partitioning": {
      "selects": ["without_range_failing_pruning","without_range_primary_key"]
    },
    "YOUR_PATH_TO_PROJECT/Projects/Partition/Scripts/range_partitioning": {}
  }'
```

### Code für Range-Partitionierung-Vergleich zwischen RANGE COLUMNS and only RANGE (nicht in CI/CD enthalten, also pattern.json):
```bash
cd ../..
cd Tools
./sysbench_script.sh \
  -out "YOUR_PATH_TO_PROJECT/Projects/Partition/Output" \
  -var '{"type":["range_columns","only_range"]}' \
  -scripts '{
    "YOUR_PATH_TO_PROJECT/Projects/Partition/Scripts/range_partitioning": {
      "vars": "type",
      "selects": ["with_primary_key","with_pruning"]
    }
  }'
```

### Code für Hash-Partitionierung mit Range:
```bash
cd ../..
cd Tools
./sysbench_script.sh \
  -out "YOUR_PATH_TO_PROJECT/Projects/Partition/Output" \
  -var '{"partitions_size":[5,50,500]}' \
  -scripts '{
    "YOUR_PATH_TO_PROJECT/Projects/Partition/Scripts/without_partitioning": {
      "selects": ["without_hash_pruning_range"]
    },
    "YOUR_PATH_TO_PROJECT/Projects/Partition/Scripts/hash_partitioning": {
      "vars": "partitions_size"
    }
  }'
```

### Vergleich zwischen Hash-und Key-Partitionierung (nicht in CI/CD enthalten, also pattern.json):
```bash
cd ../..
cd Tools
./sysbench_script.sh \
  -out "YOUR_PATH_TO_PROJECT/Projects/Partition/Output" \
  -var '{"type":["hash","key"],"partitions_size":[5,100]}' \
  -scripts '{
    "YOUR_PATH_TO_PROJECT/Projects/Partition/Scripts/hash_partitioning": {
      "vars": "type,partitions_size"
    }
  }'
```

### Code für List-Partitionierung:
```bash
cd ../..
cd Tools
./sysbench_script.sh \
  -out "YOUR_PATH_TO_PROJECT/Projects/Partition/Output" \
  -scripts '{
    "YOUR_PATH_TO_PROJECT/Projects/Partition/Scripts/without_partitioning": {
      "selects": ["without_list_pruning_simple","without_list_pruning_multiple"]
    },
    "YOUR_PATH_TO_PROJECT/Projects/Partition/Scripts/list_partitioning": {}
  }'
```

```bash
cd ../..
cd Tools
./generate_graph.sh \
  YOUR_PATH_TO_PROJECT/Projects/Partition/Output
```