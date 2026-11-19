do $$
begin

    raise notice ' Расчёт ДМК ';
    call public.calc_meteo11(
        row(1, 100, 25, 765, 15, 6, null)::input_params
    );

    raise notice ' Расчёт ВР ';
    call public.calc_meteo11(
        row(2, 100, 25, 765, 15, null, 100)::input_params
    );

end;
$$;