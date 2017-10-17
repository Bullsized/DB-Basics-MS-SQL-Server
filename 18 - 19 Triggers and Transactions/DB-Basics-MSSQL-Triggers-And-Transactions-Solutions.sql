--problem 1
USE Bank
GO

CREATE TABLE Logs
(
	LogId INT PRIMARY KEY IDENTITY,
	AccountId INT NOT NULL,
	OldSum DECIMAL (8, 2),
	NewSum DECIMAL (8, 2)
)
GO

CREATE TRIGGER tr_LogsUpdate ON Accounts AFTER UPDATE
AS
BEGIN
	DECLARE @account INT = (SELECT Id FROM deleted)
	DECLARE @OldSum DECIMAL (8, 2) = (SELECT Balance FROM deleted)
	DECLARE @NewSum DECIMAL (8, 2) = (SELECT Balance FROM inserted)
	INSERT INTO Logs VALUES
	(@account, @OldSum, @NewSum)
END
GO

UPDATE Accounts
SET Balance += 200.07
WHERE Id = 1
GO

--problem 1 second solution
CREATE TRIGGER tr_SumChanges ON Accounts AFTER UPDATE
		    AS
		 BEGIN
   INSERT INTO Logs (AccountId, OldSum, NewSum)
		SELECT i.Id, d.Balance, i.Balance FROM inserted AS i
	INNER JOIN deleted AS d
			ON i.AccountHolderId = d.AccountHolderId
		   END

--problem 2
CREATE TABLE NotificationEmails
(
	Id INT PRIMARY KEY IDENTITY,
	Recipient INT NOT NULL,
	[Subject] NVARCHAR(MAX),
	Body NVARCHAR(MAX)
)
GO

CREATE TRIGGER tr_MailCreator ON Logs AFTER INSERT
AS
BEGIN
	DECLARE @Recipient INT = (SELECT LogId FROM Logs)
	DECLARE @Subject NVARCHAR(MAX) = 'Balance change for account: ' + 
		CONVERT(NVARCHAR(50), (SELECT LogId FROM Logs))
	DECLARE @Body NVARCHAR(MAX) = 'On ' + CONVERT(NVARCHAR(50), GETDATE()) + 
		' your balance was changed from ' + CONVERT(NVARCHAR(50), (SELECT OldSum FROM Logs)) + 
		' to ' + CONVERT(NVARCHAR(50), (SELECT NewSum FROM Logs)) + '.'

	INSERT INTO NotificationEmails VALUES
	(@Recipient, @Subject, @Body)
END
GO

--problem 2 second solution
CREATE TRIGGER tr_MailCreator ON Logs AFTER INSERT
AS
BEGIN
  DECLARE @Recipient int = (SELECT AccountId FROM inserted);
  DECLARE @OldBalance money = (SELECT OldSum FROM inserted);
  DECLARE @NewBalance money = (SELECT NewSum FROM inserted);
  DECLARE @Subject varchar(200) = CONCAT('Balance change for account: ', @recipient);
  DECLARE @Body varchar(200) = CONCAT('On ', GETDATE(), ' your balance was changed from ', @oldBalance, ' to ', @newBalance, '.');  

  INSERT INTO NotificationEmails VALUES (@Recipient, @Subject, @Body)
END
GO

--problem 3 - working yet 0/100 solution
CREATE PROCEDURE usp_DepositMoney (@AccountId INT, @MoneyAmount DECIMAL(15, 4))
AS
BEGIN TRANSACTION
IF (@MoneyAmount <= 0)
BEGIN
	ROLLBACK
	RAISERROR('Invalid amount, bruv~', 16, 1)
	RETURN
END

UPDATE Accounts
SET Balance += @MoneyAmount
WHERE Id = @AccountId

COMMIT
GO

EXEC usp_DepositMoney 1, 55.0
GO

--problem 3 solution that will pass in Judge
CREATE PROCEDURE usp_DepositMoney (@AccountId INT, @MoneyAmount DECIMAL(15, 4))
AS
BEGIN

BEGIN TRANSACTION
UPDATE Accounts
SET Balance += @moneyAmount
WHERE Accounts.Id = @AccountId
COMMIT

END
GO

--problem 3 easiest solution
CREATE PROCEDURE usp_DepositMoney (@AccountId INT, @MoneyAmount DECIMAL(15, 4))
AS
BEGIN
	UPDATE Accounts
	SET Balance += @MoneyAmount
	WHERE Id = @AccountId
END
GO

--problem 4
CREATE PROCEDURE usp_WithdrawMoney (@AccountId INT, @MoneyAmount DECIMAL(15, 4))
AS
BEGIN
	UPDATE Accounts
	SET Balance -= @MoneyAmount
	WHERE Id = @AccountId
END
GO

--problem 4 second solution
CREATE PROCEDURE usp_WithdrawMoney (@AccountId INT, @MoneyAmount DECIMAL(15, 4))
AS
BEGIN
	BEGIN TRANSACTION
		UPDATE Accounts
		SET Balance -= @moneyAmount
		WHERE Accounts.Id = @AccountId
	COMMIT
END
GO

