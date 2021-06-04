--############################################ ALTER CAMPAIGN CLICK TABLE
 ALTER TABLE contorion.campaign_click_table ALTER COLUMN order_id TYPE integer
	USING order_id::NUMERIC::integer,
ALTER COLUMN customer_id TYPE integer
	USING customer_id::NUMERIC::integer ;

--############################################ ALTER ORDER TABLE
 ALTER TABLE contorion.order_table ALTER COLUMN order_id TYPE integer
	USING order_id::NUMERIC::integer ;

--############################################ CREATE TABLE DIM ORDER TO GET REVENUE
 DROP TABLE IF EXISTS contorion.dim_order;

CREATE TABLE contorion.dim_order AS
SELECT
	order_id AS id,
	customer_id,
	order_timestamp,
	net_revenue
FROM
	contorion.campaign_click_table
	WHERE order_id IS NOT null
GROUP BY
	1,
	2,
	3,
	4;

SELECT count(id) FROM contorion.dim_order ot ;

SELECT * FROM contorion.dim_customer WHERE id = 101572
;

--==========Revenue Total, Avg basket size
 SELECT
	sum(net_revenue)::decimal(10,2) AS revenue_total,
	sum(net_revenue)::decimal(10,2) / count(id) AS avg_basket_size,
	count(id) AS orders_total,
	count(DISTINCT customer_id)::decimal(10,2) AS customer_count,
	count(id)::decimal(10,2) / count(DISTINCT customer_id)::decimal(10,2)
	
FROM
	contorion.dim_order
	--38633.62
;
--==========Avg revenue by customer
 SELECT
	sum(net_revenue)::NUMERIC / count(customer_id) AS avg_rev_customer
FROM
	contorion.dim_order
	--94.92
;
--############################################ CREATE TABLE DIM CUSTOMER  
 DROP TABLE IF EXISTS contorion.dim_customer;

CREATE TABLE contorion.dim_customer AS
SELECT
	DISTINCT customer_id AS id,
	customer_group
FROM
	contorion.campaign_click_table
;
--==========Avg revenue by customer group
SELECT
	sum(net_revenue) ::NUMERIC / count(dim_customer.id) AS avg_rev_customer,
	sum(net_revenue) ::NUMERIC AS revenue_total,
	count(dim_customer.id) AS customers_count,
	count(dim_order.id) AS orders_count,
	customer_group
	
FROM
	contorion.dim_order
LEFT JOIN contorion.dim_customer ON
	customer_id = dim_customer.id
WHERE
	customer_group IS NOT NULL
GROUP BY
	5
;

--############################################ CREATE TABLE DIM VISITOR 
 DROP TABLE IF EXISTS contorion.dim_visitor;

CREATE TABLE contorion.dim_visitor AS
SELECT
	visitor_id AS id,
	customer_id,
	count(click_id) AS clicks,
	sum(marketing_cost) AS marketing_cost
	--ROW_NUMBER() OVER (PARTITION BY visitor_id ORDER BY click_timestamp desc) AS last_click_row
FROM
	contorion.campaign_click_table
	GROUP BY 1,2
	; 

--==========Avg click costs
WITH 
customer_revenue AS 
(SELECT
	customer_id,
	count(id) AS order_count,
	sum(net_revenue) AS revenue
FROM
	contorion.dim_order
GROUP BY
	1)
	select
	sum(order_count)::decimal(10,2) AS orders_total,
	sum(order_count)::decimal(10, 2) / NULLIF(sum(clicks)::decimal(10, 2), 0) AS click_conversion,
	sum(order_count)::decimal(10, 2) / count(dim_customer.id)::decimal(10, 2) AS order_customer_percentage,
	count(dim_customer.id)::decimal(10, 2)  / count(dim_visitor.id)::decimal(10, 2) as customer_conversion,
	count(dim_customer.id)::decimal(10, 2)  / sum(order_count)::decimal(10, 2) as nth_customer_order,
	sum(clicks)::decimal(10, 2) / sum(order_count)::decimal(10, 2)  AS every_nth_click,
	sum(revenue) ::decimal(10,2) / sum(clicks)::decimal(10,2) AS revenue_per_click,
