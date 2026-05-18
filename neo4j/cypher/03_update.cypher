// 1. Пометить счёт как подозрительный

MATCH (a:Account {number: 'RU403002'})
SET a.suspicious = true
RETURN a.number, a.suspicious;

// 2. Пометить все счета, участвующие в переводах > 1 000 000

MATCH (a:Account)-[t:TRANSFER]->(:Account)
WHERE t.amount > 1000000
SET a.suspicious = true
RETURN a.number AS marked_suspicious;

// 3. Изменить статус транзакции на 'blocked' для подозрительных переводов

MATCH (:Account)-[t:TRANSFER]->(:Account)
WHERE t.amount > 1000000
SET t.status = 'blocked'
RETURN t.amount, t.status;

// 4. Обновить баланс счёта после подтверждения перевода

MATCH (a:Account {number: 'RU401111'})
SET a.balance = a.balance - 150000
RETURN a.number, a.balance;

// 5. Заблокировать клиента (сменить статус)

MATCH (c:Client {name: 'Олег Кузнецов'})
SET c.status = 'suspended'
RETURN c.name, c.status;
