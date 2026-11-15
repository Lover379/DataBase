

do $$
begin
    raise notice '========================================';
    raise notice ' Расчёт ДМК (t0=25, направление=765, скорость=15)';
    raise notice '========================================';

    call public.calc_meteo11(
        row(1, 25, 765, 6, 15, null, null)::public.input_params
    );

    raise notice '========================================';
    raise notice ' Расчёт ВР (t0=25, направление=765, дальность=100)';
    raise notice '========================================';

    call public.calc_meteo11(
        row(2, 25, 765, null, null, 100, null)::public.input_params
    );

    raise notice '========================================';
    raise notice ' Запуск завершён';
    raise notice '========================================';
end;
$$;
