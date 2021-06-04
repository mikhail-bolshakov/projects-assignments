DROP TABLE IF EXISTS 
drsmile.bhshop_entry 
CASCADE;

CREATE TABLE 
drsmile.bhshop_entry 
( 
bhshop_id varchar(64), 
monday_from TIME , 
monday_to TIME , 
tuesday_from TIME , 
tuesday_to TIME , 
wednesday_from TIME , 
wednesday_to TIME , 
thursday_from TIME , 
thursday_to TIME , 
friday_from TIME , 
friday_to TIME , 
saturday_from TIME, 
saturday_to TIME , 
sunday_from TIME , 
sunday_to TIME , 
from_date date , 
to_date date );

 
DROP TABLE IF EXISTS 
drsmile.public_holiday_calendar_entry 
CASCADE;

CREATE TABLE 
drsmile.public_holiday_calendar_entry 
( 
public_holiday_calendar_id varchar(64), 
date date, 
holiday_name TEXT) ;

DROP TABLE IF EXISTS 
drsmile.shops 
CASCADE;

CREATE TABLE 
drsmile.shops 
(
shop_id varchar(64), 
public_holiday_calendar_id varchar(64), 
bhshop_id varchar(64), 
max_days_booking_advance int )