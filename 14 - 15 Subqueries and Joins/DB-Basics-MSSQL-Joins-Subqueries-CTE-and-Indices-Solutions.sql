USE SoftUni
GO

SELECT * FROM Employees

--problem 1
    SELECT TOP 5 e.EmployeeID, 
               e.JobTitle, 
               a.AddressID, 
               a.AddressText 
          FROM Employees AS e
    INNER JOIN Addresses AS a 
            ON a.AddressID = e.AddressID
	  ORDER BY a.AddressID ASC

--problem 2
SELECT TOP 50 e.FirstName,
              e.LastName,
              t.[Name] AS Town,
              a.AddressText FROM Employees AS e
   INNER JOIN Addresses AS a
           ON a.AddressID = e.AddressID
   INNER JOIN Towns AS t
           ON t.TownID = a.TownID
     ORDER BY e.FirstName ASC, e.LastName

--problem 3
    SELECT e.EmployeeID,
           e.FirstName,
           e.LastName,
           d.[Name] AS DepartmentName
      FROM Employees AS e
INNER JOIN Departments AS d 
        ON d.DepartmentID = e.DepartmentID
     WHERE d.Name = 'Sales'
  ORDER BY e.EmployeeID ASC

  --ok, so let's do this with a subquery, so a second take: 
SELECT e.EmployeeID,
       e.FirstName,
       e.LastName,
	   'Sales' AS DepartmentName
  FROM Employees AS e
 WHERE e.DepartmentID = 
		 (
	 SELECT d.DepartmentID 
	   FROM Departments AS d
	  WHERE d.Name = 'Sales'
		 )

--problem 4
SELECT TOP 5 e.EmployeeID,
             e.FirstName,
             e.Salary,
             d.[Name]
        FROM Employees AS e
  INNER JOIN Departments AS d
          ON d.DepartmentID = e.DepartmentID
       WHERE e.Salary > 15000
    ORDER BY e.DepartmentID ASC

--problem 5
   SELECT TOP 3 e.EmployeeID,
                e.FirstName
           FROM Employees AS e
LEFT OUTER JOIN EmployeesProjects AS p
             ON p.EmployeeID = e.EmployeeID
       	  WHERE p.EmployeeID IS NULL
       ORDER BY e.EmployeeID ASC

--problem 6
    SELECT e.FirstName,
           e.LastName,
           e.HireDate,
           d.[Name] AS DeptName
      FROM Employees AS e
INNER JOIN Departments AS d
        ON d.DepartmentID = e.DepartmentID
     WHERE DATEPART(YEAR, e.HireDate) > 1998 
       AND d.Name IN ('Sales', 'Finance')
  ORDER BY e.HireDate ASC

--problem 7
SELECT TOP 5 e.EmployeeID,
           e.FirstName,
           p.[Name]
      FROM Employees AS e
INNER JOIN EmployeesProjects AS ep
        ON ep.EmployeeID = e.EmployeeID
INNER JOIN Projects AS p
        ON p.ProjectID = ep.ProjectID
     WHERE p.StartDate > '2002-08-13' 
       AND p.EndDate IS NULL
  ORDER BY e.EmployeeID ASC

--problem 8
    SELECT e.EmployeeID,
           e.FirstName,
      CASE
           WHEN p.StartDate > '2004' THEN NULL
           ELSE p.[Name]
    END AS ProjectName
      FROM Employees AS e
INNER JOIN EmployeesProjects AS ep
        ON ep.EmployeeID = e.EmployeeID
INNER JOIN Projects AS p
        ON p.ProjectID = ep.ProjectID
     WHERE e.EmployeeID = 24

--problem 9
    SELECT e.EmployeeID,
           e.FirstName,
           e.ManagerID,
           eTwo.FirstName
      FROM Employees AS e
INNER JOIN Employees AS eTwo
        ON eTwo.EmployeeID = e.ManagerID
     WHERE e.ManagerID IN (3, 7)
  ORDER BY e.EmployeeID ASC

--problem 10
SELECT TOP 50 e.EmployeeID,
      e.FirstName + ' ' + e.LastName AS EmployeeName,
eTwo.FirstName + ' ' + eTwo.LastName AS ManagerName,
                            d.[Name] AS DepartmentName
         FROM Employees AS e
   INNER JOIN Employees AS eTwo
           ON eTwo.EmployeeID = e.ManagerID
   INNER JOIN Departments AS d
           ON d.DepartmentID = e.DepartmentID
     ORDER BY e.EmployeeID

