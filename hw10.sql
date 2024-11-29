-- ��������� ���� ����� BarberShop
CREATE DATABASE BarberShopV2;
GO

-- ������������ �������� ���� �����
USE BarberShopV2;
GO

-- ������� ��� �������
CREATE TABLE Barbers (
    BarberId INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Gender NVARCHAR(10) NOT NULL CHECK (Gender IN ('Male', 'Female')),
    Phone NVARCHAR(15),
    Email NVARCHAR(100),
    BirthDate DATE NOT NULL,
    HireDate DATE NOT NULL,
    Position NVARCHAR(20) NOT NULL CHECK (Position IN ('Chief Barber', 'Senior Barber', 'Junior Barber')),
    CONSTRAINT CHK_BarberAge CHECK (DATEDIFF(YEAR, BirthDate, GETDATE()) >= 21)
);

-- ������� ��� ������
CREATE TABLE Services (
    ServiceId INT IDENTITY(1,1) PRIMARY KEY,
    ServiceName NVARCHAR(100) NOT NULL UNIQUE,
    Price MONEY NOT NULL,
    DurationMinutes INT NOT NULL CHECK (DurationMinutes > 0)
);

-- ������� ��� ������ �볺��� ��� �������
CREATE TABLE BarberFeedbacks (
    FeedbackId INT IDENTITY(1,1) PRIMARY KEY,
    BarberId INT NOT NULL FOREIGN KEY REFERENCES Barbers(BarberId),
    Rating NVARCHAR(20) NOT NULL CHECK (Rating IN ('Very Bad', 'Bad', 'Normal', 'Good', 'Excellent')),
    FeedbackText NVARCHAR(MAX)
);

-- ������� ��� �������� �������
CREATE TABLE BarberSchedule (
    ScheduleId INT IDENTITY(1,1) PRIMARY KEY,
    BarberId INT NOT NULL FOREIGN KEY REFERENCES Barbers(BarberId),
    AvailableDate DATE NOT NULL,
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    CONSTRAINT CHK_ScheduleTime CHECK (EndTime > StartTime)
);

-- ������� ��� �볺���
CREATE TABLE Clients (
    ClientId INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(15),
    Email NVARCHAR(100)
);

-- ������� ��� ������ �볺���
CREATE TABLE Appointments (
    AppointmentId INT IDENTITY(1,1) PRIMARY KEY,
    ClientId INT NOT NULL FOREIGN KEY REFERENCES Clients(ClientId),
    BarberId INT NOT NULL FOREIGN KEY REFERENCES Barbers(BarberId),
    ServiceId INT NOT NULL FOREIGN KEY REFERENCES Services(ServiceId),
    AppointmentDate DATE NOT NULL,
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    TotalPrice MONEY NOT NULL,
    Rating NVARCHAR(20) CHECK (Rating IN ('Very Bad', 'Bad', 'Normal', 'Good', 'Excellent')),
    FeedbackText NVARCHAR(MAX)
);

-- ����������� ��������� ������� ���-�������
CREATE TRIGGER PreventSingleChiefBarberDeletion
ON Barbers
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Barbers
        WHERE Position = 'Chief Barber'
        AND BarberId NOT IN (SELECT BarberId FROM DELETED)
    )
    BEGIN
        DELETE FROM Barbers WHERE BarberId IN (SELECT BarberId FROM DELETED);
    END
    ELSE
    BEGIN
        PRINT 'Deletion prevented: at least one Chief Barber must exist.';
    END
END;
GO

-- ������� ���������
CREATE FUNCTION GreetUser(@Name NVARCHAR(100))
RETURNS NVARCHAR(200)
AS
BEGIN
    RETURN 'Hello, ' + @Name + '!';
END;

-- �������� ������� ����
CREATE FUNCTION IsYearEven()
RETURNS NVARCHAR(10)
AS
BEGIN
    RETURN CASE WHEN DATEPART(YEAR, GETDATE()) % 2 = 0 THEN 'Even' ELSE 'Odd' END;
END;

-- ������� ��� ���������� �������� �����
CREATE FUNCTION IsPrime(@Number INT)
RETURNS NVARCHAR(10)
AS
BEGIN
    DECLARE @i INT = 2;
    WHILE (@i < @Number)
    BEGIN
        IF (@Number % @i = 0)
            RETURN 'No';
        SET @i = @i + 1;
    END;
    RETURN 'Yes';
END;

-- ��������� ���������: ���������
CREATE PROCEDURE SayHello
AS
BEGIN
    PRINT 'Hello, world!';
END;

-- ��������� ��������� ��� ����
CREATE PROCEDURE GetCurrentTime
AS
BEGIN
    SELECT CONVERT(VARCHAR, GETDATE(), 108) AS CurrentTime;
END;

-- ��������� ���������: �������� �����
CREATE PROCEDURE GetFactorial(@Number INT)
AS
BEGIN
    DECLARE @Result INT = 1;
    WHILE (@Number > 1)
    BEGIN
        SET @Result = @Result * @Number;
        SET @Number = @Number - 1;
    END;
    SELECT @Result AS Factorial;
END;

-- ��������� �����
INSERT INTO Barbers (FullName, Gender, Phone, Email, BirthDate, HireDate, Position)
VALUES ('John Smith', 'Male', '1234567890', 'john@example.com', '1990-01-15', '2020-05-10', 'Chief Barber'),
       ('Jane Doe', 'Female', '0987654321', 'jane@example.com', '1992-08-25', '2022-06-15', 'Junior Barber');

INSERT INTO Services (ServiceName, Price, DurationMinutes)
VALUES ('Haircut', 30.00, 30), 
       ('Beard Trim', 20.00, 20);

-- ������ ������� ���������
SELECT dbo.GreetUser('Nick') AS Greeting;

-- ������ ������� ���������� ����
SELECT dbo.IsYearEven() AS YearType;

-- ������ ��������� ���������
EXEC SayHello;

-- ������ ��������� ��� ���������
EXEC GetFactorial 5;

-- ��������� ��� �������
SELECT * FROM Barbers;

-- ��������� ��� ������
SELECT * FROM Services;
