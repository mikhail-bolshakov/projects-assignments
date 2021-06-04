/*
The first time the recursive CTE runs it generates a single row 1 using the anchor member. 
In the second execution, the recursive member joins against the 1 and outputs a second row, 2. 
In the third execution the recursive step joins against both rows 1 and 2 and adds the rows 2 (a duplicate) and 3.
Notice how the CTE specifies its output as the named value prev_val. This lets us refer to the output of the previous recursive step.
And at the very end there is a termination condition to halt the recursion once the sum gets to 10. Without this condition, the CTE would enter an infinite loop!
simple recursive CTE that generates the numbers 1 to 10. The anchor member selects the value 1, and the recursive member adds to it up to the number 10:
*/
WITH RECURSIVE incrementer (prev_val) AS
(
  SELECT 1 -- anchor member
         UNION ALL SELECT -- recursive member
         incrementer.prev_val + 1
  FROM incrementer
  WHERE prev_val < 10
  -- termination condition
)
SELECT *
FROM incrementer;

--================= takes the sum, double, and square of starting values of 1, 2 and 3:
WITH RECURSIVE cruncher (inc, DOUBLE, square) AS
(
  SELECT 1,
         2.0,
         3.0 -- anchor member
         UNION ALL SELECT -- recursive member
         cruncher.inc + 1,
         cruncher.double*2,
         cruncher.square ^ 2
  FROM cruncher
  WHERE inc < 10
)
SELECT *
FROM cruncher
;
--##################################
  
WITH RECURSIVE subordinates AS
(
  SELECT employee_id,
         manager_id,
         full_name
  FROM employees
  WHERE employee_id = 2
  UNION
  SELECT e.employee_id,
         e.manager_id,
         e.full_name
  FROM employees e
    INNER JOIN subordinates s ON s.employee_id = e.manager_id
)
SELECT *
FROM subordinates;



--#########################################
/*When the optional RECURSIVE keyword is enabled, the WITH clause can accomplish 
things not otherwise possible in standard SQL. Using RECURSIVE, a query in the 
WITH clause can refer to its own output. 
This is a simple example that computes the sum of integers from 1 through 100:
*/
WITH RECURSIVE t(n) AS (
    VALUES (1)
  UNION ALL
    SELECT n+1 FROM t WHERE n < 100
)
SELECT sum(n) FROM t;


--###################################
WITH RECURSIVE ctename(empno, ename) AS (
      SELECT empno, ename, 0 AS level
      FROM emp
      WHERE empno = 7566
   UNION all
      SELECT emp.empno, emp.ename, ctename.level + 1
      FROM emp
         JOIN ctename ON emp.mgr = ctename.empno
)
SELECT * FROM ctename;

--===================Another frequent requirement is to collect all ancestors in a "path":

WITH RECURSIVE ctename AS (
      SELECT empno, ename,
             ename AS path
      FROM emp
      WHERE empno = 7566
   UNION ALL
      SELECT emp.empno, emp.ename,
             ctename.path || ' -> ' || emp.ename
      FROM emp
         JOIN ctename ON emp.mgr = ctename.empno
)
SELECT * FROM ctename;

--######################### recursive CTE that computes the first elements of the Fibonacci sequence:
WITH RECURSIVE fib AS (
      SELECT 1 AS n,
             1::bigint AS "fib?",
             1::bigint AS "fib???"
   UNION ALL
      SELECT n+1,
             "fib???",
             "fib?" + "fib???"
      FROM fib
)
SELECT n, "fib?" FROM fib
LIMIT 20;

/*Travelling Salesman problem*/

create table places as (
  select
    'Seattle' as name, 47.6097 as lat, 122.3331 as lon
    union all select 'San Francisco', 37.7833, 122.4167
    union all select 'Austin', 30.2500, 97.7500
    union all select 'New York', 40.7127, 74.0059
    union all select 'Boston', 42.3601, 71.0589
    union all select 'Chicago', 41.8369, 87.6847
    union all select 'Los Angeles', 34.0500, 118.2500
    union all select 'Denver', 39.7392, 104.9903
)
;
--=============
create extension cube;
create extension earthdistance;

--=============To use KM instead of miles, use constants 111.12 & 92.215 to replace 69.1 & 57.3 
CREATE OR REPLACE FUNCTION 
lat_lon_distance (lat1 FLOAT,lon1 FLOAT,lat2 FLOAT,lon2 FLOAT) 
RETURNS FLOAT
AS
$$ DECLARE x FLOAT = 69.1*(lat2 - lat1);
y FLOAT = 69.1*(lon2 - lon1)*COS(lat1 / 57.3);
BEGIN RETURN SQRT(x*x + y*y);
END $$ LANGUAGE plpgsql

;

--Our CTE will use San Francisco as its anchor city, and then recurse from there to every other city:

WITH RECURSIVE travel (places_chain, last_lat, last_lon, total_distance, num_places) AS
(
  SELECT -- anchor member
         name,
         lat,
         lon,
         0::FLOAT,
         1
  FROM places
  WHERE name = 'San Francisco'
  UNION ALL
  SELECT -- recursive member
         -- add to the current places_chain
         travel.places_chain || ' -> ' || places.name,
         places.lat,
         places.lon,
         -- add to the current total_distance
         travel.total_distance + lat_lon_distance(last_lat,last_lon,places.lat,places.lon),
         travel.num_places + 1
  FROM places,
       travel
  WHERE POSITION(places.name IN travel.places_chain) = 0
)
/*
The parameters in the CTE are:

places_chain: The list of places visited so far, which will be different for each instance of the recursion
last_lat and last_lon: The latitude and longitude of the last place in the places_chain
total_distance: The distance traveled going from one place to the next in the places_chain
num_places: The number of places in places_chain - we'll use this to tell which routes are complete because they visited all cities
In the recursive member, the where clause ensures that we never repeat a place. 
If we've already visited Denver, position(?) will return a number greater than 0, invalidating this instance of the recursion.
We can see all possible routes by selecting all 8-city chains:

SELECT *
FROM travel
WHERE num_places = 8
*/
SELECT travel.places_chain || ' -> ' || places.name,
       total_distance + lat_lon_distance(travel.last_lat,travel.last_lon,places.lat,places.lon) AS final_dist
FROM travel,
     places
WHERE travel.num_places = 8
AND   places.name = 'San Francisco'
ORDER BY 2 -- ascending!
         LIMIT 1





