-- Анализ возвратов (invoice 'C')
-- Какой % заказов возвращается?

-- от количества заказов
select
     count(distinct case when invoice not like 'C%' then invoice end) as total_invoices,
     count(distinct case when invoice like 'C%' then invoice end) as returned_invoices,
     round(
        count(distinct case when invoice like 'C%' then invoice end) * 100.0 /
        count(distinct case when invoice not like 'C%' then invoice end), 2) as return_rate
from raw.online_retail
;
 -- от выручки
select
     sum(case when quantity > 0 then quantity * price end) as total_revenue,
     abs(sum(case when quantity < 0 then quantity * price end)) as returned_revenue,
     round(
         abs(sum(case when quantity < 0 then quantity * price end)) * 100.0 /
        sum(case when quantity > 0 then quantity * price end), 2) as return_revenue_rate
from raw.online_retail;
-- клиенты у которых был возврат
select
     count(distinct case when invoice not like 'C%' then customer_id end) as total_customers,
     count(distinct case when invoice like 'C%' then customer_id end) as customer_w_retrns,
     round(
        count(distinct case when invoice like 'C%' then customer_id end) * 100.0 /
        count(distinct case when invoice not like 'C%' then customer_id end), 2) as return_customer_rate
from raw.online_retail
where customer_id is not null;
-- какие товары возвращают чаще всего
select 
      t.stock_code,
      mode() within group (order by t.description) as description,
      abs(sum(t.quantity)) as return_quantity,
      abs(sum(t.quantity * t.price)) as return_revenue,
      s.sold_quantity,
      round(abs(sum(t.quantity)) * 100.0 / s.sold_quantity, 2) as return_rate
from raw.online_retail t
join (
      select
        stock_code,
        sum(quantity) as sold_quantity
    from raw.online_retail
    where quantity > 0
    group by stock_code
) s on t.stock_code = s.stock_code
where t.invoice like 'C%' and t.stock_code not in ('M', 'POST', 'DOT', 'BANK CHARGES', 'AMAZONFEE') -- фильтруем технические операции
    and s.sold_quantity > 100
group by t.stock_code, s.sold_quantity
having round(abs(sum(t.quantity)) * 100.0 / s.sold_quantity, 2) < 90 -- фильтруем три аномалии в данных
order by return_quantity desc
limit 10;