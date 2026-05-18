-- 1. Пометить счёт как подозрительный

UPDATE accounts
SET suspicious = TRUE
WHERE number = 'RU403002';

-- 2. Пометить все счета, участвующие в переводах > 1 000 000

UPDATE accounts
SET suspicious = TRUE
WHERE id IN (
    SELECT from_account_id FROM transfers WHERE amount > 1000000
);

-- 3. Изменить статус транзакции на 'blocked' для подозрительных переводов

UPDATE transfers
SET status = 'blocked'
WHERE amount > 1000000;

-- 4. Обновить баланс счёта после подтверждения перевода

UPDATE accounts
SET balance = balance - 150000
WHERE number = 'RU401111';

-- 5. Заблокировать клиента (сменить статус)

UPDATE clients
SET status = 'suspended'
WHERE name = 'Олег Кузнецов';
