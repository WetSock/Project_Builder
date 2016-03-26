IF OBJECT_ID ('Задачи', 'U') IS NOT NULL
    DROP TABLE Задачи;
GO
IF OBJECT_ID ('Проект_Пользователь', 'U') IS NOT NULL
    DROP TABLE Проект_Пользователь;
GO
IF OBJECT_ID ('Проекты', 'U') IS NOT NULL
    DROP TABLE Проекты;
GO
IF OBJECT_ID ('Пользователи', 'U') IS NOT NULL
    DROP TABLE Пользователи;
GO

CREATE TABLE Проекты 
([ID Проекта] int IDENTITY PRIMARY KEY,
 Название nchar(20) not null, 
 [Дата создания] date null
);

Create table Пользователи
([id Пользователя] int IDENTITY Primary key,
 Логин nchar(20) not null UNIQUE,
 Пароль nchar(20) not null,
 Имя nchar(20) null,
 Фамилия nchar(20) null,
 Отчество nchar(20) null
);

Create table Проект_Пользователь
(Проект int not null,
 Пользователь int not null,
 Администратор nchar(2) null,
 Модератор nchar(2) null,
 CONSTRAINT PK_Проект_Пользователь
               PRIMARY KEY (Проект, Пользователь),
 CONSTRAINT FK_Проект_ПП Foreign KEY (Проект) references Проекты ([ID Проекта])
            on delete Cascade,
 CONSTRAINT FK_Пользователь_ПП Foreign KEY (Пользователь) 
                 references Пользователи ([ID Пользователя]) on delete Cascade
);

Create table Задачи
(
  [id Задачи] int IDENTITY not null,
  Проект int not null,
  Название nchar(20) not null default 'Задача',
  Описание nvarchar(max) null,
  [Предполагаемая дата начала] date not null,
  [Фактическая дата начала] date null,
  [Предполагаемая дата окончания] date not null,
  [Фактическая дата окончания] date null,
  Подчиняется int null,
  constraint PK_Задачи Primary key ([id Задачи],Проект),
  CONSTRAINT FK_Проект_Задачи Foreign KEY (Проект) references Проекты ([ID Проекта])
            on delete Cascade,
  constraint [Задача не может быть своей подзадачей] check (not Подчиняется=[id Задачи])
);

GO

-- Триггер на удаление проекта без участников

IF OBJECT_ID ('Проект без участников','TR') IS NOT NULL
DROP TRIGGER [Проект без участников];
go
Create trigger [Проект без участников]
on Проект_Пользователь
after Delete
as delete from Проекты
where Проекты.[id Проекта] in  
(select Проект from deleted) and   
Проекты.[id Проекта] not in 
(select Проект from Проект_Пользователь)  

GO

-- Процедура создания нового пользователя
IF OBJECT_ID ('Новый пользователь','P') is not NULL
    drop PROCEDURE [Новый пользователь];
go
Create PROCEDURE [Новый пользователь]
(
  @login nchar(20),
  @password nchar(20)
)
as
    if (@login in (select Логин from Пользователи))
        Print 'Пользователь с таким логином уже существует'
    else
        INSERT into Пользователи
           values (@login,@password,NULL,NULL,NULL)
    
go    
     
-- Процедура для создания нового проекта с входными параметрами
--   @users_id - id создателя и одновременно администратора проекта,
--   @project_id - id проекта (заменить на автоматическую генерацию id),
--   @project_name - название проекта (может повторяться)

IF OBJECT_ID ( 'Новый проект', 'P' ) IS NOT NULL 
    DROP PROCEDURE [Новый проект];
GO
CREATE PROCEDURE [Новый проект]
(
  @users_id int,
  @project_name nchar(20)
)
AS
-- Создатель проекта должен быть записан в таблице Пользователи
    if (@users_id not in
    (select [id Пользователя] 
    from Пользователи))
       Print 'Неверное id создателя проекта'
    else
    
    begin
    -- Создание строки в таблице Проекты с заданным id, названием и текущей датой.
       INSERT into Проекты 
              values (@project_name,GETDATE());
    -- Указание создателя проекта в качестве его участника и администратора
       INSERT into Проект_Пользователь
              values (@@IDENTITY,@users_id,'Да',NULL)
    end
