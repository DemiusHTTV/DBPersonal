do $$
begin
    -- const_param_limits
    drop table if exists const_param_limits cascade;
    create table const_param_limits (
        param_id        integer      not null,
        min_value       numeric(8,2),
        max_value       numeric(8,2),
        default_value   numeric(8,2) not null,
        fraction_digits smallint     not null default 0
    );

    insert into const_param_limits (param_id, min_value, max_value, default_value, fraction_digits) values
        (1, null, null, 100, 0),
        (2,  -58,   58,  15, 1),
        (3,  500,  900, 750, 0),
        (4,    0,   59,   0, 0),
        (5,    0,   15,   0, 0),
        (6,    0,  150,   0, 0);

    -- const_meteo
    drop table if exists const_meteo cascade;
    create table const_meteo (
        code        varchar(30)  not null,
        value       numeric(8,2) not null,
        description text         not null
    );

    insert into const_meteo (code, value, description) values
        ('BASE_PRESSURE',          750,  'Табличное наземное давление, мм рт. ст.'),
        ('BASE_TEMPERATURE',       15.9, 'Табличная приземная виртуальная температура, °C'),
        ('PRESSURE_NEG_OFFSET',    500,  'Смещение записи отрицательного БББ: -7 пишется как 507'),
        ('TEMPERATURE_NEG_OFFSET', 50,   'Смещение записи отрицательного ТТ: -13 пишется как 63');

    alter table const_param_limits
        add constraint pk_const_param_limits primary key (param_id),
        add constraint fk_const_param_limits_param foreign key (param_id) references params (id),
        add constraint ck_const_param_limits_range
            check (min_value is null or max_value is null or min_value <= max_value);

    alter table const_meteo
        add constraint pk_const_meteo primary key (code);

    -- fn_const
    create or replace function fn_const(p_code varchar)
    returns numeric
    language plpgsql
    stable
    as $body$
    declare
        v_value numeric;
    begin
        select const_meteo.value
          into v_value
          from const_meteo
         where const_meteo.code = p_code;

        if v_value is null then
            raise exception 'константа «%» не найдена в const_meteo', p_code;
        end if;

        return v_value;
    end;
    $body$;
end;
$$;
