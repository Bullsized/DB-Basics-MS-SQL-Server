/* quick note - if you are pasting the solutions directly into Judge
   make sure that you omit the EXEC parts and the selections after
   every task, otherwise you'll get the compile error! */

USE SoftUni
GO

SELECT * FROM Employees
GO

--problem 1
CREATE PROCEDURE usp_GetEmployeesSalaryAbove35000
			  AS
		  SELECT FirstName AS [First Name], 
				 LastName AS [Last Name] 
            FROM Employees
		   WHERE Salary > 35000

EXEC usp_GetEmployeesSalaryAbove35000
GO

--problem 2
CREATE PROCEDURE usp_GetEmployeesSalaryAboveNumber (@Number DECIMAL(18, 4))
              AS
		  SELECT FirstName AS [First Name],
		         LastName AS [Last Name]
		    FROM Employees
		   WHERE Salary >= @Number

EXEC usp_GetEmployeesSalaryAboveNumber 48100
GO

--problem 3
CREATE PROCEDURE usp_GetTownsStartingWith (@StartingChars NVARCHAR(MAX))
              AS
	      SELECT [Name] AS Town
      	    FROM Towns
		   WHERE [Name] LIKE CONCAT(@StartingChars, '%')
		   --second way: WHERE SUBSTRING(Name, 1, LEN(@StartingChars)) = @StartingChars

EXEC usp_GetTownsStartingWith 'bor'
GO

--problem 4
CREATE PROCEDURE usp_GetEmployeesFromTown (@TownName VARCHAR(50))
              AS
	      SELECT FirstName AS [First Name],
		         LastName AS [Last Name]
		    FROM Employees AS e
	  INNER JOIN Addresses AS a 
		      ON a.AddressID = e.AddressID
	  INNER JOIN Towns AS t 
		      ON t.TownID = a.TownID
	WHERE t.Name = @TownName

EXEC usp_GetEmployeesFromTown 'Sofia'
GO

--problem 5
CREATE FUNCTION ufn_GetSalaryLevel (@Salary DECIMAL (18, 4))
     RETURNS VARCHAR(10)
	 AS
	 BEGIN

		 DECLARE @SalaryLevel VARCHAR(10)

		 IF (@Salary < 30000)
			 BEGIN
				SET @SalaryLevel = 'Low'
			 END
		 ELSE IF (@Salary BETWEEN 30000 AND 50000)
			 BEGIN
				SET @SalaryLevel = 'Average'
			 END
		 ELSE
			BEGIN
				SET @SalaryLevel = 'High'
			END

			RETURN @SalaryLevel
	 END

SELECT FirstName, LastName, Salary, dbo.ufn_GetSalaryLevel(Salary) AS SalaryLevel
FROM Employees
ORDER BY Salary DESC
GO

--problem 6
CREATE PROCEDURE usp_EmployeesBySalaryLevel (@LevelOfSalary VARCHAR(10))
              AS
		  SELECT FirstName AS [First Name],
		         LastName AS [Last Name]
		    FROM Employees
		   WHERE dbo.ufn_GetSalaryLevel(Salary) = @LevelOfSalary

EXEC usp_EmployeesBySalaryLevel 'Low'
GO

--problem 7
CREATE FUNCTION ufn_IsWordComprised(@setOfLetters VARCHAR(50), @word VARCHAR(50))
	RETURNS BIT
		     AS
		  BEGIN
				DECLARE @isComprised BIT = 0;
				DECLARE @currentIndex INT = 1;
				DECLARE @currentChar CHAR;

				WHILE(@currentIndex <= LEN(@word))
					BEGIN

					  SET @currentChar = SUBSTRING(@word, @currentIndex, 1);
					  IF(CHARINDEX(@currentChar, @setOfLetters) = 0)
					    RETURN @isComprised;
					  SET @currentIndex += 1;

					END

				RETURN @isComprised + 1;

				RETURN @isComprised
			END
			GO

						 SELECT 'bobr' AS [SetOfLetters], 
								 'Rob' AS [Word], 
dbo.ufn_IsWordComprised('bobr', 'Rob') AS [Result]
								    GO
--problem 8
 CREATE PROC usp_DeleteEmployeesFromDepartment (@departmentId INT)
          AS
 ALTER TABLE Departments
