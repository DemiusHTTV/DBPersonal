select * from public.employees as t1
inner join (
select emploee_id , count(*) as cnt_btchs
from public.measurment_baths
group by emploee_id
)as inner_t1 on t1.id = inner_t1.emploee_id
order by t1.id;


select * from public.measurment_baths as t1
left join
(select measurment_bath_id, count(*) as cnt_btchs
from public.measurment_input_params
group by measurment_bath_id
) as inner_t1 on t1.id = inner_t1.measurment_bath_id
order by t1.id;



select * from public.measurment_baths as t1
inner join
(

    select measurment_bath_id, count(*) as cnt_records
    from public.measurment_input_params
    group by measurment_bath_id
) as inner_t2 on t1.id = inner_t2.measurment_bath_id
where inner_t2.cnt_records != 5;


select t1.id, t1.measurment_bath_id, t2.name, t1.value
from public.measurment_input_params as t1
inner join public.type_of_params as t2
    on t2.id = t1.type_of_params_id
where
       t1.value is null
     
    or (t2.id = 1 and t1.value != trunc(t1.value))
       -- Температура: от -58 до 58, один знак после запятой
    or (t2.id = 2 and (t1.value not between -58 and 58
                       or t1.value * 10 != trunc(t1.value * 10)))
       -- Давление: целое от 500 до 900
    or (t2.id = 3 and (t1.value not between 500 and 900
                       or t1.value != trunc(t1.value)))
       -- Направление ветра: целое от 0 до 59
    or (t2.id = 4 and (t1.value not between 0 and 59
                       or t1.value != trunc(t1.value)))
       -- Скорость ветра: целое от 0 до 15
    or (t2.id = 5 and (t1.value not between 0 and 15
                       or t1.value != trunc(t1.value)))
       -- Дальность сноса пуль: целое от 0 до 150
    or (t2.id = 6 and (t1.value not between 0 and 150
                       or t1.value != trunc(t1.value)));


select t1.id, t1.name as parameter_name, t2.name as unit_name, t3.name as base_unit_name
from public.type_of_params as t1
left join public.units_of_measurement as t2 on t2.id = t1.unit_id
left join public.base_unit as t3 on t3.id = t2.base_unit_id
order by t1.id;