select row_number() over (order by objects.sort, objects.name) as "№",
       objects.name                                            as "Наименование",
       objects.caption                                         as "Тип"
from (
        select tables.table_name as name,
               ref.caption,
               ref.sort
        from information_schema.tables
        join (values ('BASE TABLE', 'Таблица',       1),
                     ('VIEW',       'Представление', 2)) as ref(code, caption, sort)
          on ref.code = tables.table_type
        where tables.table_catalog = 'LocalBD'
          and tables.table_schema = 'public'

        union all

        select sequences.sequence_name,
               ref.caption,
               ref.sort
        from information_schema.sequences
        join (values ('Последовательность', 3)) as ref(caption, sort)
          on true
        where sequences.sequence_catalog = 'LocalBD'
          and sequences.sequence_schema = 'public'

        union all

        select table_constraints.constraint_name,
               ref.caption,
               ref.sort
        from information_schema.table_constraints
        join (values ('PRIMARY KEY', 'Первичный ключ',          4),
                     ('FOREIGN KEY', 'Внешний ключ',            5),
                     ('UNIQUE',      'Уникальность',            6),
                     ('CHECK',       'Проверочное ограничение', 7)) as ref(code, caption, sort)
          on ref.code = table_constraints.constraint_type
        where table_constraints.constraint_catalog = 'LocalBD'
          and table_constraints.table_schema = 'public'
          and table_constraints.constraint_name not like '%\_not\_null'
     ) as objects;
