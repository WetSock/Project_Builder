IF OBJECT_ID ('Task_User', 'U') is not null
    DROP TABLE Task_User;
GO
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
 Position bit null, -- 1 means moderator, 2 means administrator
 
 CONSTRAINT PK_Project_User
               PRIMARY KEY (ProjectID, UserID),
 CONSTRAINT FK_Project_PU Foreign KEY (ProjectID) references Projects (ProjectID)
            on delete Cascade,
 CONSTRAINT FK_Users_PU Foreign KEY (UserID) 
                 references Users (UserID) on delete Cascade
);

Create table Tasks
(
  TaskID int IDENTITY Primary key,
  ProjectID int not null,
  Name nchar(20) not null default 'Задача',
  Decription nvarchar(max) null,
  [Предполагаемая дата начала] date not null,
  [Фактическая дата начала] date null,
  [Предполагаемая дата окончания] date not null,
  [Фактическая дата окончания] date null,
  NextStage int null,
  CONSTRAINT FK_Projects_Tasks Foreign KEY (ProjectID) references Projects (ProjectID)
            on delete Cascade
);

Create table Subtasks
(
   MainTask int,
   SubTask int UNIQUE,
   Constraint PK_Subtasks Primary Key (MainTask,SubTask),
   Constraint FK_Tasks_Subtasks Foreign Key (MainTask) references Tasks (TaskID),
   Constraint FK_Tasks_Subtasks1 Foreign Key (SubTask) references Tasks (TaskID)
)

GO

Create table Task_User
(
  TaskID int references Tasks (TaskID),
  UserID int,
  constraint PK_Task_User Primary key (TaskID,UserID),
)

-- Триггер на удаление проекта без участников

IF OBJECT_ID ('Project without participants','TR') IS NOT NULL
DROP TRIGGER [Project without participants];
go
Create trigger [Project without participants] 
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
IF OBJECT_ID ('User registration','P') is not NULL
    drop PROCEDURE [User registration];
go
Create PROCEDURE [User registration]
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

IF OBJECT_ID ( 'New project', 'P' ) IS NOT NULL 
    DROP PROCEDURE [New project];
GO
CREATE PROCEDURE [New project]
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
              values (@@IDENTITY,@users_id,2)
    commit tran;
GO

-- Добавление нового участника в проект
IF OBJECT_ID ( 'New participant', 'P' ) IS NOT NULL 
    DROP PROCEDURE [New participant];
GO
CREATE procedure [New participant]
(
   @ProjectID int,
   @UserID int,
   @Position bit = Null
)
as 
   INSERT into Project_User
          values (@ProjectID,@UserID,@Position);
go

-- Добавление новой задачи в проект
IF OBJECT_ID ('New task','P') is not NULL
    drop PROCEDURE [New task];
go
Create PROCEDURE [New task]
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
if OBJECT_ID ('Project removal','P') is not null
     drop PROCEDURE [Project removal];
go
create PROCEDURE [Project removal]
(
   @ProjectID int
)
as
   DELETE from Projects
      where ProjectID=@ProjectID
go

-- Процедура удаления пользователя
if OBJECT_ID ('User removal','P') is not null
     drop PROCEDURE [User removal];
go
create PROCEDURE [User removal]
(
   @UserID int
)
as
   DELETE from Users
      where UserID=@UserID
go

-- Процедура удаления участника проекта
if OBJECT_ID ('Participant removal','P') is not null
     drop PROCEDURE [Participant removal];
go
create PROCEDURE [Participant removal]
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
if OBJECT_ID ('Task removal','P') is not null
     drop PROCEDURE [Task removal];
go
create PROCEDURE [Task removal]
(
   @TaskID int
)
as
   DELETE from Tasks 
      where TaskID=@TaskID
go

-- Добавление нескольких строк для тестов
    
Exec [User registration] 'WetSock','12345'
Exec [User registration] 'Cinereo','Null'
Exec [User registration] 'Morbid','qwerty'
Exec [User registration] 'Ragnaros',qwerty  
Exec [User registration] 'Dority',qwerty 
Exec [User registration] 'Edward',qwerty
Exec [User registration] 'Rudeus',qwerty
Exec [User registration] 'Rikka',qwerty
Exec [User registration] 'Zanoba',qwerty
Exec [User registration] 'Naruto',qwerty
Exec [User registration] 'Mizuki',qwerty
Exec [User registration] 'Пико',qwerty
Exec [User registration] 'Mikoto',qwerty
Exec [User registration] 'Goriade-san',qwerty

Exec [New Project] 1,'Тест'
Exec [New Project] 2,'Этот самый'
Exec [New Project] 3,'Автоматом'
Exec [New Project] 5,'Девичник'
Exec [New Project] 10,'Мальчишник'
Exec [New Project] 4,'Захват мира'

Exec [User removal] 12

Exec [New participant] 2,3
Exec [New participant] 1,2,1
Exec [New participant] 3,2,NULL

Exec [New task] 1,'2007-10-01','2010-12-05'
Exec [New task] 1,'1996-10-25','1970-01-01'   
go
