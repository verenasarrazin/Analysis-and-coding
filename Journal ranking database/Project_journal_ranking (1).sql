

-- ------------------------- JOURNAL RANKING DATABASE -----------------------------------


CREATE DATABASE IF NOT EXISTS journal_ranking;
USE journal_ranking;

-- These tables were read in from csv files
SELECT * FROM main; -- includes Journal Title, Country, Subject Area; most of the other tables refer to the ID variable as foreign key
SELECT * FROM docs; -- includes how many documents journals publish and how often they are cited
SELECT * FROM scores; -- includes quality scores such as SJR index and Cite Score
SELECT * FROM publisher; -- includes publisher and Open Access
SELECT * FROM country; -- includes the continent for each country

-- This table was created manually to save the date of new entries
CREATE TABLE date_added(
ID INT,
DateAdded DATE);

-- Add primary and foreign keys ---------------------------------------------------------------------------------------------------------------------------------------

-- primary key for main table
ALTER TABLE main
ADD PRIMARY KEY (ID);

-- primary key for country table
ALTER TABLE country
ADD PRIMARY KEY (Country);

-- foreign key to link main to country
ALTER TABLE main
ADD FOREIGN KEY (Country)
REFERENCES country (Country);

-- add primary and foreign key to docs
ALTER TABLE docs
ADD PRIMARY KEY (ID);

ALTER TABLE docs
ADD FOREIGN KEY (ID)
REFERENCES main (ID);

-- add primary and foreign key to scores
ALTER TABLE scores
ADD PRIMARY KEY (ID);

ALTER TABLE scores
ADD FOREIGN KEY (ID)
REFERENCES main (ID);

-- add primary and foreign key to publisher
ALTER TABLE publisher
ADD PRIMARY KEY (ID);

ALTER TABLE publisher
ADD FOREIGN KEY (ID)
REFERENCES main (ID);

-- add foreign key for date_added
ALTER TABLE date_added
ADD FOREIGN KEY (ID)
REFERENCES main (ID);


-- Queries (with subqueries) ----------------------------------------------------------------------------------------------------------------------------------------

-- Count how many journals exist for each Subject Area, and order by number

SELECT SubjectArea, COUNT(Title) FROM main
GROUP BY SubjectArea
ORDER BY COUNT(Title) DESC;

-- Display for each subject area the journal with the highest SJR index

SELECT ID, Title, SubjectArea FROM main
WHERE ID IN
(SELECT min(t1.ID)
FROM main t1
INNER JOIN scores t2
ON t1.ID = t2.ID
GROUP BY SubjectArea);

-- Count how many journals per subject area have been cited more than 100,000 times in the past 3 years

SELECT Count(t1.ID) AS More_than_100000_cites, SubjectArea
FROM main t1
INNER JOIN docs t2
ON t1.ID = t2.ID AND TotalCites3y > 100000
GROUP BY SUBJECTArea;


-- FUNCTIONS --------------------------------------------------------------------------------------------------------------------------------------------------

-- 1 --

-- The function more_cites_than_average(TotalCites3y INT) tests whether a journal has more cites than the average across all journals.
-- The function first calls the function average_cites() which calculates the average cites across all journals.


delimiter $$
CREATE FUNCTION average_cites()
RETURNS FLOAT
DETERMINISTIC
BEGIN
	DECLARE cites_average FLOAT;
    SELECT AVG(TotalCites3y) INTO cites_average FROM docs;
    RETURN (cites_average);
END $$
DELIMITER ;

SELECT average_cites();

delimiter $$
CREATE FUNCTION more_cites_than_average(TotalCites3y INT)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
	DECLARE more_than_avg VARCHAR(20);
       IF TotalCites3y > average_cites() THEN
		    SET more_than_avg = 'YES';
	   ELSEIF (TotalCites3y < average_cites()) THEN
			SET more_than_avg = 'no';
	   ELSEIF (TotalCites3y = average_cites()) THEN
			SET more_than_avg = 'Average';
	   END IF;
	RETURN (more_than_avg);
END $$
delimiter ;

-- apply function to all journals
SELECT ID,  more_cites_than_average(TotalCites3y) AS Above_average_cites FROM docs;


-- 2 --

-- The function correlation() returns the Pearson correlation between SJR_index and CiteScore.
-- It calls the function covariance() which calculates the covariance between these variables.


delimiter \\
CREATE FUNCTION covariance()
RETURNS FLOAT
DETERMINISTIC
BEGIN
DECLARE cov FLOAT;
SELECT( SUM( SJR_index * CIteScore ) - SUM( SJR_index ) * SUM( CIteScore ) / COUNT( SJR_index ) ) / COUNT( SJR_index ) INTO cov FROM scores;
RETURN (cov);
END \\
delimiter ;


delimiter \\
CREATE FUNCTION correlation()
RETURNS FLOAT
DETERMINISTIC
BEGIN
DECLARE corr FLOAT;
SELECT COVARIANCE() / ( STDDEV( SJR_index ) * STDDEV( CiteScore ) ) INTO corr FROM scores;
RETURN (corr);
END \\
delimiter ;

-- Call the correlation() function
select correlation() AS Correlation_SJR_CiteScore;



-- View ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Create view that combines main, publisher and scores
CREATE VIEW journal_info AS
SELECT t1.ID, Title, BestQuartile, Country, SubjectArea, Publisher, OA AS OpenAcces, SJR_index
FROM main t1
INNER JOIN publisher t2
ON t1.ID = t2.ID
INNER JOIN scores t3
ON t2.ID = t3.ID;

SELECT * FROM journal_info;

-- Use this view for analalysis: Display number of OpenAccess and non-OpenAccess journals, and the corresponing average SJR-index

SELECT OpenAcces, COUNT(Title) AS Number_of_journals, AVG(SJR_index) AS Average_SJR_index FROM journal_info
GROUP BY OpenAcces;


-- Stored procedure ----------------------------------------------------------------------------------------------------------------------------------------------------------

-- inserts a new entry into main

delimiter $$
CREATE PROCEDURE insert_main(
	IN ID INT,
    IN Title VARCHAR(80),
    IN BestQuartile VARCHAR(2),
    IN Country VARCHAR(80),
    IN SubjectArea VARCHAR(80))
BEGIN INSERT INTO main
(ID, Title, BestQuartile, Country, SubjectArea)
VALUES
(ID, Title, BestQuartile, Country, SubjectArea);
END $$
delimiter ;

-- Test this procedure:
CALL insert_main(18016, 'Verenas journal', 'Q4', 'Germany', 'Medicine');
SELECT * FROM main
WHERE ID = 18016;

-- Trigger -------------------------------------------------------------------------------------------------------------------------------------------------------------

-- This trigger adds the date (and ID) to the table date_added for every new row inserted into main.

delimiter $$
CREATE TRIGGER add_date AFTER INSERT ON main
FOR EACH ROW
BEGIN
INSERT INTO date_added
(ID, DateAdded)
VALUES
(NEW.ID, DATE(now()));
	END $$
DELIMITER ;

-- Check if inserting a row into main added date to date_added:
SELECT * FROM date_added;