--==	
count(dim_customer.id)::decimal(10, 2) AS customer_count_total,
	count(customer_revenue.customer_id)::decimal(10, 2) AS customer_w_orders_count,
	count(dim_visitor.id)::decimal(10, 2) AS visitor_count,
	count(dim_customer.id)::decimal(10, 2) / count(dim_visitor.id) FILTER (WHERE clicks > 1)::decimal(10,2)  
	AS customer_conversion_from_more_one_click_visitor,
	count(dim_visitor.id) FILTER (WHERE clicks > 1)::decimal(10,2) / count(dim_customer.id)::decimal(10, 2),  
	count(customer_revenue.customer_id)::decimal(10, 2) / count(dim_visitor.id) FILTER (WHERE clicks > 1)::decimal(10,2)  
	AS customer_w_orders_conversion_from_more_one_click_visitor,
	count(customer_revenue.customer_id) FILTER (WHERE order_count > 1)::decimal(10,2) AS customers_more_one_order,
	count(dim_visitor.id) FILTER (WHERE clicks > 1)::decimal(10,2) AS visitors_more_one_click,
	count(dim_visitor.id) FILTER (WHERE clicks = 1)::decimal(10,2) AS visitors_w_one_click,
	count(customer_revenue.customer_id)::decimal(10, 2) / count(dim_customer.id)::decimal(10, 2) AS customers_w_orders_conversion, 
	
	count(dim_visitor.id)::decimal(10, 2) / count(dim_customer.id)::decimal(10, 2) AS every_nth_visitor_conversion,
	count(dim_visitor.id)::decimal(10, 2) / count(customer_revenue.customer_id)::decimal(10, 2) AS every_nth_visitor_to_order_conversion,
	sum(clicks)::decimal(10, 2) AS click_total,
	sum(revenue) ::decimal(10,2) AS revenue_total,
	sum(marketing_cost)::decimal(10,2) AS costs_total,
	sum(revenue) ::decimal(10,2) / sum(marketing_cost)::decimal(10,2) AS roi,
	sum(revenue) ::decimal(10,2)- sum(marketing_cost)::decimal(10,2) AS profit,
	(sum(revenue) ::decimal(10,2)- sum(marketing_cost)::decimal(10,2)) / sum(revenue) ::decimal(10,2) AS profit_margin,
	sum(marketing_cost)::decimal(10,2) / sum(clicks)::decimal(10,2) AS click_cost,
	sum(marketing_cost)::decimal(10,2) / count(dim_customer.id)::decimal(10, 2) AS cac_total,
	sum(marketing_cost)::decimal(10,2) / count(customer_revenue.customer_id)::decimal(10, 2) AS cac_customers_w_orders,
	count(dim_visitor.id) FILTER (WHERE clicks = 1)::decimal(10,2) / count(dim_visitor.id)::decimal(10,2)  AS bounce_rate
FROM
	contorion.dim_visitor
LEFT JOIN customer_revenue ON
	customer_revenue.customer_id = dim_visitor.customer_id
Left JOIN contorion.dim_customer 
ON dim_visitor.customer_id  = dim_customer.id
	

;
--############################################ CHANNEL COSTS 
SELECT channel,
COUNT(click_id) AS clicks,
COALESCE(COALESCE(SUM(marketing_cost),0)::decimal(10,2),0)::decimal(10,2) AS marketing_cost,
COALESCE(COALESCE(SUM(marketing_cost),0)::numeric / NULLIF(COUNT(click_id)::numeric,0),0)::decimal(10,2) AS cost_per_click
FROM contorion.campaign_click_table
GROUP BY 1
ORDER BY marketing_cost desc;


;
--############################################ CHANNEL REVENUE 	
WITH 
	final_query AS 
	(
	SELECT
	channel,
	click_id,
	click_timestamp,
	net_revenue,
	visitor_id,
	(net_revenue / count(click_id) OVER (PARTITION BY visitor_id))::decimal(10, 4) AS revenue_linear_attr, 
	(1::NUMERIC / count(click_id) OVER (PARTITION BY visitor_id)::NUMERIC)::decimal(10, 4) AS acquisitions,
	CASE
		WHEN click_id = FIRST_VALUE (click_id) OVER (PARTITION BY visitor_id
	ORDER BY
		click_timestamp ASC) THEN COALESCE(net_revenue, 0)::decimal(8, 2) / 2::decimal(8, 2)
		ELSE 0::decimal(8, 2)
	END +
	CASE
		WHEN click_id = LAST_VALUE (click_id) OVER (PARTITION BY visitor_id
	ORDER BY
		click_timestamp ASC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) 
		THEN COALESCE(net_revenue, 0)::decimal(8, 2) / 2::decimal(8, 2)
		ELSE 0::decimal(8, 2)
	END AS revenue_ushape_attr
FROM
	contorion.campaign_click_table
WHERE 
	net_revenue IS NOT NULL)
	SELECT channel, sum(revenue_linear_attr) AS revenue_linear_attr, sum(acquisitions) AS acquisitions, 
	sum(revenue_ushape_attr) AS revenue_ushape_attr
	
	FROM final_query 
	GROUP BY 1

;
/*
technically all window definitions are supposed to have a RANGE.
The custom is that if no RANGE is specified, 
then it is assumed to be `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW'.
With that default RANGE, last_value() is always CURRENT ROW, 
hence UNBOUNDED FOLLOWING must be specified to get what you want.
*/
SELECT channel, 
click_id, 
click_timestamp, 
net_revenue, 
visitor_id,
FIRST_VALUE (click_id) OVER (PARTITION BY visitor_id
ORDER BY click_timestamp asc) AS first_click,
LAST_VALUE (click_id) OVER (PARTITION BY visitor_id
ORDER BY click_timestamp ASC RANGE BETWEEN 
            UNBOUNDED PRECEDING AND 
            UNBOUNDED FOLLOWING ) AS last_click
FROM contorion.campaign_click_table WHERE visitor_id = 2149904386900590080
;