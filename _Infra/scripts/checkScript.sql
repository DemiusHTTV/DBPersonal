-- 1. Каждый пользователь имеет одинаковое количество измерений?
--    Во всех строках cnt_btchs должно быть одно и то же значение.
select * from public.employees as t1
left join (
select emploee_id , count(*) as cnt_btchs
from public.measurment_baths
group by emploee_id
)as inner_t1 on t1.id = inner_t1.emploee_id
order by t1.id;


-- 2. У нас нет пустых пачек измерения?
--    Запрос возвращает только пачки без параметров: пустой результат = нарушений нет.
select * from public.measurment_baths as t1
left join
(select measurment_bath_id, count(*) as cnt_btchs
from public.measurment_input_params
group by measurment_bath_id
) as inner_t1 on t1.id = inner_t1.measurment_bath_id
where inner_t1.measurment_bath_id is null
order by t1.id;


-- 3. Каждая пачка измерений содержит полное количество параметров?
--    Запрос возвращает только пачки с неполным набором: пустой результат = нарушений нет.
select * from public.measurment_baths as t1
inner join
(

    select measurment_bath_id, count(*) as cnt_records
    from public.measurment_input_params
    group by measurment_bath_id
) as inner_t2 on t1.id = inner_t2.measurment_bath_id
where inner_t2.cnt_records != 5;


-- 4. Все значения, которые сформировал генератор, корректны и в рамках нужных диапазонов?
--    Подзапрос собирает все некорректные значения и группирует их по пачкам,
--    внешний запрос выводит сами проблемные пачки: пустой результат = нарушений нет.
select t1.id, t1.emploee_id, t1.measurment_type_id, t1.started,
       inner_t1.cnt_bad_values, inner_t1.bad_params
from public.measurment_baths as t1
inner join (
    select t2.measurment_bath_id,
           count(*) as cnt_bad_values,
           string_agg(t3.name, ', ' order by t3.id) as bad_params
    from public.measurment_input_params as t2
    inner join public.type_of_params as t3
        on t3.id = t2.type_of_params_id
    where
           t2.value is null
           -- Высота, м: целое от 0 до 2000
        or (t3.id = 1 and (t2.value not between 0 and 2000
                           or t2.value != trunc(t2.value)))
           -- Температура, °C: от -58 до 58, один знак после запятой
        or (t3.id = 2 and (t2.value not between -58 and 58
                           or t2.value * 10 != trunc(t2.value * 10)))
           -- Давление, мм рт. ст.: целое от 500 до 900
        or (t3.id = 3 and (t2.value not between 500 and 900
                           or t2.value != trunc(t2.value)))
           -- Направление ветра, °: целое от 0 до 359
        or (t3.id = 4 and (t2.value not between 0 and 359
                           or t2.value != trunc(t2.value)))
           -- Скорость ветра, м/с: целое от 0 до 15
        or (t3.id = 5 and (t2.value not between 0 and 15
                           or t2.value != trunc(t2.value)))
    group by t2.measurment_bath_id
) as inner_t1 on inner_t1.measurment_bath_id = t1.id
order by t1.id;


-- 5. Все единицы измерения верны и корректны по отношению к указанным параметрам?
--    Для каждого типа параметра задаём ожидаемую единицу измерения и её физическую
--    величину (базовую единицу): температура должна измеряться в градусах Цельсия,
--    давление - в мм рт. ст. и т.д.
--    Запрос возвращает только расхождения: пустой результат = нарушений нет.
select t1.id, t1.name as parameter_name, t2.name as unit_name, t3.name as base_unit_name
from public.type_of_params as t1
left join public.units_of_measurement as t2 on t2.id = t1.unit_id
left join public.base_unit as t3 on t3.id = t2.base_unit_id
left join (
    values ('Высота',            'м',          'Метр'),
           ('Температура',       '°C',         'Градус Цельсия'),
           ('Давление',          'мм рт. ст.', 'Паскаль'),
           ('Направление ветра', '°',          'Градус (угол)'),
           ('Скорость ветра',    'м/с',        'Метр в секунду')
) as inner_t1 (param_name, unit_name, base_unit_name)
    on  inner_t1.param_name     = t1.name
    and inner_t1.unit_name      = t2.name
    and inner_t1.base_unit_name = t3.name
where inner_t1.param_name is null
order by t1.id;


-- 5.1. Справочная выборка к запросу 5: полное сопоставление
--      параметр - единица измерения - базовая единица.
select t1.id, t1.name as parameter_name, t2.name as unit_name, t3.name as base_unit_name
from public.type_of_params as t1
left join public.units_of_measurement as t2 on t2.id = t1.unit_id
left join public.base_unit as t3 on t3.id = t2.base_unit_id
order by t1.id;
