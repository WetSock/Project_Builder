IF OBJECT_ID ('Subtasks', 'U') is not null
    DROP TABLE Subtasks;
GO
IF OBJECT_ID ('Tasks', 'U') IS NOT NULL
    DROP TABLE Tasks;
GO
IF OBJECT_ID ('Project_User', 'U') IS NOT NULL
    DROP TABLE Project_User;
GO
IF OBJECT_ID ('Projects', 'U') IS NOT NULL
    DROP TABLE Projects;
GO
IF OBJECT_ID ('Users', 'U') IS NOT NULL
    DROP TABLE Users;
GO
 
CREATE TABLE Projects (
 ProjectID int IDENTITY PRIMARY KEY,
 Name nchar(20) not null, 
 CreationDate date null
);

Create table Users(
 UserID int IDENTITY Primary key,
 UserLogin nchar(20) not null UNIQUE,
 UserPassword nchar(20) not null,
 Name nchar(20) null,
 Surname nchar(20) null,
 Patronymic nchar(20) null
);

Create table Project_User(
 ProjectID int not null,
 UserID int not null,
 Administrator bit null,
 Moderator bit null,
 CONSTRAINT PK_Project_User
               PRIMARY KEY (ProjectID, UserID),
 CONSTRAINT FK_Project_PU Foreign KEY (ProjectID) references Projects (ProjectID)
            on delete Cascade,
 CONSTRAINT FK_Users_PU Foreign KEY (UserID) 
                 references Users (UserID) on delete Cascade
);

Create table Tasks
(
  TaskID int IDENTITY not null,
  ProjectID int not null,
  Name nchar(20) not null default 'Задача',
  Decription nvarchar(max) null,
  [Предполагаемая дата начала] date not null,
  [Фактическая дата начала] date null,
  [Предполагаемая дата окончания] date not null,
  [Фактическая дата окончания] date null,
  NextStage int null,
  constraint PK_Tasks Primary key (TaskID,ProjectID),
  CONSTRAINT FK_Projects_Tasks Foreign KEY (ProjectID) references Projects (ProjectID)
            on delete Cascade
);

Create table Subtasks
(
   MainTask int,
   SubTask int UNIQUE,
   ProjectID int,
   Constraint PK_Subtasks Primary Key (MainTask,SubTask),
   Constraint FK_Tasks_Subtasks Foreign Key (MainTask,ProjectID) references Tasks (TaskID,ProjectID),
   Constraint FK_Tasks_Subtasks1 Foreign Key (SubTask,ProjectID) references Tasks (TaskID,ProjectID)
)

GO

-- Триггер на удаление проекта без участников

IF OBJECT_ID ('Проект без участников','TR') IS NOT NULL
DROP TRIGGER [Проект без участников];
go
Create trigger [Проект без участников] 
  on Project_User
  after Delete
as 
  delete from Projects
    where Projects.ProjectID in  
      (select ProjectID from deleted) and   
       Projects.ProjectID not in 
          (select ProjectID from Project_User)  
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
    if (@login in (select UserLogin from Users))
        Print 'Пользователь с таким логином уже существует'
    else
        INSERT into Users
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
    (select UserID 
    from Users))
       Print 'Неверное id создателя проекта'
    else
    
    begin tran;
    -- Создание строки в таблице Проекты с заданным id, названием и текущей датой.
       INSERT into Projects
              values (@project_name,GETDATE());
    -- Указание создателя проекта в качестве его участника и администратора
       INSERT into Project_User
              values (@@IDENTITY,@users_id,1,NULL)
    commit tran;
GO

-- Добавление нового участника в проект
IF OBJECT_ID ( 'Новый участник проекта', 'P' ) IS NOT NULL 
    DROP PROCEDURE [Новый участник проекта];
GO
CREATE procedure [Новый участник проекта]
(
   @ProjectID int,
   @UserID int,
   @Admin bit = Null,
   @Moderator bit = Null
)
as 
   INSERT into Project_User
          values (@ProjectID,@UserID,@Admin,@Moderator);
go

-- Добавление новой задачи в проект
IF OBJECT_ID ('Новая задача','P') is not NULL
    drop PROCEDURE [Новая задача];
go
Create PROCEDURE [Новая задача]
(
  @ProjectID int,
  @Begin date,
  @End date
)
as
  INSERT into Tasks (ProjectID,[Предполагаемая дата начала],[Предполагаемая дата окончания])
         values (@ProjectID,@Begin,@End) 
go    

-- Процедура удаления проекта
if OBJECT_ID ('Удаление проекта','P') is not null
     drop PROCEDURE [Удаление проекта];
go
create PROCEDURE [Удаление проекта]
(
   @ProjectID int
)
as
   DELETE from Projects
      where ProjectID=@ProjectID
go

-- Процедура удаления пользователя
if OBJECT_ID ('Удаление пользователя','P') is not null
     drop PROCEDURE [Удаление пользователя];
go
create PROCEDURE [Удаление пользователя]
(
   @UserID int
)
as
   DELETE from Users
      where UserID=@UserID
go

-- Процедура удаления участника проекта
if OBJECT_ID ('Удаление участника проекта','P') is not null
     drop PROCEDURE [Удаление участника проекта];
go
create PROCEDURE [Удаление участника проекта]
(
   @ProjectID int,
   @UserID int
)
as
   DELETE from Project_User
      where ProjectID=@ProjectID and
            UserID=@UserID
go

-- Процедура удаления задачи
if OBJECT_ID ('Удаление задачи','P') is not null
     drop PROCEDURE [Удаление задачи];
go
create PROCEDURE [Удаление задачи]
(
   @TaskID int
)
as
   DELETE from Tasks 
      where TaskID=@TaskID
go

-- Добавление нескольких строк для тестов
    
Exec [Новый пользователь] 'WetSock','12345'
Exec [Новый пользователь] 'Cinereo','Null'
Exec [Новый пользователь] 'Morbid','qwerty'
Exec [Новый пользователь] 'Ragnaros',qwerty  
Exec [Новый пользователь] 'Dority',qwerty 
Exec [Новый пользователь] 'Edward',qwerty
Exec [Новый пользователь] 'Rudeus',qwerty
Exec [Новый пользователь] 'Rikka',qwerty
Exec [Новый пользователь] 'Zanoba',qwerty
Exec [Новый пользователь] 'Naruto',qwerty
Exec [Новый пользователь] 'Mizuki',qwerty
Exec [Новый пользователь] 'Пико',qwerty
Exec [Новый пользователь] 'Mikoto',qwerty
Exec [Новый пользователь] 'Goriade-san',qwerty

Exec [Новый проект] 1,'Тест'
Exec [Новый проект] 2,'Этот самый'
Exec [Новый проект] 3,'Автоматом'
Exec [Новый проект] 5,'Девичник'
Exec [Новый проект] 10,'Мальчишник'
Exec [Новый проект] 4,'Захват мира'

Exec [Удаление пользователя] 12

Exec [Новый участник проекта] 2,3
Exec [Новый участник проекта] 1,2,1
Exec [Новый участник проекта] 3,2,NULL,1

Exec [Новая задача] 1,'2007-10-01','2010-12-05'
Exec [Новая задача] 1,'1996-10-25','1970-01-01'   
go
