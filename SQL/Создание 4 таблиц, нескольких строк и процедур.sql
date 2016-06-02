IF OBJECT_ID ('UserMessages', 'U') is not null
    DROP TABLE UserMessages;
IF OBJECT_ID ('Task_User', 'U') is not null
    DROP TABLE Task_User;
IF OBJECT_ID ('Subtasks', 'U') is not null
    DROP TABLE Subtasks;
IF OBJECT_ID ('Tasks', 'U') IS NOT NULL
    DROP TABLE Tasks;
IF OBJECT_ID ('Project_User', 'U') IS NOT NULL
    DROP TABLE Project_User;
IF OBJECT_ID ('Projects', 'U') IS NOT NULL
    DROP TABLE Projects;
IF OBJECT_ID ('Users', 'U') IS NOT NULL
    DROP TABLE Users;

------------------------------------------------------------------ 
-- Блок создания таблиц 
------------------------------------------------------------------
 
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
 Position bit null, -- Null - участник, 1 - модератор, 0 - администратор
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
  RequiredStartDate date not null,
  RequiredFinishDate date not null,
  FinishDate date null,
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
   Constraint PK_Subtasks Primary Key (MainTask,SubTask,ProjectID),
   Constraint FK_Tasks_Subtasks Foreign Key (MainTask,ProjectID) references Tasks (TaskID,ProjectID),
   Constraint FK_Tasks_Subtasks1 Foreign Key (SubTask,ProjectID) references Tasks (TaskID,ProjectID)
)

create table Task_User
(
   TaskID int,
   UserID int,
   ProjectID int,
   constraint PK_Task_User Primary Key (TaskID,UserID,ProjectID),
   constraint FK_Tasks Foreign Key (TaskID,ProjectID) references Tasks (TaskID,ProjectID) on delete Cascade,
   CONSTRAINT FK_Users Foreign KEY (UserID) references Users (UserID) on delete Cascade  
)

create table UserMessages
(
   MessageID int IDENTITY Primary Key,
   SenderID int,
   ReceiverID int,
   UserMessage text,
   CONSTRAINT FK_Sender Foreign KEY (SenderID) references Users (UserID),
   CONSTRAINT FK_Receiver Foreign KEY (ReceiverID) references Users (UserID) on delete cascade 
)
GO

------------------------------------------------------------------
-- Блок создания триггеров
------------------------------------------------------------------

-- Триггер на удаление проекта без участников

IF OBJECT_ID ('Project without users','TR') IS NOT NULL
DROP TRIGGER [Project without users];
go
Create trigger [Project without users] 
  on Project_User
  after Delete
as 
  delete from Projects
    where Projects.ProjectID in  
      (select ProjectID from deleted) and   
       Projects.ProjectID not in 
          (select ProjectID from Project_User)  
GO

------------------------------------------------------------------
-- Блок создания процедур на добавление записей
------------------------------------------------------------------

-- Процедура создания нового пользователя
IF OBJECT_ID ('User Registration','P') is not NULL
    drop PROCEDURE [User Registration];
go
Create PROCEDURE [User Registration]
(
  @login nchar(20),
  @password nchar(20)
)
as
    if (@login in (select UserLogin from Users))
        Print 'User with this login already exists'
    else
    begin
        INSERT into Users
           values (@login,@password,NULL,NULL,NULL)
    end
    
go    
     
-- Процедура для создания нового проекта с входными параметрами
--   @users_id - id создателя и одновременно администратора проекта,
--   @project_id - id проекта (заменить на автоматическую генерацию id),
--   @project_name - название проекта (может повторяться)

IF OBJECT_ID ( 'Project Creation', 'P' ) IS NOT NULL 
    DROP PROCEDURE [Project Creation];
GO
CREATE PROCEDURE [Project Creation]
(
  @users_id int,
  @project_name nchar(20)
)
AS
-- Создатель проекта должен быть записан в таблице Пользователи
    if (@users_id not in
    (select UserID 
    from Users))
       Print 'Wrong user`s ID'
    else
    BEGIN
    begin tran;
    -- Создание строки в таблице Проекты с заданным id, названием и текущей датой.
       INSERT into Projects
              values (@project_name,GETDATE())
    -- Указание создателя проекта в качестве его участника и администратора
       INSERT into Project_User
              values (@@IDENTITY,@users_id,0)
    commit tran;
    END;
GO

-- Добавление нового участника в проект
IF OBJECT_ID ( 'New Participant', 'P' ) IS NOT NULL 
    DROP PROCEDURE [New Participant];
GO
CREATE procedure [New Participant]
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
IF OBJECT_ID ('New Task','P') is not NULL
    drop PROCEDURE [New Task];
go
Create PROCEDURE [New Task]
(
  @ProjectID int,
  @Begin date,
  @End date
)
as
  INSERT into Tasks (ProjectID,RequiredStartDate,RequiredFinishDate)
         values (@ProjectID,@Begin,@End) 
go    

------------------------------------------------------------------
-- Блок создания процедур на удаление записей
------------------------------------------------------------------

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
   if ((select COUNT(*) 
         from Project_User 
         where ProjectID=@ProjectID and Position=0 and UserID<>@UserID)=0 and 
       (select COUNT(*) 
         from Project_User
         where ProjectID=@ProjectID)>1)
      Print 'Promote someone first!' 
    else
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


------------------------------------------------------------------
-- Добавление нескольких строк для тестов
------------------------------------------------------------------
    
Exec [User Registration] 'WetSock','12345'
Exec [User Registration] 'Cinereo','Null'
Exec [User Registration] 'Morbid','qwerty'
Exec [User Registration] 'Ragnaros',qwerty  
Exec [User Registration] 'Dority',qwerty 
Exec [User Registration] 'Edward',qwerty
Exec [User Registration] 'Rudeus',qwerty
Exec [User Registration] 'Rikka',qwerty
Exec [User Registration] 'Zanoba',qwerty
Exec [User Registration] 'Naruto',qwerty
Exec [User Registration] 'Mizuki',qwerty
Exec [User Registration] 'Пико',qwerty
Exec [User Registration] 'Mikoto',qwerty
Exec [User Registration] 'Goriade-san',qwerty

Exec [Project Creation] 1,'Тест'
Exec [Project Creation] 2,'Этот самый'
Exec [Project Creation] 3,'Автоматом'
Exec [Project Creation] 5,'Девичник'
Exec [Project Creation] 10,'Мальчишник'
Exec [Project Creation] 4,'Захват мира'


Exec [New Participant] 2,3
Exec [New Participant] 1,2,1
Exec [New Participant] 3,2,NULL

Exec [New Task] 1,'2007-10-01','2010-12-05'
Exec [New Task] 1,'1996-10-25','1970-01-01'   
go
