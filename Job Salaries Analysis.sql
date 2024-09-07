CREATE DATABASE ds;

USE ds;

SELECT * FROM ds_salaries;

-- 1. CHECKING MISSING VALUE
SELECT * FROM ds_salaries
WHERE COALESCE
	(work_year, 
    experience_level, 
    employment_type, 
    job_title, 
    salary, 
    salary_currency, 
    salary_in_usd, 
    employee_residence, 
    remote_ratio, 
    company_location, 
    company_size) 
IS NULL;

-- 2. JOB TITLE IDENTIFICATION (JOB TYPE)
SELECT DISTINCT job_title 
FROM ds_salaries 
ORDER BY job_title;

-- 3. JOB TITLES RELATED TO DATA ANALYST;
SELECT DISTINCT job_title 
FROM ds_salaries 
WHERE job_title LIKE '%data analyst%'
ORDER BY job_title;

-- 4 AVERAGE SALARY OF DATA ANALYST?
SELECT (AVG(salary_in_usd)*15000)/12 AS avg_sal_rp_monthly 
FROM ds_salaries 
WHERE job_title LIKE '%data analyst%';
-- secara keseluruhan, ini kurang bisa menggambarkan karena ada experience level

-- 4.1 AVERAGE SALARY OF DATA ANALYST BASED ON EXPERIENCE LEVEL?
SELECT experience_level,
	(AVG(salary_in_usd)*15000)/12 AS avg_sal_rp_monthly 
FROM ds_salaries
WHERE job_title LIKE '%data analyst%'
GROUP BY experience_level
ORDER BY avg_sal_rp_monthly;

-- 4.2 AVERAGE SALARY OF DATA ANALYST BASED ON EXPERIENCE LEVEL AND EMPLOYMENT TYPE
SELECT experience_level,
	employment_type,
	(AVG(salary_in_usd)*15000)/12 AS avg_sal_rp_monthly 
FROM ds_salaries
WHERE job_title LIKE '%data analyst%'
GROUP BY experience_level, employment_type
ORDER BY experience_level;

-- 5. COUNTRY WITH ATTRACTIVE SALARY FOR DATA ANALYST POSITION
SELECT company_location, 
	AVG(salary_in_usd) AS avg_sal_in_usd
FROM ds_salaries
WHERE job_title LIKE '%data analyst%'
    AND employment_type = 'FT'
    AND experience_level IN ('EN','MI')
GROUP BY company_location
HAVING avg_sal_in_usd >= 20000
ORDER BY avg_sal_in_usd DESC;

-- 6. YEAR WITH THE HIGHEST SALARY INCERASE FROM MID-LEVEL TO SENIOR-LEVEL DATA ANALYST
-- FOR FULL-TIME JOB
WITH ds_1 AS (
	SELECT work_year,
		AVG(salary_in_usd) sal_in_usd_se
	FROM ds_salaries
    WHERE 
		employment_type = 'FT'
		AND experience_level = 'SE'
        AND job_title LIKE '%data analyst%'
	GROUP BY work_year
), ds_2 AS (
	SELECT work_year,
		AVG(salary_in_usd) sal_in_usd_mi
	FROM ds_salaries
    WHERE 
		employment_type = 'FT'
		AND experience_level = 'MI'
        AND job_title LIKE '%data analyst%'
	GROUP BY work_year
), t_year AS (
	SELECT DISTINCT work_year
    FROM ds_salaries
) 
SELECT t_year.work_year, 
	ds_1.sal_in_usd_se, 
    ds_2.sal_in_usd_mi,
    ds_1.sal_in_usd_se - ds_2.sal_in_usd_mi difference
FROM t_year
LEFT JOIN ds_1 ON ds_1.work_year = t_year.work_year
LEFT JOIN ds_2 ON ds_2.work_year = t_year.work_year;