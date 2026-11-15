do $$
begin
    begin
    update calc_correction_types set header_values = array[1,2,3,4,5,6,7,8,9,10,20,30,40,50] where id = 1;

    update calc_correction_types
       set header_values = null
     where id in (5, 7);

    end;
    
    begin
    -- Делаем отдельный справчнник
    create sequence calc_correction_headers_seq;

    create table calc_correction_headers
    (
        id           integer not null primary key default nextval('public.calc_correction_headers_seq'),
        type_id      integer not null,
        position     integer not null,
        header_value integer not null
    );

    comment on table calc_correction_headers is 'Заголовки столбцов таблиц корректировок';
    comment on column calc_correction_headers.type_id is 'Тип таблицы, к которой относится заголовок';
    comment on column calc_correction_headers.position is 'Номер столбца, позиция в row_values';
    comment on column calc_correction_headers.header_value is 'Значение заголовка столбца';

    -- Перенос данных из массива в отдельную таблицу
    insert into calc_correction_headers(type_id, position, header_value)
    select calc_correction_types.id,
           header.position,
           header.value
    from calc_correction_types
    cross join lateral unnest(calc_correction_types.header_values)
               with ordinality as header(value, position)
    where calc_correction_types.header_values is not null;

    alter table calc_correction_types drop column header_values;
    end;

    begin
    update calc_correction_types
       set description = 'Таблица 2, Отрицательные температуры'
     where id = 8;

    update calc_correction_types
       set description = 'Таблица 2, Положительные температуры'
     where id = 9;

    -- Положительные температуры лежали в типе 7 вместе с направлением ветра ДМК.
    update calc_correction
       set type_id = 9
     where type_id = 7
       and cardinality(row_values) > 1;

    -- Прочерки в столбцах 40 и 50 заполняем null чтобы длина строки совпала с заголовком
    update calc_correction
       set row_values = array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]
     where type_id = 9;

    -- Высота 400, столбец 40 а было -39
    update calc_correction
       set row_values[13] = -38
     where type_id = 8
       and height_id = 2;

    -- ДМК, высота 1200, столбец 11 м/с а было 23
    update calc_correction
       set row_values[9] = 22
     where type_id = 6
       and height_id = 4;

    -- Переделываем направления в малых делениях угломера 1-00 это 100 
    update calc_correction
       set row_values = array[row_values[1] * 100]
     where type_id in (5, 7);
    end;

--Заполняем правильными данными
    begin
          -- Таблица 2, отрицательные значения
    insert into calc_correction(height_id, type_id, row_values)
    values(5, 8, array[-1, -2, -3, -3, -4, -4, -5, -6, -7, -7, -17, -25, -34, -42]),
          (6, 8, array[-1, -2, -3, -3, -4, -4, -5, -6, -6, -7, -16, -24, -32, -40]),
          (7, 8, array[-1, -2, -2, -3, -4, -4, -5, -5, -6, -7, -15, -23, -31, -38]),
          (8, 8, array[-1, -2, -2, -3, -4, -4, -4, -5, -5, -6, -15, -22, -30, -37]),
          (9, 8, array[-1, -2, -2, -3, -4, -4, -4, -4, -5, -6, -14, -20, -27, -34]);

    -- Таблица 2, положительные значения
    insert into calc_correction(height_id, type_id, row_values)
    values(5, 9, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]),
          (6, 9, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]),
          (7, 9, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]),
          (8, 9, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]),
          (9, 9, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]);

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

    -- Таблица 3, направление среднего ветра
    insert into calc_correction(height_id, type_id, row_values)
    values(5, 5, array[300]), (6, 5, array[300]), (7, 5, array[300]),
          (8, 5, array[400]), (9, 5, array[400]),
          (5, 7, array[400]), (6, 7, array[400]), (7, 7, array[400]),
          (8, 7, array[500]), (9, 7, array[500]);

    end;

    --Ну и кнш добавляем связи

    begin

    end;
end $$;

