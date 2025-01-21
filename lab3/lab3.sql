/**********************************************************************************
    LAB 3 - PART 1: Run your first analytical query
**********************************************************************************/

/*---------------------------------------------------------------------------------
    Create a new warehouse to run your queries on
---------------------------------------------------------------------------------*/
/*
    1. Navigate to Admin > Warehouses.
    2. Click on + Warehouse                    
    3. Fill in the details of the warehouse using the below values and click Create Warehouse.
            Warehouse Name: QUERY_WH
            Comment: Warehouse for lab exercises.
            Type: Standard
            Size: X-Small

    Tip: You can also create warehouses using SQL in the worksheet.

            CREATE OR REPLACE WAREHOUSE QUERY_WH
               WAREHOUSE_TYPE = 'STANDARD'
               WAREHOUSE_SIZE = 'X-SMALL'
               INITIALLY_SUSPENDED = TRUE
               COMMENT = 'Warehouse for lab exercises.';
*/

/*---------------------------------------------------------------------------------
    Set the worksheet context and run your first analytical query.
---------------------------------------------------------------------------------*/
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

 
/**********************************************************************************
    LAB 3 - PART 2: Leverage persisted (cached) query results
**********************************************************************************/

/*---------------------------------------------------------------------------------
    Run the same query again and compare the query duration and the Query Profile.
---------------------------------------------------------------------------------*/
/*
    1. If you haven’t already, take note of the ‘Query duration’ in the ‘Query Details’ for the previous query you ran.
    2. Run the Pricing Summary Report Query (Q1) for the second time and see how long it takes.
    3. In the Query Details section, click on the Query ID (this will open the Query Profile in a new browser tab).

    Why the query ran FASTER the second time
        It’s because you’re using Persisted Query Results!
        When a query is executed, the result is persisted (i.e. cached) for a period of time. 
        At the end of the time period, the result is purged from the system.
        Snowflake uses persisted query results to avoid re-generating results when nothing has changed 
        (i.e. “retrieval optimization”)

    Note: 
        For persisted query results of all sizes, the cache expires after 24 hours.
        Each time the persisted result for a query is reused, Snowflake resets the 
        24-hour retention period for the result, up to a maximum of 31 days from 
        the date and time that the query was first executed. After 31 days, the 
        result is purged and the next time the query is submitted, a new result 
        is generated and persisted.

    Ref: https://docs.snowflake.com/en/user-guide/querying-persisted-results.

*/

 
/**********************************************************************************
    LAB 3 - PART 3: Optimize query performance
**********************************************************************************/

/*---------------------------------------------------------------------------------
    Run the same query on different warehouse sizes to see how this impacts
    performance.
---------------------------------------------------------------------------------*/
-- for this exercise we'll use a schema with larger data set
USE SCHEMA tpch_sf1000;

-- turn off Persisted Query Results so that cache is not used when we rerun the query
ALTER USER SET USE_CACHED_RESULT = false;

-- suspend the warehouse
ALTER WAREHOUSE query_wh SUSPEND;

-- set QUERY_WH to XSMALL
ALTER WAREHOUSE query_wh SET warehouse_size = XSMALL;

-- Run the Pricing Summary Report Query (Q1) and take note of the query duration (this may take about 1m 30s)

-- suspend the warehouse
ALTER WAREHOUSE query_wh SUSPEND;

-- scale-up warehouse from XSMALL to MEDIUM
ALTER WAREHOUSE query_wh SET warehouse_size = MEDIUM;

-- Run the Pricing Summary Report Query (Q1) and take note of the query duration (this may take about 30s)

-- scale-down back to XSMALL for the next lab
ALTER WAREHOUSE query_wh SET warehouse_size = XSMALL;


/**********************************************************************************
    LAB 3 - PART 4: Visualize query results using charts
**********************************************************************************/
/*---------------------------------------------------------------------------------
    Turn your SQL results into charts
---------------------------------------------------------------------------------*/
/*
    Follow these instructions in Snowsight:
    1. Navigate to Projects > Worksheets
    2. Open your “LAB 3” worksheet
    3. Run the Pricing Summary Report Query (Q1)
    4. Click on Chart
    5. Set Chart type to Bar 
    6. Under Appearance, set Orientation to Horizontal
    7. Under Data, set the X-Axis and Y-Axis to the values in the image
*/

-- END OF LAB 3
