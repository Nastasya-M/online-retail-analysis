-- Загрузка данных из CSV в таблицу raw.online_retail


COPY raw.online_retail (
    invoice,
    stock_code,
    description,
    quantity,
    invoice_date,
    price,
    customer_id,
    country
)
FROM '/data/online_retail_II.csv'
WITH (
    FORMAT CSV,
    HEADER TRUE,
    DELIMITER ',',
    ENCODING 'WIN1252',
    NULL ''
);

-- Проверка загрузки
SELECT COUNT(*) AS total_rows FROM raw.online_retail;
