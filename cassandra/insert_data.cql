USE otus_hw;

INSERT INTO orders_by_customer (customer_id, region, order_date, order_time, order_id, status, total_amount, items_count, description)
VALUES (1, 'US-WEST', '2026-05-15', '08:30:00', 5c3d2a1b-4e5f-6a7b-8c9d-0e1f2a3b4c5d, 'COMPLETED',  150.00, 3, 'Three books order');

INSERT INTO orders_by_customer (customer_id, region, order_date, order_time, order_id, status, total_amount, items_count, description)
VALUES (1, 'US-WEST', '2026-05-15', '14:20:00', 6d4e3b2c-5f6a-7b8c-9d0e-1f2a3b4c5d6e, 'SHIPPED',     89.99, 1, 'Wireless headphones');

INSERT INTO orders_by_customer (customer_id, region, order_date, order_time, order_id, status, total_amount, items_count, description)
VALUES (1, 'US-WEST', '2026-05-16', '09:00:00', 7e5f4c3d-6a7b-8c9d-0e1f-2a3b4c5d6e7f, 'PROCESSING', 245.50, 5, 'Kitchen appliances set');

INSERT INTO orders_by_customer (customer_id, region, order_date, order_time, order_id, status, total_amount, items_count, description)
VALUES (1, 'US-WEST', '2026-05-17', '11:45:00', 8f6a5d4e-7b8c-9d0e-1f2a-3b4c5d6e7f8a, 'CANCELLED',   42.00, 2, 'Cancelled accessories');

INSERT INTO orders_by_customer (customer_id, region, order_date, order_time, order_id, status, total_amount, items_count, description)
VALUES (2, 'US-EAST', '2026-05-15', '10:15:00', 9a7b6e5f-8c9d-0e1f-2a3b-4c5d6e7f8a9b, 'COMPLETED', 310.00, 4, 'Laptop and accessories');

INSERT INTO orders_by_customer (customer_id, region, order_date, order_time, order_id, status, total_amount, items_count, description)
VALUES (2, 'US-EAST', '2026-05-16', '16:30:00', ab8c7f6a-9d0e-1f2a-3b4c-5d6e7f8a9b0c, 'SHIPPED',     75.50, 2, 'Running shoes');

INSERT INTO orders_by_customer (customer_id, region, order_date, order_time, order_id, status, total_amount, items_count, description)
VALUES (2, 'US-EAST', '2026-05-17', '07:00:00', bc9d8a7b-0e1f-2a3b-4c5d-6e7f8a9b0c1d, 'PROCESSING', 199.99, 1, 'Smart watch');

INSERT INTO orders_by_customer (customer_id, region, order_date, order_time, order_id, status, total_amount, items_count, description)
VALUES (3, 'EU-CENTRAL', '2026-05-15', '12:00:00', cd0e9b8c-1f2a-3b4c-5d6e-7f8a9b0c1d2e, 'COMPLETED',  520.00, 8, 'Office supplies bulk');

INSERT INTO orders_by_customer (customer_id, region, order_date, order_time, order_id, status, total_amount, items_count, description)
VALUES (3, 'EU-CENTRAL', '2026-05-16', '09:45:00', de1f0c9d-2a3b-4c5d-6e7f-8a9b0c1d2e3f, 'SHIPPED',    133.33, 3, 'Board games collection');

INSERT INTO orders_by_customer (customer_id, region, order_date, order_time, order_id, status, total_amount, items_count, description)
VALUES (3, 'EU-CENTRAL', '2026-05-17', '18:10:00', ef2a1d0e-3b4c-5d6e-7f8a-9b0c1d2e3f4a, 'CANCELLED',   67.80, 1, 'Cancelled plant pot');

INSERT INTO orders_by_customer (customer_id, region, order_date, order_time, order_id, status, total_amount, items_count, description)
VALUES (4, 'US-WEST', '2026-05-15', '13:25:00', f0b3e2a4-c5d6-7e8f-9a0b-1c2d3e4f5a6b, 'COMPLETED',   44.99, 1, 'USB cable');

INSERT INTO orders_by_customer (customer_id, region, order_date, order_time, order_id, status, total_amount, items_count, description)
VALUES (4, 'US-WEST', '2026-05-18', '08:00:00', a1c4f3b5-d6e7-8f9a-0b1c-2d3e4f5a6b7c, 'PROCESSING', 178.00, 6, 'Craft supplies');

INSERT INTO products (category, created_at, product_id, name, price, description)
VALUES ('Electronics', '2026-01-10T10:00:00', 11111111-aaaa-bbbb-cccc-111111111111, 'Wireless Headphones',  89.99, 'Noise cancelling over-ear headphones');

INSERT INTO products (category, created_at, product_id, name, price, description)
VALUES ('Electronics', '2026-02-15T12:00:00', 22222222-aaaa-bbbb-cccc-222222222222, 'Smart Watch',          199.99, 'Fitness tracker with heart rate monitor');

INSERT INTO products (category, created_at, product_id, name, price, description)
VALUES ('Electronics', '2026-03-20T14:00:00', 33333333-aaaa-bbbb-cccc-333333333333, 'USB-C Cable',           12.99, 'Braided 2m fast charging cable');

INSERT INTO products (category, created_at, product_id, name, price, description)
VALUES ('Books', '2026-01-05T09:00:00', 44444444-aaaa-bbbb-cccc-444444444444, 'Effective Java',        49.99, 'Best practices for Java developers');

INSERT INTO products (category, created_at, product_id, name, price, description)
VALUES ('Books', '2026-02-20T09:00:00', 55555555-aaaa-bbbb-cccc-555555555555, 'Designing Data-Intensive Apps', 54.99, 'Big ideas behind reliable scalable systems');

INSERT INTO products (category, created_at, product_id, name, price, description)
VALUES ('Books', '2026-03-10T09:00:00', 66666666-aaaa-bbbb-cccc-666666666666, 'Clean Architecture',    44.99, 'Software structure and design principles');

INSERT INTO products (category, created_at, product_id, name, price, description)
VALUES ('Sports', '2026-01-15T11:00:00', 77777777-aaaa-bbbb-cccc-777777777777, 'Running Shoes',         75.50, 'Lightweight trail running shoes');

INSERT INTO products (category, created_at, product_id, name, price, description)
VALUES ('Sports', '2026-04-01T11:00:00', 88888888-aaaa-bbbb-cccc-888888888888, 'Yoga Mat',              29.99, 'Non-slip 6mm exercise mat');

INSERT INTO products (category, created_at, product_id, name, price, description)
VALUES ('Kitchen', '2026-01-20T13:00:00', 99999999-aaaa-bbbb-cccc-999999999999, 'Coffee Maker',         149.99, 'Programmable drip coffee machine');

INSERT INTO products (category, created_at, product_id, name, price, description)
VALUES ('Kitchen', '2026-03-25T13:00:00', aaaaaaaa-bbbb-cccc-dddd-aaaaaaaaaaaa, 'Knife Set',            89.00, 'Professional 8-piece stainless steel set');
