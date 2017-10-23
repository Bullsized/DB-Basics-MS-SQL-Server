CREATE DATABASE ReportService
GO

USE ReportService
GO

--1
CREATE TABLE Users
(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	Username NVARCHAR(30) UNIQUE NOT NULL,
	[Password] NVARCHAR(50) NOT NULL,
	[Name] NVARCHAR(50),
	Gender CHAR CHECK(Gender = 'M' OR Gender = 'F'),
	BirthDate DATETIME,
	Age INT,
	Email NVARCHAR(50) NOT NULL
)

CREATE TABLE Departments
(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE [Status]
(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	Label VARCHAR(30) NOT NULL
)

CREATE TABLE Employees
(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	FirstName NVARCHAR(25),
	LastName NVARCHAR(25),
	Gender CHAR CHECK(Gender = 'M' OR Gender = 'F'),
	BirthDate DATETIME,
	Age INT,
	DepartmentId INT FOREIGN KEY REFERENCES Departments(Id) NOT NULL
)

CREATE TABLE Categories
(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] VARCHAR(50) NOT NULL,
	DepartmentId INT FOREIGN KEY REFERENCES Departments(Id)
)

CREATE TABLE Reports
(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
	StatusId INT FOREIGN KEY REFERENCES [Status](Id) NOT NULL,
	OpenDate DATETIME NOT NULL,
	CloseDate DATETIME,
	Description VARCHAR(200),
	UserId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id)
)

--2
INSERT INTO Employees (FirstName, LastName, Gender, BirthDate, DepartmentId) VALUES
('Marlo', 'O’Malley', 'M', '9/21/1958', 1),
('Niki', 'Stanaghan', 'F', '11/26/1969', 4),
('Ayrton', 'Senna', 'M', '03/21/1960', 9),
('Ronnie', 'Peterson', 'M', '02/14/1944', 9),
('Giovanna', 'Amati', 'F', '07/20/1959', 5)

INSERT INTO Reports (CategoryId, StatusId, OpenDate, CloseDate, [Description], UserId, EmployeeId) VALUES
(1,	1, '04/13/2017', NULL, 'Stuck Road on Str.133', 6, 2),
(6,	3, '09/05/2015', '12/06/2015', 'Charity trail running', 3, 5),
(14, 2, '09/07/2015', NULL, 'Falling bricks on Str.58', 5, 2),
(4,	3, '07/03/2017', '07/06/2017', 'Cut off streetlight on Str.11', 1, 1)

--3
-- Switch all report’s status to “in progress” where it is currently “waiting” for the “Streetlight” category (look up the category ID and status ID’s manually, there is no need to use table joins).
UPDATE Reports
SET StatusId = 2
WHERE StatusId = 1 AND CategoryId = 4

--4
DELETE FROM Reports
WHERE StatusId = 4

--5
SELECT Username, Age 
FROM Users
ORDER BY Age, Username DESC

--6
SELECT [Description], OpenDate FROM Reports
WHERE EmployeeId IS NULL
ORDER BY OpenDate, [Description]

--7
SELECT e.FirstName, e.LastName, r.Description, FORMAT(r.OpenDate, 'yyyy-MM-dd') FROM Reports AS r
INNER JOIN Employees AS e
ON e.Id = r.EmployeeId
WHERE r.EmployeeId IS NOT NULL
ORDER BY r.EmployeeId, r.OpenDate, r.Id

--8
SELECT c.Name, COUNT(*) AS ReportsNumber FROM Categories AS c
INNER JOIN Reports AS r ON r.CategoryId = c.Id
GROUP BY c.Name
ORDER BY ReportsNumber DESC, c.Name

--9
SELECT c.Name AS [CategoryName], COUNT(e.Id) AS [Employees Number] FROM Categories AS c
INNER JOIN Departments AS d
ON d.Id = c.DepartmentId
INNER JOIN Employees AS e
ON e.DepartmentId = d.Id
GROUP BY c.Name
ORDER BY c.Name

--10
SELECT CONCAT(e.FirstName, ' ', e.LastName) AS [Name], 
	COUNT(r.UserId) AS [Users Number] 
FROM Employees AS e
LEFT OUTER JOIN Reports AS r
ON r.EmployeeId = e.Id
GROUP BY CONCAT(e.FirstName, ' ', e.LastName)
ORDER BY [Users Number] DESC, [Name]

--11
SELECT r.OpenDate, 
	r.[Description], 
	u.Email AS [Reporter Email] 
FROM Reports AS r
INNER JOIN Users AS u
ON u.Id = r.UserId
WHERE CloseDate IS NULL 
AND LEN(Description) > 20 
AND [Description] LIKE '%str%' 
AND CategoryId IN 
	(
	SELECT c.Id FROM Categories AS c
	JOIN Departments d ON d.Id = c.DepartmentId
	WHERE d.[Name] IN ('Infrastructure', 'Emergency', 'Roads Maintenance')
	)
ORDER BY OpenDate, u.Email, r.Id

