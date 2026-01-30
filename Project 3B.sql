Create database Project3;
use project3;

# Table-1 users #

Create table users (
user_id int,
created_at varchar(100),
company_id int,
language varchar(50),
activated_at varchar(100),
state varchar(50));

show variables like 'secure_file_priv';

load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Table-1 users.csv"
into table users
fields terminated by','
enclosed by'"'
lines terminated by'\n'
ignore 1 rows;

select * from users;

# Table-2 events #
create table The_events(
user_id int,
occurred_at varchar(100),
event_type varchar(50),
event_name varchar(100),
location varchar(50),
device varchar(50),
user_type int
);

load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Table-2 events.csv"
into table The_events
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

desc events;

select * from events;

# Table-3 email_events #

create table email_events(
user_id int,
occurred_at varchar(100),
action varchar(100),
user_type int
);

load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Table-3 email_events.csv"
into table email_events
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

select * from email_events;



# TASK-2 A USER ENGAGEMENT #

SELECT 
    *,
    EXTRACT(WEEK FROM occurred_at) AS week_number,
    COUNT(DISTINCT user_id) AS number_of_users
FROM
    project3.The_events
GROUP BY week_number;

# Task-2 B  USER GROWTH #

select 
year_num,
week_num,
num_active_users,
SUM(num_active_users)OVER(ORDER BY year_num, week_num ROWS BETWEEN 
UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_active_users
from
(
select 
extract (year from activated_at) as year_num,
extract (week from activated_at) as week_num,
count(distinct user_id) as num_active_users
from 
users
WHERE
state = 'active'
group by year_num,week_num
order by year_num,week_num
) ;


# TASK-2 C WEEKLY RETENTION #

SELECT
distinct user_id,
COUNT(user_id),
SUM(CASE WHEN retention_week = 1 Then 1 Else 0 END) as week_1
FROM 
(
SELECT
user_id,signup_week,engagement_week,engagement_week-signup_week as week_1
FROM 
(
(SELECT distinct user_id, extract(week from occurred_at) as signup_week from The_events
WHERE event_type = 'signup_flow'
and event_name = 'complete_signup'
and extract(week from occurred_at) = 18
) 
LEFT JOIN
(SELECT distinct user_id, extract (week from occurred_at) as engagement_week FROM The_events
where event_type = 'engagement'
)
on user_id = user_id
)order by user_id);

# TASK-2 D WEEKLY ENGAGEMENT #

SELECT 
extract(year from occurred_at) as year_num,
extract(week from occurred_at) as week_num,
device,
COUNT(distinct user_id) as no_of_users
FROM 
The_events
where event_type = 'engagement'
GROUP by 1,2,3
order by 1,2,3;

# TASK-2 E EMAIL ENGAGEMENT #

SELECT
100.0*SUM(CASE when email_cat = 'email_opened' then 1 else 0 end)/SUM(CASE when 
email_cat = 'email_sent' then 1 else 0 end) as email_opening_rate,
100.0*SUM(CASE when email_cat = 'email_clicked' then 1 else 0 end)/SUM(CASE when 
email_cat = 'email_sent' then 1 else 0 end) as email_clicking_rate
FROM 
(
SELECT 
*,
CASE 
WHEN action in ('sent_weekly_digest','sent_reengagement_email')
then 'email_sent'
WHEN action in ('email_open')
then 'email_opened'
WHEN action in ('email_clickthrough')
then 'email_clicked'
end as email_cat
from email_events
) a;