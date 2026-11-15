

do $$
begin


    begin
        create sequence calc_correction_headers_seq;

        create table calc_correction_headers
        (
            id           integer not null primary key default nextval('public.calc_correction_headers_seq'),
            type_id      integer not null,
            position     integer not null,
            header_value integer not null
        );

        alter table calc_correction_headers
            add constraint fk_headers_type foreign key (type_id)
            references calc_correction_types(id);

        comment on table calc_correction_headers is 'Заголовки столбцов таблиц корректировок';
        comment on column calc_correction_headers.type_id is 'Тип таблицы, к которой относится заголовок';
        comment on column calc_correction_headers.position is 'Номер столбца, позиция в row_values';
        comment on column calc_correction_headers.header_value is 'Значение заголовка столбца';

        -- Переносим заголовки из массива в нормальную таблицу
        insert into calc_correction_headers(type_id, position, header_value)
        select types.id,
               header.position,
               header.value
        from calc_correction_types as types
        cross join lateral unnest(types.header_values)
                   with ordinality as header(value, position)
        where types.header_values is not null;

        -- Структура типов меняется: массив заголовков больше не хранится здесь
        alter table calc_correction_types drop column header_values;
    end;


    begin
        -- Названия дочерних типов приведены к смыслу таблиц
        update calc_correction_types
           set description = 'Таблица 2, отрицательные температуры'
         where id = 9;

        update calc_correction_types
           set description = 'Таблица 2, положительные температуры'
         where id = 8;

        -- Положительные температуры лежали в типе 7 вместе с направлением ветра
        -- ДМК. Разводим их по назначению: положительная температура — это тип 8.
        update calc_correction
           set type_id = 8
         where type_id = 7
           and cardinality(row_values) > 1;

        -- Прочерки в столбцах 40 и 50 становятся NULL, чтобы длина строки
        -- совпадала с длиной заголовка
        update calc_correction
           set row_values = array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]
         where type_id = 8;

        -- Таблица 2, высота 400: в столбце 40 стоит -39 вместо -38
        update calc_correction
           set row_values[13] = -38
         where type_id = 9
           and height_id = 2;

        -- Таблица 3, ДМК, высота 1200: в столбце 11 м/с стоит 23 вместо 22
        update calc_correction
           set row_values[9] = 22
         where type_id = 6
           and height_id = 4;

        -- Направления среднего ветра переведены в малые деления угломера:
        -- 1-00 это 100, 2-00 это 200 и т. д.
        update calc_correction
           set row_values = array[row_values[1] * 100]
         where type_id in (5, 7);
    end;


    begin
        -- Таблица 2, отрицательные температуры
        insert into calc_correction(height_id, type_id, row_values)
        values(5, 9, array[-1, -2, -3, -4, -4, -5, -5, -6, -7, -7, -17, -25, -34, -42]),
              (6, 9, array[-1, -2, -3, -3, -4, -4, -5, -6, -6, -7, -16, -24, -32, -40]),
              (7, 9, array[-1, -2, -2, -3, -4, -4, -5, -5, -6, -7, -15, -23, -31, -38]),
              (8, 9, array[-1, -2, -2, -3, -4, -4, -4, -5, -5, -6, -15, -22, -30, -37]),
              (9, 9, array[-1, -2, -2, -3, -4, -4, -4, -4, -5, -6, -14, -20, -27, -34]);

        -- Таблица 2, положительные температуры
        insert into calc_correction(height_id, type_id, row_values)
        values(5, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]),
              (6, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]),
              (7, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]),
              (8, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]),
              (9, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]);

        -- Таблица 3, скорость среднего ветра (ВР)
        insert into calc_correction(height_id, type_id, row_values)
        values(5, 4, array[4, 6, 7, 8, 9, 10, 11, 13, 14, 15, 17, 17]),
              (6, 4, array[4, 6, 7, 8, 9, 10, 11, 13, 14, 16, 17, 18]),
              (7, 4, array[4, 6, 8, 9, 9, 10, 12, 14, 15, 16, 18, 19]),
              (8, 4, array[5, 6, 8, 9, 10, 11, 12, 14, 15, 17, 18, 19]),
              (9, 4, array[5, 6, 8, 9, 10, 11, 12, 14, 16, 18, 19, 20]);

        -- Таблица 3, скорость среднего ветра (ДМК)
        insert into calc_correction(height_id, type_id, row_values)
        values(5, 6, array[6, 8, 11, 13, 14, 17, 20, 21, 23, 25, 27, 29, 32]),
              (6, 6, array[6, 9, 11, 13, 14, 17, 20, 21, 24, 26, 28, 30, 32]),
              (7, 6, array[6, 9, 12, 14, 15, 18, 21, 22, 25, 27, 29, 32, 34]),
              (8, 6, array[6, 9, 12, 14, 15, 18, 21, 23, 25, 28, 30, 32, 36]),
              (9, 6, array[6, 10, 12, 14, 16, 19, 22, 24, 26, 29, 32, 34, 36]);

        -- Таблица 3, направление среднего ветра: ВР (тип 5), ДМК (тип 7)
        insert into calc_correction(height_id, type_id, row_values)
        values(5, 5, array[300]), (6, 5, array[300]), (7, 5, array[300]),
              (8, 5, array[400]), (9, 5, array[400]),
              (5, 7, array[400]), (6, 7, array[400]), (7, 7, array[400]),
              (8, 7, array[500]), (9, 7, array[500]);
    end;


    begin
        -- Смысловой код: расчёт обращается к типам по смыслу, а не по номеру id
        alter table calc_correction_types add column if not exists code text;

        update calc_correction_types set code = 'temp_base'     where id = 1;
        update calc_correction_types set code = 'speed_base'    where id = 2;
        update calc_correction_types set code = 'direction_base' where id = 3;
        update calc_correction_types set code = 'speed'         where id in (4, 6);
        update calc_correction_types set code = 'direction'     where id in (5, 7);
        update calc_correction_types set code = 'temp_negative' where id = 9;
        update calc_correction_types set code = 'temp_positive' where id = 8;

        comment on column calc_correction_types.code is
            'Смысловой код таблицы для обращения из расчёта';

        -- Ссылки на справочники: высоты и заголовки
        alter table calc_correction
            add constraint fk_correction_height foreign key (height_id)
            references calc_correction_heights(id);

        alter table calc_correction
            add constraint uq_correction_height_type unique (height_id, type_id);

        alter table calc_correction_headers
            add constraint uq_headers_type_position unique (type_id, position);

        -- Один смысловой код в рамках типа оборудования
        alter table calc_correction_types
            add constraint uq_types_code_equipment unique (code, measurment_equipment_id);
    end;


    begin
        create sequence calc_input_params_seq;

    -- Таблица параметров нужна, чтобы собрать входящие параметры запросом из БД
    create table calc_input_params
    (
        id                 integer not null primary key default nextval('public.calc_input_params_seq'),
        name               text not null unique,
        equipment_type_id  integer not null,
        temperature        numeric not null,
        wind_direction     numeric not null,
        bullet_drift       numeric,
        wind_speed         numeric,
        height_min         integer not null,
        height_max         integer not null
    );

    comment on table calc_input_params is 'Наборы входящих параметров расчёта Метео-11';

    insert into calc_input_params(name, equipment_type_id, temperature, wind_direction,
                                  bullet_drift, wind_speed, height_min, height_max)
        values ('ДМК типовые', 1, 25, 765, null, 15, 6, null),
               ('ВР типовые',  2, 25, 765, 100,  null, null, 15);

    -- Порядок полей должен совпадать с порядком атрибутов составного типа:
    -- приведение row(...)::input_params работает позиционно.
    create type public.input_params as
        (
            equipment_type_id  integer,   -- 1 = ДМК, 2 = ВР
            temperature        numeric,   -- t0, градусы
            wind_direction     numeric,   -- направление ветра, деления шкалы
            height_min         integer,   -- нижняя граница высот, метры
            wind_speed         numeric,   -- скорость ветра, м/с (для ДМК)
            bullet_drift       numeric,   -- дальность дрейфа снаряда (для ВР)
            height_max         integer    -- верхняя граница высот, метры
        );

        comment on type public.input_params is 'Входящие параметры расчёта Метео-11';
    end;



    -- Константы расчёта вынесены в функцию, чтобы «15,9» не кочевало по коду
    create or replace function public.fn_const(par_name text)
    returns numeric
    language plpgsql
    immutable
    as $fn$
    begin
        if par_name = 'BASE_TEMPERATURE' then
            return 15.9;                     -- нормальная температура по ТЗ
        end if;

        if par_name = 'TEMP_MIN' then
            return -58.0;
        end if;

        if par_name = 'TEMP_MAX' then
            return 58.0;
        end if;

        raise exception 'Неизвестная константа расчёта: %', par_name;
    end;
    $fn$;

    -- Код стандартной высоты по её значению
    create or replace function public.fn_height_id(par_height integer)
    returns integer
    language plpgsql
    stable
    as $fn$
    declare
        v_id integer;
    begin
        select heights.id
          into v_id
          from calc_correction_heights as heights
         where heights.height = par_height;

        if v_id is null then
            raise exception 'Нет стандартной высоты % в calc_correction_heights', par_height;
        end if;

        return v_id;
    end;
    $fn$;

    -- Идентификатор типа таблицы по смысловому коду и оборудованию
    create or replace function public.fn_type_id(
        par_code         text,
        par_equipment_id integer default null
    )
    returns integer
    language plpgsql
    stable
    as $fn$
    declare
        v_id integer;
    begin
        select types.id
          into v_id
          from calc_correction_types as types
         where types.code = par_code
           and (par_equipment_id is null
                or types.measurment_equipment_id = par_equipment_id);

        if v_id is null then
            raise exception 'Не найден тип таблицы корректировок: %, оборудование %',
                par_code, par_equipment_id;
        end if;

        return v_id;
    end;
    $fn$;

    -- Строка корректировок по типу таблицы и высоте
    create or replace function public.fn_calc_row(
        par_type_id   integer,
        par_height_id integer
    )
    returns integer[]
    language plpgsql
    stable
    as $fn$
    declare
        v_row integer[];
    begin
        select corrections.row_values
          into v_row
          from calc_correction as corrections
         where corrections.type_id = par_type_id
           and corrections.height_id = par_height_id;

        if v_row is null then
            raise exception 'Нет данных в calc_correction: тип %, высота %',
                par_type_id, par_height_id;
        end if;

        return v_row;
    end;
    $fn$;

    -- Опорный отрезок интерполяции по температуре, узлы берём из справочника
    create or replace function public.fn_interp_temp(p_temperature numeric)
    returns public."interType"
    language plpgsql
    stable
    as $fn$
    declare
        v_result public."interType";
    begin
        select temperatures.temperature, temperatures.correction
          into v_result.x0, v_result.y0
          from calc_correction_temperature as temperatures
         where temperatures.temperature <= p_temperature
         order by temperatures.temperature desc
         limit 1;

        select temperatures.temperature, temperatures.correction
          into v_result.x1, v_result.y1
          from calc_correction_temperature as temperatures
         where temperatures.temperature >= p_temperature
         order by temperatures.temperature asc
         limit 1;

        -- выход за таблицу в одну сторону — вырожденный отрезок
        if v_result.x0 is null then
            v_result.x0 := v_result.x1;
            v_result.y0 := v_result.y1;
        end if;

        if v_result.x1 is null then
            v_result.x1 := v_result.x0;
            v_result.y1 := v_result.y0;
        end if;

        return v_result;
    end;
    $fn$;

    -- Вспомогательная: табличное значение по порогу заголовка (largest header <= value)
    create or replace function public.fn_header_by_value(
        par_type_id integer,
        par_value   numeric
    )
    returns table (header_value integer, position integer)
    language plpgsql
    stable
    as $fn$
    begin
        return query
            select headers.header_value, headers.position
              from calc_correction_headers as headers
             where headers.type_id = par_type_id
               and headers.header_value <= par_value
             order by headers.header_value desc
             limit 1;
    end;
    $fn$;

    -- Проверка входящих параметров
    create or replace function public.fn_validate_input(par_params input_params)
    returns text
    language plpgsql
    stable
    as $fn$
    declare
        v_errors text := '';
    begin
        if par_params.equipment_type_id not in (1, 2) then
            v_errors := v_errors || 'Неизвестный тип оборудования; ';
        end if;

        -- Heights — необязательный параметр: null означает «все типовые высоты»
        if coalesce(par_params.height_min, 0) > coalesce(par_params.height_max, 0) then
            v_errors := v_errors || 'Нижняя граница высот выше верхней; ';
        end if;

        if par_params.temperature is null
           or par_params.temperature < fn_const('TEMP_MIN')
           or par_params.temperature > fn_const('TEMP_MAX') then
            v_errors := v_errors || 'Температура вне диапазона; ';
        end if;

        if par_params.wind_direction is null then
            v_errors := v_errors || 'Направление ветра не задано; ';
        end if;

        -- Скорость для ДМК и дрейф для ВР — взаимоисключающие входные данные
        if par_params.equipment_type_id = 1 and par_params.bullet_drift is not null then
            v_errors := v_errors || 'Для ДМК дальность дрейфа не задаётся; ';
        end if;

        if par_params.equipment_type_id = 2 and par_params.wind_speed is not null then
            v_errors := v_errors || 'Для ВР скорость ветра не задаётся; ';
        end if;

        return rtrim(v_errors, '; ');
    end;
    $fn$;

    -- Форматирование строки бюллетеня
    create or replace function public.fn_format_row(
        par_height    integer,
        par_temp      integer,
        par_temp_code integer,
        par_direction integer,
        par_speed     integer
    )
    returns text
    language plpgsql
    immutable
    as $fn$
    begin
        return format(
            'Высота %s (%s) | Откл. темп.: %s (%s) | Направление: %s | Скорость: %s',
            par_height,
            lpad((par_height / 100)::text, 2, '0'),
            par_temp,
            lpad(abs(par_temp_code)::text, 2, '0'),
            lpad(par_direction::text, 2, '0'),
            lpad(par_speed::text, 2, '0')
        );
    end;
    $fn$;

    -- Среднее отклонение температуры по Таблице 2
    create or replace function public.fn_temp_correction(
        par_params    input_params,
        par_height_id integer
    )
    returns table (out_value integer, out_code integer)
    language plpgsql
    stable
    as $fn$
    declare
        v_dt_v      numeric;
        v_deviation integer;
        v_type_id   integer;
        v_row       integer[];
        v_remainder integer;
        v_part      integer;
        v_position  integer;
        v_sum       integer := 0;
    begin
        -- dT0 = t0 + dTv - 15.9
        v_dt_v      := public.calculate_interpolation(
                           par_params.temperature,
                           fn_interp_temp(par_params.temperature));
        v_deviation := round(par_params.temperature + v_dt_v
                             - fn_const('BASE_TEMPERATURE'))::integer;

        v_type_id := fn_type_id(case when v_deviation < 0
                                     then 'temp_negative'
                                     else 'temp_positive'
                                end);
        v_row       := fn_calc_row(v_type_id, par_height_id);
        v_remainder := abs(v_deviation);

        while v_remainder > 0 loop
            -- разложение отклонения на слагаемые по заголовкам таблицы;
            -- заголовки родителя (Таблица 2) покрывают оба дочерних типа
            select headers.header_value, headers.position
              into v_part, v_position
              from calc_correction_headers as headers
             where headers.type_id in (v_type_id,
                    (select types.parent_id from calc_correction_types as types
                      where types.id = v_type_id))
               and headers.header_value <= v_remainder
               and v_row[headers.position] is not null
             order by headers.header_value desc
             limit 1;

            if v_part is null then
                raise exception 'Отклонение % не раскладывается по таблице % (высота %)',
                    v_deviation, v_type_id, par_height_id;
            end if;

            v_sum       := v_sum + v_row[v_position];
            v_remainder := v_remainder - v_part;
        end loop;

        -- отрицательное отклонение кодируется модулем плюс 50
        return query
            select v_sum::integer,
                   case when v_deviation < 0 then 50 + abs(v_sum) else v_sum end;
    end;
    $fn$;

    -- Скорость среднего ветра по Таблице 3
    create or replace function public.fn_speed_correction(
        par_params    input_params,
        par_height_id integer
    )
    returns integer
    language plpgsql
    stable
    as $fn$
    declare
        v_type_id   integer;
        v_input     numeric;
        v_minimum   numeric;
        v_row       integer[];
        v_x0        numeric;
        v_x1        numeric;
        v_pos0      integer;
        v_pos1      integer;
    begin
        v_type_id := fn_type_id('speed', par_params.equipment_type_id);
        v_input   := coalesce(par_params.wind_speed, par_params.bullet_drift);

        -- порог слабого ветра — первый столбец таблицы
        select min(headers.header_value)
          into v_minimum
          from calc_correction_headers as headers
         where headers.type_id = v_type_id;

        if coalesce(v_input, 0) < v_minimum then
            return 0;
        end if;

        v_row := fn_calc_row(v_type_id, par_height_id);

        select headers.header_value, headers.position
          into v_x0, v_pos0
          from calc_correction_headers as headers
         where headers.type_id = v_type_id
           and headers.header_value <= v_input
         order by headers.header_value desc
         limit 1;

        select headers.header_value, headers.position
          into v_x1, v_pos1
          from calc_correction_headers as headers
         where headers.type_id = v_type_id
           and headers.header_value >= v_input
         order by headers.header_value asc
         limit 1;

        -- значение правее последнего столбца — берём последний без экстраполяции
        if v_x1 is null then
            return v_row[v_pos0];
        end if;

        return round(public.calculate_interpolation(
                         v_input,
                         row(v_x0, v_x1, v_row[v_pos0], v_row[v_pos1])::public."interType"
                     ))::integer;
    end;
    $fn$;

    -- Направление среднего ветра по Таблице 3
    create or replace function public.fn_direction_correction(
        par_params    input_params,
        par_height_id integer
    )
    returns integer
    language plpgsql
    stable
    as $fn$
    declare
        v_type_id integer;
        v_input   numeric;
        v_minimum numeric;
        v_delta   integer;
        v_circle  integer;
    begin
        v_input := coalesce(par_params.wind_speed, par_params.bullet_drift);

        select min(headers.header_value)
          into v_minimum
          from calc_correction_headers as headers
         where headers.type_id = fn_type_id('speed', par_params.equipment_type_id);

        -- при слабом ветре скорость и направление заполняются нулями
        if coalesce(v_input, 0) < v_minimum then
            return 0;
        end if;

        v_type_id := fn_type_id('direction', par_params.equipment_type_id);

        select corrections.row_values[1]
          into v_delta
          from calc_correction as corrections
         where corrections.type_id = v_type_id
           and corrections.height_id = par_height_id;

        -- полный круг числа делений направления
        v_circle := 6000;

        return mod(round(par_params.wind_direction)::integer
                   + coalesce(v_delta, 0) / 100, v_circle / 100);
    end;
    $fn$;

    raise notice 'DDL применён: справочник заголовков, корректировки данных,'
                 || ' тип input_params и функции расчёта созданы';
