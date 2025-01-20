/*----------------------------------------------------------------------------------
    LAB 4 - PART 1: Schedule query execution
----------------------------------------------------------------------------------*/
-- set the worksheet context
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE query_wh;
USE DATABASE lab_db;
USE SCHEMA public;

-- create a table where we will store employee records
CREATE OR REPLACE TABLE employees (
	first_name STRING,
	last_name STRING,
	email STRING,
	address STRING,
	city STRING,
	start_date DATE
);

-- insert 3 new records
INSERT INTO employees 
VALUES
    ('Brendon','Durnall','bdurnalld@sf_tuts.com','26814 Weeping Birch Place','Sabadell','2017-11-14')
    ,('Avo','Laudham','alaudham2@sf_tuts.com','6948 Debs Park','Prażmów','2017-10-18')
    ,('Violette','Shermore','vshermorel@sf_tuts.com','899 Merchant Center','Troitsk','2017-01-19');

-- query the table and make sure the data is inserted correctly
SELECT * FROM employees;

-- let's say you need a curated version of the Employees table 
-- which contains two columns for full name and start date
CREATE OR REPLACE TABLE employee_names (
    full_name STRING,
    start_date DATE
);

-- you can schedule a Task object that executes your query
-- this task runs every night at 2AM, Toronto time
create or replace task employee_names_update
    warehouse = compute_wh
    schedule = 'USING CRON 0 2 * * * America/Toronto'
    as
        BEGIN
            TRUNCATE employee_names;
            INSERT INTO employee_names
                select first_name || ' ' || last_name as full_name, start_date
                from employees;
        END;
 
-- when tasks are created, they are in a 'suspended' state
-- run the command below to start the task
ALTER TASK employee_names_update RESUME;

-- we don't want to wait until 2AM in the morning to see the task run!
-- so let's make the task run immediately
EXECUTE TASK employee_names_update;

-- Check to see if the query in the task has run successfully.
SELECT * FROM employee_names;


-- -- (OPTIONAL) You can also wrap your query in a Stored Procedure and call it in the task
-- CREATE OR REPLACE PROCEDURE emp_proc()
--     RETURNS string
--     LANGUAGE SQL
--     AS
--         BEGIN
--             TRUNCATE employee_names;
--             INSERT INTO employee_names
--                 SELECT first_name || ' ' || last_name as full_name, start_date
--                 FROM employees;
--         END;

-- CREATE OR REPLACE TASK employee_names_update
--     WAREHOUSE = compute_wh
--     SCHEDULE = 'USING CRON 0 2 * * * America/Toronto'
--     AS
--         CALL emp_proc();



/*----------------------------------------------------------------------------------
    LAB 4 - PART 2: Build continuous data pipelines
----------------------------------------------------------------------------------*/
        
-- instead of using schedules, let's create a target table that refresh automatically 
-- when the base table gets updated using Dynamic Tables

-- set the worksheet context
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE query_wh;
USE DATABASE lab_db;
USE SCHEMA public;

-- create a dynamic table
CREATE OR REPLACE DYNAMIC TABLE employee_names_dt
    TARGET_LAG = '1 minute'
    WAREHOUSE = compute_wh
    REFRESH_MODE = incremental
    AS
        SELECT first_name || ' ' || last_name AS full_name, start_date
        FROM employees; 

        
SELECT * FROM employee_names_dt;

-- insert a new employee record
INSERT INTO employees 
VALUES ('Wallis','Sizey','wsizeyf@sf_tuts.com','36761 American Lane','Taibao','2016-12-30')
    ,('Carson','Bedder','cbedderh@sf_tuts.co.au','71 Clyde Gallagher Place','Leninskoye','2017-03-29')
    ,('Dana','Avory','davoryi@sf_tuts.com','2 Holy Cross Pass','Wenlin','2017-05-11');

-- check the dynamic table (if table is not updated, wait a few seconds and try again)
SELECT * FROM employee_names_dt;

