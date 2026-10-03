-- DML-скрипт для очистки и заполнения тестовыми данными (PostgreSQL)

-- 1. Очистка транзакционных данных
DELETE FROM measurment_input_params;
DELETE FROM measurment_baths;

-- 2. (Опционально) Заполнение справочников, если они пусты. 
--    ID в справочниках должны строго совпадать с ID в INSERT ниже.

-- Справочник сотрудников (предполагаем, что их 3)
DELETE FROM employees;
INSERT INTO employees (id, name, birthday, military_rank_id) VALUES
(1, 'Иванов А.А.', '1990-05-15'::timestamp, 1),
(2, 'Петров Б.Б.', '1992-08-20'::timestamp, 2),
(3, 'Сидоров В.В.', '1995-01-10'::timestamp, 1);

-- Справочник оборудования (ДМК и ВР)
DELETE FROM measurment_types;
INSERT INTO measurment_types (id, short_name, description) VALUES
(1, 'ДМК', 'Десантный метеокомплект'),
(2, 'ВР', 'Ветровое ружье');

-- Справочник типов параметров (ID должны совпадать с логикой в основном INSERT)
DELETE FROM type_of_params;
INSERT INTO type_of_params (id, name, unit_id) VALUES
(1, 'Высота метеопоста', 1),   -- метры
(2, 'Температура', 2),         -- градусы Цельсия
(3, 'Давление', 3),            -- мм рт. ст.
(4, 'Направление ветра', 4),   -- большие деления угломера
(5, 'Скорость ветра', 5),      -- м/с
(6, 'Дальность сноса пуль', 6);-- метры

-- 3. Создание 30 пачек измерений (по 10 на каждого сотрудника, чередуя оборудование)
WITH batches AS (
    INSERT INTO measurment_baths (id, emploee_id, measurment_type_id, started)
    SELECT 
        g.id,
        -- Распределение по сотрудникам: 1,2,3,1,2,3...
        ((g.id - 1) % 3) + 1 as emploee_id,
        -- Чередование оборудования: нечетные - ДМК (1), четные - ВР (2)
        CASE WHEN g.id % 2 = 1 THEN 1 ELSE 2 END as measurment_type_id,
        -- Время: имитация истории (каждая следующая пачка на 1 минуту раньше)
        NOW() - (INTERVAL '1 minute' * g.id) as started
    FROM generate_series(1, 30) AS g(id)
    RETURNING id, measurment_type_id
)

-- 4. Генерация 180 строк параметров (6 параметров * 30 пачек)
INSERT INTO measurment_input_params (measurment_bath_id, type_of_params_id, value)
SELECT 
    b.id,
    p.id as type_of_params_id,
    CASE p.id
        -- 1. Высота метеопоста: от -200 до 500 (целое)
        WHEN 1 THEN (FLOOR(RANDOM() * 701) - 200)::numeric
        -- 2. Температура: от -58.0 до 58.0 (один знак после запятой)
        WHEN 2 THEN (ROUND((RANDOM() * 116.0 - 58.0) * 10) / 10.0)::numeric
        -- 3. Давление: от 500 до 900 (целое)
        WHEN 3 THEN (FLOOR(RANDOM() * 401) + 500)::numeric
        -- 4. Направление ветра: от 0 до 59 (целое)
        WHEN 4 THEN (FLOOR(RANDOM() * 60))::numeric
        -- 5. Скорость ветра: 0-15 для ДМК, NULL для ВР
        WHEN 5 THEN 
            CASE 
                WHEN b.measurment_type_id = 1 THEN (FLOOR(RANDOM() * 16))::numeric
                ELSE NULL 
            END
        -- 6. Дальность сноса пуль: 0-150 для ВР, NULL для ДМК
        WHEN 6 THEN 
            CASE 
                WHEN b.measurment_type_id = 2 THEN (FLOOR(RANDOM() * 151))::numeric
                ELSE NULL 
            END
    END
FROM batches b
-- Соединяем каждую пачку со всеми 6-ю типами параметров
CROSS JOIN (VALUES 
    (1), (2), (3), (4), (5), (6)
) AS p(id)
ORDER BY b.id, p.id;

-- 5. Проверка результата
RAISE NOTICE 'Создано % пачек измерений.', (SELECT COUNT(*) FROM measurment_baths);
RAISE NOTICE 'Создано % записей параметров.', (SELECT COUNT(*) FROM measurment_input_params);

-- Визуальная проверка последних записей
SELECT 
    b.id, 
    e.name as employee, 
    mt.short_name as equipment, 
    b.started
FROM measurment_baths b
JOIN employees e ON b.emploee_id = e.id
JOIN measurment_types mt ON b.measurment_type_id = mt.id
ORDER BY b.id DESC
LIMIT 5;
