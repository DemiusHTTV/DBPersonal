begin;

do $structure$
begin
    drop table if exists measurements cascade;
    drop table if exists equipment_params cascade;
    drop table if exists packs cascade;
    drop table if exists users cascade;
    drop table if exists positions cascade;
    drop table if exists params cascade;
    drop table if exists equipment_types cascade;
    drop table if exists temperature_corrections cascade;

    drop sequence if exists measurements_seq cascade;
    drop sequence if exists packs_seq cascade;
    drop sequence if exists users_seq cascade;
    drop sequence if exists positions_seq cascade;
    drop sequence if exists params_seq cascade;
    drop sequence if exists equipment_types_seq cascade;
    drop sequence if exists temperature_corrections_seq cascade;

    create sequence equipment_types_seq start with 1 increment by 1;
    create sequence params_seq start with 1 increment by 1;
    create sequence positions_seq start with 1 increment by 1;
    create sequence users_seq start with 1 increment by 1;
    create sequence packs_seq start with 1 increment by 1;
    create sequence measurements_seq start with 1 increment by 1;
    create sequence temperature_corrections_seq start with 1 increment by 1;

    create table equipment_types (
        id         integer     not null default nextval('equipment_types_seq'),
        short_name varchar(10) not null,
        name       text        not null
    );

    create table params (
        id   integer     not null default nextval('params_seq'),
        name text        not null,
        unit varchar(20) not null
    );

    create table equipment_params (
        equipment_type_id integer not null,
        param_id          integer not null
    );

    create table positions (
        id                integer not null default nextval('positions_seq'),
        name              text    not null,
        equipment_type_id integer
    );

    create table users (
        id          integer not null default nextval('users_seq'),
        full_name   text    not null,
        birthday    date,
        position_id integer not null
    );

    create table packs (
        id                integer     not null default nextval('packs_seq'),
        number            varchar(30) not null,
        user_id           integer     not null,
        equipment_type_id integer     not null,
        created_date      timestamp   not null
    );

    create table measurements (
        id       integer      not null default nextval('measurements_seq'),
        pack_id  integer      not null,
        param_id integer      not null,
        value    numeric(8,2) not null
    );

    create table temperature_corrections (
        id         integer      not null default nextval('temperature_corrections_seq'),
        label      varchar(20)  not null,
        t_from     numeric(4,1),
        t_to       numeric(4,1) not null,
        correction numeric(3,1) not null
    );
end;
$structure$;

commit;


begin;

do $data$
begin
    insert into equipment_types (id, short_name, name) values
        (1, 'ДМК', 'Десантный метеорологический комплект'),
        (2, 'ВР',  'Ветровое ружьё');

    insert into params (id, name, unit) values
        (1, 'Высота метеопоста',    'м'),
        (2, 'Температура',          '°C'),
        (3, 'Давление',             'мм рт. ст.'),
        (4, 'Направление ветра',    'б. д. у.'),
        (5, 'Скорость ветра',       'м/с'),
        (6, 'Дальность сноса пуль', 'м');

    insert into equipment_params (equipment_type_id, param_id) values
        (1, 1), (1, 2), (1, 3), (1, 4), (1, 5),
        (2, 1), (2, 2), (2, 3), (2, 4), (2, 6);

    insert into positions (id, name, equipment_type_id) values
        (1, 'Метеоролог',               1),
        (2, 'Оператор ветрового ружья', 2),
        (3, 'Начальник метеопоста',     1);

    insert into users (id, full_name, birthday, position_id) values
        (1, 'Иванов Иван Сергеевич',   '1989-03-14', 1),
        (2, 'Петрова Анна Викторовна', '1994-07-02', 2),
        (3, 'Сидоров Олег Николаевич', '1978-11-30', 3);

    insert into packs (id, number, user_id, equipment_type_id, created_date) values
        (1, 'Метео-11 24093', 1, 1, '2026-10-24 09:30:00'),
        (2, 'Метео-11 24141', 1, 1, '2026-10-24 14:10:00'),
        (3, 'Метео-11 25100', 2, 2, '2026-10-25 10:00:00'),
        (4, 'Метео-11 25154', 3, 1, '2026-10-25 15:40:00');

    insert into measurements (id, pack_id, param_id, value) values
        (1,  1, 1, 240), (2,  1, 2, 15.4), (3,  1, 3, 748), (4,  1, 4, 30), (5,  1, 5, 4),
        (6,  2, 1, 240), (7,  2, 2, 17.1), (8,  2, 3, 747), (9,  2, 4, 32), (10, 2, 5, 6),
        (11, 3, 1, 240), (12, 3, 2, 16.8), (13, 3, 3, 751), (14, 3, 4, 28), (15, 3, 6, 12),
        (16, 4, 1, 240), (17, 4, 2, 3.0),  (18, 4, 3, 755), (19, 4, 4, 15), (20, 4, 5, 5);

    insert into temperature_corrections (id, label, t_from, t_to, correction) values
        (1, 'Ниже 0', null,  0.0, 0.0),
        (2, '0 - 5',   0.0,  5.0, 0.5),
        (3, '10 - 15', 10.0, 15.0, 1.0),
        (4, '20',      20.0, 20.0, 1.5),
        (5, '25',      25.0, 25.0, 2.0),
        (6, '30',      30.0, 30.0, 3.5),
        (7, '40',      40.0, 40.0, 4.5);

    perform setval('equipment_types_seq',         (select max(id) from equipment_types)         + 1, false);
    perform setval('params_seq',                  (select max(id) from params)                  + 1, false);
    perform setval('positions_seq',               (select max(id) from positions)               + 1, false);
    perform setval('users_seq',                   (select max(id) from users)                   + 1, false);
    perform setval('packs_seq',                   (select max(id) from packs)                   + 1, false);
    perform setval('measurements_seq',            (select max(id) from measurements)            + 1, false);
    perform setval('temperature_corrections_seq', (select max(id) from temperature_corrections) + 1, false);
