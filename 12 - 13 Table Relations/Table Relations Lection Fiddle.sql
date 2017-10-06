CREATE DATABASE TableRelationsDemo
GO

USE TableRelationsDemo
GO

CREATE TABLE Mountains
(
	Id INT IDENTITY,
	[Name] VARCHAR(50),
	CONSTRAINT PK_Mountains PRIMARY KEY (Id)
)

ALTER TABLE Mountains ALTER COLUMN [Name] VARCHAR(50) NOT NULL -- if you want to add the NOT NULL clause

CREATE TABLE Peaks
(
	Id INT IDENTITY,
	[Name] VARCHAR(50),
	MountainId INT NOT NULL, --FOREIGN KEY REFERENCES Mountains(Id)  second way to do this, otherwise use the CONSTRAINT
	CONSTRAINT PK_Peaks PRIMARY KEY (Id), --PK = Primary Key
	CONSTRAINT FK_Peaks_Mountains FOREIGN KEY (MountainId) REFERENCES Mountains(Id) --FK = Foreign Key
)

ALTER TABLE Peaks ALTER COLUMN [Name] VARCHAR(50) NOT NULL

INSERT INTO Mountains VALUES
('Rila'), 
('Pirin')

INSERT INTO Peaks VALUES
('Musala', 1), --if you try NULL in the place of 1: Msg 515, Level 16, State 2, Line 31 Error will show up
('Malyovitsa', 1),
('Vihren', 2),
('Kutelo', 2)

/* here if you make a syntax error, the identity will not continue forward. (e.g. if you add a ','to the query);
yet if you make an exception - the identity will continue on */

SELECT * FROM Peaks

CREATE TABLE Employees
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Projects
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE EmployeesProjects --many-to-many mapping table
(
	EmployeeId INT NOT NULL,
	ProjectId INT NOT NULL, --you can separate the next 3 commands with an empty line and put the capital commands on a new line as well
	CONSTRAINT PK_EmployeesProjects PRIMARY KEY (EmployeeId, ProjectId),
	CONSTRAINT FK_EmployeesProjects_Employees FOREIGN KEY (EmployeeId) REFERENCES Employees(Id) ON DELETE CASCADE,
	CONSTRAINT FK_EmployeesProjects_Projects FOREIGN KEY (ProjectId) REFERENCES Projects(Id)
)

SELECT * FROM INFORMATION_SCHEMA.TABLES

INSERT INTO Employees ([Name]) VALUES
('Hulk'),
('Captain America'),
('Thor'),
('Iron Man')

INSERT INTO Projects ([Name]) VALUES
('Comics'),
('Mooviez'),
('Guardians'),
('Clips')

SELECT * FROM Employees
SELECT * FROM Projects

INSERT INTO EmployeesProjects (EmployeeId, ProjectId) VALUES
(1, 1),
(2, 4),
(3, 2),
(4, 3)

SELECT * FROM Employees AS e
JOIN EmployeesProjects AS ep ON ep.EmployeeId = e.Id
JOIN Projects AS p ON p.Id = ep.ProjectId



CREATE TABLE Drivers --one-to-many mapping table
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Cars 
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	DriverId INT FOREIGN KEY REFERENCES Drivers(Id) UNIQUE
)

INSERT INTO Drivers ([Name]) VALUES
('Jim Raynor'),
('Kerigan')

INSERT INTO Cars ([Name], DriverId) VALUES
('Battlecruiser', 1),
('Wraith', 2) --the Unique constraint cannot be overridden, once set - it forever stays a Wraith

SELECT Cars.Name, Drivers.Name FROM Cars 
JOIN Drivers ON Drivers.Id = Cars.Id



--CASCADING
SELECT * FROM EmployeesProjects