--12
SELECT DISTINCT c.[Name] AS [Category Name] FROM Categories AS c
FULL JOIN Reports AS r
ON r.CategoryId = c.Id
FULL JOIN Users AS u
ON u.Id = r.UserId
WHERE DATEPART(MONTH, u.BirthDate) = DATEPART(MONTH, r.OpenDate) 
AND DATEPART(DAY, u.BirthDate) = DATEPART(DAY, r.OpenDate)
ORDER BY [Category Name]

--13
SELECT u.Username FROM Users AS u
INNER JOIN Reports AS r
ON r.UserId = u.Id
WHERE u.Username LIKE '[0-9]%' AND SUBSTRING(u.Username, 1, 1) = CAST(r.CategoryId AS nvarchar)
OR Username LIKE '%[0-9]' AND RIGHT(u.Username, 1) = CAST(r.CategoryId AS nvarchar)
ORDER BY u.Username

/*  tryout ~ 
	u.Username LIKE '[0-9]%' AND CONVERT(INT, LEFT(Username, 1)) = r.CategoryId
	OR Username LIKE '%[0-9]' AND CONVERT(INT, RIGHT(Username, 1)) = r.CategoryId
	ORDER BY u.Username
*/

--100/100 SOLUTION V V V
SELECT u.Username FROM Users AS u
INNER JOIN Reports AS r
ON r.UserId = u.Id
INNER JOIN Categories AS c
ON r.CategoryId = c.Id
WHERE 
	(
	LEFT(u.Username, 1) LIKE '[0-9]' AND c.Id = TRY_CAST(LEFT(u.Username, 1) AS INT)
	)
	OR 
	(
	RIGHT(u.Username, 1) LIKE '[0-9]' AND c.Id = TRY_CAST(RIGHT(u.Username, 1) AS INT)
	)
GROUP BY u.Username
ORDER BY u.Username

--14
WITH CTE_OpenedReports(EmployeeId, Count) AS
(
	SELECT e.Id, COUNT(r.Id) FROM Employees AS e
	INNER JOIN Reports AS r
	ON e.Id = r.EmployeeId
	WHERE DATEPART(YEAR, r.OpenDate) = 2016
	GROUP BY e.Id
),

CTE_ClosedReports(EmployeeId, Count) AS
(
	SELECT e.Id, COUNT(r.Id) FROM Employees AS e
	INNER JOIN Reports AS r
	ON e.Id = r.EmployeeId
	WHERE DATEPART(YEAR, r.CloseDate) = 2016
	GROUP BY e.Id
)

SELECT CONCAT(e.FirstName, ' ', e.LastName) AS [Name],
	CONCAT(ISNULL(c.Count, 0), '/', ISNULL(o.Count, 0)) AS [Closed Open Reports]
FROM CTE_ClosedReports AS c
FULL JOIN CTE_OpenedReports AS o
ON c.EmployeeId = o.EmployeeId
INNER JOIN Employees AS e
ON c.EmployeeId = e.Id OR o.EmployeeId = e.Id
ORDER BY [Name], e.Id

--15
SELECT d.[Name], 
	CASE 
	WHEN CAST(AVG(DATEDIFF(DAY, r.OpenDate, r.CloseDate)) AS VARCHAR(20)) IS NULL THEN 'no info'
	ELSE CAST(AVG(DATEDIFF(DAY, r.OpenDate, r.CloseDate)) AS VARCHAR(20))
	END AS [Average Duration] 
	FROM Departments AS d
INNER JOIN Categories AS c
ON c.DepartmentId = d.Id
INNER JOIN Reports AS r
ON r.CategoryId = c.Id
GROUP BY d.[Name]
GO

--16
WITH CTE_TotalReportsByDepartment (DepartmentId, Count) AS
(
	SELECT d.Id, COUNT(r.Id)
	FROM Departments AS d
	INNER JOIN Categories AS c
	ON d.Id = c.DepartmentId
	INNER JOIN Reports AS r
	ON r.CategoryId = c.Id
	GROUP BY d.Id
)

SELECT d.[Name] AS [Department Name],
	c.[Name] AS [Category Name],
	CAST(ROUND(CEILING(CAST(COUNT(r.Id) AS DECIMAL(7,2)) * 100)/tr.Count, 0) AS INT) AS [Percentage]
FROM Departments AS d
INNER JOIN CTE_TotalReportsByDepartment AS tr 
ON d.Id = tr.DepartmentId
INNER JOIN Categories AS c 
ON c.DepartmentId = d.Id
INNER JOIN Reports AS r
ON r.CategoryId = c.Id
GROUP BY d.[Name], c.[Name], tr.Count
GO

--17
CREATE FUNCTION udf_GetReportsCount (@employeeId INT, @statusId INT)
RETURNS INT
AS
BEGIN
	RETURN (SELECT COUNT(Id) FROM Reports
			WHERE EmployeeId = @employeeId 
			AND StatusId = @statusId)
END
GO

