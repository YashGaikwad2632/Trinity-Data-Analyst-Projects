Create database Project03;
Use Project03;

Create Table job_data(
job_id int,actors_id int,event varchar(100),language varchar(100),time_spent int,org varchar(100),ds date);

# Insert data into Table #
Insert into job_data(job_id,actors_id,event,language,time_spent,org,ds)
values
(21,1001,'skip','English',15,'A','2020-11-30'),
(22,1006,'transfer','Arabic',25,'B','2020-11-30'),
(23,1003,'decision','Persian',20,'C','2020-11-29'),
(23,1005,'transfer','Persian',22,'D','2020-11-28'),
(25,1002,'decision','Hindi',11,'B','2020-11-28'),
(11,1007,'decision','French',104,'D','2020-11-27'),
(23,1004,'skip','Persian',56,'A','2020-11-26'),
(20,1003,'transfer','Italian',45,'C','2020-11-25');

select * from job_data;

# TASK-A NUMBER OF JOBS REVIEWED #

SELECT 
    COUNT(job_id) / (30 * 24) AS number_of_jobs_reviewed_per_day_non_distinct
FROM
    job_data;
    
# TASK-B THROUGHPUT #

SELECT ds as date_of_review, jobs_reviewed, AVG(jobs_reviewed) 
OVER(ORDER BY ds ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS 
throughput_7_rolling_average
FROM 
( 
SELECT ds, COUNT( DISTINCT job_id) AS jobs_reviewed
FROM job_data
GROUP BY ds ORDER BY ds 
) a;

# Task-c PERCENTAGE SHARE OF EACH LANGUAGE #

SELECT 
    job_data.job_id,
    job_data.language,
    COUNT(job_data.language) AS total_of_each_language,
    ((COUNT(job_data.language) / (SELECT 
            COUNT(*)
        FROM
            job_data)) * 100) AS percentage_share_of_each_language
FROM
    job_data
GROUP BY job_data.language;

# TASK-D DUPLICATE ROWS #

SELECT * 
FROM 
(
SELECT *, ROW_NUMBER()OVER(PARTITION BY job_id) AS row_num
FROM job_data
) a 
WHERE row_num>1;