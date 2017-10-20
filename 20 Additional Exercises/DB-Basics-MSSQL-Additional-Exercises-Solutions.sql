USE Diablo
GO

--problem 1
SELECT
SUBSTRING(Email, 
CHARINDEX('@', Email, 1) + 1, 
LEN(Email) + 1 - CHARINDEX('@', Email, 1)) AS [Email Provider],

COUNT(Email) AS [Number of Users]

FROM Users

GROUP BY SUBSTRING(Email, 
CHARINDEX('@', Email, 1) + 1, 
LEN(Email) + 1 - CHARINDEX('@', Email, 1))

ORDER BY [Number of Users] DESC, [Email Provider]

--problem 2
	SELECT g.[Name],
		   gt.[Name],
		   u.Username,
		   ug.[Level],
		   ug.Cash,
		   ch.[Name]
	  FROM Games AS g
INNER JOIN GameTypes AS gt
		ON gt.Id = g.GameTypeId
INNER JOIN UsersGames AS ug
		ON ug.GameId = g.Id
INNER JOIN Users AS u
		ON u.Id = ug.UserId
INNER JOIN Characters AS ch
		ON ch.Id = ug.CharacterId
  ORDER BY ug.[Level] DESC, u.Username, g.[Name]

--problem 3
	SELECT u.Username,
		   g.[Name],
		   COUNT(i.Id) AS [Items Count],
		   SUM(i.Price) AS [Items Price]
	  FROM UsersGames AS ug
INNER JOIN Users AS u
		ON u.Id = ug.UserId
INNER JOIN Games AS g
		ON g.Id = ug.GameId
INNER JOIN UserGameItems AS ugi
		ON ugi.UserGameId = ug.Id
INNER JOIN Items AS i
		ON i.Id = ugi.ItemId
  GROUP BY u.Username, g.[Name]
	HAVING COUNT(i.Id) >= 10
  ORDER BY [Items Count] DESC, [Items Price] DESC, u.Username

--problem 4
	SELECT u.Username,
		   g.Name AS [Game],
		   MAX(ch.Name) AS Character,
		   MAX(statch.Strength) + MAX(statgt.Strength) + SUM(stati.Strength) AS Strength, 
		   MAX(statch.Defence) + MAX(statgt.Defence) + SUM(stati.Defence) AS Defence, 
		   MAX(statch.Speed) + MAX(statgt.Speed) + SUM(stati.Speed) AS Speed, 
		   MAX(statch.Mind) + MAX(statgt.Mind) + SUM(stati.Mind) AS Mind, 
		   MAX(statch.Luck) + MAX(statgt.Luck) + SUM(stati.Luck) AS Luck
	  FROM Users AS u
INNER JOIN UsersGames AS ug
		ON ug.UserId = u.Id
INNER JOIN Games AS g
		ON g.Id = ug.GameId
INNER JOIN Characters AS ch
		ON ch.Id = ug.CharacterId
INNER JOIN [Statistics] AS statch
		ON statch.Id = ch.StatisticId
INNER JOIN GameTypes AS gt
		ON gt.Id = g.GameTypeId
INNER JOIN [Statistics] AS statgt
		ON statgt.Id = gt.BonusStatsId
INNER JOIN UserGameItems AS ugi
		ON ugi.UserGameId = ug.Id
INNER JOIN Items AS i
		ON i.Id = ugi.ItemId
INNER JOIN [Statistics] AS stati
		ON stati.Id = i.StatisticId
  GROUP BY u.Username, g.Name
  ORDER BY Strength DESC, Defence DESC, Speed DESC, Mind DESC, Luck DESC

--problem 5
	SELECT i.[Name],
		   i.Price,
		   i.MinLevel,
		   st.Strength,
		   st.Defence,
		   st.Speed,
		   st.Luck,
		   st.Mind
	  FROM Items AS i
INNER JOIN [Statistics] AS st
		ON st.Id = i.StatisticId
	 WHERE st.Mind > (SELECT AVG(Mind) FROM [Statistics])
	   AND st.Luck > (SELECT AVG(Luck) FROM [Statistics])
	   AND st.Speed > (SELECT AVG(Speed) FROM [Statistics])
  ORDER BY i.[Name]

