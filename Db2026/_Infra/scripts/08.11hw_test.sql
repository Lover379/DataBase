SELECT
    t.description,
    ch.position,
    ch.header_value
FROM public.calc_correction_headers AS ch
JOIN public.calc_correction_types AS t
    ON t.id = ch.type_id
ORDER BY ch.type_id, ch.position;