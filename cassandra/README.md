# Кластер Cassandra

#### 1) docker-compose.yaml [docker-compose.yaml](docker-compose.yaml)
#### 2) Создание схемы и таблиц [schema.cql](schema.cql)
#### 3) Инициализация таблиц данными [insert_data.cql](insert_data.cql)
#### 4) Примеры запросов к таблицам [queries.cql](queries.cql)

# Нагрузочное тестирование с помощью Apache Cassandra Stress Tool

```bash
docker exec cassandra-1 nodetool status
``` 

### 1. Тест записи (Write)

```bash
docker exec cassandra-1 /opt/cassandra/tools/bin/cassandra-stress write \
  duration=1m \
  -node cassandra-1,cassandra-2,cassandra-3 \
  -rate threads=10
```

### 2. Тест чтения (Read)

```bash
docker exec cassandra-1 /opt/cassandra/tools/bin/cassandra-stress read \
  duration=1m no-warmup \
  -node cassandra-1,cassandra-2,cassandra-3 \
  -rate threads=10 \
  -errors ignore
```

### 3. Смешанная нагрузка (Mixed)

```bash
docker exec cassandra-1 /opt/cassandra/tools/bin/cassandra-stress mixed \
  duration=2m \
  -node cassandra-1,cassandra-2,cassandra-3 \
  -rate threads=20 \
  -errors ignore
```

### Результаты тестирования

#### ![1](screen/1.png)

#### write test
![1](screen/write_test_1.png)
![1](screen/write_test_2.png)

#### read test
![1](screen/read_test_1.png)
![1](screen/read_test_2.png)

####  mixed test
![1](screen/mixed_test_1.png)
![1](screen/mixed_test_2.png)