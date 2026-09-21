DROP TABLE IF EXISTS Measurements;
DROP TABLE IF EXISTS EquipmentParams;
DROP TABLE IF EXISTS Packs;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Positions;
DROP TABLE IF EXISTS TypeOfEquipment;
DROP TABLE IF EXISTS Params;


CREATE TABLE TypeOfEquipment(
    id   int PRIMARY KEY,
    name text NOT NULL
);

COMMENT ON TABLE  TypeOfEquipment      IS 'Справочник типов метеооборудования';
COMMENT ON COLUMN TypeOfEquipment.id   IS 'Идентификатор типа оборудования';
COMMENT ON COLUMN TypeOfEquipment.name IS 'Наименование прибора';


CREATE TABLE Params(
    id   int PRIMARY KEY,
    name text NOT NULL,
    unit text
);

COMMENT ON TABLE  Params      IS 'Справочник метеорологических параметров';
COMMENT ON COLUMN Params.id   IS 'Идентификатор параметра';
COMMENT ON COLUMN Params.name IS 'Наименование параметра';
COMMENT ON COLUMN Params.unit IS 'Единица измерения';


CREATE TABLE EquipmentParams(
    id_type  int NOT NULL,
    id_param int NOT NULL,
    PRIMARY KEY (id_type, id_param),
    FOREIGN KEY (id_type)  REFERENCES TypeOfEquipment(id),
    FOREIGN KEY (id_param) REFERENCES Params(id)
);

COMMENT ON TABLE  EquipmentParams          IS 'Соответствие оборудования и измеряемых им параметров';
COMMENT ON COLUMN EquipmentParams.id_type  IS 'Тип оборудования';
COMMENT ON COLUMN EquipmentParams.id_param IS 'Измеряемый параметр';


CREATE TABLE Positions(
    id                 int PRIMARY KEY,
    name               text NOT NULL,
    ID_TypeOfEquipment int,
    FOREIGN KEY (ID_TypeOfEquipment) REFERENCES TypeOfEquipment(id)
);

COMMENT ON TABLE  Positions                    IS 'Должности личного состава метеопоста';
COMMENT ON COLUMN Positions.id                 IS 'Идентификатор должности';
COMMENT ON COLUMN Positions.name               IS 'Наименование должности';
COMMENT ON COLUMN Positions.ID_TypeOfEquipment IS 'Штатное оборудование должности';


CREATE TABLE Users(
    id           int PRIMARY KEY,
    name         text NOT NULL,
    ID_Positions int,
    FOREIGN KEY (ID_Positions) REFERENCES Positions(id)
);

COMMENT ON TABLE  Users              IS 'Личный состав метеопоста';
COMMENT ON COLUMN Users.id           IS 'Идентификатор сотрудника';
COMMENT ON COLUMN Users.name         IS 'ФИО сотрудника';
COMMENT ON COLUMN Users.ID_Positions IS 'Занимаемая должность';


CREATE TABLE Packs(
    id           int PRIMARY KEY,
    name         text NOT NULL,
    id_user      int,
    created_date timestamp,
    FOREIGN KEY (id_user) REFERENCES Users(id)
);

COMMENT ON TABLE  Packs              IS 'Пачка — единичный сеанс метеонаблюдения';
COMMENT ON COLUMN Packs.id           IS 'Идентификатор пачки';
COMMENT ON COLUMN Packs.name         IS 'Номер пачки';
COMMENT ON COLUMN Packs.id_user      IS 'Метеоролог, выполнивший замер';
COMMENT ON COLUMN Packs.created_date IS 'Дата и время проведения замера';


CREATE TABLE Measurements(
    id       int PRIMARY KEY,
    id_pack  int NOT NULL,
    id_param int NOT NULL,
    id_type  int NOT NULL,
    value    numeric(10, 2),
    FOREIGN KEY (id_pack)  REFERENCES Packs(id),
    FOREIGN KEY (id_param) REFERENCES Params(id),
    FOREIGN KEY (id_type)  REFERENCES TypeOfEquipment(id)
);

COMMENT ON TABLE  Measurements          IS 'Результаты измерений метеопараметров';
COMMENT ON COLUMN Measurements.id       IS 'Идентификатор замера';
COMMENT ON COLUMN Measurements.id_pack  IS 'Пачка, в которую входит замер';
COMMENT ON COLUMN Measurements.id_param IS 'Измеренный параметр';
COMMENT ON COLUMN Measurements.id_type  IS 'Оборудование, которым выполнен замер';
COMMENT ON COLUMN Measurements.value    IS 'Полученное значение';


