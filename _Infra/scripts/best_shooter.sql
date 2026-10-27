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
select rank() over (order by count(*) filter (where validated.errors <> '')) as "Место",
       users.full_name                                  as "Пользователь",
       positions.name                                   as "Должность",
       count(*)                                         as "Пачек",
       count(*) filter (where validated.errors <> '')   as "Ошибок"
from validated
join users
  on users.id = validated.user_id
join positions
  on positions.id = users.position_id
group by users.full_name, positions.name
order by count(*) filter (where validated.errors <> ''), users.full_name;
