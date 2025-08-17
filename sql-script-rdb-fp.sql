-- task 1
CREATE SCHEMA IF NOT EXISTS pandemic;
USE pandemic;

-- data columns imported as TEXT (except Year) to import all data (especially those with empty fields)
-- create new table with correct datatypes
CREATE TABLE infectious_cases_clean (
	Entity VARCHAR(50) NOT NULL,
    Code VARCHAR(50) NULL,
    Year INT NULL,
    Number_yaws INT NULL,
    polio_cases INT NULL,
    cases_guinea_worm INT NULL,
    Number_rabies DOUBLE NULL,
    Number_malaria DOUBLE NULL,
    Number_hiv DOUBLE NULL,
    Number_tuberculosis DOUBLE NULL,
    Number_smallpox INT NULL,
    Number_cholera_cases INT NULL
);

-- copy data from original table with converting empty values to NULL
INSERT INTO infectious_cases_clean
(Entity, Code, Year, Number_yaws, polio_cases, cases_guinea_worm,
 Number_rabies, Number_malaria, Number_hiv, Number_tuberculosis,
 Number_smallpox, Number_cholera_cases)
SELECT 
	Entity,
    Code,
    Year,
    NULLIF(Number_yaws, ''),
    NULLIF(polio_cases, ''),
    NULLIF(cases_guinea_worm, ''),
    NULLIF(Number_rabies, ''),
    NULLIF(Number_malaria, ''),
    NULLIF(Number_hiv, ''),
    NULLIF(Number_tuberculosis, ''),
    NULLIF(Number_smallpox, ''),
    NULLIF(Number_cholera_cases, '')
FROM infectious_cases;

-- selecting all data (number of data 1521, so limit is greater)
SELECT * FROM pandemic.infectious_cases_clean LIMIT 15230;

-- task 2
-- create Countries table with unique countries and their codes
CREATE TABLE Countries (
    CountryID INT AUTO_INCREMENT PRIMARY KEY,
    Entity VARCHAR(100) NOT NULL,
    Code VARCHAR(10) NOT NULL,
    UNIQUE (Entity, Code)
);

-- loading data into Countries table
INSERT INTO Countries (Entity, Code)
SELECT DISTINCT Entity, Code
FROM infectious_cases_clean;

-- selecting countries data
SELECT * FROM pandemic.countries;

-- create infectious cases table with referring to country through foreign key
CREATE TABLE Infectious_Cases_Normalised (
    CaseID INT AUTO_INCREMENT PRIMARY KEY,
    CountryID INT NOT NULL,
    Year INT NOT NULL,
    Number_yaws INT NULL,
    polio_cases INT NULL,
    cases_guinea_worm INT NULL,
    Number_rabies DOUBLE NULL,
    Number_malaria DOUBLE NULL,
    Number_hiv DOUBLE NULL,
    Number_tuberculosis DOUBLE NULL,
    Number_smallpox INT NULL,
    Number_cholera_cases INT NULL,
    FOREIGN KEY (CountryID) REFERENCES Countries(CountryID)
);

-- insert data into normalized infectious cases table
INSERT INTO Infectious_Cases_Normalised
(CountryID, Year, Number_yaws, polio_cases, cases_guinea_worm,
 Number_rabies, Number_malaria, Number_hiv, Number_tuberculosis,
 Number_smallpox, Number_cholera_cases)
SELECT 
    c.CountryID,
    ic.Year,
    ic.Number_yaws,
    ic.polio_cases,
    ic.cases_guinea_worm,
    ic.Number_rabies,
    ic.Number_malaria,
    ic.Number_hiv,
    ic.Number_tuberculosis,
    ic.Number_smallpox,
    ic.Number_cholera_cases
FROM infectious_cases_clean ic
JOIN Countries c ON ic.Entity = c.Entity AND ic.Code = c.Code;

-- selecting normalized infectious cases data
SELECT * FROM pandemic.infectious_cases_normalised;

-- task 3
SELECT 
    c.Entity,
    c.Code,
    AVG(ic.Number_rabies) AS avg_rabies,
    MIN(ic.Number_rabies) AS min_rabies,
    MAX(ic.Number_rabies) AS max_rabies,
    SUM(ic.Number_rabies) AS sum_rabies
FROM Infectious_Cases_Normalised ic
JOIN Countries c ON ic.CountryID = c.CountryID
WHERE ic.Number_rabies IS NOT NULL
GROUP BY c.Entity, c.Code
ORDER BY avg_rabies DESC
LIMIT 10;

-- task 4
WITH years_cte AS (
    SELECT 
        ic.CountryID,
        ic.Year,
        STR_TO_DATE(CONCAT(ic.Year, '-01-01'), '%Y-%m-%d') AS FirstOfYear,
        CURDATE() AS CurrentDate
    FROM Infectious_Cases_Normalised ic
)
SELECT 
    c.Entity,
    c.Code,
    y.Year,
    y.FirstOfYear,
    y.CurrentDate,
    TIMESTAMPDIFF(YEAR, y.FirstOfYear, y.CurrentDate) AS YearDifference
FROM years_cte y
JOIN Countries c ON y.CountryID = c.CountryID;

-- task 5
DELIMITER $$

CREATE FUNCTION YearDifferenceFromNow(year_input INT)
RETURNS INT
NOT DETERMINISTIC
NO SQL
BEGIN
    DECLARE start_of_year DATE;
    SET start_of_year = STR_TO_DATE(CONCAT(year_input, '-01-01'), '%Y-%m-%d');
    RETURN TIMESTAMPDIFF(YEAR, start_of_year, CURDATE());
END $$

DELIMITER ;

-- using the function
SELECT 
    c.Entity,
    c.Code,
    ic.Year,
    YearDifferenceFromNow(ic.Year) AS YearDifference
FROM Infectious_Cases_Normalised ic
JOIN Countries c ON ic.CountryID = c.CountryID