INSERT INTO TypeOfEquipment (id, name) VALUES (1, 'ДМК (десантный метеокомплект)');
INSERT INTO TypeOfEquipment (id, name) VALUES (2, 'ВР (ветровое ружьё)');

INSERT INTO Params (id, name, unit) VALUES (1, 'Высота метеопоста',    'м');
INSERT INTO Params (id, name, unit) VALUES (2, 'Температура',          '°C');
INSERT INTO Params (id, name, unit) VALUES (3, 'Давление',             'мм рт. ст.');
INSERT INTO Params (id, name, unit) VALUES (4, 'Направление ветра',    'б. д. у.');
INSERT INTO Params (id, name, unit) VALUES (5, 'Скорость ветра',       'м/с');
INSERT INTO Params (id, name, unit) VALUES (6, 'Дальность сноса пуль', 'м');


INSERT INTO EquipmentParams (id_type, id_param) VALUES (1, 1);
INSERT INTO EquipmentParams (id_type, id_param) VALUES (1, 2);
INSERT INTO EquipmentParams (id_type, id_param) VALUES (1, 3);
INSERT INTO EquipmentParams (id_type, id_param) VALUES (1, 4);
INSERT INTO EquipmentParams (id_type, id_param) VALUES (1, 5);

INSERT INTO EquipmentParams (id_type, id_param) VALUES (2, 2);
INSERT INTO EquipmentParams (id_type, id_param) VALUES (2, 6);

INSERT INTO Positions (id, name, ID_TypeOfEquipment) VALUES (1, 'Метеоролог',               1);
INSERT INTO Positions (id, name, ID_TypeOfEquipment) VALUES (2, 'Оператор ветрового ружья', 2);
INSERT INTO Positions (id, name, ID_TypeOfEquipment) VALUES (3, 'Начальник метеопоста',     1);

INSERT INTO Users (id, name, ID_Positions) VALUES (1, 'Иванов Иван',  1);
INSERT INTO Users (id, name, ID_Positions) VALUES (2, 'Петрова Анна', 2);
INSERT INTO Users (id, name, ID_Positions) VALUES (3, 'Сидоров Олег', 3);

INSERT INTO Packs (id, name, id_user, created_date) VALUES (1, 'Метео-11 24093', 1, '2026-05-11 10:00:00');
INSERT INTO Packs (id, name, id_user, created_date) VALUES (2, 'Метео-11 24101', 1, '2026-05-11 14:00:00');
INSERT INTO Packs (id, name, id_user, created_date) VALUES (3, 'Метео-11 25143', 2, '2026-05-11 15:30:00');


INSERT INTO Measurements (id, id_pack, id_param, id_type, value) VALUES (1, 1, 1, 1, 240);
INSERT INTO Measurements (id, id_pack, id_param, id_type, value) VALUES (2, 1, 2, 1, 15.4);
INSERT INTO Measurements (id, id_pack, id_param, id_type, value) VALUES (3, 1, 3, 1, 748.2);
INSERT INTO Measurements (id, id_pack, id_param, id_type, value) VALUES (4, 1, 4, 1, 30);
INSERT INTO Measurements (id, id_pack, id_param, id_type, value) VALUES (5, 1, 5, 1, 4.5);

INSERT INTO Measurements (id, id_pack, id_param, id_type, value) VALUES (6, 2, 2, 1, 17.1);
INSERT INTO Measurements (id, id_pack, id_param, id_type, value) VALUES (7, 2, 3, 1, 747.9);

INSERT INTO Measurements (id, id_pack, id_param, id_type, value) VALUES (8, 3, 2, 2, 16.8);
INSERT INTO Measurements (id, id_pack, id_param, id_type, value) VALUES (9, 3, 6, 2, 12.5);



SELECT Users.name            AS метеоролог,
       Positions.name        AS должность,
       Packs.name            AS пачка,
       Packs.created_date    AS дата_замера,
       TypeOfEquipment.name  AS оборудование,
       Params.name           AS параметр,
       Measurements.value    AS значение,
       Params.unit           AS единица
FROM Users, Positions, Packs, Measurements, Params, TypeOfEquipment
WHERE Users.ID_Positions = Positions.id
  AND Packs.id_user = Users.id
  AND Measurements.id_pack = Packs.id
  AND Measurements.id_param = Params.id
  AND Measurements.id_type = TypeOfEquipment.id
ORDER BY Packs.created_date, Params.id;
