-- Клиенты

INSERT INTO clients (name, email, status) VALUES
    ('Иван Петров',    'ivan@mail.ru',  'active'),
    ('Елена Сидорова', 'elena@mail.ru', 'active'),
    ('Олег Кузнецов',  'oleg@mail.ru',  'active'),
    ('Мария Волкова',  'maria@mail.ru', 'active');

-- Счета

INSERT INTO accounts (number, balance, currency, suspicious, client_id) VALUES
    ('RU401111', 500000,  'RUB', FALSE, (SELECT id FROM clients WHERE name = 'Иван Петров')),
    ('RU401112', 1500000, 'RUB', FALSE, (SELECT id FROM clients WHERE name = 'Иван Петров')),
    ('RU402001', 300000,  'RUB', FALSE, (SELECT id FROM clients WHERE name = 'Елена Сидорова')),
    ('RU403001', 200000,  'RUB', FALSE, (SELECT id FROM clients WHERE name = 'Олег Кузнецов')),
    ('RU403002', 5000000, 'RUB', FALSE, (SELECT id FROM clients WHERE name = 'Олег Кузнецов')),
    ('RU404001', 800000,  'RUB', FALSE, (SELECT id FROM clients WHERE name = 'Мария Волкова'));

-- Мерчанты

INSERT INTO merchants (name, category) VALUES
    ('Ozon',         'E-commerce'),
    ('Wildberries',  'E-commerce'),
    ('Яндекс.Такси', 'Transport');

-- Переводы между счетами

INSERT INTO transfers (from_account_id, to_account_id, amount, date, status) VALUES
    ((SELECT id FROM accounts WHERE number = 'RU401111'),
     (SELECT id FROM accounts WHERE number = 'RU402001'),
     150000, '2025-01-15', 'completed'),

    ((SELECT id FROM accounts WHERE number = 'RU402001'),
     (SELECT id FROM accounts WHERE number = 'RU403001'),
     140000, '2025-01-16', 'completed'),

    ((SELECT id FROM accounts WHERE number = 'RU403001'),
     (SELECT id FROM accounts WHERE number = 'RU404001'),
     130000, '2025-01-17', 'completed'),

    ((SELECT id FROM accounts WHERE number = 'RU404001'),
     (SELECT id FROM accounts WHERE number = 'RU401111'),
     120000, '2025-01-18', 'completed'),

    ((SELECT id FROM accounts WHERE number = 'RU403002'),
     (SELECT id FROM accounts WHERE number = 'RU401112'),
     2000000, '2025-01-20', 'completed');

-- Оплаты мерчантам

INSERT INTO account_merchant (account_id, merchant_id, amount, date) VALUES
    ((SELECT id FROM accounts WHERE number = 'RU401111'),
     (SELECT id FROM merchants WHERE name = 'Ozon'),
     5000, '2025-01-10'),

    ((SELECT id FROM accounts WHERE number = 'RU402001'),
     (SELECT id FROM merchants WHERE name = 'Wildberries'),
     12000, '2025-01-12'),

    ((SELECT id FROM accounts WHERE number = 'RU404001'),
     (SELECT id FROM merchants WHERE name = 'Яндекс.Такси'),
     3000, '2025-01-14');
