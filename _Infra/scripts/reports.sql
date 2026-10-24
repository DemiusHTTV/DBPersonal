do $$
declare
    v_pack_id integer;
begin
    delete from packs where packs.number like 'Метео-11 ОШ%';

    v_pack_id := nextval('packs_seq');
    insert into packs (id, number, user_id, equipment_type_id, created_date)
    values (v_pack_id, 'Метео-11 ОШ-1', 1, 1, '2026-10-26 08:20:00');

    insert into measurements (id, pack_id, param_id, value) values
        (nextval('measurements_seq'), v_pack_id, 1, 240),
        (nextval('measurements_seq'), v_pack_id, 2, 70.0),
        (nextval('measurements_seq'), v_pack_id, 3, 1000),
        (nextval('measurements_seq'), v_pack_id, 4, 30),
        (nextval('measurements_seq'), v_pack_id, 5, 4);

    v_pack_id := nextval('packs_seq');
    insert into packs (id, number, user_id, equipment_type_id, created_date)
    values (v_pack_id, 'Метео-11 ОШ-2', 3, 1, '2026-10-26 12:40:00');

    insert into measurements (id, pack_id, param_id, value) values
        (nextval('measurements_seq'), v_pack_id, 1, 240),
        (nextval('measurements_seq'), v_pack_id, 2, 15.44),
        (nextval('measurements_seq'), v_pack_id, 3, 752),
        (nextval('measurements_seq'), v_pack_id, 4, 99),
        (nextval('measurements_seq'), v_pack_id, 5, 7);

    v_pack_id := nextval('packs_seq');
    insert into packs (id, number, user_id, equipment_type_id, created_date)
    values (v_pack_id, 'Метео-11 ОШ-3', 2, 2, '2026-10-26 16:10:00');

    insert into measurements (id, pack_id, param_id, value) values
        (nextval('measurements_seq'), v_pack_id, 1, 240),
        (nextval('measurements_seq'), v_pack_id, 2, 16.8),
        (nextval('measurements_seq'), v_pack_id, 4, 28),
        (nextval('measurements_seq'), v_pack_id, 6, 200);
end;
$$;


-- Список параметров с ошибками
with pack_params as (
    select packs.id      as pack_id,
           packs.user_id,
           packs.equipment_type_id,
           max(measurements.value) filter (where measurements.param_id = 1) as height,
           max(measurements.value) filter (where measurements.param_id = 2) as temperature,
           max(measurements.value) filter (where measurements.param_id = 3) as pressure,
           max(measurements.value) filter (where measurements.param_id = 4) as wind_direction,
           max(measurements.value) filter (where measurements.param_id = 5) as wind_speed,
           max(measurements.value) filter (where measurements.param_id = 6) as bullet_drift
    from packs
    join measurements
      on measurements.pack_id = packs.id
    group by packs.id, packs.user_id, packs.equipment_type_id
),
validated as (
    select pack_params.*,
           fn_validate_params(
               row(pack_params.equipment_type_id,
                   pack_params.height,
                   pack_params.temperature,
                   pack_params.pressure,
                   pack_params.wind_direction,
                   pack_params.wind_speed,
                   pack_params.bullet_drift)::input_params
           ) as errors
    from pack_params
)
select validated.pack_id          as "№",
       equipment_types.short_name as "Тип оборудования",
       validated.height           as "Высота метеопоста",
       validated.temperature      as "Температура",
       validated.pressure         as "Давление",
       validated.wind_direction   as "Направление ветра",
       validated.wind_speed       as "Скорость ветра",
       validated.bullet_drift     as "Дальность сноса пуль",
       validated.errors <> ''     as "Флаг: Есть ошибка",
       validated.errors           as "Описание ошибки"
from validated
join equipment_types
  on equipment_types.id = validated.equipment_type_id
order by validated.pack_id;


-- Лучший стрелок
with pack_params as (
    select packs.id      as pack_id,
           packs.user_id,
           packs.equipment_type_id,
           max(measurements.value) filter (where measurements.param_id = 1) as height,
           max(measurements.value) filter (where measurements.param_id = 2) as temperature,
           max(measurements.value) filter (where measurements.param_id = 3) as pressure,
           max(measurements.value) filter (where measurements.param_id = 4) as wind_direction,
           max(measurements.value) filter (where measurements.param_id = 5) as wind_speed,
           max(measurements.value) filter (where measurements.param_id = 6) as bullet_drift
    from packs
    join measurements
      on measurements.pack_id = packs.id
    group by packs.id, packs.user_id, packs.equipment_type_id
),
validated as (
    select pack_params.user_id,
           fn_validate_params(
               row(pack_params.equipment_type_id,
                   pack_params.height,
                   pack_params.temperature,
                   pack_params.pressure,
                   pack_params.wind_direction,
                   pack_params.wind_speed,
                   pack_params.bullet_drift)::input_params
           ) as errors
    from pack_params
),
error_counts as (
    select validated.user_id,
           coalesce(array_length(string_to_array(nullif(validated.errors, ''), '; '), 1), 0) as error_count
    from validated
)
select rank() over (order by sum(error_counts.error_count)) as "Место",
       users.full_name                                      as "Пользователь",
       positions.name                                       as "Должность",
       count(*)                                             as "Пачек",
       sum(error_counts.error_count)                        as "Ошибок"
from error_counts
join users
  on users.id = error_counts.user_id
join positions
  on positions.id = users.position_id
group by users.full_name, positions.name
order by sum(error_counts.error_count), users.full_name;
