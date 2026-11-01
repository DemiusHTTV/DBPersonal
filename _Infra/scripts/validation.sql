do $$
begin
    -- validation_errors
    drop table if exists validation_errors cascade;
    create table validation_errors (
        code             varchar(20) not null,
        message_template text        not null
    );

    insert into validation_errors (code, message_template) values
        ('REQUIRED',  'Параметр «%1$s» не заполнен'),
        ('RANGE',     'Параметр «%1$s»: значение %2$s вне диапазона [%3$s; %4$s]'),
        ('PRECISION', 'Параметр «%1$s»: значение %2$s не соответствует точности в %5$s знаков после запятой');

    alter table validation_errors
        add constraint pk_validation_errors primary key (code);

    -- input_params
    drop type if exists input_params cascade;
    create type input_params as (
        equipment_type_id integer,
        height            numeric,
        temperature       numeric,
        pressure          numeric,
        wind_direction    numeric,
        wind_speed        numeric,
        bullet_drift      numeric
    );

    -- fn_check_param
    create or replace function fn_check_param(p_param_id integer, p_value numeric)
    returns text
    language plpgsql
    stable
    as $body$
    declare
        v_name     text;
        v_min      numeric;
        v_max      numeric;
        v_digits   smallint;
        v_template text;
    begin
        select params.name,
               const_param_limits.min_value,
               const_param_limits.max_value,
               const_param_limits.fraction_digits
          into v_name, v_min, v_max, v_digits
          from params
          join const_param_limits
            on const_param_limits.param_id = params.id
         where params.id = p_param_id;

        if p_value is null then
            select message_template into v_template from validation_errors where code = 'REQUIRED';
        elsif p_value < v_min or p_value > v_max then
            select message_template into v_template from validation_errors where code = 'RANGE';
        elsif round(p_value, v_digits) <> p_value then
            select message_template into v_template from validation_errors where code = 'PRECISION';
        else
            return '';
        end if;

        return format(v_template, v_name, p_value, v_min, v_max, v_digits);
    end;
    $body$;

    -- fn_validate_params
    create or replace function fn_validate_params(p_set input_params)
    returns text
    language plpgsql
    stable
    as $body$
    declare
        v_errors text[];
    begin
        v_errors := array_remove(array[
            fn_check_param(1, p_set.height),
            fn_check_param(2, p_set.temperature),
            fn_check_param(3, p_set.pressure),
            fn_check_param(4, p_set.wind_direction)
        ], '');

        if p_set.equipment_type_id = 1 then
            v_errors := array_remove(v_errors || fn_check_param(5, p_set.wind_speed), '');
        elsif p_set.equipment_type_id = 2 then
            v_errors := array_remove(v_errors || fn_check_param(6, p_set.bullet_drift), '');
        end if;

        return array_to_string(v_errors, '; ');
    end;
    $body$;

    -- fn_meteo_ddchhm
    create or replace function fn_meteo_ddchhm(p_date timestamp)
    returns varchar
    language plpgsql
    immutable
    as $body$
    begin
        return to_char(p_date, 'DDHH24')
            || floor(extract(minute from p_date) / 10)::integer::text;
    end;
    $body$;

    -- fn_meteo_vvvv
    create or replace function fn_meteo_vvvv(p_height numeric)
    returns varchar
    language plpgsql
    immutable
    as $body$
    begin
        return lpad(round(p_height)::integer::text, 4, '0');
    end;
    $body$;

    -- fn_meteo_bbbtt
    create or replace function fn_meteo_bbbtt(p_pressure numeric, p_temperature numeric)
    returns varchar
    language plpgsql
    stable
    as $body$
    declare
        v_pressure_deviation    integer := round(p_pressure - fn_const('BASE_PRESSURE'));
        v_temperature_deviation integer := round(
            p_temperature
            + public.calculate_interpolation(
                  p_temperature,
                  public.my_interpolation_func(p_temperature))
            - fn_const('BASE_TEMPERATURE'));
        v_bbb varchar;
        v_tt  varchar;
    begin
        v_bbb := case
                     when v_pressure_deviation >= 0
                     then lpad(v_pressure_deviation::text, 3, '0')
                     else lpad((fn_const('PRESSURE_NEG_OFFSET')
                                + abs(v_pressure_deviation))::integer::text, 3, '0')
                 end;

        v_tt := case
                    when v_temperature_deviation >= 0
                    then lpad(v_temperature_deviation::text, 2, '0')
                    else lpad((fn_const('TEMPERATURE_NEG_OFFSET')
                               + abs(v_temperature_deviation))::integer::text, 2, '0')
                end;

        return v_bbb || v_tt;
    end;
    $body$;

    -- fn_meteo_header
    create or replace function fn_meteo_header(
        p_date        timestamp,
        p_height      numeric,
        p_pressure    numeric,
        p_temperature numeric
    )
    returns varchar
    language plpgsql
    stable
    as $body$
    begin
        return fn_meteo_ddchhm(p_date)
            || ' ' || fn_meteo_vvvv(p_height)
            || ' ' || fn_meteo_bbbtt(p_pressure, p_temperature);
    end;
    $body$;
end;
$$;


do $$
declare
    v_actual text;
begin
    v_actual := fn_meteo_ddchhm(timestamp '2026-10-24 09:30:00');
    if v_actual <> '24093' then
        raise exception 'ДДЧЧМ(24.10 09:30) ожидали 24093, получили %', v_actual;
    end if;

    v_actual := fn_meteo_vvvv(60);
    if v_actual <> '0060' then
        raise exception 'ВВВВ(60) ожидали 0060, получили %', v_actual;
    end if;

    v_actual := fn_meteo_bbbtt(765, 25);
    if v_actual <> '01511' then
        raise exception 'БББТТ(765, 25) ожидали 01511, получили %', v_actual;
    end if;

    v_actual := fn_meteo_bbbtt(743, 25);
    if v_actual <> '50711' then
        raise exception 'БББТТ(743, 25) ожидали 50711, получили %', v_actual;
    end if;

    v_actual := fn_validate_params(row(1, 100, 15.0, 750, 30, 5, null)::input_params);
    if v_actual <> '' then
        raise exception 'корректный набор параметров дал ошибки: %', v_actual;
    end if;

    v_actual := fn_validate_params(row(1, 100, 70.0, 1000, 99, 5, null)::input_params);
    if v_actual = '' then
        raise exception 'некорректный набор параметров не дал ошибок';
    end if;

    raise notice 'проверки пройдены, пример ошибок: %', v_actual;
end;
$$;
