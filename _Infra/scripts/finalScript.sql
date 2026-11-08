-- Домашняя работа от 2026-11-02
do $$
begin

    begin
        drop table if exists calc_correction cascade;
        drop table if exists calc_correction_headers cascade;
        drop table if exists calc_correction_types cascade;
        drop table if exists calc_correction_heights cascade;

        drop sequence if exists calc_correction_seq;
        drop sequence if exists calc_correction_headers_seq;
        drop sequence if exists calc_correction_types_seq;
        drop sequence if exists calc_correction_height_seq;
    end;

    -- Структуры
    begin

        create sequence calc_correction_height_seq;
        create table calc_correction_heights
        (
            id     integer not null primary key default nextval('public.calc_correction_height_seq'),
            height integer not null
        );

        comment on table calc_correction_heights is 'Стандартные высоты метеобюллетеня';
        comment on column calc_correction_heights.id is 'Уникальный код';
        comment on column calc_correction_heights.height is 'Высота над уровнем моря, м';

        create sequence calc_correction_types_seq;
        create table calc_correction_types
        (
            id                      integer not null primary key default nextval('public.calc_correction_types_seq'),
            parent_id               integer,
            measurment_equipment_id integer,
            description             text not null
        );

        comment on table calc_correction_types is 'Справочник типов таблиц корректировок';
        comment on column calc_correction_types.id is 'Уникальный код';
        comment on column calc_correction_types.parent_id is 'Родительский тип таблицы';
        comment on column calc_correction_types.measurment_equipment_id is 'Тип измерительного оборудования';
        comment on column calc_correction_types.description is 'Описание к таблице';

        create sequence calc_correction_headers_seq;
        create table calc_correction_headers
        (
            id           integer not null primary key default nextval('public.calc_correction_headers_seq'),
            type_id      integer not null,
            position     integer not null,
            header_value integer not null
        );

        comment on table calc_correction_headers is 'Заголовки столбцов таблиц корректировок';
        comment on column calc_correction_headers.id is 'Уникальный код';
        comment on column calc_correction_headers.type_id is 'Тип таблицы, к которой относится заголовок';
        comment on column calc_correction_headers.position is 'Номер столбца, позиция в row_values';
        comment on column calc_correction_headers.header_value is 'Значение заголовка столбца';

        create sequence calc_correction_seq;
        create table calc_correction
        (
            id         integer not null primary key default nextval('public.calc_correction_seq'),
            height_id  integer not null,
            type_id    integer not null,
            row_values integer[] not null
        );

        comment on table calc_correction is 'Универсальная таблица корректировок';
        comment on column calc_correction.id is 'Уникальный код';
        comment on column calc_correction.height_id is 'Код высоты';
        comment on column calc_correction.type_id is 'Код типа таблиц';
        comment on column calc_correction.row_values is 'Значения строки, позиции соответствуют calc_correction_headers.position';

    end;

    -- Справочники
    begin

        insert into calc_correction_heights(height)
        values(200),(400),(800),(1200),(1600),(2000),(2400),(3000),(4000);

        insert into calc_correction_types(description, parent_id, measurment_equipment_id)
        values('Таблица 2',                                    null, null),  -- 1
              ('Таблица 3, скорость среднего ветра',           null, null),  -- 2
              ('Таблица 3, направление среднего ветра',        null, null),  -- 3
              ('Таблица 3, Скорость среднего ветра (ВР)',         2,    2),  -- 4
              ('Таблица 3, Направление среднего ветра (ВР)',      3,    2),  -- 5
              ('Таблица 3, Скорость среднего ветра (ДМК)',        2,    1),  -- 6
              ('Таблица 3, Направление среднего ветра (ДМК)',     3,    1),  -- 7
              ('Таблица 2, Отрицательные температуры',            1, null),  -- 8
              ('Таблица 2, Положительные температуры',            1, null);  -- 9

        -- Заголовок Таблицы 2 привязан к родительскому типу 1:
        insert into calc_correction_headers(type_id, position, header_value)
        values(1, 1, 1),  (1, 2, 2),  (1, 3, 3),  (1, 4, 4),  (1, 5, 5),
              (1, 6, 6),  (1, 7, 7),  (1, 8, 8),  (1, 9, 9),  (1, 10, 10),
              (1, 11, 20),(1, 12, 30),(1, 13, 40),(1, 14, 50);

        -- Дальность сноса ветровых пуль, м
        insert into calc_correction_headers(type_id, position, header_value)
        values(4, 1, 40),  (4, 2, 50),  (4, 3, 60),  (4, 4, 70),
              (4, 5, 80),  (4, 6, 90),  (4, 7, 100), (4, 8, 110),
              (4, 9, 120), (4, 10, 130),(4, 11, 140),(4, 12, 150);

        -- Скорость приземного ветра, м/с
        insert into calc_correction_headers(type_id, position, header_value)
        values(6, 1, 3),  (6, 2, 4),  (6, 3, 5),  (6, 4, 6),  (6, 5, 7),
              (6, 6, 8),  (6, 7, 9),  (6, 8, 10), (6, 9, 11), (6, 10, 12),
              (6, 11, 13),(6, 12, 14),(6, 13, 15);

    end;

    -- Таблица 2, отрицательные значения (числитель дроби)
    begin
        insert into calc_correction(height_id, type_id, row_values)
        values(1, 8, array[-1, -2, -3, -4, -5, -6, -7, -8, -8, -9, -20, -29, -39, -49]),
              (2, 8, array[-1, -2, -3, -4, -5, -6, -6, -7, -8, -9, -19, -29, -38, -48]),
              (3, 8, array[-1, -2, -3, -4, -5, -6, -6, -7, -7, -8, -18, -28, -37, -46]),
              (4, 8, array[-1, -2, -3, -4, -4, -5, -5, -6, -7, -8, -17, -26, -35, -44]),
              (5, 8, array[-1, -2, -3, -3, -4, -4, -5, -6, -7, -7, -17, -25, -34, -42]),
              (6, 8, array[-1, -2, -3, -3, -4, -4, -5, -6, -6, -7, -16, -24, -32, -40]),
              (7, 8, array[-1, -2, -2, -3, -4, -4, -5, -5, -6, -7, -15, -23, -31, -38]),
              (8, 8, array[-1, -2, -2, -3, -4, -4, -4, -5, -5, -6, -15, -22, -30, -37]),
              (9, 8, array[-1, -2, -2, -3, -4, -4, -4, -4, -5, -6, -14, -20, -27, -34]);
    end;

    -- Таблица 2, положительные значения (знаменатель дроби).

    begin
        insert into calc_correction(height_id, type_id, row_values)
        values(1, 9, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]),
              (2, 9, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]),
              (3, 9, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]),
              (4, 9, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]),
              (5, 9, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]),
              (6, 9, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]),
              (7, 9, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]),
              (8, 9, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]),
              (9, 9, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, null, null]);
    end;

    -- Таблица 3, скорость среднего ветра (ВР), м/с
    begin
        insert into calc_correction(height_id, type_id, row_values)
        values(1, 4, array[3, 4, 5, 6, 7, 7, 8, 9, 10, 11, 12, 12]),
              (2, 4, array[4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]),
              (3, 4, array[4, 5, 6, 7, 8, 9, 10, 11, 13, 14, 15, 16]),
              (4, 4, array[4, 5, 7, 8, 8, 9, 11, 12, 13, 15, 15, 16]),
              (5, 4, array[4, 6, 7, 8, 9, 10, 11, 13, 14, 15, 17, 17]),
              (6, 4, array[4, 6, 7, 8, 9, 10, 11, 13, 14, 16, 17, 18]),
              (7, 4, array[4, 6, 8, 9, 9, 10, 12, 14, 15, 16, 18, 19]),
              (8, 4, array[5, 6, 8, 9, 10, 11, 12, 14, 15, 17, 18, 19]),
              (9, 4, array[5, 6, 8, 9, 10, 11, 12, 14, 16, 18, 19, 20]);
    end;

    -- Таблица 3, скорость среднего ветра (ДМК), м/с
    begin
        insert into calc_correction(height_id, type_id, row_values)
        values(1, 6, array[4, 6, 8, 9, 10, 12, 14, 15, 16, 18, 20, 21, 22]),
              (2, 6, array[5, 7, 10, 11, 12, 14, 17, 18, 20, 22, 23, 25, 27]),
              (3, 6, array[5, 8, 10, 11, 13, 15, 18, 19, 21, 23, 25, 27, 28]),
              (4, 6, array[5, 8, 11, 12, 13, 16, 19, 20, 22, 24, 26, 28, 30]),
              (5, 6, array[6, 8, 11, 13, 14, 17, 20, 21, 23, 25, 27, 29, 32]),
              (6, 6, array[6, 9, 11, 13, 14, 17, 20, 21, 24, 26, 28, 30, 32]),
              (7, 6, array[6, 9, 12, 14, 15, 18, 21, 22, 25, 27, 29, 32, 34]),
              (8, 6, array[6, 9, 12, 14, 15, 18, 21, 23, 25, 28, 30, 32, 36]),
              (9, 6, array[6, 10, 12, 14, 16, 19, 22, 24, 26, 29, 32, 34, 36]);
    end;

    -- Таблица 3, приращение направления среднего ветра.

    begin
        insert into calc_correction(height_id, type_id, row_values)
        values(1, 5, array[0]),   (2, 5, array[100]), (3, 5, array[200]),
              (4, 5, array[200]), (5, 5, array[300]), (6, 5, array[300]),
              (7, 5, array[300]), (8, 5, array[400]), (9, 5, array[400]),
              (1, 7, array[100]), (2, 7, array[200]), (3, 7, array[300]),
              (4, 7, array[300]), (5, 7, array[400]), (6, 7, array[400]),
              (7, 7, array[400]), (8, 7, array[500]), (9, 7, array[500]);
    end;

    -- Связи и ограничения
    begin
        alter table calc_correction_heights
            add constraint uq_calc_correction_heights unique (height);

        alter table calc_correction_types
            add constraint fk_calc_correction_types_parent
                foreign key (parent_id) references calc_correction_types (id),
            add constraint fk_calc_correction_types_equipment
                foreign key (measurment_equipment_id) references equipment_types (id);

        alter table calc_correction_headers
            add constraint fk_calc_correction_headers_type
                foreign key (type_id) references calc_correction_types (id) on delete cascade,
            add constraint uq_calc_correction_headers unique (type_id, position),
            add constraint ck_calc_correction_headers_position check (position > 0);

        alter table calc_correction
            add constraint fk_calc_correction_height
                foreign key (height_id) references calc_correction_heights (id),
            add constraint fk_calc_correction_type
                foreign key (type_id) references calc_correction_types (id),
            add constraint uq_calc_correction unique (height_id, type_id);
    end;

end;
$$;