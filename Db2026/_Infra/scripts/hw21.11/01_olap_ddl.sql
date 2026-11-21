-- OLAP база данных для анализа (PostgreSQL / PL/pgSQL)
-- Направления: закупки, продажи, персонал, остатки
do $$
begin

    -- =============================================
    -- СОЗДАНИЕ БАЗЫ ДАННЫХ
    -- =============================================
    -- Выполняется отдельно: CREATE DATABASE olap_front;

    -- =============================================
    -- ПОСЛЕДОВАТЕЛЬНОСТИ
    -- =============================================
    create sequence seq_dim_ranges;
    create sequence seq_dim_category;
    create sequence seq_dim_supplier;
    create sequence seq_dim_product;
    create sequence seq_dim_staff;
    create sequence seq_dim_store;
    create sequence seq_dim_time;
    create sequence seq_fact_purchase;
    create sequence seq_fact_sales;
    create sequence seq_fact_staff;
    create sequence seq_fact_stock;

    -- =============================================
    -- ИЗМЕРЕНИЯ (DIMENSIONS)
    -- =============================================

    -- Единицы измерения
    create table dim_ranges
    (
        id          bigint primary key default nextval('public.seq_dim_ranges'),
        external_id bigint,
        name        text,
        factor      float,
        date_add    timestamp default now()
    );

    comment on table dim_ranges is 'Справочник единиц измерения';
    comment on column dim_ranges.id is 'Внутренний код';
    comment on column dim_ranges.external_id is 'Код в source MSSQL';
    comment on column dim_ranges.name is 'Наименование единицы измерения';
    comment on column dim_ranges.factor is 'Коэффициент пересчёта';
    comment on column dim_ranges.date_add is 'Дата загрузки';

    -- Категории номенклатуры (иерархия через parent_id)
    create table dim_category
    (
        id          bigint primary key default nextval('public.seq_dim_category'),
        external_id bigint,
        name        text,
        parent_id   bigint references public.dim_category(id),
        date_add    timestamp default now()
    );

    comment on table dim_category is 'Справочник категорий номенклатуры';
    comment on column dim_category.external_id is 'Код в source MSSQL';
    comment on column dim_category.name is 'Наименование категории';
    comment on column dim_category.parent_id is 'Родительская категория (логическая связь, без ключа)';

    -- Поставщики
    create table dim_supplier
    (
        id          bigint primary key default nextval('public.seq_dim_supplier'),
        external_id bigint,
        name        text,
        group_id    bigint,
        date_add    timestamp default now()
    );

    comment on table dim_supplier is 'Справочник поставщиков';
    comment on column dim_supplier.external_id is 'Код в source MSSQL';
    comment on column dim_supplier.name is 'Наименование поставщика';
    comment on column dim_supplier.group_id is 'Код группы поставщиков (логическая связь)';

    -- Номенклатура (товары/продукция)
    create table dim_product
    (
        id          bigint primary key default nextval('public.seq_dim_product'),
        external_id bigint,
        name        text,
        category_id bigint references public.dim_category(id),
        range_id    bigint references public.dim_ranges(id),
        date_add    timestamp default now()
    );

    comment on table dim_product is 'Справочник номенклатуры (товаров)';
    comment on column dim_product.external_id is 'Код в source MSSQL';
    comment on column dim_product.name is 'Наименование товара';
    comment on column dim_product.category_id is 'Код категории';
    comment on column dim_product.range_id is 'Код единицы измерения';

    -- Персонал
    create table dim_staff
    (
        id          bigint primary key default nextval('public.seq_dim_staff'),
        external_id bigint,
        name        text,
        position    text,
        store_id    bigint,
        date_add    timestamp default now()
    );

    comment on table dim_staff is 'Справочник персонала';
    comment on column dim_staff.external_id is 'Код в source MSSQL';
    comment on column dim_staff.name is 'ФИО сотрудника';
    comment on column dim_staff.position is 'Должность';
    comment on column dim_staff.store_id is 'Код точки (логическая связь)';

    -- Точки продаж / склады
    create table dim_store
    (
        id          bigint primary key default nextval('public.seq_dim_store'),
        external_id bigint,
        name        text,
        address     text,
        date_add    timestamp default now()
    );

    comment on table dim_store is 'Справочник точек продаж / складов';
    comment on column dim_store.external_id is 'Код в source MSSQL';
    comment on column dim_store.name is 'Наименование точки';
    comment on column dim_store.address is 'Адрес';

    -- Время (метрика/ресурс)
    create table dim_time
    (
        id              bigint primary key default nextval('public.seq_dim_time'),
        date_start_month date not null,
        date_end_month   date not null,
        month_name       text not null,
        year             integer not null,
        quarter_number   integer not null,
        quarter_name     text not null,
        unique (date_start_month, year)
    );

    comment on table dim_time is 'Измерение времени (метрика)';
    comment on column dim_time.date_start_month is 'Дата начала месяца';
    comment on column dim_time.date_end_month is 'Дата окончания месяца';
    comment on column dim_time.month_name is 'Название месяца';
    comment on column dim_time.year is 'Год';
    comment on column dim_time.quarter_number is 'Номер квартала';
    comment on column dim_time.quarter_name is 'Название квартала';

    -- =============================================
    -- ФАКТЫ (FACT TABLES)
    -- =============================================

    -- Факт: закупки продукции (шаг — месяц)
    create table fact_purchase
    (
        id              bigint primary key default nextval('public.seq_fact_purchase'),
        time_id         bigint not null references public.dim_time(id),
        product_id      bigint not null references public.dim_product(id),
        supplier_id     bigint references public.dim_supplier(id),
        store_id        bigint references public.dim_store(id),
        qty             numeric(18,3) default 0,
        amount          numeric(18,2) default 0,
        date_add        timestamp default now()
    );

    comment on table fact_purchase is 'Факт: закупки продукции (шаг месяц)';
    comment on column fact_purchase.qty is 'Количество';
    comment on column fact_purchase.amount is 'Сумма закупки';

    -- Факт: продажи товаров (шаг — месяц)
    create table fact_sales
    (
        id              bigint primary key default nextval('public.seq_fact_sales'),
        time_id         bigint not null references public.dim_time(id),
        product_id      bigint not null references public.dim_product(id),
        staff_id        bigint references public.dim_staff(id),
        store_id        bigint references public.dim_store(id),
        qty             numeric(18,3) default 0,
        amount          numeric(18,2) default 0,
        date_add        timestamp default now()
    );

    comment on table fact_sales is 'Факт: продажи товаров (шаг месяц)';
    comment on column fact_sales.qty is 'Количество проданное';
    comment on column fact_sales.amount is 'Сумма продажи';

    -- Факт: работа персонала (шаг — квартал/полугодиe)
    create table fact_staff
    (
        id              bigint primary key default nextval('public.seq_fact_staff'),
        time_id         bigint not null references public.dim_time(id),
        staff_id        bigint not null references public.dim_staff(id),
        store_id        bigint references public.dim_store(id),
        hours_worked    numeric(10,2) default 0,
        sales_amount    numeric(18,2) default 0,
        orders_count    integer default 0,
        date_add        timestamp default now()
    );

    comment on table fact_staff is 'Факт: работа персонала (шаг квартал/полугодиe)';
    comment on column fact_staff.hours_worked is 'Отработанные часы';
    comment on column fact_staff.sales_amount is 'Сумма продаж сотрудника';
    comment on column fact_staff.orders_count is 'Количество заказов';

    -- Факт: остатки (шаг — неделя)
    create table fact_stock
    (
        id              bigint primary key default nextval('public.seq_fact_stock'),
        time_id         bigint not null references public.dim_time(id),
        product_id      bigint not null references public.dim_product(id),
        store_id        bigint references public.dim_store(id),
        qty             numeric(18,3) default 0,
        amount          numeric(18,2) default 0,
        date_add        timestamp default now()
    );

    comment on table fact_stock is 'Факт: остатки продукции (шаг неделя)';
    comment on column fact_stock.qty is 'Количество на складе';
    comment on column fact_stock.amount is 'Стоимость остатков';

    raise notice 'DDL OLAP базы выполнен успешно';

end $$;
