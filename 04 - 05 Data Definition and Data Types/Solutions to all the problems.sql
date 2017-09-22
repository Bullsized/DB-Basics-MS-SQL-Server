--problem 1
CREATE DATABASE Minions
GO

USE Minions
GO

--problem 2
CREATE TABLE Minions (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	Name NVARCHAR(50) NOT NULL,
	Age INT NOT NULL
)
GO

CREATE TABLE Towns (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	Name NVARCHAR(50) NOT NULL
)
GO

--problem 3
ALTER TABLE Minions
ADD TownId INT FOREIGN KEY REFERENCES Towns(Id)
GO

--problem 4
INSERT INTO Towns(Name) VALUES
('Sofia'),
('Plovdiv'),
('Varna')
GO

INSERT INTO Minions(Name, Age) VALUES
('Kevin', '22', 1),
('Bob', '15', 3),
('Steward', '0', 2)
GO

--problem 5
TRUNCATE TABLE Minions
GO

--problem 6
DROP TABLE Minions
DROP TABLE Towns
GO

--problem 7
CREATE TABLE People (
	Id INT PRIMARY KEY IDENTITY NOT NULL CHECK (Id < 2147483647),
	Name NVARCHAR(200) NOT NULL,
	Picture VARBINARY CHECK (DATALENGTH(Picture)<900*1024),
	Height DECIMAL(10,2),
	[Weight] DECIMAL(10,2),
	Gender CHAR(1) NOT NULL CHECK (Gender = 'm' OR Gender = 'f'),
	Birthdate DATE NOT NULL,
	Biography NVARCHAR(MAX)
)
--GO

INSERT INTO People (Name, Picture, Height, Weight, Gender, Birthdate, Biography) VALUES
('Thor', NULL, 1.80, 75, 'm', '05-05-1666', 'The Lightning God!')

INSERT INTO People (Name, Picture, Height, Weight, Gender, Birthdate, Biography) VALUES
('The Incredible Hulk', NULL, 3.50, 187, 'm', '09-27-1955', 'The Green Mean Machine!')

INSERT INTO People (Name, Picture, Height, Weight, Gender, Birthdate, Biography) VALUES
('Ironman', NULL, 1.85, 70, 'm', '08-21-1978', 'The Flying Living Heart')

INSERT INTO People (Name, Picture, Height, Weight, Gender, Birthdate, Biography) VALUES
('Captain America', NULL, 1.64, 55, 'm', '10-12-1933', 'The Shield to Protect!')

INSERT INTO People (Name, Picture, Height, Weight, Gender, Birthdate, Biography) VALUES
('I AM GROOT', NULL, 5.25, 525, 'm', '01-01-1000', 'I AM GROOT!')

--SELECT * FROM People

--problem 8
CREATE TABLE Users (
	Id INT UNIQUE IDENTITY NOT NULL CHECK (Id < 2147483647),
	Username NVARCHAR(30) NOT NULL,
	Password VARCHAR(26) NOT NULL, 
	ProfilePicture VARBINARY CHECK (DATALENGTH(ProfilePicture)<900*1024),
	LastLoginTime DATE,
	IsDeleted BIT
)

INSERT INTO Users (Username, Password, ProfilePicture, LastLoginTime, IsDeleted) VALUES
('Voltron', 'mkoijnbhuygv', NULL, '11-11-1911', 'true')

INSERT INTO Users (Username, Password, ProfilePicture, LastLoginTime, IsDeleted) VALUES
('BeastWars', '123456789', NULL, '01-07-1999', 'false')

INSERT INTO Users (Username, Password, ProfilePicture, LastLoginTime, IsDeleted) VALUES
('MichelleVayan', 'brumbrumbrum', NULL, '10-15-1985', 'true')

INSERT INTO Users (Username, Password, ProfilePicture, LastLoginTime, IsDeleted) VALUES
('The Fruits', 'bananamama', NULL, '12-22-1965', 'true')

INSERT INTO Users (Username, Password, ProfilePicture, LastLoginTime, IsDeleted) VALUES
('Chip and Dale', 'spasitelniq_otrqd', NULL, '04-22-1966', 'true')

--SELECT * FROM Users

--problem 9 (Using SQL queries modify table Users from the previous task. First remove current primary key then create new primary key that would be the combination of fields Id and Username.)
ALTER TABLE Users
DROP CONSTRAINT PK_Users

ALTER TABLE Users
ADD CONSTRAINT PK_Users PRIMARY KEY (Id, Username)

--problem 10 (Using SQL queries modify table Users. Add check constraint to ensure that the values in the Password field are at least 5 symbols long.)
ALTER TABLE Users
ADD CONSTRAINT PasswordMinLength
CHECK (LEN(Password) > 5)

