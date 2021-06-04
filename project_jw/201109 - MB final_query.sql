
--create variable to store the total number of months = 15
--================================== NO NEED TO RUN THIS QUERY, ONLY USED TO GET THE NUMBER OF MONTHS (16).
 SET
num_mon = (
SELECT
	datediff(MONTH, MIN(DATE_TRUNC(MONTH, collector_tstamp)::DATE), MAX(DATE_TRUNC(MONTH, collector_tstamp)::DATE)) + 1
FROM
	events);


--##############################################MAIN QUERY######################################


-- use parameter now as $parameter or to comply with instructions and run it as single query use 16. 
 WITH max_date AS (
SELECT
	MAX(DATE_TRUNC(MONTH, collector_tstamp)::DATE) AS max_date
FROM
	events),
--======================generate date ranges, i.e. date table
 dates AS (
SELECT
	dateadd(MONTH, '-' || ROW_NUMBER() OVER (
ORDER BY
	NULL), dateadd (MONTH, '1', max_date)) AS MONTH
FROM
	TABLE (generator (rowcount => (16))), --HERE THE $num_mon CAN BE USED INSTEAD OF 16
	
 max_date),
--======================create date-user_id grid to see gaps, to determine correctly 'new' and 'zombie' 
--statuses since there are users with several months gaps, e.g. user_id = 'GkitoeVuymN9bQ21Wx6_Nm'
 dates_grid AS (
SELECT
	*
FROM
	(
	SELECT
		DISTINCT user_id
	FROM
		events ) AS distinct_users,
	dates),
--======================user activity history monthly, first and last months of user activity 
 user_ranges_1 AS (
SELECT
	(min(date_trunc(MONTH, collector_tstamp)) OVER (PARTITION BY user_id))::date AS start_date,
	(ADD_MONTHS(max(date_trunc(MONTH, collector_tstamp)) OVER (PARTITION BY user_id), 1))::date AS end_date,
	user_id
FROM
	events
GROUP BY
	date_trunc(MONTH, collector_tstamp),
	user_id) ,
user_ranges AS (
SELECT
	*
FROM
	user_ranges_1
GROUP BY
	1,
	2,
	3 ),
ranges_fix AS (
--======================apply ranges, join month-user grid to event history, i.e events table
SELECT
	MONTH,
	dates_grid.user_id
FROM
	user_ranges
LEFT JOIN dates_grid ON
	dates_grid.user_id = user_ranges.user_id
	AND dates_grid.month >= user_ranges.start_date
	AND dates_grid.month <= user_ranges.end_date),
--==================count number of days with events per user per month
 user_events AS (
SELECT
	date_trunc(MONTH, collector_tstamp)::date AS MONTH,
	count(DISTINCT date_trunc(DAY, collector_tstamp)::date ) AS event_count,
	user_id
FROM
	events
GROUP BY
	1,
	3),
--==================define this month status based on event_count
 prefinal AS (
SELECT
	ranges_fix.*,
	event_count,
	CASE
		WHEN event_count >= 1
		AND event_count <= 3 THEN 'infrequent'
		WHEN event_count >= 4
		AND event_count <= 7 THEN 'frequent'
		WHEN event_count >= 8 THEN 'power_user'
		WHEN event_count IS NULL
		AND LAG(event_count, 1) OVER (PARTITION BY ranges_fix.user_id
	ORDER BY
		ranges_fix.month ASC) IS NOT NULL THEN 'zombie'
		ELSE 'zombie'
	END AS this_month_status
FROM
	ranges_fix
LEFT JOIN user_events ON
	ranges_fix.user_id = user_events.user_id
	AND ranges_fix.month = user_events.month
ORDER BY
	ranges_fix.month ASC ),
--==================define last month status based on this month status previous row value
 final_query AS (
SELECT
	MONTH,
	user_id,
	this_month_status,
	CASE
		WHEN LAG(this_month_status, 1) OVER (PARTITION BY prefinal.user_id
	ORDER BY
		prefinal.month ASC) = 'zombie' THEN 'reacquired'
		WHEN LAG(this_month_status, 1) OVER (PARTITION BY prefinal.user_id
	ORDER BY
		prefinal.month ASC) IS NULL THEN 'new'
		ELSE LAG(this_month_status, 1) OVER (PARTITION BY prefinal.user_id
	ORDER BY
		prefinal.month ASC)
	END AS last_month_status
FROM
	prefinal )
--count user_ids per month, per status
 SELECT
	to_char(MONTH, 'YYYY-MM') AS MONTH,
	last_month_status,
	this_month_status,
	count(user_id) AS transitions
FROM
	final_query
WHERE
	this_month_status != last_month_status
	AND MONTH IS NOT NULL
GROUP BY
	1,
	2,
	3
ORDER BY
	MONTH DESC,
	this_month_status ASC