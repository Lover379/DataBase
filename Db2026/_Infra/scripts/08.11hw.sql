BEGIN;

-- Удаляем старые структуры
DROP TABLE IF EXISTS public.calc_correction CASCADE;
DROP TABLE IF EXISTS public.calc_correction_headers CASCADE;
DROP TABLE IF EXISTS public.calc_correction_types CASCADE;
DROP TABLE IF EXISTS public.calc_correction_heights CASCADE;

DROP SEQUENCE IF EXISTS public.calc_correction_seq CASCADE;
DROP SEQUENCE IF EXISTS public.calc_correction_types_seq CASCADE;
DROP SEQUENCE IF EXISTS public.calc_correction_height_seq CASCADE;

-- 1. Стандартные высоты
CREATE SEQUENCE public.calc_correction_height_seq;

CREATE TABLE public.calc_correction_heights
(
    id integer PRIMARY KEY DEFAULT nextval('public.calc_correction_height_seq'),
    height integer NOT NULL UNIQUE
);

ALTER SEQUENCE public.calc_correction_height_seq
OWNED BY public.calc_correction_heights.id;

INSERT INTO public.calc_correction_heights (height)
VALUES
    (200), (400), (800), (1200), (1600),
    (2000), (2400), (3000), (4000);

COMMENT ON TABLE public.calc_correction_heights
IS 'Справочник стандартных высот';

-- 2. Справочник типов таблиц
CREATE SEQUENCE public.calc_correction_types_seq;

CREATE TABLE public.calc_correction_types
(
    id integer PRIMARY KEY DEFAULT nextval('public.calc_correction_types_seq'),
    parent_id integer REFERENCES public.calc_correction_types(id),
    measurment_equipment_id integer,
    description text NOT NULL
);

ALTER SEQUENCE public.calc_correction_types_seq
OWNED BY public.calc_correction_types.id;

COMMENT ON TABLE public.calc_correction_types
IS 'Справочник типов таблиц корректировок';

-- 3. Отдельная таблица заголовков
CREATE TABLE public.calc_correction_headers
(
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    type_id integer NOT NULL REFERENCES public.calc_correction_types(id),
    position integer NOT NULL,
    header_value integer NOT NULL,
    UNIQUE (type_id, position)
);

COMMENT ON TABLE public.calc_correction_headers
IS 'Заголовки таблиц корректировок';

-- 4. Универсальная таблица корректировок
CREATE SEQUENCE public.calc_correction_seq;

CREATE TABLE public.calc_correction
(
    id integer PRIMARY KEY DEFAULT nextval('public.calc_correction_seq'),
    height_id integer NOT NULL REFERENCES public.calc_correction_heights(id),
    type_id integer NOT NULL REFERENCES public.calc_correction_types(id),
    row_values integer[],
    delta_alpha text,
    UNIQUE (height_id, type_id)
);

ALTER SEQUENCE public.calc_correction_seq
OWNED BY public.calc_correction.id;

COMMENT ON TABLE public.calc_correction
IS 'Универсальная таблица корректировок';

COMMENT ON COLUMN public.calc_correction.row_values
IS 'Массив значений корректировок';

COMMENT ON COLUMN public.calc_correction.delta_alpha
IS 'Угловая поправка ΔαWY';

-- 5. Добавляем типы таблиц
INSERT INTO public.calc_correction_types
    (id, description, parent_id, measurment_equipment_id)
VALUES
    (1, 'Таблица 2', NULL, NULL),
    (2, 'Таблица 3, скорость среднего ветра', NULL, NULL),
    (3, 'Таблица 3, направление среднего ветра', NULL, NULL),

    (4, 'Таблица 3, скорость среднего ветра (ВР)', 2, 2),
    (5, 'Таблица 3, направление среднего ветра (ВР)', 3, 2),

    (6, 'Таблица 3, скорость среднего ветра (ДМК)', 2, 1),
    (7, 'Таблица 3, направление среднего ветра (ДМК)', 3, 1),

    (8, 'Таблица 2, положительные температуры', 1, NULL),
    (9, 'Таблица 2, отрицательные температуры', 1, NULL);

