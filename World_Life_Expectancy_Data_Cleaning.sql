# World Life Expectancy Project (Data Cleaning)

SELECT * 
FROM world_life_expectancy.world_life_expectancy
;

# There should not be 2 of the same country on the same year. This checks that.
SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
FROM world_life_expectancy.world_life_expectancy
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1
;

# This section finds the row_id of the duplicates so we can delete them later
SELECT *
FROM(
	SELECT Row_ID, 
	CONCAT(Country, Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) as Row_num
	FROM world_life_expectancy
) as Row_Table
WHERE Row_Num > 1
;

# Deleting the duplicates
DELETE FROM world_life_expectancy
WHERE 
	Row_ID IN (
	SELECT Row_ID
FROM(
	SELECT Row_ID, 
	CONCAT(Country, Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) as Row_num
	FROM world_life_expectancy
) as Row_Table
WHERE Row_Num > 1
)
;


SELECT * 
FROM world_life_expectancy.world_life_expectancy
WHERE Status = ''
;

# Checking the different options for Status
SELECT DISTINCT(Status)
FROM world_life_expectancy.world_life_expectancy
WHERE Status != ''
;

SELECT DISTINCT(Country)
FROM world_life_expectancy
WHERE Status = 'Developing'
;

UPDATE world_life_expectancy
SET Status = 'Developing'
WHERE Country IN 	(SELECT DISTINCT(Country)
					FROM world_life_expectancy
					WHERE Status = 'Developing')
;

# Updates all developing blanks by self joining tables
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
SET t1.Status = 'Developing'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developing'
;


SELECT * 
FROM world_life_expectancy.world_life_expectancy
WHERE Country = 'United States of America'
;

# Updates Developed countries blanks with Self join
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
SET t1.Status = 'Developed'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developed'
;

SELECT * 
FROM world_life_expectancy.world_life_expectancy
WHERE `Life expectancy` = ''
;

# The idea is to fill in missing value with the average of the year before and after
SELECT Country, Year, `Life expectancy`
FROM world_life_expectancy.world_life_expectancy
#WHERE `Life expectancy` = ''
;

# Calculates the average of the year before and after for blank entries
SELECT t1.Country, t1.Year, t1.`Life expectancy`, 
t2.Country, t2.Year, t2.`Life expectancy`,
t3.Country, t3.Year, t3.`Life expectancy`,
ROUND((t2.`Life expectancy` + t3.`Life expectancy`) / 2,1)
FROM world_life_expectancy t1
JOIN world_life_expectancy t2 
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3 
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
WHERE t1.`Life expectancy` = ''
;

# Updates the table blanks with the calculated values
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2 
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3 
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`) / 2,1)
WHERE t1.`Life expectancy` = ''
;