GO

-- Добавление нового участника в проект
IF OBJECT_ID ( 'Новый участник проекта', 'P' ) IS NOT NULL 
    DROP PROCEDURE [Новый участник проекта];
GO
CREATE procedure [Новый участник проекта]
(
   @id_Проекта int,
   @id_Пользователя int,
   @Администратор nchar(2),
   @Модератор nchar(2)
)
as 
   INSERT into Проект_Пользователь
          values (@id_Проекта,@id_Пользователя,@Администратор,@Модератор);
go

-- Добавление новой задачи в проект
IF OBJECT_ID ('Новая задача','P') is not NULL
    drop PROCEDURE [Новая задача];
go
Create PROCEDURE [Новая задача]
(
  @Проект int,
  @Начало date,
  @Конец date
)
as
  INSERT into Задачи (Проект,[Предполагаемая дата начала],[Предполагаемая дата окончания])
         values (@Проект,@Начало,@Конец) 
go    

-- Процедура удаления проекта
if OBJECT_ID ('Удаление проекта','P') is not null
     drop PROCEDURE [Удаление проекта];
go
create PROCEDURE [Удаление проекта]
(
   @id_Проекта int
)
as
   DELETE from Проекты 
      where [ID Проекта]=@id_Проекта
go

-- Процедура удаления пользователя
if OBJECT_ID ('Удаление пользователя','P') is not null
     drop PROCEDURE [Удаление пользователя];
go
create PROCEDURE [Удаление пользователя]
(
   @id_Пользователя int
)
as
   DELETE from Пользователи
      where [ID пользователя]=@id_пользователя
go

-- Процедура удаления участника проекта
if OBJECT_ID ('Удаление участника проекта','P') is not null
     drop PROCEDURE [Удаление участника проекта];
go
create PROCEDURE [Удаление участника проекта]
(
   @id_Проекта int,
   @id_Пользователя int
)
as
   DELETE from Проект_Пользователь
      where Проект=@id_Проекта and
            Пользователь=@id_Пользователя
go

-- Процедура удаления задачи
if OBJECT_ID ('Удаление задачи','P') is not null
     drop PROCEDURE [Удаление задачи];
go
create PROCEDURE [Удаление задачи]
(
   @id_задачи int
)
as
   DELETE from Задачи 
      where [ID Задачи]=@id_Задачи
go


-- Добавление нескольких строк для тестов
INSERT INTO Проекты (Название) 
    VALUES ('Этот самый');
INSERT INTO Проекты (Название) 
    VALUES ('Тест');
    
INSERT INTO Пользователи (Логин,Пароль,Имя,Фамилия,Отчество) 
    VALUES ('WetSock','12345','Магомед','Алибеков','Русланович');
INSERT INTO Пользователи (Логин,Пароль,Имя,Фамилия) 
    VALUES ('Cinereo','Null','Данил','Астахов');
INSERT INTO Пользователи (Логин,Пароль,Имя,Фамилия) 
    VALUES ('Morbid','qwepoi123','Юджин','Краббс');
    
INSERT INTO Проект_Пользователь (Проект,Пользователь,Администратор) 
    VALUES (1,1,'Да');
INSERT INTO Проект_Пользователь (Проект,Пользователь,Модератор) 
    VALUES (1,2,'Да');

INSERT into Задачи (Проект,[Предполагаемая дата начала],[Предполагаемая дата окончания])
      values (1,'1996-10-25','1970-01-01')    
go

-- Тест нескольких процедур
Exec [Новый проект] 3, 'Автоматом'
Exec [Новый участник проекта] 3,1,NULL,NULL
Exec [Новый пользователь] Morbid,qwerty
Exec [Новая задача] 1,'2007-10-01','2010-12-05'
Exec [Удаление участника проекта] 1,2
Exec [Удаление участника проекта] 1,1