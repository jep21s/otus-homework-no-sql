-- 1. Все переводы с указанием отправителя и получателя

SELECT
    a_from.number AS from_account,
    a_to.number   AS to_account,
    t.amount,
    t.date,
    t.status
FROM transfers t
JOIN accounts a_from ON t.from_account_id = a_from.id
JOIN accounts a_to   ON t.to_account_id   = a_to.id
ORDER BY t.date;

-- 2. Кратчайший путь между двумя счетами (WITH RECURSIVE)
-- Найти кратчайший путь от RU401111 до RU403001 через переводы

WITH RECURSIVE path_search AS (
    SELECT
        from_account_id,
        to_account_id,
        ARRAY[from_account_id, to_account_id] AS path_nodes,
        ARRAY[
            (SELECT number FROM accounts WHERE id = from_account_id),
            (SELECT number FROM accounts WHERE id = to_account_id)
        ] AS path_numbers,
        1 AS depth
    FROM transfers
    WHERE from_account_id = (SELECT id FROM accounts WHERE number = 'RU401111')

    UNION ALL

    SELECT
        ps.from_account_id,
        t.to_account_id,
        ps.path_nodes || t.to_account_id,
        ps.path_numbers || (SELECT number FROM accounts WHERE id = t.to_account_id),
        ps.depth + 1
    FROM path_search ps
    JOIN transfers t ON ps.to_account_id = t.from_account_id
    WHERE t.to_account_id <> ALL(ps.path_nodes)
      AND ps.depth < 6
)
SELECT path_numbers AS chain, depth AS hops
FROM path_search
WHERE to_account_id = (SELECT id FROM accounts WHERE number = 'RU403001')
ORDER BY depth
LIMIT 1;

-- 3. Все цепочки переводов от RU401111 → RU404001 (до 4 шагов)

WITH RECURSIVE chain AS (
    SELECT
        from_account_id,
        to_account_id,
        ARRAY[
            (SELECT number FROM accounts WHERE id = from_account_id),
            (SELECT number FROM accounts WHERE id = to_account_id)
        ] AS path_numbers,
        ARRAY[t.amount] AS amounts,
        1 AS hops
    FROM transfers t
    WHERE from_account_id = (SELECT id FROM accounts WHERE number = 'RU401111')

    UNION ALL

    SELECT
        c.from_account_id,
        t.to_account_id,
        c.path_numbers || (SELECT number FROM accounts WHERE id = t.to_account_id),
        c.amounts || t.amount,
        c.hops + 1
    FROM chain c
    JOIN transfers t ON c.to_account_id = t.from_account_id
    WHERE t.to_account_id <> ALL(
        ARRAY(SELECT unnest(c.path_numbers)::VARCHAR || '_dummy' LIMIT 0)
    )
    AND NOT EXISTS (
        SELECT 1 FROM accounts WHERE id = t.to_account_id
        AND number = ANY(c.path_numbers)
    )
    AND c.hops < 4
)
SELECT path_numbers AS chain, amounts, hops
FROM chain
WHERE to_account_id = (SELECT id FROM accounts WHERE number = 'RU404001');

-- 4. Кольцевые переводы (деньги вернулись в исходный счёт)

WITH RECURSIVE ring AS (
    SELECT
        from_account_id  AS start_account,
        to_account_id    AS current_account,
        ARRAY[from_account_id] AS visited,
        ARRAY[
            (SELECT number FROM accounts WHERE id = from_account_id)
        ] AS path_numbers,
        ARRAY[]::NUMERIC[] AS amounts,
        0 AS ring_length
    FROM transfers

    UNION ALL

    SELECT
        r.start_account,
        t.to_account_id,
        r.visited || t.to_account_id,
        r.path_numbers || (SELECT number FROM accounts WHERE id = t.to_account_id),
        r.amounts || t.amount,
        r.ring_length + 1
    FROM ring r
    JOIN transfers t ON r.current_account = t.from_account_id
    WHERE r.ring_length < 6
      AND (
          t.to_account_id = r.start_account
          OR NOT EXISTS (
              SELECT 1 FROM accounts WHERE id = t.to_account_id AND id = ANY(r.visited)
          )
      )
)
SELECT
    a.number AS account,
    r.path_numbers AS ring,
    r.amounts,
    r.ring_length
FROM ring r
JOIN accounts a ON r.start_account = a.id
WHERE r.current_account = r.start_account
  AND r.ring_length >= 2;

-- 5. Подозрительные цепочки: все переводы в цепочке > 1 000 000

WITH RECURSIVE sus_chain AS (
    SELECT
        from_account_id,
        to_account_id,
        ARRAY[
            (SELECT number FROM accounts WHERE id = from_account_id),
            (SELECT number FROM accounts WHERE id = to_account_id)
        ] AS path_numbers,
        ARRAY[t.amount] AS amounts,
        1 AS hops
    FROM transfers t
    WHERE t.amount > 1000000

    UNION ALL

    SELECT
        sc.from_account_id,
        t.to_account_id,
        sc.path_numbers || (SELECT number FROM accounts WHERE id = t.to_account_id),
        sc.amounts || t.amount,
        sc.hops + 1
    FROM sus_chain sc
    JOIN transfers t ON sc.to_account_id = t.from_account_id
    WHERE t.amount > 1000000
      AND sc.hops < 3
      AND NOT EXISTS (
          SELECT 1 FROM accounts WHERE id = t.to_account_id AND number = ANY(sc.path_numbers)
      )
)
SELECT path_numbers AS chain, amounts
FROM sus_chain;

-- 6. Все клиенты, чьи счета участвовали в переводах > 1 000 000

SELECT DISTINCT c.name AS client, a.number AS account, t.amount
FROM clients c
JOIN accounts a ON a.client_id = c.id
JOIN transfers t ON t.from_account_id = a.id
WHERE t.amount > 1000000;

-- 7. Клиенты и мерчанты, которым они платили

SELECT c.name AS client, m.name AS merchant, am.amount, am.date
FROM clients c
JOIN accounts a ON a.client_id = c.id
JOIN account_merchant am ON am.account_id = a.id
JOIN merchants m ON am.merchant_id = m.id
ORDER BY am.date;
