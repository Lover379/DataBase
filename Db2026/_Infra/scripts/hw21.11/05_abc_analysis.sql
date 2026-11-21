-- ABC-анализ продаж по товарам
-- Классификация: A (вклад 0-80%), B (80-95%), C (95-100%)
-- Основан на накопительной сумме выручки (метод Парето 80/20)

-- =============================================
-- ABC-анализ продаж (за всё время)
-- =============================================
with sales_by_product as (
    -- Суммарная выручка по каждому товару
    select p.id            as product_id,
           p.name          as product_name,
           sum(fs.qty)     as total_qty,
           sum(fs.amount)  as total_amount
    from fact_sales fs
    join dim_product p on p.id = fs.product_id
    group by p.id, p.name
),
ranked as (
    -- Сортировка по убыванию выручки + накопительный процент
    select product_id,
           product_name,
           total_qty,
           total_amount,
           sum(total_amount) over (
               order by total_amount desc
               rows between unbounded preceding and current row
           ) as cumulative_amount,
           sum(total_amount) over () as grand_total
    from sales_by_product
)
select product_id,
       product_name,
       total_qty,
       total_amount,
       round(100.0 * cumulative_amount / grand_total, 2) as cumulative_pct,
       case
           when 100.0 * cumulative_amount / grand_total <= 80 then 'A'
           when 100.0 * cumulative_amount / grand_total <= 95 then 'B'
           else 'C'
       end as abc_category
from ranked
order by total_amount desc;

-- =============================================
-- ABC-анализ закупок по поставщикам
-- =============================================
with purchase_by_supplier as (
    select s.id            as supplier_id,
           s.name          as supplier_name,
           sum(fp.qty)     as total_qty,
           sum(fp.amount)  as total_amount
    from fact_purchase fp
    join dim_supplier s on s.id = fp.supplier_id
    group by s.id, s.name
),
ranked as (
    select supplier_id,
           supplier_name,
           total_qty,
           total_amount,
           sum(total_amount) over (
               order by total_amount desc
               rows between unbounded preceding and current row
           ) as cumulative_amount,
           sum(total_amount) over () as grand_total
    from purchase_by_supplier
)
select supplier_id,
       supplier_name,
       total_qty,
       total_amount,
       round(100.0 * cumulative_amount / grand_total, 2) as cumulative_pct,
       case
           when 100.0 * cumulative_amount / grand_total <= 80 then 'A'
           when 100.0 * cumulative_amount / grand_total <= 95 then 'B'
           else 'C'
       end as abc_category
from ranked
order by total_amount desc;
