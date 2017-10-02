USE Gringotts
GO

SELECT * FROM INFORMATION_SCHEMA.TABLES

SELECT * FROM WizzardDeposits

--problem 1
SELECT COUNT(Id) AS [Count] FROM WizzardDeposits 

--problem 2
SELECT MAX(MagicWandSize) AS [LongestMagicWand] FROM WizzardDeposits

--problem 3
SELECT DISTINCT DepositGroup, 
 MAX(MagicWandSize) AS [LongestMagicWand] 
FROM WizzardDeposits
GROUP BY DepositGroup

--problem 4
SELECT TOP 2 DepositGroup 
FROM WizzardDeposits
GROUP BY DepositGroup
ORDER BY AVG(MagicWandSize)

--problem 5
SELECT DepositGroup, --no need to input distinct, as the group by does that for you
 SUM(DepositAmount) AS [TotalSum]
FROM WizzardDeposits
GROUP BY DepositGroup

--problem 6
SELECT DepositGroup,
 SUM(DepositAmount) AS [TotalSum]
FROM WizzardDeposits
GROUP BY DepositGroup, MagicWandCreator
HAVING MagicWandCreator = 'Ollivander family'

--problem 7
SELECT DepositGroup,
 SUM(DepositAmount) AS [TotalSum]
FROM WizzardDeposits
GROUP BY DepositGroup, MagicWandCreator
HAVING MagicWandCreator = 'Ollivander family' AND SUM(DepositAmount) < 150000
ORDER BY TotalSum DESC

--problem 8
SELECT DepositGroup, MagicWandCreator,
 MIN(DepositCharge) AS [MinDepositCharge]
FROM WizzardDeposits
GROUP BY DepositGroup, MagicWandCreator
ORDER BY MagicWandCreator, DepositGroup

--problem 9
SELECT
 CASE
  WHEN Age < 10 THEN '[0-10]'
  WHEN Age < 21 THEN '[11-20]'
  WHEN Age < 31 THEN '[21-30]'
  WHEN Age < 41 THEN '[31-40]'
  WHEN Age < 51 THEN '[41-50]'
  WHEN Age < 61 THEN '[51-60]'
 ELSE '[61+]'
END AS [AgeGroup],
COUNT(*) AS WizardCount
FROM WizzardDeposits
GROUP BY
 CASE
  WHEN Age < 10 THEN '[0-10]'
  WHEN Age < 21 THEN '[11-20]'
  WHEN Age < 31 THEN '[21-30]'
  WHEN Age < 41 THEN '[31-40]'
  WHEN Age < 51 THEN '[41-50]'
  WHEN Age < 61 THEN '[51-60]'
 ELSE '[61+]'
END

--problem 10
SELECT LEFT(FirstName, 1) AS [FirstLetter]
FROM WizzardDeposits
WHERE DepositGroup = 'Troll Chest'
GROUP BY LEFT(FirstName, 1)
--ORDER BY FirstLetter    will pass 100/100 without that line

--problem 11
SELECT DepositGroup,
 IsDepositExpired,
 AVG(DepositInterest) AS AverageInterest
FROM WizzardDeposits
WHERE DATEPART(YEAR, DepositStartDate) > 1984
GROUP BY DepositGroup, IsDepositExpired
ORDER BY DepositGroup DESC, IsDepositExpired

--problem 12 
SELECT SUM(DepositAmount - NextDeposit) AS [SumDifference]
  FROM (SELECT DepositAmount , 
	  LEAD (DepositAmount) OVER (ORDER BY Id) AS [NextDeposit]
	  FROM WizzardDeposits) AS WizzartDeposits --props to Pazzo ~

--problem 13
USE SoftUni
GO

SELECT * FROM Employees

SELECT DepartmentID,
 SUM(Salary) AS [TotalSalary]
FROM Employees
GROUP BY DepartmentID
ORDER BY DepartmentID

--problem 14
SELECT DepartmentID,
 MIN(SALARY) AS [MinimumSalary]
FROM Employees
WHERE DepartmentID IN (2, 5, 7) AND 
 DATEPART(YEAR, HireDate) > 1999
GROUP BY DepartmentID

--problem 15
SELECT * INTO TempTable FROM Employees
WHERE Salary > 30000

DELETE FROM TempTable
WHERE ManagerID = 42

UPDATE TempTable
SET Salary += 5000
WHERE DepartmentID = 1

SELECT DepartmentID,
 AVG(Salary) AS [AverageSalary]
FROM TempTable
GROUP BY DepartmentID

--problem 16
SELECT DepartmentID,
 MAX(Salary) AS [MaxSalary]
FROM Employees
GROUP BY DepartmentID
HAVING MAX(Salary) NOT BETWEEN 30000 AND 70000

--problem 17
SELECT COUNT(Salary) AS [Count]
FROM Employees
GROUP BY ManagerID
HAVING ManagerID IS NULL

--problem 18     from Data Aggregation - септември 2017 - Владимир Дамяновски
SELECT DepartmentID, ThirdHighestSalary FROM
(
	SELECT DepartmentID,
	 MAX(Salary) AS ThirdHighestSalary,
	 DENSE_RANK() OVER(PARTITION BY DepartmentID ORDER BY Salary DESC) AS Rank
	FROM Employees
	GROUP BY DepartmentID, Salary
)
AS ThirdPart
WHERE Rank = 3

--problem 19     from Data Aggregation - септември 2017 - Владимир Дамяновски
SELECT TOP 10 e1.FirstName, e1.LastName, e1.DepartmentID 
FROM Employees AS e1
WHERE Salary >
(
	SELECT AVG(Salary)
	FROM Employees AS e2
	WHERE e2.DepartmentID = e1.DepartmentID
	GROUP BY DepartmentID
)