--problem 11 (Using SQL queries modify table Users. Make the default value of LastLoginTime field to be the current time.)
ALTER TABLE Users
ADD DEFAULT GETDATE() FOR LastLoginTime

--problem 12 (Using SQL queries modify table Users. Remove Username field from the primary key so only the field Id would be primary key. Now add unique constraint to the Username field to ensure that the values there are at least 3 symbols long.)
ALTER TABLE Users
DROP CONSTRAINT PK_Users

ALTER TABLE Users
ADD CONSTRAINT PK_Users PRIMARY KEY (Id)

ALTER TABLE Users
ADD CONSTRAINT uc_Username UNIQUE (Username)

ALTER TABLE Users
ADD CONSTRAINT uc_UsernameLength CHECK (LEN(Username) >= 3)

--problem 13
CREATE DATABASE Movies 
GO

USE Movies
GO

CREATE TABLE Directors (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	DirectorName NVARCHAR(100) NOT NULL,
	Notes NVARCHAR(MAX)
)

CREATE TABLE Genres (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	GenreName NVARCHAR(30) NOT NULL,
	Notes NVARCHAR(MAX)
)

CREATE TABLE Categories (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	CategoryName NVARCHAR(50) NOT NULL,
	Notes NVARCHAR(MAX)
)

CREATE TABLE Movies (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	Title NVARCHAR(50) NOT NULL,
	DirectorId INT FOREIGN KEY REFERENCES Directors(Id),
	CopyrightYear DATE,
	[Length] BIGINT,
	GenreId INT FOREIGN KEY REFERENCES Genres(Id),
	Rating INT,
	Notes NVARCHAR(MAX)
)

INSERT INTO Directors (DirectorName, Notes) VALUES
('Uwe Boll', 'Total Idiot'),
('Guy Ritchie', 'It''s been emotional'),
('Martin Scorseze', 'Let''s depart'),
('Steven Soderbergh', 'Ocean''s 11, 12, 13, 15?'),
('Wachovski Sisters', 'Take the red pill, take the blue pill')

SELECT * FROM Directors

INSERT INTO Genres(GenreName, Notes) VALUES
('Horror', 'scary shait'),
('Thriller', 'from Michael Jackson'),
('Comedy', 'a genre back in the days'),
('Drama', 'when you wanna take the girls out on a movie'),
('Action', 'kaBOOM')

SELECT * FROM Genres

INSERT INTO Categories(CategoryName, Notes) VALUES
('First Cat', ''),
('Second Cat', 'string.Empty'),
('Third Cat, Lotta CATS', '[zero]'),
('Fifth Cat', 'null'),
('Seventh Cat Cat Cat', '')

SELECT * FROM Categories

INSERT INTO Movies (Title, DirectorId, CopyrightYear, [Length], GenreId, Rating, Notes) VALUES
('Snatch', 2, '1999', '103', 3, 10, 'drop the gun, fat boy')

INSERT INTO Movies (Title, DirectorId, CopyrightYear, [Length], GenreId, Rating, Notes) VALUES
('The Matrix', 5, '1997', '130', 5, 10, 'I know kung-fu!')

INSERT INTO Movies (Title, DirectorId, CopyrightYear, [Length], GenreId, Rating, Notes) VALUES
('Bob sus zele', 1, '2000', '120', 3, 1, 'make a mess!')

INSERT INTO Movies (Title, DirectorId, CopyrightYear, [Length], GenreId, Rating, Notes) VALUES
('The Girlfriend', 4, '2007', '90', 4, 3, 'Sasha Grey ~')

INSERT INTO Movies (Title, DirectorId, CopyrightYear, [Length], GenreId, Rating, Notes) VALUES
('Wolf from Wall Street', 3, '2015', '145', 1, 9, 'I know kung-fu!')

SELECT * FROM Movies

--problem 14
CREATE DATABASE CarRental 
GO

USE CarRental
GO

CREATE TABLE Categories (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	CategoryName NVARCHAR(50),
	DailyRate DECIMAL(5, 2) NOT NULL,
	WeeklyRate DECIMAL(5, 2) NOT NULL,
	MonthlyRate DECIMAL(5, 2) NOT NULL,
	WeekendRate DECIMAL(5, 2) NOT NULL
)
INSERT INTO Categories (CategoryName, DailyRate, WeeklyRate, MonthlyRate, WeekendRate) VALUES
('monster trucks', 5.21, 23.5, 125.5, 45.5)

INSERT INTO Categories (CategoryName, DailyRate, WeeklyRate, MonthlyRate, WeekendRate) VALUES
('tesla cars', 51.21, 123.5, 225.5, 435.5)

INSERT INTO Categories (CategoryName, DailyRate, WeeklyRate, MonthlyRate, WeekendRate) VALUES
('opel astrak', 0.21, 3.5, 5.5, 1.5)

