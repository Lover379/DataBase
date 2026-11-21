-- SQL запросы для выборки данных из MSSQL (база Front)
-- Источник: MS SQL Server 2017, база данных "Front"
-- Назначение: извлечение ресурсов (данных) для загрузки в OLAP PostgreSQL

-- =============================================
-- 1. ЕДИНИЦЫ ИЗМЕРЕНИЯ (dim_ranges)
-- =============================================
select id, sizeid as name,
       portionrate as factor
from [size]

-- =============================================
-- 2. КАТЕГОРИИ (dim_category)
-- =============================================
select * from
(
    select id,
           description as name,
           case when coalesce(ParentID, 0) = 0
                then null else parentId end as parent_id
    from category
) as t1
order by parent_id, name

-- =============================================
-- 3. ПОСТАВЩИКИ (dim_supplier)
-- =============================================
select * from
(
    select t1.id,
           t1.clientid as name,
           t1.clientgroup as group_id,
           t2.[description] as group_name
    from vendors t1
    inner join vendorgroup t2 on t1.clientgroup = t2.vendorgroupid
) as t1
order by group_id

-- =============================================
-- 4. НОМЕНКЛАТУРА / ТОВАРЫ (dim_product)
-- =============================================
select id,
       name,
       categoryid as category_id,
       sizeid as range_id
from item

-- =============================================
-- 5. ПЕРСОНАЛ (dim_staff)
-- =============================================
select id,
       name,
       post as position,
       shopid as store_id
from personal

-- =============================================
-- 6. ТОЧКИ ПРОДАЖ (dim_store)
-- =============================================
select id,
       name,
       address
from shop

-- =============================================
-- 7. ФАКТ: ЗАКУПКИ (fact_purchase)
-- Агрегация по месяцам
-- =============================================
select
    doc.id as doc_id,
    doc.shopid as store_id,
    doc.clientid as supplier_id,
    d.id as product_id,
    sum(d.qty) as qty,
    sum(d.qty * d.price) as amount,
    YEAR(doc.docdate) as yr,
    MONTH(doc.docdate) as mn
from doc
inner join docdetail d on doc.id = d.docid
where doc.doctype = 1  -- закупки
group by doc.id, doc.shopid, doc.clientid, d.id,
         YEAR(doc.docdate), MONTH(doc.docdate)

-- =============================================
-- 8. ФАКТ: ПРОДАЖИ (fact_sales)
-- Агрегация по месяцам
-- =============================================
select
    doc.shopid as store_id,
    doc.userid as staff_id,
    d.id as product_id,
    sum(d.qty) as qty,
    sum(d.qty * d.price) as amount,
    YEAR(doc.docdate) as yr,
    MONTH(doc.docdate) as mn
from doc
inner join docdetail d on doc.id = d.docid
where doc.doctype = 0  -- продажи
group by doc.shopid, doc.userid, d.id,
         YEAR(doc.docdate), MONTH(doc.docdate)

-- =============================================
-- 9. ФАКТ: РАБОТА ПЕРСОНАЛА (fact_staff)
-- Агрегация по кварталам
-- =============================================
select
    doc.userid as staff_id,
    doc.shopid as store_id,
    YEAR(doc.docdate) as yr,
    DATEPART(QUARTER, doc.docdate) as qr,
    COUNT(distinct doc.id) as orders_count,
    SUM(d.qty * d.price) as sales_amount
from doc
inner join docdetail d on doc.id = d.docid
where doc.doctype = 0  -- продажи
group by doc.userid, doc.shopid,
         YEAR(doc.docdate), DATEPART(QUARTER, doc.docdate)

-- =============================================
-- 10. ФАКТ: ОСТАТКИ (fact_stock)
-- Агрегация по неделям
-- =============================================
select
    s.shopid as store_id,
    s.itemid as product_id,
    DATEPART(YEAR, s.date) as yr,
    DATEPART(WEEK, s.date) as wk,
    MAX(s.qty) as qty,
    MAX(s.qty * s.price) as amount
from stock s
group by s.shopid, s.itemid,
         DATEPART(YEAR, s.date), DATEPART(WEEK, s.date)
