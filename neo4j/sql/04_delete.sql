-- 1. Удалить конкретную транзакцию (перевод)

DELETE FROM transfers
WHERE from_account_id = (SELECT id FROM accounts WHERE number = 'RU401111')
  AND to_account_id   = (SELECT id FROM accounts WHERE number = 'RU402001')
  AND date = '2025-01-15';

-- 2. Удалить все заблокированные транзакции

DELETE FROM transfers WHERE status = 'blocked';

-- 3. Удалить счёт и все его связи (каскад через ON DELETE CASCADE)

DELETE FROM accounts WHERE number = 'RU403001';

-- 4. Удалить клиента со всеми счетами и связями (каскад)

DELETE FROM accounts WHERE client_id = (SELECT id FROM clients WHERE name = 'Мария Волкова');
DELETE FROM clients WHERE name = 'Мария Волкова';

-- 5. Очистить всю базу

TRUNCATE account_merchant, transfers, accounts, merchants, clients CASCADE;
