-- Когортный анализ удержания клиентов (Когорта - месяц первой покупки клиента)


-- первая покупка каждого клиента
WITH first_purchase AS (
    select 
      customer_id,
      date_trunc('month', min(invoice_date)) as cohort_month
    from raw.online_retail
    where quantity > 0 and price > 0 and customer_id is not null
    group by customer_id
    ),
--все покупки каждого клиента и номер периода
purchases as (
              select 
                o.customer_id,
                f.cohort_month,
                date_trunc('month', o.invoice_date) as purchase_month,
                extract(year from age (date_trunc('month', o.invoice_date), f.cohort_month)) * 12 +
                extract(month from age (date_trunc('month', o.invoice_date), f.cohort_month)) as period_number
              from raw.online_retail as o
              join first_purchase as f 
              using (customer_id)
              where o.quantity > 0 and o.price > 0
              ),
--уникальные клиенты в каждой когорте и периоде
chogort_size as (
                 select
                   cohort_month,
                   count(distinct(customer_id)) as cohort_customers 
                 from purchases
                 where period_number = 0
                 group by cohort_month
                 ),
retention as (
             select 
               p.cohort_month,
               p.period_number,
               count(distinct p.customer_id) as active_customers
             from purchases p
             group by p.cohort_month, p.period_number
)
-- таблица с retention rate
select
    cohort_month,
    max(case when period_number = 0 then retention_rate end) as "0",
    max(case when period_number = 1 then retention_rate end) as "1",
    max(case when period_number = 2 then retention_rate end) as "2",
    max(case when period_number = 3 then retention_rate end) as "3",
    max(case when period_number = 4 then retention_rate end) as "4",
    max(case when period_number = 5 then retention_rate end) as "5",
    max(case when period_number = 6 then retention_rate end) as "6",
    max(case when period_number = 7 then retention_rate end) as "7",
    max(case when period_number = 8 then retention_rate end) as "8",
    max(case when period_number = 9 then retention_rate end) as "9",
    max(case when period_number = 10 then retention_rate end) as "10",
    max(case when period_number = 11 then retention_rate end) as "11",
    max(case when period_number = 12 then retention_rate end) as "12"
from (
        select  
          r.cohort_month,
          r.period_number,
          r.active_customers,
          cs.cohort_customers,
          round((r.active_customers * 100.0 )/ cs.cohort_customers, 1) as retention_rate
        from retention as r join chogort_size as cs on r.cohort_month = cs.cohort_month
        order by cohort_month, period_number
) t
group by cohort_month
order by cohort_month;

