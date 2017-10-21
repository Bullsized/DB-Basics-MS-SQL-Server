--The exam from 24 April 2017
CREATE DATABASE WMS
GO

USE WMS
GO

--1
CREATE TABLE Clients
(
	ClientId INT PRIMARY KEY IDENTITY NOT NULL,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	Phone CHAR(12) NOT NULL
)

CREATE TABLE Mechanics
(
	MechanicId INT PRIMARY KEY IDENTITY NOT NULL,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	[Address] VARCHAR(255) NOT NULL
)

CREATE TABLE Models
(
	ModelId INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] VARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Jobs
(
	JobId INT PRIMARY KEY IDENTITY NOT NULL,
	ModelId INT FOREIGN KEY REFERENCES Models(ModelId) NOT NULL,
	[Status] VARCHAR(11) DEFAULT 'Pending' CHECK ([Status] = 'In Progress' OR [Status] = 'Finished' OR [Status] = 'Pending') NOT NULL,
	ClientId INT FOREIGN KEY REFERENCES Clients(ClientId) NOT NULL,
	MechanicId INT FOREIGN KEY REFERENCES Mechanics(MechanicId),
	IssueDate DATE NOT NULL,
	FinishDate DATE
)

CREATE TABLE Orders
(
	OrderId INT PRIMARY KEY IDENTITY NOT NULL,
	JobId INT FOREIGN KEY REFERENCES Jobs(JobId),
	IssueDate DATE,
	Delivered BIT DEFAULT 0 NOT NULL
)

CREATE TABLE Vendors
(
	VendorId INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] VARCHAR(50) UNIQUE
)


CREATE TABLE Parts
(
	PartId INT PRIMARY KEY IDENTITY NOT NULL,
	SerialNumber VARCHAR(50) UNIQUE NOT NULL,
	[Description] VARCHAR(255),
	Price MONEY CHECK(Price <= 9999.99 AND Price > 0) NOT NULL,
	VendorId INT FOREIGN KEY REFERENCES Vendors(VendorId) NOT NULL,
	StockQty INT DEFAULT 0 CHECK(StockQty >= 0) NOT NULL
)

CREATE TABLE OrderParts
(
	OrderId INT FOREIGN KEY REFERENCES Orders(OrderId) NOT NULL,
	PartId INT FOREIGN KEY REFERENCES Parts(PartId) NOT NULL,
	Quantity INT DEFAULT 1 CHECK(Quantity >= 1),
	CONSTRAINT PK_OlderParts PRIMARY KEY (OrderId, PartId)
)

CREATE TABLE PartsNeeded
(
	JobId INT FOREIGN KEY REFERENCES Jobs(JobId) NOT NULL,
	PartId INT FOREIGN KEY REFERENCES Parts(PartId) NOT NULL,
	Quantity INT DEFAULT 1 CHECK(Quantity >= 1),
	CONSTRAINT PK_PartsNeeded PRIMARY KEY (JobId, PartId)
)

--2
INSERT INTO Clients (FirstName, LastName, Phone) VALUES
('Teri', 'Ennaco', '570-889-5187'),
('Merlyn', 'Lawler', '201-588-7810'),
('Georgene', 'Montezuma', '925-615-5185'),
('Jettie', 'Mconnell',	'908-802-3564'),
('Lemuel', 'Latzke', '631-748-6479'),
('Melodie',	'Knipp', '805-690-1682'),
('Candida',	'Corbley', '908-275-8357')

INSERT INTO Parts (SerialNumber, [Description], Price, VendorId) VALUES
('WP8182119', 'Door Boot Seal',	117.86,	2),
('W10780048', 'Suspension Rod',	42.81, 1),
('W10841140', 'Silicone Adhesive', 6.77, 4),
('WPY055980', 'High Temperature Adhesive', 13.94, 3)

--3
UPDATE Jobs
SET MechanicId = 3, [Status] = 'In Progress'
WHERE Status = 'Pending'

--4
DELETE FROM OrderParts
WHERE OrderId = 19

DELETE FROM Orders
Where OrderId = 19

--5
SELECT FirstName, LastName, Phone
FROM Clients
ORDER BY LastName, ClientId

--6
SELECT [Status], IssueDate
FROM Jobs
WHERE [Status] <> 'Finished'
ORDER BY IssueDate, JobId

--7
SELECT m.FirstName + ' ' + m.LastName AS [Mechanic],
j.[Status],
j.IssueDate
FROM Jobs AS j
INNER JOIN Mechanics AS m
ON m.MechanicId = j.MechanicId
ORDER BY m.MechanicId, j.IssueDate, j.JobId

--8 
SELECT c.FirstName + ' ' + c.LastName AS [Client],
DATEDIFF(DAY, j.IssueDate, '2017/04/24') AS [Days going],
j.[Status]
FROM Clients AS C
INNER JOIN Jobs AS j
ON j.ClientId = c.ClientId
WHERE j.[Status] <> 'Finished'