CREATE TABLE Cars (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	PlateNumber VARCHAR(8),
	Manufacturer VARCHAR(30),
	Model VARCHAR(30),
	CarYear DATE,
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id),
	Doors REAL,
	Picture VARBINARY(MAX),
	Condition NVARCHAR(100),
	Available BIT
)

INSERT INTO Cars (PlateNumber, Manufacturer, Model, CarYear, CategoryId, Doors, Condition, Available) VALUES
('B 0525 A', 'Opel', 'Astra', '1994', 3, 4, 'BRAND NEW WITH RUST', 1)

INSERT INTO Cars (PlateNumber, Manufacturer, Model, CarYear, CategoryId, Doors, Condition, Available) VALUES
('A 2241 X', 'Opel', 'Cadet', '1990', 1, 2, 'BRAND NEW WITH RUST', 1)

INSERT INTO Cars (PlateNumber, Manufacturer, Model, CarYear, CategoryId, Doors, Condition, Available) VALUES
('X 4452 A', 'Opel', 'Vectra', '1997', 3, 4, 'BRAND NEW WITH RUST', 2)

CREATE TABLE Employees (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Title NVARCHAR(30),
	Notes NVARCHAR(MAX)
)

INSERT INTO Employees (FirstName, LastName) VALUES
('Dancho', 'Lechkov'),
('Hristo', 'Stoichkov'),
('Emil', 'Kremenliev')

CREATE TABLE Customers (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	DriverLicenceNumber NVARCHAR(15) NOT NULL,
	FullName NVARCHAR(100) NOT NULL,
	Address NVARCHAR(500),
	City NVARCHAR(50),
	ZIPCode NVARCHAR(10),
	Notes NVARCHAR(200)
)

INSERT INTO Customers (DriverLicenceNumber, FullName) VALUES
('Bql', 'Georgi Ivanov'),
('Zelen', 'Petur Hubchev'),
('Cherven', 'Dimitur Penev')

CREATE TABLE RentalOrders (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id),
	CustomerId INT FOREIGN KEY REFERENCES Customers(Id),
	CarId INT,
	TankLevel INT,
	KilometrageStart INT,
	KilometrageEnd INT,
	TotalKilometrage INT,
	StartDate DATE,
	EndDate DATE,
	TotalDays AS DATEDIFF(DAY, StartDate, EndDate),
	RateApplied INT,
	TaxRate DECIMAL(5, 2),
	OrderStatus NVARCHAR(50),
	Notes NVARCHAR(MAX)
)

INSERT INTO RentalOrders (EmployeeId, CustomerId, StartDate, EndDate) VALUES
(1, 1, '05/05/1995', '05/10/1995'),
(2, 1, '10/10/2010', '10/12/2010'),
(3, 3, '06/07/2017', '09/07/2017')

--problem 15
CREATE DATABASE Hotel
USE Hotel

CREATE TABLE Employees (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Title NVARCHAR(100),
	Notes NVARCHAR(MAX)
)

INSERT INTO Employees (FirstName, LastName) VALUES
('Michael', 'Jackson'),
('Michael', 'Jordan'),
('Michael', 'Keaton')

CREATE TABLE Customers (
	AccountNumber INT UNIQUE IDENTITY NOT NULL,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	PhoneNumber INT,
	EmergencyName NVARCHAR(100),
	EmergencyNumber INT,
	Notes NVARCHAR(MAX)
)

INSERT INTO Customers (FirstName, LastName) VALUES
('Josh', 'Brolin'),
('Jon', 'Snow'),
('Jake', 'Gylenhaal')

CREATE TABLE RoomStatus (
	RoomStatus NVARCHAR(50) PRIMARY KEY NOT NULL,
	Notes NVARCHAR(MAX)
)

INSERT INTO RoomStatus (RoomStatus) VALUES
('Occupied'),
('Available'),
('Cleaning')

CREATE TABLE RoomTypes (
	RoomType NVARCHAR(50) PRIMARY KEY NOT NULL,
	Notes NVARCHAR(MAX)
)

INSERT INTO RoomTypes (RoomType) VALUES
('4 person'),
('2 person'),
('Boksonierka, brat')

CREATE TABLE BedTypes (
	BedType NVARCHAR(50) PRIMARY KEY NOT NULL,
	Notes NVARCHAR(MAX)
)

INSERT INTO BedTypes (BedType) VALUES
('King'),
('Queen'),
('Midget')

CREATE TABLE Rooms (
	RoomNumber INT PRIMARY KEY IDENTITY NOT NULL,
	RoomType NVARCHAR(50) FOREIGN KEY REFERENCES RoomTypes(RoomType),
	BedType NVARCHAR(50) FOREIGN KEY REFERENCES BedTypes(BedType),
	Rate DECIMAL(6,2),
	RoomStatus NVARCHAR(50),
	Notes NVARCHAR(MAX)
)

