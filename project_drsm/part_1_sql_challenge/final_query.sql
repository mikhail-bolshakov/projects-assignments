/*Created: 2020-11-13
 *Author: Bolshakov Mikhail
 *Notes:
 */

--get bhshop_id entry, date ranges and working hours
WITH working_hours AS (
SELECT
	bhshop_id,
	from_date,
	to_date,
	sum(monday_to - monday_from) AS monday_hours,
	sum(tuesday_to - tuesday_from) AS tuesday_hours,
	sum(wednesday_to - wednesday_from) AS wednesday_hours,
	sum(thursday_to - thursday_from) AS thursday_hours,
	sum(friday_to - friday_from) AS friday_hours,
	sum(saturday_to - saturday_from) AS saturday_hours,
	sum(sunday_to - sunday_from) AS sunday_hours
FROM
	drsmile.bhshop_entry be
GROUP BY 1,2,3),

--create date grid by cross joining the dates table and distinct bhshop_id, 
--extract day of the week from full_date
date_grid AS (
SELECT
	MONTH,
	bhshop_id,
	full_date,
	REPLACE(to_char(full_date, 'Day'), ' ', '') AS weekday
FROM
	help_tables.dates_table,
	(
	SELECT DISTINCT bhshop_id FROM
		drsmile.bhshop_entry) AS distinct_users ),

--unpivot the working hours query to get date ranges, 
--days of the week and business hours in those ranges/dates		
unpivot_wh AS (
SELECT
	bhshop_id,
	from_date,
	to_date,
	UNNEST(ARRAY['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']) AS weekday,
	UNNEST(ARRAY[monday_hours, tuesday_hours, wednesday_hours, thursday_hours, friday_hours, saturday_hours, sunday_hours]) AS hours
FROM
	working_hours
GROUP BY 1,2,3,4,5) ,

--get the dates, business hours on that dates, join to the shops table to get the shop_id, 
--join to the public_holiday_calendar_entry to exclude holidays from working days calendar,
--create a partition to group by assigning a row number based on the max_days_booking_advance
prefinal_query AS (
SELECT
	date_grid.weekday,
	full_date,
	shops.shop_id,
	date_grid.bhshop_id,
	CASE
		WHEN phse.date IS NOT NULL THEN NULL
		ELSE unpivot_wh.hours
	END AS hours,
	CEIL(ROW_NUMBER() OVER(PARTITION BY date_grid.bhshop_id ORDER BY full_date ASC)::NUMERIC 
	/ 
	(max_days_booking_advance::NUMERIC + 1)) AS booking_advance_partition
FROM
	unpivot_wh
LEFT JOIN date_grid ON
	unpivot_wh.bhshop_id = date_grid.bhshop_id
	AND full_date >= from_date
	AND full_date <= to_date
	AND unpivot_wh.weekday = date_grid.weekday
INNER JOIN drsmile.shops ON
	date_grid.bhshop_id = shops.bhshop_id
LEFT JOIN drsmile.public_holiday_calendar_entry phse ON
	phse.public_holiday_calendar_id = shops.public_holiday_calendar_id
	AND full_date = phse.date ) ,
	
-- calculate sum of available for appointment hours starting from 2020-11-12 onwards partitioning by shop_id and booking_advance_partition	
final_query AS(
SELECT
	full_date,
	shop_id,
	sum(hours) OVER (PARTITION BY shop_id, booking_advance_partition) AS available_hours
FROM
	prefinal_query 
WHERE
	full_date >= '2020-11-12' )
	
-- filter out top 3 shops with the highest number of hours worth of bookings 
SELECT * FROM final_query 
WHERE
	full_date = '2020-11-12' AND available_hours IS NOT null
GROUP BY 1,2,3 
ORDER BY 3 DESC
LIMIT 3