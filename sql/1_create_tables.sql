-- Создание таблицы


DROP TABLE IF EXISTS raw.online_retail;

CREATE TABLE raw.online_retail (
    invoice      VARCHAR(20),
    stock_code   VARCHAR(20),
    description  TEXT,
    quantity     INTEGER,
    invoice_date TIMESTAMP,
    price        NUMERIC(10, 2),
    customer_id  VARCHAR(20),
    country      VARCHAR(100)
);
