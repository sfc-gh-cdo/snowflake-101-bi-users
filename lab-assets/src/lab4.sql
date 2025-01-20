/*----------------------------------------------------------
    LAB 4 - PART 1: Schedule query execution
----------------------------------------------------------*/
// Set the worksheet context
use role accountadmin;
use warehouse query_wh;
use database lab2_db;
use schema public;

// Create a table where we will store employee records
create or replace table employees (
	FIRST_NAME STRING,
	LAST_NAME STRING,
	EMAIL STRING,
	ADDRESS STRING,
	CITY STRING,
	START_DATE DATE
);

// Insert 3 new records
insert into employees 
values
    ('Brendon','Durnall','bdurnalld@sf_tuts.com','26814 Weeping Birch Place','Sabadell','2017-11-14')
    ,('Avo','Laudham','alaudham2@sf_tuts.com','6948 Debs Park','Prażmów','2017-10-18')
    ,('Violette','Shermore','vshermorel@sf_tuts.com','899 Merchant Center','Troitsk','2017-01-19');

// Query the table and make sure the data is inserted correctly
select * from employees;

// Let's say you need a curated version of the Employees table which contains two columns for full name and start date
create or replace table employee_names (
    FULL_NAME STRING,
    START_DATE DATE
);

// You can schedule a Task object that executes your query
// This task runs every night at 2AM, Toronto time
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
 
// When tasks are created, they are in a 'suspended' state
// Run the command below to start the task
alter task employee_names_update resume;

// We don't want to wait until 2AM in the morning to see the task run!
// So let's make the task run immediately
execute task employee_names_update;

// Check to see if the query in the task has run successfully.
select * from employee_names;


-- // (OPTIONAL) You can also wrap your query in a Stored Procedure and call it in the task
-- create or replace procedure emp_proc()
--     returns string
--     language SQL
--     as
--         BEGIN
--             TRUNCATE employee_names;
--             INSERT INTO employee_names
--                 select first_name || ' ' || last_name as full_name, start_date
--                 from employees;
--         END;

-- create or replace task employee_names_update
--     warehouse = compute_wh
--     schedule = 'USING CRON 0 2 * * * America/Toronto'
--     as
--         CALL emp_proc();


/*----------------------------------------------------------
    LAB 4 - PART 2: Build continuous data pipelines
----------------------------------------------------------*/
        
// Instead of using schedules, we can also have the target table refresh
// Let's see how this works.

create or replace dynamic table employee_names_dt
    target_lag = '1 minute'
    warehouse = compute_wh
    refresh_mode = incremental
    as
        select first_name || ' ' || last_name as full_name, start_date
        from employees; 


select * from employee_names_dt;

// Insert a new employee record
insert into employees 
values ('Wallis','Sizey','wsizeyf@sf_tuts.com','36761 American Lane','Taibao','2016-12-30')
    ,('Carson','Bedder','cbedderh@sf_tuts.co.au','71 Clyde Gallagher Place','Leninskoye','2017-03-29')
    ,('Dana','Avory','davoryi@sf_tuts.com','2 Holy Cross Pass','Wenlin','2017-05-11');

// Check the dynamic table
select * from employee_names_dt;


