-- === Запросы с WHERE ===

-- 1) Все заказы конкретного клиента в конкретном регионе (полный partition key)
SELECT * FROM otus_hw.orders_by_customer
WHERE customer_id = 1 AND region = 'US-WEST';

-- 2) Заказы клиента в регионе за конкретную дату (partition key + clustering key)
SELECT * FROM otus_hw.orders_by_customer
WHERE customer_id = 1 AND region = 'US-WEST' AND order_date = '2026-05-15';

-- 3) Заказы клиента в регионе за диапазон дат (partition key + range по clustering key)
SELECT * FROM otus_hw.orders_by_customer
WHERE customer_id = 2 AND region = 'US-EAST'
  AND order_date >= '2026-05-15' AND order_date <= '2026-05-16';

-- === Создание вторичного индекса ===

-- Индекс на поле status (не входит в primary key)
CREATE INDEX IF NOT EXISTS idx_orders_status ON otus_hw.orders_by_customer (status);

-- === Запросы с использованием вторичного индекса (поле status) ===

-- 4) Все завершённые заказы
SELECT customer_id, region, order_date, order_time, total_amount
FROM otus_hw.orders_by_customer
WHERE status = 'COMPLETED';

-- 5) Все отменённые заказы
SELECT customer_id, region, order_date, order_time, description
FROM otus_hw.orders_by_customer
WHERE status = 'CANCELLED';

-- 6) Все заказы в обработке
SELECT customer_id, region, order_date, order_time, items_count, total_amount
FROM otus_hw.orders_by_customer
WHERE status = 'PROCESSING';