--18
CREATE PROCEDURE usp_AssignEmployeeToReport (@employeeId INT, @reportId INT)
AS
BEGIN
	DECLARE @employeeDept INT = (SELECT DepartmentId FROM Employees
								  WHERE Id = @employeeId)

	DECLARE @JobDept INT = (SELECT DepartmentId 
							  FROM Categories AS c
						INNER JOIN Reports AS r
								ON r.CategoryId = c.Id
							 WHERE r.Id = @reportId)

	IF (@employeeDept = @JobDept)
	BEGIN
		UPDATE Reports
		   SET EmployeeId = @employeeId
		 WHERE Id = @reportId
	END
	ELSE
	BEGIN
		RAISERROR ('Employee doesn''t belong to the appropriate department!', 16, 1)
	END
END
GO

--19
CREATE TRIGGER tr_CloseReports 
			ON Reports
		 AFTER UPDATE
		    AS
		 BEGIN

	UPDATE Reports
	   SET StatusId = 3
	  FROM deleted AS d
INNER JOIN inserted AS i 
		ON i.Id = d.Id
	 WHERE i.CloseDate IS NOT NULL
		   
		   END

--20
/* 
	props to Ruskovweb for this solution, link to his solutions:
	https://github.com/ruskovweb/SoftUni/tree/master/03-C%23%20DB%20Fundamentals/01-Databases%20Basics%20-%20MS%20SQL%20Server/Databases%20MSSQL%20Server%20Exam%20-%2022%20October%202017/DBBasicExam-22.10.2017
	
*/
SELECT [Category Name],
	Waitings + InProgress AS [Reports Number],
	CASE
	WHEN Waitings > InProgress
	THEN 'waiting'
	WHEN Waitings < InProgress
	THEN 'in progress'
	ELSE 'equal'
	END AS [Main Status]
FROM (
		SELECT c.[Name] AS [Category Name], 
		COUNT(CASE WHEN StatusId = 1 THEN 1 ELSE NULL END) AS [Waitings],
		COUNT(CASE WHEN StatusId = 2 THEN 1 ELSE NULL END) AS [InProgress]
		FROM Reports AS r
		INNER JOIN Categories AS c
		ON c.Id = r.CategoryId
		WHERE StatusId IN 
			(
			SELECT Id 
			FROM [Status] 
			WHERE Label IN ('waiting', 'in progress')
			)
		GROUP BY r.CategoryId, c.[Name]
	) AS Temp
ORDER BY [Category Name], [Reports Number], [Main Status]

/* jibberish tryouts
SELECT c.[Name], 
	COUNT(r.Id) AS [Reports Number]--,
--	s.Label AS [Main Status]
FROM Categories AS c
INNER JOIN Reports AS r
ON r.CategoryId = c.Id
--INNER JOIN [Status] AS s
--ON s.Id = r.StatusId
WHERE r.StatusId IN (1, 2)
GROUP BY c.[Name]--, s.Label
ORDER BY c.[Name]

SELECT c.[Name], 
	COUNT(r.Id) AS [Reports Number],
	CASE
	WHEN COUNT(r.Id) % 2 = 0 THEN 'equal'
	ELSE s.Label
	END AS [Main Status]
FROM Categories AS c
INNER JOIN Reports AS r
ON r.CategoryId = c.Id
INNER JOIN [Status] AS s
ON s.Id = r.StatusId
WHERE r.StatusId IN (1, 2)
GROUP BY c.[Name], s.Label
ORDER BY c.[Name]

SELECT *
INTO InProgressTable
FROM (SELECT c.[Name], 
	COUNT(r.Id) AS [Reports Number],
	s.Label AS [Main Status]
FROM Categories AS c
INNER JOIN Reports AS r
ON r.CategoryId = c.Id
INNER JOIN [Status] AS s
ON s.Id = r.StatusId
WHERE r.StatusId IN (1, 2) AND s.Label = 'in progress'
GROUP BY c.[Name], s.Label) AS InProgress

SELECT *
INTO WaitingTable
FROM (SELECT c.[Name], 
	COUNT(r.Id) AS [Reports Number],
	s.Label AS [Main Status]
FROM Categories AS c
INNER JOIN Reports AS r
ON r.CategoryId = c.Id
INNER JOIN [Status] AS s
ON s.Id = r.StatusId
WHERE r.StatusId IN (1, 2) AND s.Label = 'waiting'
GROUP BY c.[Name], s.Label) AS Waiting

SELECT * FROM WaitingTable AS WT
FULL JOIN InProgressTable AS PT
ON PT.Name = WT.Name

SELECT
CASE
WHEN WT.[Reports Number] > PT.[Reports Number] THEN WT.[Name] AS [Category Name], SUM(WT.[Reports Number] + PT.[Reports Number]) AS [Reports Number], 'waiting' AS [Main Status]
WHEN WT.[Reports Number] < PT.[Reports Number] THEN PT.[Name] AS [Category Name], SUM(WT.[Reports Number] + PT.[Reports Number]) AS [Reports Number], 'in progress' AS [Main Status]
WHEN WT.[Reports Number] = PT.[Reports Number] THEN WT.[Name] AS [Category Name], SUM(WT.[Reports Number] + PT.[Reports Number]) AS [Reports Number], 'equal' AS [Main Status]
FROM WaitingTable AS WT
FULL JOIN InProgressTable AS PT
ON PT.Name = WT.Name

pretty much useless... the best way to do it is with 3 subqueries ~
*/