SELECT setval(
    'public.calc_correction_types_seq',
    (SELECT MAX(id) FROM public.calc_correction_types)
);

-- 6. Заголовки таблицы 2
INSERT INTO public.calc_correction_headers
    (type_id, position, header_value)
SELECT t.type_id, h.position, h.header_value
FROM (VALUES (8), (9)) AS t(type_id)
CROSS JOIN (
    VALUES
        (1, 1), (2, 2), (3, 3), (4, 4),
        (5, 5), (6, 6), (7, 7), (8, 8),
        (9, 9), (10, 10), (11, 20),
        (12, 30), (13, 40), (14, 50)
) AS h(position, header_value);

-- Заголовки таблицы 3 ВР
INSERT INTO public.calc_correction_headers
    (type_id, position, header_value)
VALUES
    (4, 1, 40), (4, 2, 50), (4, 3, 60),
    (4, 4, 70), (4, 5, 80), (4, 6, 90),
    (4, 7, 100), (4, 8, 110), (4, 9, 120),
    (4, 10, 130), (4, 11, 140), (4, 12, 150);

-- Заголовки таблицы 3 ДМК
INSERT INTO public.calc_correction_headers
    (type_id, position, header_value)
VALUES
    (6, 1, 3), (6, 2, 4), (6, 3, 5),
    (6, 4, 6), (6, 5, 7), (6, 6, 8),
    (6, 7, 9), (6, 8, 10), (6, 9, 11),
    (6, 10, 12), (6, 11, 13), (6, 12, 14),
    (6, 13, 15);

-- 7. Таблица 2: отрицательные температуры
INSERT INTO public.calc_correction
    (height_id, type_id, row_values)
VALUES
    (1, 9, ARRAY[-1,-2,-3,-4,-5,-6,-7,-8,-9,-10,-20,-29,-39,-49]),
    (2, 9, ARRAY[-1,-2,-3,-4,-5,-6,-6,-7,-8,-9,-19,-29,-38,-48]),
    (3, 9, ARRAY[-1,-2,-3,-4,-5,-6,-6,-7,-7,-8,-18,-28,-37,-46]),
    (4, 9, ARRAY[-1,-2,-3,-4,-4,-5,-5,-6,-7,-8,-17,-26,-35,-44]),
    (5, 9, ARRAY[-1,-2,-3,-4,-4,-5,-5,-6,-7,-7,-17,-25,-34,-42]),
    (6, 9, ARRAY[-1,-2,-3,-3,-4,-6,-6,-7,-7,-7,-16,-24,-32,-40]),
    (7, 9, ARRAY[-1,-2,-2,-3,-4,-4,-5,-5,-6,-7,-15,-23,-31,-38]),
    (8, 9, ARRAY[-1,-2,-3,-4,-4,-5,-5,-6,-6,-6,-15,-22,-30,-37]),
    (9, 9, ARRAY[-1,-2,-2,-3,-4,-4,-4,-5,-5,-5,-14,-20,-27,-34]);

-- 8. Таблица 2: положительные температуры
-- Прочерки из исходной таблицы представлены как NULL.
INSERT INTO public.calc_correction
    (height_id, type_id, row_values)
VALUES
    (1, 8, ARRAY[1,2,3,4,5,6,7,8,9,10,20,30,NULL,NULL]),
    (2, 8, ARRAY[1,2,3,4,5,6,7,8,9,10,19,30,NULL,NULL]),
    (3, 8, ARRAY[1,2,3,4,5,6,7,8,9,10,18,30,NULL,NULL]),
    (4, 8, ARRAY[1,2,3,4,5,6,7,8,9,10,17,20,30,NULL]),
    (5, 8, ARRAY[1,2,3,4,5,6,7,8,9,10,17,30,NULL,NULL]),
    (6, 8, ARRAY[1,2,3,4,5,6,7,8,9,10,16,20,30,NULL]),
    (7, 8, ARRAY[1,2,3,4,5,6,7,8,9,10,15,20,30,NULL]),
    (8, 8, ARRAY[1,2,3,4,5,6,7,8,9,10,15,20,30,NULL]),
    (9, 8, ARRAY[1,2,3,4,5,6,7,8,9,10,14,20,NULL,NULL]);

