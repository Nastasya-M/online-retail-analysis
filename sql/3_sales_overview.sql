-- Общая статистика

-- Структура датасета
select *
from raw.online_retail
limit 10;

-- Какая выручка по месяцам, есть ли сезонность?

select 
     date_trunc('month', invoice_date) as month,
     round(sum(quantity * price), 2) as revenue,
     count(distinct invoice) as invoices
from raw.online_retail
where quantity > 0 and price > 0
group by 1
order by 1;

-- Топ-10 товаров по выручке и по количеству заказов
select 
    stock_code,
    mode() within group (order by description),
    count(distinct invoice) as invoices,
    round(sum(quantity * price), 2) as revenue
from raw.online_retail
where quantity > 0 and price > 0
group by stock_code, description
order by revenue desc
limit 10;

-- В каких странах больше всего покупают? (топ-10)
select 
     country,
     round(sum(quantity * price), 2) as revenue
from raw.online_retail
where quantity > 0 and price > 0
group by country 
order by revenue desc
limit 10;

-- Средний чек по месяцам
select 
      date_trunc('month', invoice_date) as month,
      round(sum(quantity * price) / count(distinct invoice),2 )as aov
from raw.online_retail
where quantity > 0 and price > 0
group by month
order by month;


