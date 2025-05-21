-- This project focuses on analyzing the top 25 richest Presidents of the United States using a raw dataset that includes details like name, political party, vice presidents, salaries, and date records. The goal was to clean, transform, and visualize the data using MySQL and Excel Dashboarding techniques.--
-- so first I would want to clean the data using sql which I feel has a better edge over cleaning in excel especially if it's a large dataset.But for now, let's keep it simple.


-- Step 1: Preview original data
SELECT * FROM presidential;

-- Step 2: Creating a staging table to work on.This table just copies the data for convinience,one of the best practices:)--
CREATE TABLE Presidential_staging LIKE presidential;
INSERT Presidential_staging SELECT * FROM presidential;

-- We begin by creating a staging copy of the original dataset to avoid manipulating raw data directly.

-- Step 3: Correcting typos

UPDATE presidential_staging 
SET party = 'Democratic' 
WHERE party = 'Demorcatic';
-- Fixed a typo in the party column (Demorcatic -> Democratic)--

-- Step 4: Check for duplicates
WITH CTE_DUP AS (
    SELECT *, 
    ROW_NUMBER() OVER (
        PARTITION BY president, prior, party, vice, salary, `date updated`, `date created`
    ) AS ROW_NUM
    FROM presidential_staging
)
SELECT * FROM CTE_DUP WHERE ROW_NUM > 1;
-- we Use a CTE and ROW_NUMBER() to find duplicate records by grouping on key fields.

-- Step 5: Creating new cleaned table and remove duplicates
DROP TABLE IF EXISTS presidential_staging2;
CREATE TABLE presidential_staging2 (
  `MyUnknownColumn` int DEFAULT NULL,
  `S.No.` int DEFAULT NULL,
  `president` text,
  `prior` text,
  `party` text,
  `vice` text,
  `salary` text,
  `date updated` text,
  `date created` text,
  `ROW_NUM` INT
);

INSERT INTO presidential_staging2
SELECT *, 
ROW_NUMBER() OVER (
    PARTITION BY president, prior, party, vice, salary, `date updated`, `date created`
) AS ROW_NUM
FROM presidential_staging;

DELETE FROM presidential_staging2 WHERE ROW_NUM > 1;

-- 2. standardize data

-- Step 6: Cleaning and standardizing fields
UPDATE presidential_staging2
SET 
    vice = TRIM(REGEXP_REPLACE(vice, 'John C.*', 'John C.Calhoun')),
    party = CASE 
        WHEN party LIKE 'Whig%' THEN 'Whig'
        WHEN party LIKE 'Republican%' THEN 'Republican'
        ELSE party
    END,
    prior = REGEXP_REPLACE(
             REGEXP_REPLACE(TRIM(prior), '‰ÛÒ', '-'),
             '\\s+', ' '
           );
-- Now that we have the trimmed and standardized data of:

-- Vice president names

-- Party names (removed extra characters)

-- Prior  fields (handled special characters and spacing)


-- Step 7: Formatting date columns
UPDATE presidential_staging2
SET `date updated` = CASE
    WHEN `date updated` REGEXP '[a-zA-Z]' THEN
        DATE_FORMAT(STR_TO_DATE(`date updated`, '%d %M %Y'), '%d-%m-%Y')
    ELSE `date updated`
END;

UPDATE presidential_staging2
SET `date created` = CASE
    WHEN `date created` REGEXP '[a-zA-Z]' THEN
        DATE_FORMAT(STR_TO_DATE(`date created`, '%d %M %Y'), '%d-%m-%Y')
    ELSE `date created`
END;

-- we Converted date columns to consistent DD-MM-YYYY format for better readability and analysis.
-- Step 8: Dropping unwanted columns
ALTER TABLE presidential_staging2 DROP COLUMN MyUnknownColumn;
ALTER TABLE presidential_staging2 DROP COLUMN ROW_NUM;
SELECT * FROM presidential_staging2 ORDER BY `S.No.`;
-- Finally, removed temporary and irrelevant columns, and sorted the cleaned data.

SELECT * FROM presidential_staging2;
-- we can finally look at our final version of the presidential table which is now cleaned.
