// Создание клиентов

CREATE (ivan:Client {name: 'Иван Петров', email: 'ivan@mail.ru', status: 'active'})
CREATE (elena:Client {name: 'Елена Сидорова', email: 'elena@mail.ru', status: 'active'})
CREATE (oleg:Client  {name: 'Олег Кузнецов', email: 'oleg@mail.ru', status: 'active'})
CREATE (maria:Client {name: 'Мария Волкова', email: 'maria@mail.ru', status: 'active'});

// Создание счетов

CREATE (acc_ivan_1:Account {number: 'RU401111', balance: 500000, currency: 'RUB', suspicious: false})
CREATE (acc_ivan_2:Account {number: 'RU401112', balance: 1500000, currency: 'RUB', suspicious: false})
CREATE (acc_elena_1:Account {number: 'RU402001', balance: 300000, currency: 'RUB', suspicious: false})
CREATE (acc_oleg_1:Account {number: 'RU403001', balance: 200000, currency: 'RUB', suspicious: false})
CREATE (acc_oleg_2:Account {number: 'RU403002', balance: 5000000, currency: 'RUB', suspicious: false})
CREATE (acc_maria_1:Account {number: 'RU404001', balance: 800000, currency: 'RUB', suspicious: false});

// Связи OWNS (клиент -> счет)

MATCH (c:Client {name: 'Иван Петров'}), (a:Account {number: 'RU401111'})
CREATE (c)-[:OWNS]->(a);

MATCH (c:Client {name: 'Иван Петров'}), (a:Account {number: 'RU401112'})
CREATE (c)-[:OWNS]->(a);

MATCH (c:Client {name: 'Елена Сидорова'}), (a:Account {number: 'RU402001'})
CREATE (c)-[:OWNS]->(a);

MATCH (c:Client {name: 'Олег Кузнецов'}), (a:Account {number: 'RU403001'})
CREATE (c)-[:OWNS]->(a);

MATCH (c:Client {name: 'Олег Кузнецов'}), (a:Account {number: 'RU403002'})
CREATE (c)-[:OWNS]->(a);

MATCH (c:Client {name: 'Мария Волкова'}), (a:Account {number: 'RU404001'})
CREATE (c)-[:OWNS]->(a);

// Создание мерчантов

CREATE (ozon:Merchant {name: 'Ozon', category: 'E-commerce'})
CREATE (wildberries:Merchant {name: 'Wildberries', category: 'E-commerce'})
CREATE (yandex:Merchant {name: 'Яндекс.Такси', category: 'Transport'});

// Переводы между счетами (TRANSFER)

MATCH (a1:Account {number: 'RU401111'}), (a2:Account {number: 'RU402001'})
CREATE (a1)-[:TRANSFER {amount: 150000, date: '2025-01-15', status: 'completed'}]->(a2);

MATCH (a1:Account {number: 'RU402001'}), (a2:Account {number: 'RU403001'})
CREATE (a1)-[:TRANSFER {amount: 140000, date: '2025-01-16', status: 'completed'}]->(a2);

MATCH (a1:Account {number: 'RU403001'}), (a2:Account {number: 'RU404001'})
CREATE (a1)-[:TRANSFER {amount: 130000, date: '2025-01-17', status: 'completed'}]->(a2);

MATCH (a1:Account {number: 'RU404001'}), (a2:Account {number: 'RU401111'})
CREATE (a1)-[:TRANSFER {amount: 120000, date: '2025-01-18', status: 'completed'}]->(a2);

MATCH (a1:Account {number: 'RU403002'}), (a2:Account {number: 'RU401112'})
CREATE (a1)-[:TRANSFER {amount: 2000000, date: '2025-01-20', status: 'completed'}]->(a2);

// Оплаты мерчантам (PAYS_TO)

MATCH (a:Account {number: 'RU401111'}), (m:Merchant {name: 'Ozon'})
CREATE (a)-[:PAYS_TO {amount: 5000, date: '2025-01-10'}]->(m);

MATCH (a:Account {number: 'RU402001'}), (m:Merchant {name: 'Wildberries'})
CREATE (a)-[:PAYS_TO {amount: 12000, date: '2025-01-12'}]->(m);

MATCH (a:Account {number: 'RU404001'}), (m:Merchant {name: 'Яндекс.Такси'})
CREATE (a)-[:PAYS_TO {amount: 3000, date: '2025-01-14'}]->(m);
