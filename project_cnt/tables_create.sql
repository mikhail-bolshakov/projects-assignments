DROP TABLE IF EXISTS test.campaign_click_table CASCADE;

CREATE TABLE test.campaign_click_table
(
   visitor_id       bigint,
   click_id         bigint,
   click_timestamp  timestamp without time zone,
   channel          text,
   partner          varchar(64),
   customer_id      varchar(64),
   customer_group   varchar(64),
   order_id         varchar(64),
   order_timestamp  timestamp without time zone,
   net_revenue      float8,
   marketing_cost   float8
);


--####################################
DROP TABLE IF EXISTS test.order_table CASCADE;

CREATE TABLE test.order_table
(
   order_id  varchar(64),
   product   bigint,
   items     integer
)