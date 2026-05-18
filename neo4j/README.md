# Графовые базы данных: Neo4j vs PostgreSQL

## Запуск окружения

```bash
docker-compose up -d
```

| Сервис | URL | Credentials |
|---|---|---|
| Neo4j Browser | http://localhost:7474 | `neo4j` / `testpassword` |
| PostgreSQL | http://localhost:5432 | `postgres` / `postgres`, БД `graph_comparison` |

---

## 1. Три варианта применения графовых баз данных

### 1.1. Обнаружение мошенничества в финансовых транзакциях

В банковской сфере графовая база данных идеально подходит для выявления мошеннических схем. Узлы - клиенты, счета, мерчанты, устройства; рёбра - переводы, владение, оплаты. Типичная задача - найти кольцевые переводы (деньги прошли через цепочку счетов и вернулись обратно), обнаружить кратчайший путь между подозрительными счетами, или выявить цепочки транзакций, где каждая сумма чуть меньше порога отчётности (smurfing).

### 1.2. Анализ зависимостей IT-инфраструктуры

Современные микросервисные архитектуры состоят из сотен компонентов: серверы, базы данных, балансировщики, очереди сообщений, API-шлюзы. Узлы - сервисы и инфраструктурные элементы; рёбра - «зависит от», «размещён на», «подключён к». Запрос «что упадёт, если откажет сервер X?» - это обход графа зависимостей в глубину.

### 1.3. Логистика и оптимизация маршрутов доставки

В логистике графовая модель естественным образом описывает транспортную сеть: склады, распределительные центры, пункты доставки - узлы; маршруты между ними - рёбра с весами (расстояние, время, стоимость). Поиск кратчайшего пути между двумя точками, оптимизация маршрута с несколькими остановками, расчёт влияния отключения одного узла на доступность других.

---

## 2. Модель данных (пример: мошенничество в транзакциях)

### Графовая модель (Neo4j)

```
(Client)──OWNS──>(Account)──TRANSFER──>(Account)──OWNS──>(Client)
                         │
                         └──PAYS_TO──>(Merchant)
```

**Узлы:**
- `Client` — name, email, status (active/suspended)
- `Account` — number, balance, currency, suspicious
- `Merchant` — name, category

**Рёбра:**
- `OWNS` — Client → Account
- `TRANSFER` — Account → Account (amount, date, status)
- `PAYS_TO` — Account → Merchant (amount, date)

### Реляционная модель (PostgreSQL)

```
clients ──1:N──> accounts ──N:1──> transfers <──1:N── accounts
                    │
                    └──N:M──> account_merchant <──1:N── merchants
```

Таблицы: `clients`, `accounts`, `transfers`, `merchants`, `account_merchant` (5 таблиц + FK + индексы).

---

## 3. Файлы с запросами

| Операция | Cypher | SQL |
|---|---|---|
| Создание | `cypher/01_create.cypher` | `sql/00_schema.sql` + `sql/01_insert.sql` |
| Поиск | `cypher/02_read.cypher` | `sql/02_select.sql` |
| Обновление | `cypher/03_update.cypher` | `sql/03_update.sql` |
| Удаление | `cypher/04_delete.cypher` | `sql/04_delete.sql` |

---

## 4. Сравнение SQL и Cypher

### 4.1. Создание данных

| Критерий | Cypher | SQL |
|---|---|---|
| Кол-во файлов | 1 файл запросов | 2 файла (DDL + DML) |
| Определение схемы | Не требуется | 5 таблиц, FK, CHECK, индексы |
| Читаемость | `(ivan)-[:OWNS]->(acc)` — визуально понятно | `INSERT ... SELECT id FROM ...` — вложенные подзапросы для FK |

### 4.2. Поиск

**Кратчайший путь** между двумя счетами:

```cypher
// Cypher — 3 строки
MATCH path = shortestPath(
  (a1:Account {number: 'RU401111'})-[:TRANSFER*]-(a2:Account {number: 'RU403001'})
)
RETURN path;
```