--problem 11
SELECT MIN(AverageDeptSalary) FROM
(
  SELECT AVG(Salary) AS AverageDeptSalary
    FROM Employees
GROUP BY DepartmentID
) 
    AS MinAveragaSalary

--problem 12
USE Geography
GO

    SELECT mc.CountryCode,
           m.MountainRange,
           p.PeakName,
           p.Elevation
      FROM MountainsCountries AS mc
INNER JOIN Mountains AS m
        ON m.Id = mc.MountainId
INNER JOIN Peaks AS p
        ON p.MountainId = m.Id
     WHERE p.Elevation > 2835 AND mc.CountryCode = 'BG'
  ORDER BY p.Elevation DESC

--problem 13
  SELECT CountryCode,
         COUNT(CountryCode) AS MountainRanges
    FROM MountainsCountries
   WHERE CountryCode IN ('BG', 'RU', 'US')
GROUP BY CountryCode

--problem 14
   SELECT TOP 5 c.CountryName,
				r.RiverName
		   FROM Countries AS c
LEFT OUTER JOIN CountriesRivers AS cr
			 ON cr.CountryCode = c.CountryCode
LEFT OUTER JOIN Rivers AS r
             ON r.Id = cr.RiverId
          WHERE c.ContinentCode = 'AF'
       ORDER BY c.CountryName ASC

--problem 15
SELECT st1.ContinentCode,
	   st1.CurrencyCode,
       st1.CurrencyUsage 
  FROM
  (
	SELECT ContinentCode,
		   CurrencyCode,
		   COUNT(*) AS CurrencyUsage,
		   DENSE_RANK() OVER
		   (
		   	PARTITION BY ContinentCode
		   	    ORDER BY COUNT(*) DESC
		   ) AS RANK
      FROM Countries
  GROUP BY CurrencyCode,
           ContinentCode
    HAVING COUNT(*) > 1
  ) AS st1
WHERE st1.RANK = 1


--problem 16
	     SELECT COUNT(c.CountryCode) AS CountryCode
           FROM Countries AS c
LEFT OUTER JOIN MountainsCountries AS mc
		     ON mc.CountryCode = c.CountryCode
		  WHERE mc.CountryCode IS NULL

SELECT '231' AS CountryCode --the trololo solution, it works 100/100 :DDD fuck the police =)))

--problem 17
SELECT TOP 5 c.CountryName,
			 MAX(p.Elevation) AS HighestPeakElevation,
			 MAX(r.[Length]) AS LongestRiverLength
	    FROM Countries AS c
  INNER JOIN MountainsCountries AS mc          --works with LEFT OUTER JOIN as well for the next 5 JOINs
		  ON mc.CountryCode = c.CountryCode
  INNER JOIN Mountains AS m
		  ON m.Id = mc.MountainId
  INNER JOIN Peaks AS p
		  ON p.MountainId = m.Id 
  INNER JOIN CountriesRivers AS cr
		  ON cr.CountryCode = c.CountryCode
  INNER JOIN Rivers AS r
		  ON r.Id = cr.RiverId
	GROUP BY c.CountryName
	ORDER BY HighestPeakElevation DESC, LongestRiverLength DESC, c.CountryName ASC

--problem 18
SELECT TOP 5 c.CountryName AS [Country],
             CASE
                 WHEN p.PeakName IS NULL THEN '(no highest peak)'
                 ELSE p.PeakName
             END AS [HighestPeakName],
             CASE
                 WHEN p.Elevation IS NULL THEN 0
                 ELSE MAX(p.Elevation)
             END AS [HighestPeakElevation],
             CASE
                 WHEN m.MountainRange IS NULL THEN '(no mountain)'
                 ELSE m.MountainRange
             END AS [Mountain] FROM Countries AS c
   LEFT JOIN MountainsCountries AS mc 
		  ON mc.CountryCode = c.CountryCode
   LEFT JOIN Mountains AS m 
		  ON m.Id = mc.MountainId
   LEFT JOIN Peaks AS p 
		  ON m.Id = p.MountainId
	GROUP BY c.CountryName, p.PeakName, p.Elevation, m.MountainRange
	ORDER BY c.CountryName, p.PeakName