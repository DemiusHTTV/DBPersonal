DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Packs;
DROP TABLE IF EXISTS Positions;
DROP TABLE IF EXISTS TypeOfEquipment;
DROP TABLE IF EXISTS Params;

CREATE table Packs(
id int PRIMARY KEY,
name text
);
CREATE table Users(
id int PRIMARY KEY,
name text,
ID_Positions int,
id_packs int
);
CREATE table Positions(
id int PRIMARY KEY,
name text,
ID_TypeOfEquipment int
);
CREATE table Params(
id int PRIMARY KEY,
name string
);
CREATE table TypeOfEquipment(
id int PRIMARY KEY,
name text,
ID_Params int
);
 
INSERT INTO Packs (id, name) VALUES (1, 'Метео-11 24093');
INSERT INTO Packs (id, name) VALUES (2, 'Метео-11 24101');
INSERT INTO Packs (id, name) VALUES (3, 'Метео-11 25143');
 
INSERT INTO Positions (id, name) VALUES (1, 'Метеоролог');
INSERT INTO Positions (id, name) VALUES (2, 'Оператор ветрового ружья');
INSERT INTO Positions (id, name) VALUES (3, 'Начальник метеопоста');
 
INSERT INTO Users (id, name, ID_Positions) VALUES (1, 'Иванов Иван',1);
INSERT INTO Users (id, name, ID_Positions) VALUES (2, 'Петрова Анна',2);
INSERT INTO Users (id, name, ID_Positions) VALUES (3, 'Сидоров Олег',3);
 
INSERT INTO Params (id, name) VALUES (1, 'Высота метеопоста, м');
INSERT INTO Params (id, name) VALUES (2, 'Температура, °C');
INSERT INTO Params (id, name) VALUES (3, 'Давление, мм рт. ст.');
INSERT INTO Params (id, name) VALUES (4, 'Направление ветра, б. д. у.');
INSERT INTO Params (id, name) VALUES (5, 'Скорость ветра, м/с');
INSERT INTO Params (id, name) VALUES (6, 'Дальность сноса пуль, м');
 
INSERT INTO TypeOfEquipment (id, name) VALUES (1, 'ДМК (десантный метеокомплект)');
INSERT INTO TypeOfEquipment (id, name) VALUES (2, 'ВР (ветровое ружьё)');
 
UPDATE Positions set ID_TypeOfEquipment = 1
WHERE name = 'Метеоролог';
 
UPDATE Positions set ID_TypeOfEquipment = 2
WHERE name = 'Оператор ветрового ружья';
 
UPDATE Positions set ID_TypeOfEquipment = 1
WHERE name Like 'Начальник%метеопоста';


UPDATE TypeOfEquipment 
SET ID_Params = 5
WHERE id = 1;
 
UPDATE TypeOfEquipment 
SET ID_Params = 6
WHERE id = 2;
 
Update Users 
set id_packs = 2
Where id = 1;
 
update Users
set id_packs = 1
where id = 2;
 
update Users
set id_packs = 3
where id = 3;

/* ну это если по Ansi 92 делать как в задании скзано 
я думал как на паре с помощью where 
*/

SELECT *
FROM Users
JOIN Positions on Users.ID_Positions = Positions.id
JOIN TypeOfEquipment on Positions.ID_TypeOfEquipment = TypeOfEquipment.id
JOIN Params on TypeOfEquipment.ID_Params = Params.id
JOIN Packs on Users.id_packs = Packs.id;