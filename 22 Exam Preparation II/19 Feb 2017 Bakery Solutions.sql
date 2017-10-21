--Database Basics MS SQL Exam – 19 Feb 2017
CREATE DATABASE Bakery
GO

USE Bakery
GO

--1
CREATE TABLE Countries
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(50) UNIQUE
)

CREATE TABLE Products
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(25) UNIQUE,
	[Description] NVARCHAR(250),
	Recipe NVARCHAR(MAX),
	Price MONEY CHECK(Price >= 0)
)

CREATE TABLE Distributors
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(25) UNIQUE,
	AddressText NVARCHAR(30),
	Summary NVARCHAR(200),
	CountryId INT FOREIGN KEY REFERENCES Countries(Id)
)

CREATE TABLE Ingredients
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30),
	[Description] NVARCHAR(200),
	OriginCountryId INT FOREIGN KEY REFERENCES Countries(Id),
	DistributorId INT FOREIGN KEY REFERENCES Distributors(Id)
)

CREATE TABLE ProductsIngredients
(
	ProductId INT FOREIGN KEY REFERENCES Products(Id),
	IngredientId INT FOREIGN KEY REFERENCES Ingredients(Id)
	CONSTRAINT PK_ProductsIngredients PRIMARY KEY (ProductId, IngredientId)
)

CREATE TABLE Customers
(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(25),
	LastName NVARCHAR(25),
	Gender CHAR CHECK(Gender = 'M' OR Gender = 'F'),
	Age INT,
	PhoneNumber CHAR(10),
	CountryId INT FOREIGN KEY REFERENCES Countries(Id)
)

CREATE TABLE Feedbacks
(
	Id INT PRIMARY KEY IDENTITY,
	[Description] NVARCHAR(255),
	Rate DECIMAL (3, 2),
	ProductId INT FOREIGN KEY REFERENCES Products(Id),
	CustomerId INT FOREIGN KEY REFERENCES Customers(Id)
)

--2
INSERT INTO Distributors (Name, CountryId, AddressText, Summary) VALUES
('Deloitte & Touche',		2,	'6 Arch St #9757',	'Customizable neutral traveling'),
('Congress Title',		13,	'58 Hancock St',	'Customer loyalty'),
('Kitchen People',		1,	'3 E 31st St #77',	'Triple-buffered stable delivery'),
('General Color Co Inc',	21,	'6185 Bohn St #72',	'Focus group'),
('Beck Corporation',		23,	'21 E 64th Ave',	'Quality-focused 4th generation hardware')

INSERT INTO Customers (FirstName, LastName, Age, Gender, PhoneNumber, CountryId) VALUES
('Francoise', 'Rautenstrauch', 15, 'M', '0195698399', 5),
('Kendra', 'Loud', 22, 'F', '0063631526', 11),
('Lourdes', 'Bauswell', 50, 'M', '0139037043', 8),
('Hannah', 'Edmison', 18, 'F', '0043343686', 1),
('Tom', 'Loeza', 31, 'M', '0144876096', 23),
('Queenie', 'Kramarczyk', 30, 'F', '0064215793', 29),
('Hiu', 'Portaro', 25, 'M', '0068277755', 16),
('Josefa', 'Opitz', 43, 'F', '0197887645', 17)

--3
UPDATE Ingredients
SET DistributorId = 35
WHERE [Name] IN ('Bay Leaf', 'Paprika', 'Poppy')

UPDATE Ingredients
SET OriginCountryId = 14
WHERE OriginCountryId = 8

--4
DELETE FROM Feedbacks
WHERE CustomerId = 14

DELETE FROM Feedbacks
WHERE ProductId = 5

--5
/*USE master
GO

DROP DATABASE Bakery
GO*/
SELECT p.[Name], p.Price, p.[Description]
FROM Products AS p
ORDER BY p.Price DESC, p.[Name]

--6
SELECT [Name], [Description], OriginCountryId 
FROM Ingredients
WHERE OriginCountryId IN (1, 10, 20)
ORDER BY Id

--7
SELECT TOP 15 i.Name, i.Description, c.Name AS CountryName
FROM Ingredients AS i
INNER JOIN Countries AS c
ON c.Id = i.OriginCountryId
WHERE c.Name IN ('Bulgaria', 'Greece')
ORDER BY i.Name, c.Name

