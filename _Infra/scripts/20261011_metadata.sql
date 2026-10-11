SELECT row_number() over (ORDER BY objects.sort, objects.name) AS "№",
       objects.name                                            AS "Наименование",
       objects.caption                                         AS "Тип"
FROM (
        SELECT tables.table_name AS name,
               ref.caption,
               ref.sort
        FROM information_schema.tables
        JOIN (values ('BASE TABLE', 'Таблица',       1),
                     ('VIEW',       'Представление', 2)) AS ref(code, caption, sort)
          ON ref.code = tables.table_type
        WHERE tables.table_schema = 'public'

        UNION ALL

        SELECT sequences.sequence_name,
               ref.caption,
               ref.sort
        FROM information_schema.sequences
        JOIN (values ('Последовательность', 3)) AS ref(caption, sort)
          ON true
        WHERE sequences.sequence_schema = 'public'
     ) AS objects;



SELECT row_number() over (ORDER BY table_constraints.table_name,
                                   ref.sort,
                                   table_constraints.constraint_name) AS "№",
       table_constraints.table_name                                   AS "Таблица",
       table_constraints.constraint_name                              AS "Наименование",
       ref.caption                                                    AS "Тип"
FROM information_schema.table_constraints
JOIN (values ('PRIMARY KEY', 'Первичный ключ',          1),
             ('FOREIGN KEY', 'Внешний ключ',            2),
             ('UNIQUE',      'Уникальность',            3),
             ('CHECK',       'Проверочное ограничение', 4)) AS ref(code, caption, sort)
  ON ref.code = table_constraints.constraint_type
WHERE table_constraints.table_schema = 'public'  -- NOT NULL попадает в information_schema как CHECK с системным именем
  AND table_constraints.constraint_name NOT LIKE '%\_not\_null';