-- Расчет
do $$
begin

    -- Таблица  нужна расчёту 
    if to_regclass('public.calc_correction_temperature') is null then
        create table calc_correction_temperature
        (
            temperature numeric(8,2) not null primary key,
            correction  numeric(8,2) not null
        );

        insert into calc_correction_temperature(temperature, correction)
        values(0, 0.5), (5, 0.5), (10, 1), (20, 1), (25, 2), (30, 3.5), (40, 4.5);
    end if;

    -- коды таблиц процедура обращается к типам по смыслу
    alter table calc_correction_types add column if not exists code text;

    update calc_correction_types set code = 'temp_base'     where id = 1;
    update calc_correction_types set code = 'speed_base'    where id = 2;
    update calc_correction_types set code = 'dir_base'      where id = 3;
    update calc_correction_types set code = 'speed'         where id in (4, 6);
    update calc_correction_types set code = 'direction'     where id in (5, 7);
    update calc_correction_types set code = 'temp_negative' where id = 8;
    update calc_correction_types set code = 'temp_positive' where id = 9;

    comment on column calc_correction_types.code is 'Смысловой код таблицы для обращения из расчёта';

    alter table calc_correction_types
        add constraint uq_calc_correction_types_code unique (code, measurment_equipment_id);

end;
$$;


create or replace function public.my_interpolation_func(p_target_temp numeric)
returns public."interType"
language plpgsql
as $body$
declare
    var_result public."interType";
begin
    select temperature, correction
      into var_result.x0, var_result.y0
      from public.calc_correction_temperature
     where temperature <= p_target_temp
     order by temperature desc
     limit 1;

    select temperature, correction
      into var_result.x1, var_result.y1
      from public.calc_correction_temperature
     where temperature >= p_target_temp
     order by temperature asc
     limit 1;

    if var_result.x0 is null then
        var_result.x0 := var_result.x1;
        var_result.y0 := var_result.y1;
    end if;

    if var_result.x1 is null then
        var_result.x1 := var_result.x0;
        var_result.y1 := var_result.y0;
    end if;

    return var_result;
end;
$body$;


-- Идентификатор типа таблицы по смысловому коду и оборудованию
create or replace function public.fn_type_id(
    par_code         text,
    par_equipment_id integer default null
)
returns integer
language plpgsql
stable
as $body$
declare
    v_id integer;
begin
    select types.id
      into v_id
      from calc_correction_types as types
     where types.code = par_code
       and (par_equipment_id is null or types.measurment_equipment_id = par_equipment_id);

    if v_id is null then
        raise exception 'Не найден тип таблицы корректировок: %, оборудование %',
            par_code, par_equipment_id;
    end if;

    return v_id;
end;
$body$;


-- Строка корректировок по типу таблицы и высоте
create or replace function public.fn_calc_row(
    par_type_id   integer,
    par_height_id integer
)
returns integer[]
language plpgsql
stable
as $body$
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
$body$;



-- Среднее отклонение температуры по Таблице 2
create or replace function public.fn_temp_correction(
    par_params    input_params,
    par_height_id integer,
    out out_value integer,
    out out_code  integer
)
language plpgsql
stable
as $body$
declare
    v_deviation integer;
    v_type_id   integer;
    v_row       integer[];
    v_remainder integer;
    v_part      integer;
    v_position  integer;
begin
    -- dT0 = t0 + dTv - 15.9
    v_deviation := round(par_params.temperature
                         + public.calculate_interpolation(
                               par_params.temperature,
                               public.my_interpolation_func(par_params.temperature))
                         - fn_const('BASE_TEMPERATURE'));

    if v_deviation < 0 then
        v_type_id := fn_type_id('temp_negative');
    else
        v_type_id := fn_type_id('temp_positive');
    end if;

    v_row       := fn_calc_row(v_type_id, par_height_id);
    v_remainder := abs(v_deviation);
    out_value   := 0;

    while v_remainder > 0 loop

        select headers.header_value, headers.position
          into v_part, v_position
          from calc_correction_types as types
          join calc_correction_headers as headers
            on headers.type_id in (types.id, types.parent_id)
         where types.id = v_type_id
           and headers.header_value <= v_remainder
           and v_row[headers.position] is not null
         order by headers.header_value desc
         limit 1;

        if v_part is null then
            raise exception 'Не удалось разложить отклонение % по таблице %',
                v_deviation, v_type_id;
        end if;

        out_value   := out_value + v_row[v_position];
        v_remainder := v_remainder - v_part;
    end loop;

    -- отрицательное отклонение записывается как модуль плюс 50
    if v_deviation < 0 then
        out_code := 50 + abs(out_value);
    else
        out_code := out_value;
    end if;
end;
$body$;


-- Скорость среднего ветра по Таблице 3
create or replace function public.fn_speed_correction(
    par_params    input_params,
    par_height_id integer
)
returns integer
language plpgsql
stable
as $body$
declare
    v_type_id   integer;
    v_input     numeric;
    v_minimum   numeric;
    v_row       integer[];
    v_x0        numeric;
    v_x1        numeric;
    v_position0 integer;
    v_position1 integer;
