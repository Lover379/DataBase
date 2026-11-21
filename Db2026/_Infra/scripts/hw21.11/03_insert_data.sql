-- PL/pgSQL скрипт вставки данных в OLAP базу (PostgreSQL)
-- Источник данных: результаты выборки из MSSQL (Front)
-- Данный скрипт загружает извлечённые данные в OLAP структуру

do $$
begin

    -- =============================================
    -- ЗАГРУЗКА ИЗМЕРЕНИЙ (DIMENSIONS)
    -- =============================================

    -- Единицы измерения (dim_ranges)
    -- Данные из MSSQL: select id, sizeid, portionrate from [size]
    begin
        insert into dim_ranges(external_id, name, factor) values
        (1, 'порция', 1.000),
        (2, '100г', 100.000),
        (3, 'Бут.500мл.', 500.000),
        (4, '50 мл', 50.000),
        (5, '1 день', 1.000),
        (6, 'г', 1.000),
        (7, 'мл', 1.000),
        (8, '300мл', 300.000),
        (9, '50мл', 50.000),
        (10, '200г', 200.000),
        (11, 'SNG', 1.000),
        (12, 'Бут.330мл', 330.000),
        (13, '20г', 20.000),
        (14, '40г', 40.000),
        (15, '150г', 150.000),
        (16, '190г', 190.000),
        (17, '180г', 180.000),
        (18, '30г', 30.000),
        (19, 'Бут.250мл', 250.000),
        (20, 'Ч400мл', 400.000),
        (21, 'пачка', 1.000),
        (22, '30Л', 30000.000),
        (23, '10мл', 1.000),
        (24, 'Бут.750мл.', 750.000),
        (25, 'Бут.350мл', 350.000),
        (26, '10г', 10.000),
        (27, '350мл', 200.000),
        (28, '140г', 140.000),
        (29, '500мл', 500.000),
        (30, '280мл', 280.000),
        (31, '120 мл', 120.000),
        (32, '250мл', 250.000),
        (33, '340мл', 340.000),
        (34, '185мл', 185.000),
        (35, '75мл', 75.000),
        (36, '60мл', 60.000),
        (37, '80мл', 80.000),
        (38, '310мл', 310.000),
        (39, 'литр', 1000.000),
        (40, '1000 г', 1000.000),
        (41, '50 г', 50.000),
        (42, 'кг', 1000.000),
        (43, 'Бут.700мл', 700.000),
        (44, 'Бут.600мл', 600.000),
        (45, '0,5 литра', 500.000),
        (46, '0,3 литра', 300.000),
        (47, '200мл', 1.000),
        (48, '150  мл', 1.000),
        (49, '150мл', 150.000),
        (50, 'пакет', 1.000),
        (51, '5л', 5000.000),
        (52, '850г', 850.000),
        (53, '500г', 500.000),
        (54, '550г', 550.000),
        (55, '570г', 570.000),
        (56, '400г', 400.000),
        (57, '250г', 250.000),
        (58, '160г', 160.000),
        (59, '48г', 48.000),
        (60, '90г', 90.000),
        (61, '0,97л', 970.000),
        (62, 'уп 24шт', 24.000),
        (63, '100мл', 100.000),
        (64, 'Бут.375мл', 375.000),
        (65, 'Бут.640мл', 640.000),
        (66, 'Бут.610мл', 610.000),
        (67, 'Бут.580мл', 580.000),
        (68, 'Упаковка 100', 100.000),
        (69, 'шт', 1.000),
        (70, 'Пачка 50', 50.000),
        (71, '80 г', 80.000),
        (72, 'Бут 1,25', 1250.000),
        (73, 'Бут 2л', 2000.000),
        (74, 'Бут 1,75 л', 1075.000),
        (75, 'Бут. 1 л', 1000.000),
        (76, '1,5 литра', 1500.000),
        (77, 'Бут. 450 мл', 1.000),
        (78, 'Бут.200мл', 1.000);
    end;

    -- Категории (dim_category)
    -- Данные из MSSQL: select id, description, ParentID from category
    -- Вставлены сначала категории верхнего уровня (parent_id IS NULL),
    -- затем дочерние, чтобы FK сработал
    begin
        -- Корневые категории
        insert into dim_category(external_id, name, parent_id) values
        (1, 'Напитки', null),
        (2, 'Еда', null),
        (3, 'Десерты', null),
        (4, 'Алкоголь', null),
        (5, 'Соусы', null);

        -- Дочерние категории
        insert into dim_category(external_id, name, parent_id) values
        (6, 'Безалкогольные', 1),
        (7, 'Горячие', 1),
        (8, 'Первые блюда', 2),
        (9, 'Вторые блюда', 2),
        (10, 'Салаты', 2),
        (11, 'Выпечка', 3),
        (12, 'Мороженое', 3),
        (13, 'Пиво', 4),
        (14, 'Крепкий', 4);
    end;

    -- Поставщики (dim_supplier)
    -- Данные из MSSQL: select id, clientid, clientgroup from vendors
    begin
        insert into dim_supplier(external_id, name, group_id) values
        (1, 'Поставщик_1', 1),
        (2, 'Поставщик_2', 1),
        (3, 'Поставщик_3', 2),
        (4, 'Поставщик_4', 2),
        (5, 'Поставщик_5', 3),
        (6, 'Поставщик_6', 1),
        (7, 'Поставщик_7', 3),
        (8, 'Поставщик_8', 2);
    end;

    -- Номенклатура (dim_product)
    -- Данные из MSSQL: select id, name, categoryid, sizeid from item
    begin
        insert into dim_product(external_id, name, category_id, range_id) values
        (1, 'Кола 0.5', 6, 3),
        (2, 'Кола 1.0', 6, 39),
        (3, 'Фанта 0.5', 6, 3),
        (4, 'Спрайт 0.5', 6, 3),
        (5, 'Борщ', 8, 1),
        (6, 'Пельмени', 9, 2),
        (7, 'Цезарь', 10, 1),
        (8, 'Чизкейк', 11, 1),
        (9, 'Мороженое ванильное', 12, 1),
        (10, 'Светлое пиво 0.5', 13, 3);
    end;

    -- Персонал (dim_staff)
    -- Данные из MSSQL: select id, name, post, shopid from personal
    begin
        insert into dim_staff(external_id, name, position, store_id) values
        (1, 'Иванов И.И.', 'Кассир', 1),
        (2, 'Петров П.П.', 'Кассир', 1),
        (3, 'Сидоров С.С.', 'Официант', 1),
        (4, 'Козлова А.В.', 'Официант', 2),
        (5, 'Морозов Д.Е.', 'Управляющий', 1),
        (6, 'Волкова Е.С.', 'Кассир', 2),
        (7, 'Новиков А.А.', 'Повар', 1),
        (8, 'Федорова М.И.', 'Повар', 2);
    end;

    -- Точки продаж (dim_store)
    -- Данные из MSSQL: select id, name, address from shop
    begin
        insert into dim_store(external_id, name, address) values
        (1, 'Кафе Центр', 'г. Иркутск, ул. Ленина, 1'),
        (2, 'Кафе Север', 'г. Иркутск, ул. Байкальская, 50'),
        (3, 'Бар Юг', 'г. Ангарск, ул. К.Маркса, 10');
    end;

    -- =============================================
    -- ЗАГРУЗКА ФАКТОВ (FACT TABLES)
    -- =============================================

    -- Факт: закупки (fact_purchase)
    -- Связка через external_id -> id
    begin
        insert into fact_purchase(time_id, product_id, supplier_id, store_id, qty, amount)
        select t.id,
               p.id,
               s.id,
               st.id,
               v.qty,
               v.amount
        from (values
            -- yr, mn, product_ext, supplier_ext, store_ext, qty, amount
            (2025, 1, 1, 1, 1, 100.000, 15000.00),
            (2025, 1, 2, 2, 1,  50.000, 12500.00),
            (2025, 1, 5, 3, 1,  30.000,  9000.00),
            (2025, 2, 1, 1, 1,  80.000, 12000.00),
            (2025, 2, 3, 2, 2,  60.000,  9000.00),
            (2025, 2, 6, 4, 1,  40.000,  8000.00),
            (2025, 3, 1, 1, 1, 120.000, 18000.00),
            (2025, 3, 7, 5, 2,  20.000,  6000.00),
            (2025, 3, 10, 6, 1, 200.000, 40000.00)
        ) as v(yr, mn, product_ext, supplier_ext, store_ext, qty, amount)
        cross join lateral (
            select id from dim_time
            where year = v.yr
              and date_start_month = make_date(v.yr, v.mn, 1)
        ) t
        join dim_product p on p.external_id = v.product_ext
        left join dim_supplier s on s.external_id = v.supplier_ext
        left join dim_store st on st.external_id = v.store_ext;
    end;

    -- Факт: продажи (fact_sales)
    begin
        insert into fact_sales(time_id, product_id, staff_id, store_id, qty, amount)
        select t.id,
               p.id,
               stf.id,
               st.id,
               v.qty,
               v.amount
        from (values
            -- yr, mn, product_ext, staff_ext, store_ext, qty, amount
            (2025, 1, 1, 1, 1,  45.000,  13500.00),
            (2025, 1, 2, 2, 1,  20.000,   7000.00),
            (2025, 1, 5, 3, 1,  15.000,   4500.00),
            (2025, 2, 1, 1, 1,  50.000,  15000.00),
            (2025, 2, 3, 4, 2,  30.000,   9000.00),
            (2025, 2, 7, 3, 1,  25.000,  10000.00),
            (2025, 3, 1, 6, 2,  55.000,  16500.00),
            (2025, 3, 8, 4, 2,  10.000,   5000.00),
            (2025, 3, 10, 1, 1,  80.000,  32000.00)
        ) as v(yr, mn, product_ext, staff_ext, store_ext, qty, amount)
        cross join lateral (
            select id from dim_time
            where year = v.yr
              and date_start_month = make_date(v.yr, v.mn, 1)
        ) t
        join dim_product p on p.external_id = v.product_ext
        left join dim_staff stf on stf.external_id = v.staff_ext
        left join dim_store st on st.external_id = v.store_ext;
    end;

    -- Факт: работа персонала (fact_staff)
    -- Агрегация по кварталам: привязка к первому месяцу квартала
    begin
        insert into fact_staff(time_id, staff_id, store_id, hours_worked, sales_amount, orders_count)
        select t.id,
               stf.id,
               st.id,
               v.hours_worked,
               v.sales_amount,
               v.orders_count
        from (values
            -- yr, quarter_month, staff_ext, store_ext, hours, sales, orders
            (2025, 1, 1, 1, 160.00,  28500.00, 45),
            (2025, 1, 2, 1, 168.00,  19000.00, 30),
            (2025, 1, 3, 1, 152.00,  14500.00, 25),
            (2025, 4, 1, 1, 164.00,  31500.00, 50),
            (2025, 4, 4, 2, 148.00,  24000.00, 35),
            (2025, 4, 6, 2, 170.00,  21500.00, 38)
        ) as v(yr, quarter_month, staff_ext, store_ext, hours_worked, sales_amount, orders_count)
        cross join lateral (
            select id from dim_time
            where year = v.yr
              and date_start_month = make_date(v.yr, v.quarter_month, 1)
        ) t
        join dim_staff stf on stf.external_id = v.staff_ext
        left join dim_store st on st.external_id = v.store_ext;
    end;

    -- Факт: остатки (fact_stock)
    -- Привязка к ближайшему месяцу (неделя входит в месяц)
    begin
        insert into fact_stock(time_id, product_id, store_id, qty, amount)
        select t.id,
               p.id,
               st.id,
               v.qty,
               v.amount
        from (values
            -- yr, mn, product_ext, store_ext, qty, amount
            (2025, 1, 1, 1,  55.000,  8250.00),
            (2025, 1, 2, 1,  30.000,  7500.00),
            (2025, 1, 5, 1,  15.000,  4500.00),
            (2025, 2, 1, 1,  85.000, 12750.00),
            (2025, 2, 3, 2,  30.000,  4500.00),
            (2025, 3, 1, 1, 130.000, 19500.00),
            (2025, 3, 10, 1, 120.000, 24000.00)
        ) as v(yr, mn, product_ext, store_ext, qty, amount)
        cross join lateral (
            select id from dim_time
            where year = v.yr
              and date_start_month = make_date(v.yr, v.mn, 1)
        ) t
        join dim_product p on p.external_id = v.product_ext
        left join dim_store st on st.external_id = v.store_ext;
    end;

    commit;

    raise notice 'Данные загружены в OLAP базу успешно';

end $$;
