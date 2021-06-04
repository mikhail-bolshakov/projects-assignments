--holidays table is created from holidays_table.py
--the sql is snowflake dialect
ALTER SESSION
   SET WEEK_START = 1;
   
CREATE TEMP TABLE mb_holidays 
(holiday_date date,
holiday_name string);
 
INSERT INTO mb_holidays values
( '2019-01-01' , 'Neujahr' ) ,
( '2019-04-19' , 'Karfreitag' ) ,
( '2019-04-22' , 'Ostermontag' ) ,
( '2019-05-01' , 'Erster Mai' ) ,
( '2019-05-30' , 'Christi Himmelfahrt' ) ,
( '2019-06-10' , 'Pfingstmontag' ) ,
( '2019-10-03' , 'Tag der Deutschen Einheit' ) ,
( '2019-12-25' , 'Erster Weihnachtstag' ) ,
( '2019-12-26' , 'Zweiter Weihnachtstag' ) ,
( '2020-01-01' , 'Neujahr' ) ,
( '2020-04-10' , 'Karfreitag' ) ,
( '2020-04-13' , 'Ostermontag' ) ,
( '2020-05-01' , 'Erster Mai' ) ,
( '2020-05-21' , 'Christi Himmelfahrt' ) ,
( '2020-06-01' , 'Pfingstmontag' ) ,
( '2020-10-03' , 'Tag der Deutschen Einheit' ) ,
( '2020-12-25' , 'Erster Weihnachtstag' ) ,
( '2020-12-26' , 'Zweiter Weihnachtstag' ) ,
( '2021-01-01' , 'Neujahr' ) ,
( '2021-04-02' , 'Karfreitag' ) ,
( '2021-04-05' , 'Ostermontag' ) ,
( '2021-05-01' , 'Erster Mai' ) ,
( '2021-05-13' , 'Christi Himmelfahrt' ) ,
( '2021-05-24' , 'Pfingstmontag' ) ,
( '2021-10-03' , 'Tag der Deutschen Einheit' ) ,
( '2021-12-25' , 'Erster Weihnachtstag' ) ,
( '2021-12-26' , 'Zweiter Weihnachtstag' ) ,
( '2022-01-01' , 'Neujahr' ) ,
( '2022-04-15' , 'Karfreitag' ) ,
( '2022-04-18' , 'Ostermontag' ) ,
( '2022-05-01' , 'Erster Mai' ) ,
( '2022-05-26' , 'Christi Himmelfahrt' ) ,
( '2022-06-06' , 'Pfingstmontag' ) ,
( '2022-10-03' , 'Tag der Deutschen Einheit' ) ,
( '2022-12-25' , 'Erster Weihnachtstag' ) ,
( '2022-12-26' , 'Zweiter Weihnachtstag' ) ,
( '2023-01-01' , 'Neujahr' ) ,
( '2023-04-07' , 'Karfreitag' ) ,
( '2023-04-10' , 'Ostermontag' ) ,
( '2023-05-01' , 'Erster Mai' ) ,
( '2023-05-18' , 'Christi Himmelfahrt' ) ,
( '2023-05-29' , 'Pfingstmontag' ) ,
( '2023-10-03' , 'Tag der Deutschen Einheit' ) ,
( '2023-12-25' , 'Erster Weihnachtstag' ) ,
( '2023-12-26' , 'Zweiter Weihnachtstag' ) ,
( '2024-01-01' , 'Neujahr' ) ,
( '2024-03-29' , 'Karfreitag' ) ,
( '2024-04-01' , 'Ostermontag' ) ,
( '2024-05-01' , 'Erster Mai' ) ,
( '2024-05-09' , 'Christi Himmelfahrt' ) ,
( '2024-05-20' , 'Pfingstmontag' ) ,
( '2024-10-03' , 'Tag der Deutschen Einheit' ) ,
( '2024-12-25' , 'Erster Weihnachtstag' ) ,
( '2024-12-26' , 'Zweiter Weihnachtstag' ) ,
( '2025-01-01' , 'Neujahr' ) ,
( '2025-04-18' , 'Karfreitag' ) ,
( '2025-04-21' , 'Ostermontag' ) ,
( '2025-05-01' , 'Erster Mai' ) ,
( '2025-05-29' , 'Christi Himmelfahrt' ) ,
( '2025-06-09' , 'Pfingstmontag' ) ,
( '2025-10-03' , 'Tag der Deutschen Einheit' ) ,
( '2025-12-25' , 'Erster Weihnachtstag' ) ,
( '2025-12-26' , 'Zweiter Weihnachtstag' ) 
;
--###############################################

 
WITH CTE_MY_DATE
AS
(SELECT DATEADD(DAY,SEQ4 (),'2019-01-01')::DATE AS full_date
FROM TABLE (GENERATOR (ROWCOUNT => 1000))),dates_table AS 
(SELECT full_date,
       date_trunc('month',full_date) AS date_trunc_month,
       date_trunc('year',full_date) AS date_trunc_year,
       DAYOFYEAR(full_date) AS day_year_ordinal,
       DAYNAME(full_date) AS day_name,
       WEEK(full_date) AS week_num,
       DAYOFWEEK(full_date) AS day_of_week,
       quarter(full_date) AS quarter_num,
       MONTHNAME(full_date) AS month_name,
       datediff(DAY,date_trunc ('month',full_date),last_day (full_date,MONTH)) + 1 AS days_in_month
FROM cte_my_date),
holidays AS (
     SELECT holiday_date,
       holiday_name
FROM mb_holidays), 
holidays_accounted_for AS 
( 
SELECT dates_table.*,
       CASE
         WHEN holiday_date IS NULL AND day_of_week::INTEGER NOT IN (6,0) THEN TRUE
         ELSE FALSE
       END AS is_working_day_de,
       iff(holiday_date IS NOT NULL, True, False) AS is_holiday_de
FROM dates_table
  LEFT JOIN holidays ON holiday_date = full_date ) 
  SELECT *,
       COUNT_IF(IS_WORKING_DAY_DE = TRUE) 
        OVER (PARTITION BY DATE_TRUNC_MONTH,DATE_TRUNC_YEAR) AS working_days_month,
       iff((COUNT_IF (IS_WORKING_DAY_DE = TRUE) 
       	OVER (PARTITION BY DATE_TRUNC_MONTH,DATE_TRUNC_YEAR 
       	ORDER BY full_date ASC rows BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) - 1) < 0,0,
       	COUNT_IF (IS_WORKING_DAY_DE = TRUE) 
       	OVER (PARTITION BY DATE_TRUNC_MONTH,DATE_TRUNC_YEAR ORDER BY full_date 
       	ASC rows BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) - 1) AS work_days_left
FROM holidays_accounted_for
ORDER BY full_date ASC
;