--9
SELECT m.FirstName + ' ' + m.LastName AS [Mechanic],
AVG(DATEDIFF(DAY, j.IssueDate, j.FinishDate)) AS [Average Days]
FROM Mechanics AS m
INNER JOIN Jobs AS j
ON j.MechanicId = m.MechanicId
GROUP By m.MechanicId, m.FirstName + ' ' + m.LastName
ORDER BY m.MechanicId

--10
SELECT TOP 3 m.FirstName + ' ' + m.LastName AS [Mechanic],
COUNT(j.[Status]) AS Jobs
FROM Mechanics AS m
INNER JOIN Jobs AS j
ON j.MechanicId = m.MechanicId
WHERE j.[Status] <> 'Finished' 
GROUP BY m.MechanicId, m.FirstName + ' ' + m.LastName
ORDER BY Jobs DESC

--10 second solution
SELECT m.FirstName + ' ' + m.LastName AS [Mechanic],
COUNT(j.JobId) AS [Jobs]
FROM Mechanics AS m
INNER JOIN Jobs AS j
ON j.MechanicId = m.MechanicId
GROUP BY m.FirstName, m.LastName, m.MechanicId, j.Status
HAVING j.Status <> 'Finished' AND COUNT(j.JobId) > 1
ORDER BY Jobs DESC

--11
SELECT FirstName + ' ' + LastName AS [Available]
FROM Mechanics
WHERE MechanicId NOT IN 
	(
	SELECT DISTINCT MechanicId FROM Jobs
	WHERE MechanicId IS NOT NULL AND [Status] <> 'Finished'
	)
ORDER BY MechanicId

--12
SELECT ISNULL(SUM(p.Price * op.Quantity), 0) AS [Parts Total]
FROM Parts AS p
INNER JOIN OrderParts AS op
ON op.PartId = p.PartId
INNER JOIN Orders AS o
ON o.OrderId = op.OrderId
WHERE DATEDIFF(WEEK, o.IssueDate, '2017-04-24') <= 3

--13
SELECT j.JobId,
		(
		SELECT ISNULL(SUM(p.Price * op.Quantity), 0) FROM Parts AS p
		INNER JOIN OrderParts AS op ON op.PartId = p.PartId
		INNER JOIN Orders AS o ON o.OrderId = op.OrderId
		INNER JOIN Jobs AS jo ON jo.JobId = o.JobId
		WHERE jo.JobId = j.JobId) AS Total
FROM Jobs AS j
WHERE j.Status = 'Finished'
ORDER BY Total DESC, j.JobId

--14
SELECT m.ModelId, 
	m.[Name], 
	CAST(AVG(DATEDIFF(DAY, j.IssueDate, j.FinishDate)) AS VARCHAR(10)) + ' days' AS [Average Service Time]
	FROM Models as m
INNER JOIN Jobs as j on j.ModelId = m.ModelId
GROUP BY m.ModelId, m.[Name]
ORDER BY AVG(DATEDIFF(DAY, j.IssueDate, j.FinishDate))

--15
SELECT TOP 1 WITH TIES m.Name AS Model,
	COUNT(*) AS [Times Serviced],
	(
		SELECT ISNULL(SUM(p.Price * op.Quantity), 0) FROM Jobs AS j
		INNER JOIN Orders AS o 
		ON o.JobId = j.JobId
		INNER JOIN OrderParts AS op
		ON op.OrderId = o.OrderId
		INNER JOIN Parts AS p
		ON p.PartId = op.PartId
		WHERE j.ModelId = m.ModelId
	) AS [Parts Total]
	 FROM Models AS m
INNER JOIN Jobs AS j
ON j.ModelId = m.ModelId
GROUP BY m.ModelId, m.[Name]
ORDER BY [Times Serviced] DESC

--16
SELECT 
	p.PartId,
	p.Description,
	SUM(pn.Quantity) AS [Required],
	SUM(p.StockQty) AS [In Stock],
	ISNULL(SUM(op.Quantity), 0)  AS [Ordered]
FROM Parts AS p
LEFT JOIN PartsNeeded AS pn
ON pn.PartId = p.PartId
LEFT JOIN Jobs AS j
ON j.JobId = pn.JobId
LEFT JOIN Orders AS o
ON o.JobId = j.JobId
LEFT JOIN OrderParts AS op
ON op.OrderId = o.OrderId
WHERE j.Status <> 'Finished' OR ((p.StockQty - pn.Quantity) < 0 )
					AND Delivered = 0
GROUP BY p.PartId, p.Description, j.Status
HAVING SUM(p.StockQty) + ISNULL(SUM(op.Quantity), 0) < SUM(pn.Quantity)
ORDER BY p.PartId
GO

