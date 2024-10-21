-- Data Cleaning

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or blank values
-- 4. Remove Any Columns

SELECT * FROM layoffs;

-- Create staging table to alter data

CREATE TABLE layoffs_staging
LIKE layoffs
;

SELECT *
FROM layoffs_staging
;

INSERT layoffs_staging
SELECT *
FROM layoffs
;

-- Find if there exists duplicate companies by matching name, industry, number of layoffs and date the data was gathered

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`)
FROM layoffs_staging;

WITH duplicate_cte AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1
;

-- Delete all duplicated companies
-- Create another table with created row that shows duplicates (row_num)

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, funds_raised_millions) AS row_num
FROM layoffs_staging
;

SELECT * FROM layoffs_staging2
WHERE row_num > 1
;

DELETE
FROM layoffs_staging2
WHERE row_num > 1
;

SELECT *
FROM layoffs_staging2;

-- Standardizing Data

SELECT COMPANY, (TRIM(company))
FROM layoffs_staging2
;

-- Remove unnecessary spaces from companies' names

UPDATE layoffs_staging2
SET company = TRIM(company)
;

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1
;

-- Finding all industries related to crypto to insert into same category

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'CRYPTO%'
;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'CRYPTO%'
;

-- Fix countries that have small typing issues (United states had a wrong input)

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1
;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1
;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%'
;

-- Change date column to date instead of text

SELECT `date`
FROM layoffs_staging2
;

UPDATE layoffs_staging2
set `date` = str_to_date(`date`,'%m/%d/%Y')
;

ALTER table layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Look for missing values on numbers of layoffs

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS null
AND percentage_laid_off is null
;

SELECT *
FROM layoffs_staging2
WHERE industry is null
OR industry = ''
;

-- Populate values of layoffs based on same companies' data

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry is null or t1.industry = '')
AND t2.industry is not null
;

-- Change blank to null to be able to edit column

UPDATE layoffs_staging2
SET industry = NULL
where industry = '';

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	on t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry is null
AND t2.industry is not null
;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS null
AND percentage_laid_off is null
;

-- Deleted companies that had no info of layoffs

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS null
AND percentage_laid_off is null
;

SELECT *
FROM layoffs_staging2
;

-- Remove added column of duplicated companies

ALTER TABLE layoffs_staging2
DROP COLUMN row_num
;