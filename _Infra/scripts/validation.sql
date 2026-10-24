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

    -- fn_validate_params
    create or replace function fn_validate_params(p input_params)
    returns text
    language plpgsql
    stable
    as $body$
    declare
        v_result text;
    begin
        with expected as (
            select params.id   as param_id,
                   params.name as param_name,
                   const_param_limits.min_value,
                   const_param_limits.max_value,
                   const_param_limits.fraction_digits,
                   case params.id
                       when 1 then p.height
                       when 2 then p.temperature
                       when 3 then p.pressure
                       when 4 then p.wind_direction
                       when 5 then p.wind_speed
                       when 6 then p.bullet_drift
                   end as value
            from equipment_params
            join params
              on params.id = equipment_params.param_id
            join const_param_limits
              on const_param_limits.param_id = params.id
            where equipment_params.equipment_type_id = p.equipment_type_id
        ),
        checked as (
            select expected.*,
                   case
                       when expected.value is null              then 'REQUIRED'
                       when expected.value < expected.min_value then 'RANGE'
                       when expected.value > expected.max_value then 'RANGE'
                       when round(expected.value, expected.fraction_digits)
                            <> expected.value                   then 'PRECISION'
                   end as error_code
            from expected
        )
        select string_agg(
                   format(validation_errors.message_template,
                          checked.param_name,
                          checked.value,
                          checked.min_value,
                          checked.max_value,
                          checked.fraction_digits),
                   '; ' order by checked.param_id)
          into v_result
          from checked
          join validation_errors
            on validation_errors.code = checked.error_code;

        return coalesce(v_result, '');
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
