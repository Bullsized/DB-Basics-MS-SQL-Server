USE SoftUni

--problem 1
SELECT * FROM INFORMATION_SCHEMA.TABLES --so that it returns every table that we have in the DB. everything in this file will be done using keyboard only, no mouse :P

SELECT * FROM Employees

SELECT FirstName, LastName FROM Employees
WHERE FirstName LIKE 'SA%'

--problem 2
SELECT FirstName, LastName FROM Employees
WHERE LastName LIKE '%ei%'

--problem 3
SELECT FirstName FROM Employees --when you have two statements for WHERE you can join them with an "AND"
WHERE DepartmentID IN (3, 10) AND --IN (x, y) means either x, or y
	  HireDate BETWEEN '1995-01-01' AND '2005-12-31' --between is used with an "AND"

--problem 4
SELECT FirstName, LastName FROM Employees
WHERE NOT JobTitle LIKE '%engineer%'

--problem 5
SELECT * FROM Towns

SELECT [Name] FROM Towns
WHERE LEN([Name]) IN (5, 6)
ORDER BY [Name]
--second solution for problem 5
SELECT [Name] FROM Towns
WHERE DATALENGTH(Name) IN (5, 6)
ORDER BY [Name]

--problem 6
SELECT * FROM Towns
WHERE LEFT([Name], 1) IN ('M', 'K', 'B', 'E')
ORDER BY [Name]
--second solution for problem 6
SELECT * FROM Towns
WHERE [Name] LIKE '[MKBE]%'
ORDER BY [Name]

--problem 7
SELECT * FROM Towns
WHERE NOT LEFT([Name], 1) IN ('R', 'D', 'B')
ORDER BY [Name]
--second solution for problem 7
SELECT * FROM Towns
WHERE [Name] LIKE '[^RDB]%'
ORDER BY [Name]
GO

--problem 8
CREATE VIEW V_EmployeesHiredAfter2000 AS
SELECT FirstName, LastName FROM Employees
WHERE DATEPART(YEAR, HireDate) > 2000
GO

--problem 9
SELECT FirstName, LastName FROM Employees
WHERE LEN(LastName) = 5

--problem 10
USE Geography

SELECT * FROM INFORMATION_SCHEMA.TABLES

SELECT * FROM Countries

SELECT CountryName, IsoCode FROM Countries
WHERE CountryName LIKE '%A%A%A%'
ORDER BY IsoCode

--problem 11
SELECT * FROM Peaks
SELECT * FROM Rivers

SELECT PeakName, RiverName, 
LOWER(PeakName + SUBSTRING(RiverName, 2, LEN(RiverName) - 1)) AS [Mix] FROM Peaks, Rivers
WHERE RIGHT(PeakName, 1) = LEFT(RiverName, 1)
ORDER By [Mix]

--problem 12
USE Diablo

SELECT * FROM INFORMATION_SCHEMA.TABLES

SELECT TOP 50 [Name], FORMAT([Start], 'yyyy-MM-dd') AS [Start] FROM Games
WHERE DATEPART (YEAR, [Start]) IN (2011, 2012)
ORDER BY [Start], [Name]

--problem 13
SELECT Username,
SUBSTRING(Email, CHARINDEX('@', Email, 1) + 1, LEN(Email)) AS [Email Provider]
FROM Users
ORDER BY [Email Provider], Username

--problem 14
SELECT Username, IpAddress AS [IP Address] FROM Users
WHERE IpAddress LIKE '___.1%.%.___'
ORDER BY Username

--problem 15
SELECT * FROM Games

SELECT [Name] AS [Game],
CASE
	WHEN DATEPART(HOUR, Start) BETWEEN 0 AND 11 THEN 'Morning'
	WHEN DATEPART(HOUR, Start) BETWEEN 12 AND 17 THEN 'Afternoon'
	WHEN DATEPART(HOUR, Start) BETWEEN 18 AND 24 THEN 'Evening'
END AS [Part of the Day],
CASE
	WHEN Duration <= 3 THEN 'Extra Short'
	WHEN Duration BETWEEN 4 AND 6 THEN 'Short'
	WHEN Duration > 6 THEN 'Long'
	WHEN Duration IS NULL THEN 'Extra Long'
END AS [Duration]
FROM Games
ORDER BY Game, Duration, [Part of the Day]

--problem 16
USE Orders

SELECT * FROM INFORMATION_SCHEMA.TABLES

SELECT * FROM Orders

SELECT ProductName, OrderDate,
DATEADD(DAY, 3, OrderDate) AS [Pay Due],
DATEADD(MONTH, 1, OrderDate) AS [Deliver Due]
FROM Orders

--problem 17 PEOPLE TABLE [not in Judge, decided to still add it]
CREATE TABLE People
(
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] VARCHAR(50),
	Birthdate DATE
)

INSERT INTO People VALUES
('Victor', '2000-12-07'),
('Steven', '1992-09-10'),
('Stephen', '1910-09-19'),
('John', '2010-01-06')

SELECT [Name],
DATEDIFF(YEAR, Birthdate, GETDATE()) AS [Age in Years],
DATEDIFF(MONTH, Birthdate, GETDATE()) AS [Age in Months],
DATEDIFF(DAY, Birthdate, GETDATE()) AS [Age in Days],
DATEDIFF(MINUTE, Birthdate, GETDATE()) AS [Age in Minutes]
FROM People