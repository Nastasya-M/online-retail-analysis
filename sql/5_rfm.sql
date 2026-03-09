-- RFM-анализ
-- R (Recency)   — дней с последней покупки
-- F (Frequency) — количество заказов
-- M (Monetary)  — сумма покупок

--  считаем метрики
WITH rfm as (
    select
      customer_id,
      max(date('2011-12-09')) - max(date(invoice_date)) as recency,
      count(distinct invoice) as frequency,
      round(sum(quantity * price), 2) as monetary
    from raw.online_retail
    where quantity  > 0 and price > 0 and customer_id is not null
    group by customer_id 
    ),
-- считаем скор
rfm_score as (
    select
      customer_id,
      recency,
      frequency,
      monetary,
      ntile(5) over (order by recency desc) as r_score,
      ntile(5) over(order by frequency desc) as f_score,
      ntile(5) over (order by ln(monetary) asc) as m_score
    from rfm
    ),
-- считаем сегменты
rfm_segments as (
    select
      customer_id,
      recency,
      frequency,
      monetary,
      r_score,
      f_score,
      m_score,
      (case
           when r_score = 5 and f_score >= 4 then 'Champions'
           when r_score >= 4 and f_score >= 4 then 'Loyal Customers'
           when r_score >= 4 and f_score >= 3 then 'Potential Loyalists'
           when r_score >= 4 and m_score >= 4 then 'Big Spenders'
           when r_score >= 3 and f_score >= 3 then 'Regular'
           when r_score <= 2 and f_score >= 4 then 'At Risk Loyal'
           when r_score <= 2 and f_score <= 2 then 'Lost'
           when r_score >= 3 and f_score = 2 then 'Promising'
           when r_score <= 2 and f_score = 3 then 'Needs Attention'
           else 'Others'
           end) as segment
    from rfm_score
    )
-- результат
select
    segment,
    count(customer_id) as customers,
    round(avg(recency)) as avg_recency,
    round(avg(frequency)) as avg_frequency,
    round(avg(monetary)) as avg_monetary
from rfm_segments
group by segment
order by customers desc;


