CREATE KEYSPACE IF NOT EXISTS otus_hw
WITH replication = {
    'class': 'NetworkTopologyStrategy',
    'dc1': 3
}
AND durable_writes = true;

USE otus_hw;

CREATE TABLE IF NOT EXISTS orders_by_customer (
    customer_id  int,
    region       text,
    order_date   date,
    order_time   time,
    order_id     uuid,
    status       text,
    total_amount decimal,
    items_count  int,
    description  text,
    PRIMARY KEY ((customer_id, region), order_date, order_time)
) WITH CLUSTERING ORDER BY (order_date DESC, order_time DESC)
  AND compaction = {'class': 'SizeTieredCompactionStrategy'};

CREATE TABLE IF NOT EXISTS products (
    category    text,
    created_at  timestamp,
    product_id  uuid,
    name        text,
    price       decimal,
    description text,
    PRIMARY KEY (category, created_at)
) WITH CLUSTERING ORDER BY (created_at DESC);
