// 1. Удалить конкретную транзакцию (перевод)

MATCH (a1:Account {number: 'RU401111'})-[t:TRANSFER {date: '2025-01-15'}]->(a2:Account {number: 'RU402001'})
DELETE t;

// 2. Удалить все заблокированные транзакции

MATCH (:Account)-[t:TRANSFER {status: 'blocked'}]->(:Account)
DELETE t;

// 3. Удалить счёт и все его связи (каскад)

MATCH (a:Account {number: 'RU403001'})
DETACH DELETE a;

// 4. Удалить клиента со всеми счетами и связями

MATCH (c:Client {name: 'Мария Волкова'})
DETACH DELETE c;

MATCH (a:Account {number: 'RU404001'})
DETACH DELETE a;

// 5. Очистить всю базу (удалить все узлы и рёбра)

MATCH (n)
DETACH DELETE n;
