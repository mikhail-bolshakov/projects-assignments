


WITH cte_my_date AS (
	SELECT 
	dateadd(day, seq4(), '2019-01-01')::DATE AS full_date
	FROM TABLE (generator(ROWCOUNT => 2000))
)
,dates_table AS (
SELECT full_date
	,date_trunc('month', full_date) AS date_trunc_month
	,date_trunc('year', full_date) AS date_trunc_year
	,dayofyear(full_date) AS day_year_ordinal
	,dayname(full_date) AS day_name
	,week(full_date) AS week_of_year
	,dayofweekiso(full_date) AS day_of_week
	,dayofmonth(full_date) AS day_of_month 
	,quarter(full_date) AS quarter_of_year
	,count(full_date) OVER (PARTITION BY quarter(full_date) ,date_trunc('year', full_date)) AS days_in_quarter
	,monthname(full_date) AS month_name
	,datediff(day, date_trunc('month', full_date), last_day(full_date, month)) + 1 AS days_in_month
FROM cte_my_date
)
,holidays_accounted_for AS (
SELECT dates_table.*
	,CASE WHEN holiday_date IS NULL	AND day_of_week::INT NOT IN (6,7) THEN true	ELSE false	END AS is_working_day_de
	,iff(holiday_date IS NOT NULL, true, false) AS is_holiday_de
FROM dates_table
LEFT JOIN {{ source('other_raw', 'german_holidays') }}
	ON holiday_date = full_date
)
,prefinal AS (
SELECT *
	,count_if(is_working_day_de = true) OVER (PARTITION BY date_trunc_month,date_trunc_year) AS working_days_in_month_de
	,iff((
		count(full_date) OVER (
			PARTITION BY date_trunc_month
			,date_trunc_year ORDER BY full_date ASC rows BETWEEN CURRENT ROW AND unbounded following) - 1) < 0, 0, 
				count(full_date) OVER (PARTITION BY date_trunc_month, date_trunc_year 
					ORDER BY full_date ASC rows BETWEEN CURRENT row	AND unbounded following) - 1) AS days_left_in_month
	,iff((
		count_if(is_working_day_de = true) OVER (
			PARTITION BY date_trunc_month
			,date_trunc_year ORDER BY full_date ASC rows BETWEEN CURRENT ROW AND unbounded following) - 1) < 1, 0, 
				count_if(is_working_day_de = true) OVER (PARTITION BY date_trunc_month,date_trunc_year 
					ORDER BY full_date ASC rows BETWEEN CURRENT row	AND unbounded following) - 1) 
	AS working_days_left_in_month_de
	,iff((
		count(full_date) OVER (
			PARTITION BY quarter_of_year
			,date_trunc_year ORDER BY full_date ASC rows BETWEEN CURRENT ROW AND unbounded following) - 1) < 0, 0, 
				count(full_date) OVER (PARTITION BY quarter_of_year, date_trunc_year 
					ORDER BY full_date ASC rows BETWEEN CURRENT row	AND unbounded following) - 1) AS days_left_in_quarter
FROM holidays_accounted_for
)
SELECT full_date 
	,date_trunc_month
	,date_trunc_year
	,day_name
	,day_of_week
	,days_in_month
	,day_of_month 
	,day_year_ordinal
	,days_left_in_month
	,days_in_quarter
	,days_left_in_quarter
	,is_holiday_de
	,is_working_day_de
	,month_name
	,quarter_of_year
	,working_days_in_month_de
	,working_days_left_in_month_de
	,week_of_year
FROM prefinal
ORDER BY full_date ASC