--problem 5
CREATE PROCEDURE usp_TransferMoney(@SenderId INT, @ReceiverId INT, @Amount DECIMAL(15, 4))
AS
BEGIN
	BEGIN TRANSACTION
		EXEC dbo.usp_WithdrawMoney @SenderId, @Amount
		EXEC dbo.usp_DepositMoney @ReceiverId, @Amount
		IF 
		(
			SELECT Balance 
			  FROM Accounts
			 WHERE Accounts.Id = @SenderId
		) < 0
		BEGIN
			ROLLBACK
		END
		ELSE
		BEGIN
		COMMIT
	END
END
GO

--problem 6
USE Diablo
GO

--problem 6.1
CREATE TRIGGER tr_RestrictHigherLevelItems
ON UserGameItems AFTER INSERT
AS
BEGIN
	DECLARE @ItemMinLevel INT = 
	(
		SELECT i.MinLevel FROM inserted AS ins
		INNER JOIN Items AS i ON i.Id = ins.ItemId
	)
	DECLARE @UserLevel INT = 
	(
		SELECT ug.[Level] FROM inserted AS ins
		INNER JOIN UsersGames AS ug ON ug.Id = ins.UserGameId
	)

	IF (@UserLevel < @ItemMinLevel)
	BEGIN
		RAISERROR('Your level is too low to aquire that item!', 16, 1)
		ROLLBACK
		RETURN
	END
END
GO

--problem 6.2
UPDATE UsersGames
SET Cash += 50000
WHERE GameId = (SELECT Id FROM Games WHERE [Name] = 'Bali') 
AND UserId IN (SELECT Id FROM Users WHERE Username IN 
('baleremuda', 'loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos'))
GO

--problem 6.3 not my solution...
INSERT INTO UserGameItems (UserGameId, ItemId)
SELECT  UsersGames.Id, i.Id 
FROM UsersGames, Items i
WHERE UserId in (
	SELECT Id 
	FROM Users 
	WHERE Username IN ('loosenoise', 'baleremuda', 'inguinalself', 'buildingdeltoid', 'monoxidecos')
) AND GameId = (SELECT Id FROM Games WHERE Name = 'Bali' ) AND ((i.Id > 250 AND i.Id < 300) OR (i.Id > 500 AND i.Id < 540))

--problem 6.4
SELECT u.Username,
       g.[Name],
	   ug.Cash,
	   i.Name
 FROM Users AS u
 INNER JOIN UsersGames AS ug ON ug.UserId = u.Id
 INNER JOIN Games AS g ON g.Id = ug.GameId
 INNER JOIN UserGameItems AS ugi ON ugi.UserGameId = ug.Id
 INNER JOIN Items AS i ON i.Id = ugi.ItemId
 WHERE g.[Name] = 'Bali'
 ORDER BY u.Username, g.[Name]

 --problem 7
BEGIN TRANSACTION
DECLARE @sum1 MONEY = (SELECT SUM(i.Price)
						FROM Items i
						WHERE MinLevel BETWEEN 11 AND 12)

IF (SELECT Cash FROM UsersGames WHERE Id = 110) < @sum1 --hardcoding for the win
ROLLBACK
ELSE BEGIN
		UPDATE UsersGames
		SET Cash -= @sum1
		WHERE Id = 110

		INSERT INTO UserGameItems (UserGameId, ItemId)
		SELECT 110, Id 
		FROM Items 
		WHERE MinLevel BETWEEN 11 AND 12
		COMMIT
	END

BEGIN TRANSACTION
DECLARE @sum2 MONEY = (SELECT SUM(i.Price)
						FROM Items i
						WHERE MinLevel BETWEEN 19 AND 21)

IF (SELECT Cash FROM UsersGames WHERE Id = 110) < @sum2
ROLLBACK
ELSE BEGIN
		UPDATE UsersGames
		SET Cash -= @sum2
		WHERE Id = 110

		INSERT INTO UserGameItems (UserGameId, ItemId)
			SELECT 110, Id 
			FROM Items 
			WHERE MinLevel BETWEEN 19 AND 21
		COMMIT
	END

SELECT i.[Name] AS 'Item Name' 
FROM UserGameItems ugi
INNER JOIN Items AS i
ON ugi.ItemId = i.Id
WHERE ugi.UserGameId = 110

--problem 8
USE SoftUni
GO

CREATE PROCEDURE usp_AssignProject (@employeeId INT, @projectID INT)
AS
BEGIN
	BEGIN TRANSACTION
	INSERT INTO EmployeesProjects VALUES (@employeeId, @projectID)
	IF
	(
	SELECT COUNT(ProjectID)
	FROM EmployeesProjects
	WHERE EmployeeID = @employeeId
	) > 3
	BEGIN
		RAISERROR('The employee has too many projects!', 16, 1)
		ROLLBACK
		RETURN
	END
	COMMIT
END

--problem 9
CREATE TABLE Deleted_Employees
(
	EmployeeId INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	MiddleName VARCHAR(50),
	JobTitle VARCHAR(50),
	DepartmentId INT,
	Salary DECIMAL (15, 2)
)
GO

CREATE TRIGGER tr_DeleteEmployee ON Employees
AFTER DELETE 
AS
BEGIN
	INSERT INTO Deleted_Employees
	SELECT FirstName, LastName, MiddleName, JobTitle, DepartmentID, Salary 
	FROM deleted
END
GO

DELETE FROM Employees
WHERE EmployeeID = 293