--17
CREATE FUNCTION udf_GetCost (@jobIdInt INT)
RETURNS DECIMAL(6, 2)
AS
BEGIN
	DECLARE @result DECIMAL(6, 2) = (
		SELECT ISNULL(SUM(p.Price * op.Quantity), 0)
		FROM Parts AS p
		INNER JOIN OrderParts AS op ON op.PartId = p.PartId
		INNER JOIN Orders AS o ON o.OrderId = op.OrderId
		INNER JOIN Jobs AS j ON j.JobId = o.JobId
		WHERE j.JobId = @jobIdInt
	)

	RETURN @result
END
GO
--SELECT dbo.udf_GetCost(1)
--SELECT dbo.udf_GetCost(3)

--18
CREATE PROCEDURE usp_PlaceOrder @JobId INT, @SerialNumber VARCHAR(50), @Quantity INT
AS
BEGIN
	DECLARE @JobStatus VARCHAR(11) = (SELECT Status FROM Jobs
WHERE JobId = @JobId)

	IF (@JobStatus = 'Finished')
	BEGIN
		RAISERROR('This job is not active!', 16, 1)
		RETURN
	END

	IF (@Quantity <= 0)
	BEGIN
		RAISERROR('Part quantity must be more than zero!', 16, 1)
		RETURN
	END

	DECLARE @DoesJobExist INT = (SELECT @@ROWCOUNT FROM Jobs WHERE JobId = 1)
	IF (@DoesJobExist IS NULL)
	BEGIN
		RAISERROR('Job not found!', 16, 1)
		RETURN
	END

	DECLARE @PartId INT = (SELECT PartId FROM Parts WHERE SerialNumber = @SerialNumber)
	IF (@PartId IS NULL)
	BEGIN
		RAISERROR('Part not found!', 16, 1)
		RETURN
	END

	DECLARE @OrderId INT = (SELECT o.OrderId
						  FROM Orders o 
						  JOIN OrderParts op ON op.OrderId = o.OrderId
						  JOIN Parts p ON p.PartId = op.PartId
						 WHERE JobId = @JobId AND p.PartId = @PartId AND IssueDate IS NULL)

	IF(@OrderId IS NULL)
	BEGIN
		INSERT INTO Orders(JobId, IssueDate) VALUES
		(@JobId, NULL)

		INSERT INTO OrderParts (OrderId, PartId, Quantity) VALUES
		(IDENT_CURRENT('Orders'), @PartId, @Quantity)
	END
	ELSE
	BEGIN
		DECLARE @PartExistsInOrder INT = (SELECT @@ROWCOUNT FROM OrderParts 
										   WHERE OrderId = @OrderId AND PartId = @PartId)

		IF(@PartExistsInOrder IS NULL)
		BEGIN
			INSERT INTO OrderParts (OrderId, PartId, Quantity) VALUES
			(@OrderId, @PartId, @Quantity)
		END
		ELSE
		BEGIN
			UPDATE OrderParts
			   SET Quantity += @Quantity
			 WHERE OrderId = @OrderId 
			   AND PartId = @PartId
		END
	    
	END
END
GO

--EXEC dbo.usp_PlaceOrder 45, '4681EA2001T', 5

--19
CREATE TRIGGER tr_DetectDelivery
ON Orders
AFTER UPDATE
AS
BEGIN
	DECLARE @OldStatus INT = (SELECT Delivered FROM deleted)
	DECLARE @NewStatus INT = (SELECT Delivered FROM inserted)

	IF (@OldStatus = 0 AND @NewStatus = 1)
	BEGIN
		UPDATE Parts
			   SET StockQty += op.Quantity
			 FROM Parts p
			 JOIN OrderParts op ON op.PartId = p.PartId
			 JOIN Orders o ON o.OrderId = op.OrderId
			 JOIN inserted i ON i.OrderId = o.OrderId
			 JOIN deleted d ON d.OrderId = o.OrderId
			WHERE d.Delivered = 0 AND i.Delivered = 1
	END	
END

--20
WITH CTE_VendorPreference
AS
(
    SELECT m.MechanicId, v.VendorId, SUM(op.Quantity) AS ItemsFromVendor FROM Mechanics AS m
    JOIN Jobs AS j ON j.MechanicId = m.MechanicId
    JOIN Orders AS o ON o.JobId = j.JobId
    JOIN OrderParts op ON op.OrderId = o.OrderId
    JOIN Parts AS p ON p.PartId = op.PartId
    JOIN Vendors v ON v.VendorId = p.VendorId
    GROUP BY m.MechanicId, v.VendorId
)

SELECT m.FirstName + ' ' + LastName AS Mechanic,
       v.Name AS Vendor,
       c.ItemsFromVendor AS Parts,
CAST(CAST(CAST(ItemsFromVendor AS DECIMAL(6, 2)) / (SELECT SUM(ItemsFromVendor) FROM CTE_VendorPreference WHERE MechanicId = c.MechanicId) * 100 AS INT) AS VARCHAR(20)) + '%' AS Preference
FROM CTE_VendorPreference AS c
JOIN Mechanics m ON m.MechanicId = c.MechanicId
JOIN Vendors v ON v.VendorId = c.VendorId
ORDER BY Mechanic, Parts DESC, Vendor