ALTER COLUMN ManagerID INT NULL

DELETE FROM EmployeesProjects
      WHERE EmployeeID IN 
			(
				SELECT EmployeeID FROM Employees
				WHERE DepartmentID = @departmentId
			)

UPDATE Employees
   SET ManagerID = NULL
 WHERE ManagerID IN 
	   (
			SELECT EmployeeID FROM Employees
			WHERE DepartmentID = @departmentId
	   )


UPDATE Departments
   SET ManagerID = NULL
 WHERE ManagerID IN 
	   (
			SELECT EmployeeID FROM Employees
			WHERE DepartmentID = @departmentId
	   )

DELETE FROM Employees
      WHERE EmployeeID IN 
			(
				SELECT EmployeeID FROM Employees
				WHERE DepartmentID = @departmentId
			)

              DELETE FROM Departments
                    WHERE DepartmentID = @departmentId
       SELECT COUNT(*) AS [Employees Count] FROM Employees AS e
INNER JOIN Departments AS d
                       ON d.DepartmentID = e.DepartmentID
                    WHERE e.DepartmentID = @departmentId
					   GO
--problem 9
USE Bank
GO

CREATE PROCEDURE usp_GetHoldersFullName
              AS
		  SELECT FirstName + ' ' + LastName AS [Full Name]
		    FROM AccountHolders
			  GO

EXEC usp_GetHoldersFullName
GO

--problem 10
CREATE PROCEDURE usp_GetHoldersWithBalanceHigherThan (@Parameter DECIMAL(16, 2))
              AS
		  SELECT ah.FirstName AS [First Name],
		         ah.LastName AS [Last Name]
		    FROM AccountHolders AS ah
	  INNER JOIN Accounts AS acc
		      ON acc.AccountHolderId = ah.Id
		GROUP BY ah.FirstName, ah.LastName
		  HAVING SUM(acc.Balance) > @Parameter

EXEC usp_GetHoldersWithBalanceHigherThan 12346.78
GO

--problem 11
CREATE FUNCTION ufn_CalculateFutureValue (@Sum MONEY, @YIRate FLOAT, @Years INT)
			    RETURNS DECIMAL(24, 4)
			    AS
			    BEGIN
			   		DECLARE @Result DECIMAL(24, 4)
			   			SET @Result = @Sum * (POWER((1 + @YIRate), @Years))
			   		RETURN @Result
			    END
	         GO

SELECT dbo.ufn_CalculateFutureValue(1000, 8.5, 5)
GO

--problem 12
                                  CREATE PROCEDURE usp_CalculateFutureValueForAccount (@AccId INT, @Rate FLOAT)
                                                AS
                           	      SELECT @AccId AS [Account Id],
                                   ah.FirstName AS [First Name],
                                    ah.LastName AS [Last Name],
			                    	acc.Balance AS [Current Balance],
dbo.ufn_CalculateFutureValue(Balance, @Rate, 5) AS [Balance in 5 years]
		                    FROM AccountHolders AS ah
		                    INNER JOIN Accounts AS acc
		                                        ON acc.AccountHolderId = ah.Id
											 WHERE @AccId = acc.Id
												GO

EXEC usp_CalculateFutureValueForAccount 1, 0.1

--problem 13
USE Diablo
GO

CREATE FUNCTION ufn_CashInUsersGames (@GameName VARCHAR(50))
        RETURNS @SumCash TABLE 
		                 (
							SumCash MONEY NOT NULL
						 )
			 AS
		  BEGIN
			  INSERT INTO @SumCash
			       SELECT SUM(ct.Cash) AS [SumCash]
				     FROM (
					                     SELECT g.Name,
							                    ug.Cash,
								                ROW_NUMBER() OVER (ORDER BY ug.Cash DESC) AS [RowNumber]
							 FROM UsersGames AS ug
							INNER JOIN Games AS g
							                 ON g.Id = ug.GameId
								          WHERE g.Name = @GameName
						  ) 
						  AS ct
					WHERE ct.RowNumber %2 <> 0
				RETURN
		    END
			GO

SELECT * FROM dbo.ufn_CashInUsersGames ('Lily Stargazer');
SELECT * FROM dbo.ufn_CashInUsersGames ('Love in a mist');