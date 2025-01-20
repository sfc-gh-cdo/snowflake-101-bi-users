/*----------------------------------------------------------
    LAB 3 - PART 1: Run your first analytical query
----------------------------------------------------------*/
-- set the Worksheet context
USE ROLE accountadmin;
USE WAREHOUSE query_wh;
USE DATABASE snowflake_sample_data;
USE SCHEMA tpch_sf100;

// Pricing Summary Report Query (Q1) 
// this query reports the amount of business that was billed, shipped, and returned.
SELECT l_returnflag,
       l_linestatus,
       sum(l_quantity) as sum_qty,
       sum(l_extendedprice) as sum_base_price,
       sum(l_extendedprice * (1-l_discount)) as sum_disc_price,
       sum(l_extendedprice * (1-l_discount) * (1+l_tax)) as sum_charge,
       avg(l_quantity) as avg_qty,
       avg(l_extendedprice) as avg_price,
       avg(l_discount) as avg_disc,
       count(*) as count_order
 FROM lineitem
 WHERE l_shipdate <= dateadd(day, -90, to_date('1998-12-01'))
 GROUP BY l_returnflag,l_linestatus
 ORDER BY l_returnflag, l_linestatus;

 
/*----------------------------------------------------------
    LAB 3 - PART 2: Leverage persisted (cached) query results
----------------------------------------------------------*/
-- Run the Pricing Summary Report Query (Q1) for the second time and see how long it takes

-- The query runs much faster the second time because you’re using Persisted Query Results (or cached query results).
-- Ref: https://docs.snowflake.com/en/user-guide/querying-persisted-results

-- Click on the Query ID under Query Details to open the Query Profile

 
/*----------------------------------------------------------
    LAB 3 - PART 3: Optimize query performance
----------------------------------------------------------*/
-- change to schema with larger data set
USE SCHEMA tpch_sf1000;

-- turn off persisted (cached) query results
ALTER USER SET USE_CACHED_RESULT = false;

-- suspend the warehouse
ALTER WAREHOUSE query_wh SUSPEND;

-- set QUERY_WH to XSMALL
ALTER WAREHOUSE query_wh SET warehouse_size = XSMALL;

-- run the Pricing Summary Report Query (Q1) and take note of the query duration (this should take about 1m 30s)

-- suspend the warehouse
ALTER WAREHOUSE query_wh SUSPEND;

-- scale-Up warehouse from XSMALL to MEDIUM
ALTER WAREHOUSE query_wh SET warehouse_size = MEDIUM;

-- Run the Pricing Summary Report Query (Q1) and take note of the query duration (this should take about 30s)

-- scale-Down back to XSMALL
ALTER WAREHOUSE query_wh SET warehouse_size = XSMALL;


/*----------------------------------------------------------
    LAB 3 - PART 4: Visualize query results using charts

    Follow these instructions in Snowsight:
    1. Navigate to Projects > Worksheets
    2. Open your “LAB 3” worksheet
    3. Run the Pricing Summary Report Query (Q1)
    4. Click on Chart
    5. Set Chart type to Bar 
    6. Under Appearance, set Orientation to Horizontal
    7. Under Data, set the X-Axis and Y-Axis to the values in the image
----------------------------------------------------------*/