-- 9. Таблица 3: скорость среднего ветра ВР
INSERT INTO public.calc_correction
    (height_id, type_id, row_values, delta_alpha)
VALUES
    (1, 4, ARRAY[3,4,5,6,7,7,8,9,10,11,12,12], '0-00'),
    (2, 4, ARRAY[4,5,6,7,8,9,10,11,12,13,14,15], '1-00'),
    (3, 4, ARRAY[4,5,6,7,8,9,10,11,13,14,15,16], '2-00'),
    (4, 4, ARRAY[4,5,7,8,8,9,11,12,13,15,15,16], '2-00'),
    (5, 4, ARRAY[4,6,7,8,9,10,11,13,14,15,17,17], '3-00'),
    (6, 4, ARRAY[4,6,7,8,9,10,11,13,14,16,17,18], '3-00'),
    (7, 4, ARRAY[4,6,8,9,9,10,12,14,15,16,18,19], '3-00'),
    (8, 4, ARRAY[5,6,8,9,10,11,12,14,15,17,18,19], '4-00'),
    (9, 4, ARRAY[6,8,9,10,11,12,14,16,18,19,20,NULL], '4-00');

-- 10. Таблица 3: скорость среднего ветра ДМК
INSERT INTO public.calc_correction
    (height_id, type_id, row_values, delta_alpha)
VALUES
    (1, 6, ARRAY[4,6,8,9,10,12,14,15,16,18,20,21,22], '1-00'),
    (2, 6, ARRAY[5,7,10,11,12,14,17,18,20,22,23,25,27], '2-00'),
    (3, 6, ARRAY[5,8,10,11,13,15,18,19,21,23,25,27,28], '3-00'),
    (4, 6, ARRAY[5,8,11,12,13,16,19,20,23,24,26,28,30], '3-00'),
    (5, 6, ARRAY[6,8,11,13,14,17,20,21,23,25,27,29,32], '4-00'),
    (6, 6, ARRAY[6,9,11,13,14,17,20,21,24,26,28,30,32], '4-00'),
    (7, 6, ARRAY[6,9,12,14,15,18,21,22,25,27,29,32,34], '4-00'),
    (8, 6, ARRAY[6,9,12,14,15,18,21,23,25,28,30,32,36], '5-00'),
    (9, 6, ARRAY[6,10,12,14,16,19,22,24,26,29,32,34,36], '5-00');

-- 11. Комментарии
COMMENT ON COLUMN public.calc_correction_types.parent_id
IS 'Родительский тип таблицы';

COMMENT ON COLUMN public.calc_correction_types.measurment_equipment_id
IS 'Тип измерительного оборудования';

COMMENT ON COLUMN public.calc_correction_headers.type_id
IS 'Тип таблицы, к которой относится заголовок';


CREATE OR REPLACE FUNCTION public.fn_calc_temperature_interpolation(
    par_temperature numeric
)
RETURNS numeric
LANGUAGE plpgsql
AS $BODY$
DECLARE
    var_params public.interpolation_params;
    var_result numeric(8,2);
    var_min_temperature numeric(8,2);
    var_max_temperature numeric(8,2);
BEGIN
    RAISE NOTICE 'Расчет интерполяции для температуры %',
        par_temperature;

    -- Проверяем границы допустимых температур
    SELECT MIN(temperature), MAX(temperature)
    INTO var_min_temperature, var_max_temperature
    FROM public.calc_correction_temperature;

    IF par_temperature < var_min_temperature
       OR par_temperature > var_max_temperature THEN
        RAISE EXCEPTION
            'Температура % вне допустимого диапазона: % - %',
            par_temperature,
            var_min_temperature,
            var_max_temperature;
    END IF;

    -- Получаем параметры интерполяции
    var_params := public.get_interpolation_params(par_temperature);

    -- Рассчитываем результат
    var_result := public.calculate_interpolation(
        par_temperature,
        var_params
    );

    RETURN var_result;
END;
$BODY$;

COMMENT ON FUNCTION public.fn_calc_temperature_interpolation(numeric)
IS 'Функция для расчета интерполяции температуры';
commit;