--8
SELECT TOP 10 p.Name, p.Description, AVG(f.Rate) AS [AverageRate], COUNT(f.Id) AS [FeedbacksAmount]
FROM Products AS p
INNER JOIN Feedbacks AS f
ON f.ProductId = p.Id
GROUP BY p.Name, p.Description
ORDER BY AverageRate DESC, FeedbacksAmount DESC

--9
SELECT f.ProductId, f.Rate, f.Description, f.CustomerId, c.Age, c.Gender 
FROM Feedbacks AS f
INNER JOIN Customers AS c
ON c.Id = f.CustomerId
WHERE f.Rate < 5.00
ORDER BY f.ProductId DESC, f.Rate

--10
SELECT CONCAT(FirstName, ' ', LastName) AS [CustomerName], PhoneNumber, Gender
FROM Customers
WHERE Id NOT IN (SELECT CustomerId FROM Feedbacks)
ORDER BY Id

--11
SELECT f.ProductId, 
	CONCAT(FirstName, ' ', LastName) AS [CustomerName], 
	f.Description AS [FeedbackDescription] 
FROM Customers AS c
INNER JOIN Feedbacks AS f ON f.CustomerId = c.Id
WHERE CustomerId IN (SELECT CustomerId FROM Feedbacks
					GROUP BY CustomerId
					HAVING COUNT(CustomerId) >= 3)
ORDER BY f.ProductId, CustomerName, f.Id

--12
SELECT FirstName, Age, PhoneNumber FROM Customers
WHERE Age >= 21 AND CHARINDEX('an', FirstName, 1) > 0 
OR PhoneNumber LIKE '%38' AND CountryId <> (SELECT Id FROM Countries WHERE Name = 'Greece')
ORDER BY FirstName, Age DESC

--13
SELECT d.Name, i.Name, p.Name, AVG(f.Rate) AS [AverageRate] 
FROM Distributors AS d
INNER JOIN Ingredients AS i
ON i.DistributorId = d.Id
INNER JOIN ProductsIngredients AS ping
ON ping.IngredientId = i.Id
INNER JOIN Products AS p
ON p.Id = ping.ProductId
INNER JOIN Feedbacks AS f
ON f.ProductId = p.Id
GROUP BY d.Name, i.Name, p.Name
HAVING AVG(f.Rate) BETWEEN 5 AND 8
ORDER BY d.Name, i.Name, p.Name

--14
SELECT TOP 1 WITH TIES c.Name AS [CountryName], AVG(f.Rate) AS [FeedbackRate] FROM Countries AS c
INNER JOIN Customers AS cust
ON cust.CountryId = c.Id
INNER JOIN Feedbacks AS f
ON f.CustomerId = cust.Id
GROUP BY c.Name
ORDER BY FeedbackRate DESC

--15
SELECT CountryName, DistributorName
FROM (
  SELECT 
    co.Name AS CountryName, d.Name AS DistributorName, 
    COUNT(i.Id) AS IngredientsCount,
    DENSE_RANK() OVER (PARTITION BY co.Name ORDER BY COUNT(i.Id) DESC) AS DistributorRank 
  FROM Countries AS co
  JOIN Distributors AS d ON d.CountryId = co.Id
  JOIN Ingredients AS i ON i.DistributorId = d.Id
  GROUP BY d.Name, co.Name
) AS CountryDistributorStats
WHERE DistributorRank = 1
ORDER BY CountryName, DistributorName
GO

--16
CREATE VIEW v_UserWithCountries AS
SELECT CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName, c.Age, c.Gender, co.[Name]
FROM Customers AS c
INNER JOIN Countries AS co
ON co.Id = c.CountryId

GO

--17
CREATE FUNCTION udf_GetRating (@Name NVARCHAR(25))
RETURNS NVARCHAR(10)
BEGIN
	DECLARE @resultRate DECIMAL (4, 2) = (
	SELECT AVG(f.Rate) 
	FROM Feedbacks AS f
	INNER JOIN Products AS p 
	ON p.Id = f.ProductId
	WHERE p.[Name] = @Name)

	DECLARE @returnStatement NVARCHAR(25)

	IF (@resultRate < 5)
	BEGIN
		SET @returnStatement = 'Bad'
	END
	ELSE IF (@resultRate < 8)
	BEGIN
		SET @returnStatement = 'Average'
	END
	ELSE IF (@resultRate >= 8)
	BEGIN
		SET @returnStatement = 'Good'
	END
	ELSE
	BEGIN
		SET @returnStatement = 'No rating'
	END

	RETURN @returnStatement