end;
$data$;

commit;


begin;

do $constraints$
begin
    alter table equipment_types         add constraint pk_equipment_types         primary key (id);
    alter table params                  add constraint pk_params                  primary key (id);
    alter table positions               add constraint pk_positions               primary key (id);
    alter table users                   add constraint pk_users                   primary key (id);
    alter table packs                   add constraint pk_packs                   primary key (id);
    alter table measurements            add constraint pk_measurements            primary key (id);
    alter table temperature_corrections add constraint pk_temperature_corrections primary key (id);
    alter table equipment_params        add constraint pk_equipment_params        primary key (equipment_type_id, param_id);

    alter sequence equipment_types_seq         owned by equipment_types.id;
    alter sequence params_seq                  owned by params.id;
    alter sequence positions_seq               owned by positions.id;
    alter sequence users_seq                   owned by users.id;
    alter sequence packs_seq                   owned by packs.id;
    alter sequence measurements_seq            owned by measurements.id;
    alter sequence temperature_corrections_seq owned by temperature_corrections.id;

    alter table equipment_params
        add constraint fk_equipment_params_equipment_type
            foreign key (equipment_type_id) references equipment_types (id) on delete cascade,
        add constraint fk_equipment_params_param
            foreign key (param_id) references params (id) on delete restrict;

    alter table positions
        add constraint fk_positions_equipment_type
            foreign key (equipment_type_id) references equipment_types (id) on delete set null;

    alter table users
        add constraint fk_users_position
            foreign key (position_id) references positions (id) on delete restrict;

    alter table packs
        add constraint fk_packs_user
            foreign key (user_id) references users (id) on delete restrict,
        add constraint fk_packs_equipment_type
            foreign key (equipment_type_id) references equipment_types (id) on delete restrict;

    alter table measurements
        add constraint fk_measurements_pack
            foreign key (pack_id) references packs (id) on delete cascade,
        add constraint fk_measurements_param
            foreign key (param_id) references params (id) on delete restrict;

    alter table equipment_types add constraint uq_equipment_types_short_name unique (short_name);
    alter table params          add constraint uq_params_name                unique (name);
    alter table positions       add constraint uq_positions_name             unique (name);
    alter table packs           add constraint uq_packs_number               unique (number);
    alter table measurements    add constraint uq_measurements_pack_param    unique (pack_id, param_id);

    alter table temperature_corrections
        add constraint ck_temperature_corrections_bounds
            check (t_from is null or t_from <= t_to),
        add constraint ck_temperature_corrections_value
            check (correction >= 0);

    alter table packs
        add constraint ck_packs_created_date
            check (created_date >= timestamp '2000-01-01 00:00:00');
end;
$constraints$;

commit;


select packs.created_date                 as "Дата замера",
       packs.number                       as "Пачка",
       users.full_name                    as "Метеоролог",
       positions.name                     as "Должность",
       equipment_types.short_name         as "Оборудование",
       params.name || ', ' || params.unit as "Параметр, ед. изм.",
       measurements.value                 as "Значение"
from measurements
join packs
  on packs.id = measurements.pack_id
join params
  on params.id = measurements.param_id
join users
  on users.id = packs.user_id
join positions
  on positions.id = users.position_id
join equipment_types
  on equipment_types.id = packs.equipment_type_id
order by packs.created_date, packs.id, params.id;