--problem 6
		 SELECT i.[Name] AS [Item],
		   	    i.price,
		   	    i.MinLevel,
		   	    gt.[Name] AS [Forbidden Game Type]
		   FROM Items AS i
LEFT OUTER JOIN GameTypeForbiddenItems AS gtfi
			 ON gtfi.ItemId = i.Id
LEFT OUTER JOIN GameTypes AS gt
			 ON gt.Id = gtfi.GameTypeId
	   ORDER BY [Forbidden Game Type] DESC, i.[Name]

--problem 7.1
--Blackguard, Bottomless Potion of Amplification, Eye of Etlich (Diablo III), Gem of Efficacious Toxin, Golden Gorget of Leoric and Hellfire Amulet
DECLARE @AlexCash MONEY;
DECLARE @AlexEdinburghID INT;
DECLARE @ItemsTotalPrice MONEY;

SET @AlexEdinburghID = (SELECT Id 
						FROM UsersGames 
						WHERE UserId = (SELECT Id FROM Users WHERE Username = 'Alex')
							AND GameId = (SELECT Id FROM Games WHERE Name = 'Edinburgh'));

SET @ItemsTotalPrice = (SELECT SUM(Price) FROM Items 
							WHERE Name IN 
							('Blackguard',
							'Bottomless Potion of Amplification',
							'Eye of Etlich (Diablo III)',
							'Gem of Efficacious Toxin',
							'Golden Gorget of Leoric',
							'Hellfire Amulet'))

UPDATE UsersGames
SET Cash -= @ItemsTotalPrice WHERE Id = @AlexEdinburghID

INSERT INTO UserGameItems VALUES
	((SELECT Id FROM Items WHERE Name = 'Blackguard'), @AlexEdinburghID),
	((SELECT Id FROM Items WHERE Name = 'Bottomless Potion of Amplification'), @AlexEdinburghID),
	((SELECT Id FROM Items WHERE Name = 'Eye of Etlich (Diablo III)'), @AlexEdinburghID),
	((SELECT Id FROM Items WHERE Name = 'Gem of Efficacious Toxin'), @AlexEdinburghID),
	((SELECT Id FROM Items WHERE Name = 'Golden Gorget of Leoric'), @AlexEdinburghID),
	((SELECT Id FROM Items WHERE Name = 'Hellfire Amulet'), @AlexEdinburghID)

--problem 7.2
    SELECT u.Username,
		   g.[Name],
		   ug.Cash,
		   i.[Name]
	  FROM Users AS u
INNER JOIN UsersGames AS ug
		ON ug.UserId = u.Id
INNER JOIN Games AS g
		ON g.Id = ug.GameId
INNER JOIN UserGameItems AS ugi
		ON ugi.UserGameId = ug.Id
INNER JOIN Items AS i
		ON i.Id = ugi.ItemId
	 WHERE g.Name = 'Edinburgh'
  ORDER BY g.[Name]

--problem 8
USE Geography
GO

    SELECT p.PeakName,
		   m.MountainRange AS [Mountain],
		   p.Elevation
	  FROM Peaks AS p
INNER JOIN Mountains AS m
		ON m.Id = p.MountainId
  ORDER BY p.Elevation DESC

--problem 9
    SELECT p.PeakName,
		   m.MountainRange AS [Mountain],
		   c.CountryName,
		   cc.ContinentName
	  FROM Peaks AS p
INNER JOIN Mountains AS m
		ON m.Id = p.MountainId
INNER JOIN MountainsCountries AS mc
		ON mc.MountainId = m.Id
INNER JOIN Countries AS c
		ON c.CountryCode = mc.CountryCode
INNER JOIN Continents AS cc
		ON cc.ContinentCode = c.ContinentCode
  ORDER BY p.PeakName, c.CountryName

--problem 10
    SELECT c.CountryName,
		   cc.ContinentName,
		   COUNT(r.RiverName) AS RiversCount,
		   CASE
			WHEN COUNT(r.RiverName) <> 0 THEN SUM(r.Length)
			ELSE 0
		   END AS TotalLength
	  FROM Countries AS c
INNER JOIN Continents AS cc
		ON cc.ContinentCode = c.ContinentCode
LEFT OUTER JOIN CountriesRivers AS cr
		ON cr.CountryCode = c.CountryCode