END
GO

/*SELECT TOP 5 Id, Name, dbo.udf_GetRating(Name)
FROM Products
Order BY Id */

--18
CREATE PROCEDURE usp_SendFeedback (@CustomerId INT, @ProductId INT, @Rate DECIMAL(10, 2), @Description NVARCHAR(255))
AS
BEGIN
	BEGIN TRANSACTION
	INSERT INTO Feedbacks (CustomerId, ProductId, Rate, Description) VALUES
	(@CustomerId, @ProductId, @Rate, @Description)
	DECLARE @NumOfFeedbacks INT = (	SELECT COUNT(Id) 
									  FROM Feedbacks
									 WHERE CustomerId = @CustomerId
									   AND ProductId = @ProductId)
	IF @NumOfFeedbacks > 3
	BEGIN
		RAISERROR('You are limited to only 3 feedbacks per product!', 16, 1)
		ROLLBACK
		RETURN
	END
	ELSE
	BEGIN
		COMMIT
	END
END
GO

/* EXEC usp_SendFeedback 1, 5, 7.50, 'Average experience'; */

--19
CREATE TRIGGER tr_KillEmAll ON Products
INSTEAD OF DELETE
AS
BEGIN
	DELETE FROM ProductsIngredients
	WHERE ProductId = (SELECT Id FROM deleted)

	DELETE FROM Feedbacks
	WHERE ProductId = (SELECT Id FROM deleted)

	DELETE FROM Products
	WHERE Id = (SELECT Id FROM deleted)
END

--20
SELECT 
  OuterTable.ProductName, 
  OuterTable.ProductAvgRate AS ProductAverageRate, 
  OuterTable.DistributorName, 
  OuterTable.DistributorCountry
FROM (
  SELECT 
    p.[Name] AS ProductName, AVG(f.Rate) AS ProductAvgRate,
    d.[Name] AS DistributorName, c.[Name] AS DistributorCountry
  FROM (
		SELECT p.Id
		  FROM Products p
		  JOIN ProductsIngredients prodingr 
		  ON prodingr.ProductId = p.Id
		  JOIN Ingredients i 
		  ON i.Id = prodingr.IngredientId
		  JOIN Distributors d 
		  ON d.Id = i.DistributorId
	 GROUP BY p.Id
	HAVING COUNT(DISTINCT(i.DistributorId)) = 1
  ) AS InnerTable
  JOIN Products AS p 
  ON p.Id = InnerTable.Id
  JOIN ProductsIngredients AS pi 
  ON pi.ProductId = p.Id
  JOIN Ingredients AS i 
  ON pi.IngredientId = i.Id
  JOIN Distributors AS d 
  ON d.Id = i.DistributorId
  JOIN Countries AS c 
  ON d.CountryId = c.Id
  JOIN Feedbacks AS f 
  ON p.Id = f.ProductId
  GROUP BY p.[Name], d.[Name], c.[Name]
) AS OuterTable
JOIN Products ON Products.[Name] = OuterTable.ProductName
ORDER BY Products.Id

/* second solution, with CTE:

WITH CTE AS (
	SELECT p.Id AS ProductId,
		p.[Name] AS ProductName, 
		AVG(f.Rate) AS AverageRate,
		d.[Name] AS DistributorName,
		c.[Name] AS DistributorCountry 
	FROM Products AS p
	JOIN Feedbacks AS f ON p.Id = f.ProductId
	JOIN ProductsIngredients AS pii ON p.Id = pii.ProductId
	JOIN Ingredients AS i ON pii.IngredientId = i.Id
	JOIN Distributors AS d ON i.DistributorId = d.Id
	JOIN Countries AS c ON c.Id = d.CountryId
	GROUP BY p.[Name], d.[Name], c.[Name], p.Id)
SELECT CTE.ProductName, AverageRate, DistributorName, DistributorCountry
FROM CTE
JOIN (
	SELECT ProductName, COUNT(DistributorName) AS DistributorCount
	FROM CTE
	GROUP BY ProductName
) AS DistributorCount ON CTE.ProductName = DistributorCount.ProductName
WHERE DistributorCount = 1
ORDER BY ProductId
*/