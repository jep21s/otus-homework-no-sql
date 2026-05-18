DROP TABLE IF EXISTS account_merchant;
DROP TABLE IF EXISTS transfers;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS clients;
DROP TABLE IF EXISTS merchants;

CREATE TABLE clients (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(200) NOT NULL,
    email       VARCHAR(200) NOT NULL UNIQUE,
    status      VARCHAR(20)  NOT NULL DEFAULT 'active'
);

CREATE TABLE accounts (
    id          SERIAL PRIMARY KEY,
    number      VARCHAR(20)  NOT NULL UNIQUE,
    balance     NUMERIC(18,2) NOT NULL DEFAULT 0,
    currency    VARCHAR(3)   NOT NULL DEFAULT 'RUB',
    suspicious  BOOLEAN      NOT NULL DEFAULT FALSE,
    client_id   INTEGER      NOT NULL REFERENCES clients(id) ON DELETE CASCADE
);

CREATE TABLE merchants (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(200) NOT NULL,
    category    VARCHAR(100) NOT NULL
);

CREATE TABLE transfers (
    id              SERIAL PRIMARY KEY,
    from_account_id INTEGER NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    to_account_id   INTEGER NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    amount          NUMERIC(18,2) NOT NULL,
    date            DATE NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'completed',
    CHECK (from_account_id <> to_account_id)
);

CREATE TABLE account_merchant (
    id          SERIAL PRIMARY KEY,
    account_id  INTEGER NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    merchant_id INTEGER NOT NULL REFERENCES merchants(id) ON DELETE CASCADE,
    amount      NUMERIC(18,2) NOT NULL,
    date        DATE NOT NULL
);

CREATE INDEX idx_transfers_from ON transfers(from_account_id);
CREATE INDEX idx_transfers_to   ON transfers(to_account_id);
CREATE INDEX idx_transfers_amount ON transfers(amount);
CREATE INDEX idx_account_merchant_account ON account_merchant(account_id);
