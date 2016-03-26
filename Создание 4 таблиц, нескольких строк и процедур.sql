IF OBJECT_ID ('������', 'U') IS NOT NULL
    DROP TABLE ������;
GO
IF OBJECT_ID ('������_������������', 'U') IS NOT NULL
    DROP TABLE ������_������������;
GO
IF OBJECT_ID ('�������', 'U') IS NOT NULL
    DROP TABLE �������;
GO
IF OBJECT_ID ('������������', 'U') IS NOT NULL
    DROP TABLE ������������;
GO

CREATE TABLE ������� 
([ID �������] int IDENTITY PRIMARY KEY,
 �������� nchar(20) not null, 
 [���� ��������] date null
);

Create table ������������
([id ������������] int IDENTITY Primary key,
 ����� nchar(20) not null UNIQUE,
 ������ nchar(20) not null,
 ��� nchar(20) null,
 ������� nchar(20) null,
 �������� nchar(20) null
);

Create table ������_������������
(������ int not null,
 ������������ int not null,
 ������������� nchar(2) null,
 ��������� nchar(2) null,
 CONSTRAINT PK_������_������������
               PRIMARY KEY (������, ������������),
 CONSTRAINT FK_������_�� Foreign KEY (������) references ������� ([ID �������])
            on delete Cascade,
 CONSTRAINT FK_������������_�� Foreign KEY (������������) 
                 references ������������ ([ID ������������]) on delete Cascade
);

Create table ������
(
  [id ������] int IDENTITY not null,
  ������ int not null,
  �������� nchar(20) not null default '������',
  �������� nvarchar(max) null,
  [�������������� ���� ������] date not null,
  [����������� ���� ������] date null,
  [�������������� ���� ���������] date not null,
  [����������� ���� ���������] date null,
  ����������� int null,
  constraint PK_������ Primary key ([id ������],������),
  CONSTRAINT FK_������_������ Foreign KEY (������) references ������� ([ID �������])
            on delete Cascade,
  constraint [������ �� ����� ���� ����� ����������] check (not �����������=[id ������])
);

GO

-- ������� �� �������� ������� ��� ����������

IF OBJECT_ID ('������ ��� ����������','TR') IS NOT NULL
DROP TRIGGER [������ ��� ����������];
go
Create trigger [������ ��� ����������]
on ������_������������
after Delete
as delete from �������
where �������.[id �������] in  
(select ������ from deleted) and   
�������.[id �������] not in 
(select ������ from ������_������������)  

GO

-- ��������� �������� ������ ������������
IF OBJECT_ID ('����� ������������','P') is not NULL
    drop PROCEDURE [����� ������������];
go
Create PROCEDURE [����� ������������]
(
  @login nchar(20),
  @password nchar(20)
)
as
    if (@login in (select ����� from ������������))
        Print '������������ � ����� ������� ��� ����������'
    else
        INSERT into ������������
           values (@login,@password,NULL,NULL,NULL)
    
go    
     
-- ��������� ��� �������� ������ ������� � �������� �����������
--   @users_id - id ��������� � ������������ �������������� �������,
--   @project_id - id ������� (�������� �� �������������� ��������� id),
--   @project_name - �������� ������� (����� �����������)

IF OBJECT_ID ( '����� ������', 'P' ) IS NOT NULL 
    DROP PROCEDURE [����� ������];
GO
CREATE PROCEDURE [����� ������]
(
  @users_id int,
  @project_name nchar(20)
)
AS
-- ��������� ������� ������ ���� ������� � ������� ������������
    if (@users_id not in
    (select [id ������������] 
    from ������������))
       Print '�������� id ��������� �������'
    else
    
    begin
    -- �������� ������ � ������� ������� � �������� id, ��������� � ������� �����.
       INSERT into ������� 
              values (@project_name,GETDATE());
    -- �������� ��������� ������� � �������� ��� ��������� � ��������������
       INSERT into ������_������������
              values (@@IDENTITY,@users_id,'��',NULL)
    end
GO

-- ���������� ������ ��������� � ������
IF OBJECT_ID ( '����� �������� �������', 'P' ) IS NOT NULL 
    DROP PROCEDURE [����� �������� �������];
GO
CREATE procedure [����� �������� �������]
(
   @id_������� int,
   @id_������������ int,
   @������������� nchar(2),
   @��������� nchar(2)
)
as 
   INSERT into ������_������������
          values (@id_�������,@id_������������,@�������������,@���������);
go

-- ���������� ����� ������ � ������
IF OBJECT_ID ('����� ������','P') is not NULL
    drop PROCEDURE [����� ������];
go
Create PROCEDURE [����� ������]
(
  @������ int,
  @������ date,
  @����� date
)
as
  INSERT into ������ (������,[�������������� ���� ������],[�������������� ���� ���������])
         values (@������,@������,@�����) 
go    

-- ��������� �������� �������
if OBJECT_ID ('�������� �������','P') is not null
     drop PROCEDURE [�������� �������];
go
create PROCEDURE [�������� �������]
(
   @id_������� int
)
as
   DELETE from ������� 
      where [ID �������]=@id_�������
go

-- ��������� �������� ������������
if OBJECT_ID ('�������� ������������','P') is not null
     drop PROCEDURE [�������� ������������];
go
create PROCEDURE [�������� ������������]
(
   @id_������������ int
)
as
   DELETE from ������������
      where [ID ������������]=@id_������������
go

-- ��������� �������� ��������� �������
if OBJECT_ID ('�������� ��������� �������','P') is not null
     drop PROCEDURE [�������� ��������� �������];
go
create PROCEDURE [�������� ��������� �������]
(
   @id_������� int,
   @id_������������ int
)
as
   DELETE from ������_������������
      where ������=@id_������� and
            ������������=@id_������������
go

-- ��������� �������� ������
if OBJECT_ID ('�������� ������','P') is not null
     drop PROCEDURE [�������� ������];
go
create PROCEDURE [�������� ������]
(
   @id_������ int
)
as
   DELETE from ������ 
      where [ID ������]=@id_������
go


-- ���������� ���������� ����� ��� ������
INSERT INTO ������� (��������) 
    VALUES ('���� �����');
INSERT INTO ������� (��������) 
    VALUES ('����');
    
INSERT INTO ������������ (�����,������,���,�������,��������) 
    VALUES ('WetSock','12345','�������','��������','����������');
INSERT INTO ������������ (�����,������,���,�������) 
    VALUES ('Cinereo','Null','�����','�������');
INSERT INTO ������������ (�����,������,���,�������) 
    VALUES ('Morbid','qwepoi123','�����','������');
    
INSERT INTO ������_������������ (������,������������,�������������) 
    VALUES (1,1,'��');
INSERT INTO ������_������������ (������,������������,���������) 
    VALUES (1,2,'��');

INSERT into ������ (������,[�������������� ���� ������],[�������������� ���� ���������])
      values (1,'1996-10-25','1970-01-01')    
go

-- ���� ���������� ��������
Exec [����� ������] 3, '���������'
Exec [����� �������� �������] 3,1,NULL,NULL
Exec [����� ������������] Morbid,qwerty
Exec [����� ������] 1,'2007-10-01','2010-12-05'
Exec [�������� ��������� �������] 1,2
Exec [�������� ��������� �������] 1,1