```sql
-- SQL — 25+ строк, WITH RECURSIVE, ручное отслеживание пути
WITH RECURSIVE path_search AS (
    SELECT from_account_id, to_account_id,
           ARRAY[from_account_id, to_account_id] AS path_nodes,
           1 AS depth
    FROM transfers WHERE from_account_id = (SELECT id FROM accounts WHERE number = 'RU401111')
    UNION ALL
    SELECT ps.from_account_id, t.to_account_id,
           ps.path_nodes || t.to_account_id, ps.depth + 1
    FROM path_search ps
    JOIN transfers t ON ps.to_account_id = t.from_account_id
    WHERE t.to_account_id <> ALL(ps.path_nodes) AND ps.depth < 6
)
SELECT ... FROM path_search WHERE to_account_id = (...) ORDER BY depth LIMIT 1;
```

**Кольцевые переводы:**

```cypher
// Cypher — 4 строки
MATCH path = (a:Account)-[:TRANSFER*2..6]->(a)
RETURN a.number, [node IN nodes(path) | node.number] AS ring;
```

```sql
-- SQL — 30+ строк, WITH RECURSIVE, проверка возврата в start_account
WITH RECURSIVE ring AS (
    SELECT from_account_id AS start_account, to_account_id AS current_account, ...
    UNION ALL
    SELECT ... FROM ring r JOIN transfers t ON ... WHERE ...
)
SELECT ... FROM ring WHERE current_account = start_account AND ring_length >= 2;
```

### 4.3. Обновление

```cypher
// Cypher — пометить счета из подозрительных переводов
MATCH (a:Account)-[t:TRANSFER]->(:Account)
WHERE t.amount > 1000000
SET a.suspicious = true;
```

```sql
-- SQL — аналогично, но без навигации по графу
UPDATE accounts SET suspicious = TRUE
WHERE id IN (SELECT from_account_id FROM transfers WHERE amount > 1000000);
```

Для простых обновлений SQL и Cypher сопоставимы. Разница проявляется, когда нужно обновить узлы, связанные через несколько уровней:

```cypher
// Cypher — заблокировать все счета в цепочке мошенничества
MATCH (a1:Account)-[:TRANSFER*1..3]->(a2:Account)
WHERE ALL (r IN relationships(path) WHERE r.amount > 1000000)
SET a2.suspicious = true;
```

В SQL это потребует `WITH RECURSIVE` + `UPDATE` через CTE, что намного объёмнее.

### 4.4. Удаление

```cypher
// Cypher — удалить счёт со всеми связями
MATCH (a:Account {number: 'RU403001'})
DETACH DELETE a;

// Cypher — очистить всю базу
MATCH (n) DETACH DELETE n;
```

```sql
-- SQL — полагается на ON DELETE CASCADE в DDL
DELETE FROM accounts WHERE number = 'RU403001';

-- SQL — очистить все таблицы
TRUNCATE account_merchant, transfers, accounts, merchants, clients CASCADE;
```

Удаление сопоставимо, но в Cypher `DETACH DELETE` — это одна явная команда, а в SQL нужно закладывать каскадирование при проектировании схемы.

### 4.5. Итоговая таблица сравнения

| Операция | Cypher (строк) | SQL (строк) | Комментарий |
|---|---|---|---|
| Описание схемы | 0 | ~40 | Cypher — schema-free |
| Создание данных | ~50 | ~55 | Сопоставимо, но SQL требует подзапросов для FK |
| Кратчайший путь | 3 | 25+ | Cypher выигрывает кратно |
| Кольца (cycles) | 4 | 30+ | Cypher — тривиально, SQL — крайне громоздко |
| Цепочки с фильтром | 4 | 25+ | В SQL нужен WITH RECURSIVE + проверка visited |
| Простое обновление | 2 | 3 | Сопоставимо |
| Обновление по графу | 3 | 15+ | Cypher выигрывает за счёт навигации |
| Удаление с каскадом | 1 | 1 (если CASCADE) | Сопоставимо |

**Вывод:** для задач с навигацией по связям (поиск путей, кольца, многоуровневые цепочки) Cypher выразительнее SQL в 5–10 раз. Рекурсивные CTE в SQL технически решают задачу, но код становится нечитаемым, трудно отлаживаемым и хрупким при изменении модели. Для простых CRUD-операций разница минимальна.