end;
$$;


create or replace procedure public.calc_meteo11(par_params input_params)
language plpgsql
as $body$
declare
    v_errors    text;
    v_temp      record;
    v_direction integer;
    v_speed     integer;
    v_row       record;
begin
    v_errors := fn_validate_input(par_params);

    if v_errors <> '' then
        raise exception 'Ошибка входных параметров: %', v_errors;
    end if;

    raise notice 'Оборудование: % | t0 = % | направление = %',
        case par_params.equipment_type_id
            when 1 then 'ДМК'
            when 2 then 'ВР'
        end,
        par_params.temperature,
        par_params.wind_direction;

    for v_row in
        select heights.id     as height_id,
               heights.height as height_value
          from calc_correction_heights as heights
         where heights.height between par_params.height_min and par_params.height_max
         order by heights.height
    loop
        select temps.out_value, temps.out_code
          into v_temp
          from fn_temp_correction(par_params, v_row.height_id) as temps;

        v_speed     := fn_speed_correction(par_params, v_row.height_id);
        v_direction := fn_direction_correction(par_params, v_row.height_id);

        raise notice '%', fn_format_row(v_row.height_value,
                                        v_temp.out_value,
                                        v_temp.out_code,
                                        v_direction,
                                        v_speed);
    end loop;
end;
$body$;

comment on procedure public.calc_meteo11(input_params)
    is 'Расчёт приближённого бюллетеня Метео-11 по типовым высотам для ДМК и ВР';