begin
    v_type_id := fn_type_id('speed', par_params.equipment_type_id);
    v_input   := coalesce(par_params.wind_speed, par_params.bullet_drift);

    -- Порог слабого ветра это первый столбец таблицы
    select min(headers.header_value)
      into v_minimum
      from calc_correction_headers as headers
     where headers.type_id = v_type_id;

    if coalesce(v_input, 0) < v_minimum then
        return 0;
    end if;

    v_row := fn_calc_row(v_type_id, par_height_id);

    select headers.header_value, headers.position
      into v_x0, v_position0
      from calc_correction_headers as headers
     where headers.type_id = v_type_id
       and headers.header_value <= v_input
     order by headers.header_value desc
     limit 1;

    select headers.header_value, headers.position
      into v_x1, v_position1
      from calc_correction_headers as headers
     where headers.type_id = v_type_id
       and headers.header_value >= v_input
     order by headers.header_value
     limit 1;

    -- входное значение может попасть между столбцами
    if v_x1 is null then
        return v_row[v_position0];
    end if;

    return round(public.calculate_interpolation(
                     v_input,
                     row(v_x0, v_x1, v_row[v_position0], v_row[v_position1])::public."interType"
                 ))::integer;
end;
$body$;


-- Направление среднего ветра по Таблице 3
create or replace function public.fn_direction_correction(
    par_params    input_params,
    par_height_id integer
)
returns integer
language plpgsql
stable
as $body$
declare
    v_type_id  integer;
    v_input    numeric;
    v_minimum  numeric;
    v_delta    integer;
    v_circle   integer;
begin
    v_input := coalesce(par_params.wind_speed, par_params.bullet_drift);

    select min(headers.header_value)
      into v_minimum
      from calc_correction_headers as headers
     where headers.type_id = fn_type_id('speed', par_params.equipment_type_id);

    -- При слабом ветре места направления и скорости заполняются нулями
    if coalesce(v_input, 0) < v_minimum then
        return 0;
    end if;

    v_type_id := fn_type_id('direction', par_params.equipment_type_id);

    select corrections.row_values[1]
      into v_delta
      from calc_correction as corrections
     where corrections.type_id = v_type_id
       and corrections.height_id = par_height_id;

    -- Полный круг берём из границ параметра: максимум 59, а что делений будет 60
    select limits.max_value::integer + 1
      into v_circle
      from const_param_limits as limits
      join params
        on params.id = limits.param_id
     where params.name = 'Направление ветра';


    return mod(round(par_params.wind_direction)::integer
               + coalesce(v_delta, 0) / 100, v_circle);
end;
$body$;


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
as $body$
begin
    return format(
        'Высота: %s (%s), Откл. темп.: %s (%s), Направление: %s, Скорость: %s',
        par_height,
        lpad((par_height / 100)::text, 2, '0'),
        par_temp,
        lpad(par_temp_code::text, 2, '0'),
        lpad(par_direction::text, 2, '0'),
        lpad(par_speed::text, 2, '0')
    );
end;
$body$;


-- Процедура расчёта по всем стандартным высотам
create or replace procedure public.calc_meteo11(par_params input_params)
language plpgsql
as $body$
declare
    v_errors    text;
    v_value     integer;
    v_code      integer;
    v_direction integer;
    v_speed     integer;
    v_row       record;
begin
    v_errors := fn_validate_params(par_params);

    if v_errors <> '' then
        raise exception 'Ошибка входных параметров: %', v_errors;
    end if;

    raise notice 'dTv = %, dT0 = %',
        public.calculate_interpolation(
            par_params.temperature,
            public.my_interpolation_func(par_params.temperature)),
        round(par_params.temperature
              + public.calculate_interpolation(
                    par_params.temperature,
                    public.my_interpolation_func(par_params.temperature))
              - fn_const('BASE_TEMPERATURE'));

    for v_row in
        select heights.id     as height_id,
               heights.height as height_value
        from calc_correction_heights as heights
        order by heights.height
    loop
        select temp.out_value, temp.out_code
          into v_value, v_code
          from fn_temp_correction(par_params, v_row.height_id) as temp;

        v_speed     := fn_speed_correction(par_params, v_row.height_id);
        v_direction := fn_direction_correction(par_params, v_row.height_id);

        raise notice '%', fn_format_row(v_row.height_value, v_value, v_code,
                                        v_direction, v_speed);
    end loop;
end;
$body$;

comment on procedure public.calc_meteo11(input_params)
    is 'Расчёт приближенного бюллетеня Метео-11 по стандартным высотам';