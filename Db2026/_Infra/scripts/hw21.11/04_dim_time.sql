-- Скрипт формирования ресурса (метрики) Время (dim_time)
-- Заполняет таблицу dim_time на диапазон лет
-- Структура: Код | Дата начала месяца | Дата окончания месяца |
--            Название месяца | Год | Номер квартала | Название квартала

do $$
declare
    v_date_start   date;
    v_date_end     date;
    v_year_start   integer := 2024;
    v_year_end     integer := 2026;
    v_year         integer;
    v_month        integer;
    v_month_name   text;
    v_quarter_num  integer;
    v_quarter_name text;
begin

    -- Очистка перед заполнением (для повторного запуска)
    delete from dim_time;

    for v_year in v_year_start..v_year_end loop
        for v_month in 1..12 loop

            v_date_start := make_date(v_year, v_month, 1);
            v_date_end   := (v_date_start + interval '1 month - 1 day')::date;

            -- Название месяца (явно по-русски, независимо от локали сервера)
            v_month_name := case v_month
                                when 1  then 'Январь'
                                when 2  then 'Февраль'
                                when 3  then 'Март'
                                when 4  then 'Апрель'
                                when 5  then 'Май'
                                when 6  then 'Июнь'
                                when 7  then 'Июль'
                                when 8  then 'Август'
                                when 9  then 'Сентябрь'
                                when 10 then 'Октябрь'
                                when 11 then 'Ноябрь'
                                when 12 then 'Декабрь'
                            end;

            -- Номер квартала
            v_quarter_num := EXTRACT(QUARTER FROM v_date_start)::integer;

            -- Название квартала
            v_quarter_name := case v_quarter_num
                                  when 1 then 'I квартал'
                                  when 2 then 'II квартал'
                                  when 3 then 'III квартал'
                                  when 4 then 'IV квартал'
                              end;

            insert into dim_time(date_start_month, date_end_month,
                                 month_name, year,
                                 quarter_number, quarter_name)
            values (v_date_start, v_date_end,
                    v_month_name, v_year,
                    v_quarter_num, v_quarter_name);

        end loop;
    end loop;

    commit;

    raise notice 'Таблица dim_time заполнена: % записей',
        (select count(*) from dim_time);

end $$;

-- Проверка результата
select id,
       date_start_month as "Дата начала месяца",
       date_end_month   as "Дата окончания месяца",
       month_name       as "Название месяца",
       year             as "Год",
       quarter_number   as "Номер квартала",
       quarter_name     as "Название квартала"
from dim_time
order by year, date_start_month;
