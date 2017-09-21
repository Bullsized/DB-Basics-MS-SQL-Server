CREATE TABLE Clients (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL
)
GO

CREATE TABLE AccountTypes (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	[Name] NVARCHAR(50) NOT NULL
)
GO

CREATE TABLE Accounts (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	AccountTypeId INT FOREIGN KEY REFERENCES AccountTypes(ID),
	Balance DECIMAL(15, 2) NOT NULL DEFAULT(0),
	ClientId INT FOREIGN KEY REFERENCES Clients(Id)
)
GO

SELECT * FROM Accounts

INSERT INTO Clients (FirstName, LastName) VALUES
('Hulk', 'Hogan'),
('Dancho', 'Lechkov'),
('Iron', 'Man')
GO

INSERT INTO AccountTypes (Name) VALUES
('Checkings'),
('Savings')
GO

INSERT INTO Accounts (ClientId, AccountTypeId, Balance) VALUES
(1, 1, 2144),
(2, 1, 4423),
(3, 1, 223.3223),
(4, 2, 30.30),
(4, 1, 222.11)

GO

CREATE VIEW v_ClientBalances AS 
SELECT (FirstName + ' ' + LastName) AS [Name of The Client],
(AccountTypes.Name) AS [Type of The Account], Balance
FROM Clients
JOIN Accounts ON Clients.Id = Accounts.ClientId
JOIN AccountTypes ON AccountTypes.Id = Accounts.AccountTypeId
GO

SELECT * FROM v_ClientBalances
GO

CREATE FUNCTION f_CalculateTotalBalance (@ClientID INT)
RETURNS DECIMAL(15, 2)
BEGIN
	DECLARE @result AS DECIMAL(15, 2) = (
		SELECT SUM(Balance)
		FROM Accounts WHERE ClientId = @ClientID
		)
	RETURN @result
END
GO

SELECT dbo.f_CalculateTotalBalance(1) AS Balance
GO

CREATE PROCEDURE p_AddAccount @ClientId INT, @AccountTypeId INT AS
INSERT INTO Accounts (ClientId, AccountTypeId)
VALUES (@ClientId, @AccountTypeId)
GO

EXEC p_AddAccount 1, 1 
GO

CREATE PROCEDURE p_Deposit @AccountId INT, @Amount DECIMAL(15, 2) AS
UPDATE Accounts
SET Balance +=@Amount
WHERE Id = @AccountId
GO

EXEC p_Deposit 1, 9999
GO

SELECT * FROM Accounts
GO

CREATE PROCEDURE p_Withdraw @AccountId INT, @Amount DECIMAL(15, 2) AS
BEGIN
	DECLARE @OldBalance DECIMAL(15, 2)
	SELECT @OldBalance = Balance FROM Accounts WHERE Id = @AccountId
	IF (@OldBalance - @Amount >= 0)
	BEGIN
		UPDATE Accounts
		SET Balance -= @Amount
		WHERE Id = @AccountId
	END
	ELSE
	BEGIN
		RAISERROR('Not Enough Minerals', 10, 1)
	END
END
GO

EXEC p_Withdraw 1, 99.9
GO

EXEC p_Withdraw 1, 9999999999 /*this will show up Not Enough Minerals, but in the console*/
GO

CREATE TABLE Transactions (
	Id INT PRIMARY KEY IDENTITY NOT NULL,
	AccountId INT FOREIGN KEY REFERENCES Accounts(Id),
	OldBalance DECIMAL(15, 2) NOT NULL,
	NewBalance DECIMAL(15, 2) NOT NULL,
	Amount AS NewBalance - OldBalance,
	[DateTime] DATETIME2
)
GO

CREATE TRIGGER tr_Transaction ON Accounts
AFTER UPDATE
AS
	INSERT INTO Transactions (AccountId, OldBalance, NewBalance, [DateTime])
	SELECT inserted.Id, deleted.Balance, inserted.Balance, GETDATE() FROM inserted
	JOIN deleted ON inserted.Id = deleted.Id
GO

SELECT * FROM Transactions
GO

EXEC p_Deposit 1, 25.00
GO

EXEC p_Withdraw 1, 12061.1
GO