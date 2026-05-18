// 1. Все переводы с указанием отправителя и получателя

MATCH (from:Account)-[t:TRANSFER]->(to:Account)
RETURN from.number AS from_account, to.number AS to_account,
       t.amount, t.date, t.status
ORDER BY t.date;

// 2. Кратчайший путь между двумя счетами через переводы

MATCH path = shortestPath(
  (a1:Account {number: 'RU401111'})-[:TRANSFER*]-(a2:Account {number: 'RU403001'})
)
RETURN path;

// 3. Все цепочки переводов от счёта Иван → Мария (до 4 шагов)

MATCH path = (a1:Account {number: 'RU401111'})-[:TRANSFER*1..4]->(a2:Account {number: 'RU404001'})
RETURN [node IN nodes(path) | node.number] AS chain,
       [rel IN relationships(path) | rel.amount] AS amounts,
       length(path) AS hops;

// 4. Кольцевые переводы (деньги вернулись в исходный счёт)

MATCH path = (a:Account)-[:TRANSFER*2..6]->(a)
RETURN a.number AS account,
       [node IN nodes(path) | node.number] AS ring,
       [rel IN relationships(path) | rel.amount] AS amounts,
       length(path) AS ring_length;

// 5. Подозрительные цепочки: переводы > 1 000 000

MATCH path = (a1:Account)-[:TRANSFER*1..3]->(a2:Account)
WHERE ALL (r IN relationships(path) WHERE r.amount > 1000000)
RETURN [node IN nodes(path) | node.number] AS chain,
       [rel IN relationships(path) | rel.amount] AS amounts;

// 6. Все клиенты, чьи счета участвовали в переводах на сумму > 1 000 000

MATCH (c:Client)-[:OWNS]->(a:Account)-[t:TRANSFER]->(a2:Account)
WHERE t.amount > 1000000
RETURN DISTINCT c.name AS client, a.number AS account, t.amount;

// 7. Клиенты и мерчанты, которым они платили

MATCH (c:Client)-[:OWNS]->(a:Account)-[p:PAYS_TO]->(m:Merchant)
RETURN c.name AS client, m.name AS merchant, p.amount, p.date
ORDER BY p.date;