LEFT OUTER JOIN Rivers AS r
		ON r.Id = cr.RiverId
  GROUP BY c.CountryName, cc.ContinentName
  ORDER BY RiversCount DESC, TotalLength DESC, c.CountryName ASC

--problem 11
		 SELECT c.CurrencyCode, 
				c.Description AS Currency, 
				COUNT(cc.CountryCode) AS NumberOfCountries
		   FROM Currencies AS c
LEFT OUTER JOIN Countries AS cc 
			 ON cc.CurrencyCode = c.CurrencyCode
	   GROUP BY c.CurrencyCode, c.Description
	   ORDER BY NumberOfCountries DESC, Currency

--problem 12
	SELECT c.ContinentName,
		   SUM(CAST(cntr.AreaInSqKm AS bigint)) AS CountriesArea,
		   SUM(CAST(cntr.[Population] AS bigint)) AS CountriesPopulation
	  FROM Continents AS c
INNER JOIN Countries AS cntr
		ON cntr.ContinentCode = c.ContinentCode
  GROUP BY c.ContinentName
  ORDER BY CountriesPopulation DESC

--problem 13.1
CREATE TABLE Monasteries
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(177),
	CountryCode CHAR(2) FOREIGN KEY REFERENCES Countries(CountryCode)
)


/*
--problem 13.2
 INSERT INTO Monasteries(Name, CountryCode) VALUES
('Rila Monastery “St. Ivan of Rila”', 'BG'), 
('Bachkovo Monastery “Virgin Mary”', 'BG'),
('Troyan Monastery “Holy Mother''s Assumption”', 'BG'),
('Kopan Monastery', 'NP'),
('Thrangu Tashi Yangtse Monastery', 'NP'),
('Shechen Tennyi Dargyeling Monastery', 'NP'),
('Benchen Monastery', 'NP'),
('Southern Shaolin Monastery', 'CN'),
('Dabei Monastery', 'CN'),
('Wa Sau Toi', 'CN'),
('Lhunshigyia Monastery', 'CN'),
('Rakya Monastery', 'CN'),
('Monasteries of Meteora', 'GR'),
('The Holy Monastery of Stavronikita', 'GR'),
('Taung Kalat Monastery', 'MM'),
('Pa-Auk Forest Monastery', 'MM'),
('Taktsang Palphug Monastery', 'BT'),
('Sümela Monastery', 'TR') 
*/

--problem 13.3
ALTER TABLE Countries 
ADD IsDeleted BIT NOT NULL DEFAULT 0

--problem 13.4
UPDATE Countries
   SET IsDeleted = 1
  FROM Countries
 WHERE CountryCode IN (
						 SELECT cr.CountryCode 
		  				   FROM CountriesRivers cr 
		  				   JOIN Rivers r 
						   ON r.Id = cr.RiverId
		  				  GROUP BY cr.CountryCode
		  				 HAVING COUNT(r.Id) > 3
		  			   )

--problem 13.5
	SELECT m.[Name],
		   c.CountryName
	  FROM Monasteries AS m
INNER JOIN Countries AS c
		ON c.CountryCode = m.CountryCode
	 WHERE c.IsDeleted <> 1
  ORDER BY m.[Name]

--problem 14.1
UPDATE Countries
   SET CountryName = 'Burma'
 WHERE CountryName = 'Myanmar'

--problem 14.2
INSERT INTO Monasteries VALUES
('Hanga Abbey', (
				SELECT CountryCode 
				FROM Countries 
				WHERE CountryName = 'Tanzania'
				))
--problem 14.3
INSERT INTO Monasteries VALUES
('Myin-Tin-Daik', (
				SELECT CountryCode 
				FROM Countries 
				WHERE CountryName = 'Myanmar'
				))

--problem 14.4
		 SELECT c.ContinentName,
				cs.CountryName,
				COUNT(m.Id) AS [MonasteriesCount]
		   FROM Continents AS c
	 INNER JOIN Countries AS cs
			 ON cs.ContinentCode = c.ContinentCode
LEFT OUTER JOIN Monasteries AS m
			 ON m.CountryCode = cs.CountryCode
		  WHERE cs.IsDeleted = 0
	   GROUP BY c.ContinentName, cs.CountryName
	   ORDER BY [MonasteriesCount] DESC, cs.CountryName