INSERT INTO Rooms (Rate) VALUES
(12.55),
(43.99),
(60.33)

CREATE TABLE Payments (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	EmployeeId INT,
	PaymentDate DATE,
	AccountNumber INT,
	FirstDateOccipied DATE,
	LastDateOccupied DATE,
	TotalDays AS DATEDIFF(DAY, FirstDateOccipied, LastDateOccupied),
	AmountCharged DECIMAL(10, 2),
	TaxRate DECIMAL(6, 2),
	TaxAmount DECIMAL(6, 2),
	PaymentTotal DECIMAL(12, 2),
	Notes NVARCHAR(MAX)
)

INSERT INTO Payments (EmployeeId, PaymentDate, AmountCharged) VALUES
(1, GETDATE(), 60.25),
(2, GETDATE(), 160.25),
(3, GETDATE(), 460.25)

CREATE TABLE Occupancies (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	EmployeeId INT,
	DateOccipied DATE,
	AccountNumber INT,
	RoomNumber INT,
	RateApplied DECIMAL(6, 2),
	PhoneCharge DECIMAL(10, 2),
	Notes NVARCHAR(MAX)
)

INSERT INTO Occupancies (EmployeeId, RateApplied, Notes) VALUES
(1, 55.55, 'enough is enough'),
(2, 15.55, 'now I know how the typewriters feel'),
(3, 35.55, 'these exercises are obsolete')

--problem 16
CREATE DATABASE SoftUni
GO  

USE SoftUni
GO

CREATE TABLE Towns (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] NVARCHAR(50)
)

CREATE TABLE Addresses (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	AddressText NVARCHAR(100),
	TownId INT FOREIGN KEY REFERENCES Towns(Id)
)

CREATE TABLE Departments (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	Name NVARCHAR(50)
)

CREATE TABLE Employees
(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	FirstName NVARCHAR(50),
	MiddleName NVARCHAR(50),
	LastName NVARCHAR(50),
	JobTitle NVARCHAR(35),
	DepartmentId INT FOREIGN KEY REFERENCES Departments(Id),
	HireDate DATE,
	Salary DECIMAL(10,2),
	AddressId INT FOREIGN KEY REFERENCES Addresses(Id)
)

--problem 17
BACKUP DATABASE SoftUni
	TO DISK = 'D:\softuni-backup.bak' --location where the backup file will be saved
		WITH FORMAT,
			MEDIANAME = 'DB Back up',
			NAME = 'SoftUni DataBase 2017-09-22';
GO

RESTORE DATABASE SoftUni
FROM DISK = 'D:\softuni-backup.bak' --location of the db on your hard drive
GO

--problem 18
USE SoftUni

INSERT INTO Towns ([Name]) VALUES
('Sofia'),
('Plovdiv'),
('Varna'),
('Burgas')

INSERT INTO Departments (Name) VALUES
('Engineering'),
('Sales'),
('Marketing'),
('Software Development'),
('Quality Assurance')

INSERT INTO Employees (FirstName, MiddleName, LastName, JobTitle, DepartmentId, HireDate, Salary) VALUES
('Ivan', 'Ivanov', 'Ivanov', '.NET Developer', 4, '2013/01/02', 3500.00),
('Petar', 'Petrov', 'Petrov', 'Senior Engineer', 1, '2004/02/03', 4000.00),
('Maria', 'Petrova', 'Ivanova', 'Intern', 5, '2016/28/08', 525.25),
('Georgi', 'Teziev', 'Ivanov', 'CEO', 2, '2007/09/12', 3000.00),
('Peter', 'Pan', 'Pan', 'Intern', 3, '2016/28/08', 599.88)
--it's quite possible for the dates to be reversed, e.g. the last one to be 2016/08/28, depends on your PC's settings

--problem 19
SELECT * FROM Towns

SELECT * FROM Departments

SELECT * FROM Employees

--problem 20
SELECT * FROM Towns ORDER BY Name

SELECT * FROM Departments ORDER BY Name

SELECT * FROM Employees ORDER BY Salary DESC --this is order by descending

--problem 21
SELECT Name FROM Towns ORDER BY Name

SELECT Name FROM Departments ORDER BY Name

SELECT FirstName, LastName, JobTitle, Salary FROM Employees ORDER BY Salary DESC --the listing should be done with a comma

--problem 22
UPDATE Employees
SET Salary += Salary * 0.1  

SELECT Salary FROM Employees

--problem 23
USE Hotel

UPDATE Payments
SET TaxRate -= TaxRate * 0.03

SELECT TaxRate FROM Payments

--problem 24
DELETE FROM Occupancies
SELECT * FROM Occupancies