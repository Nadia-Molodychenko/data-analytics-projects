with users_parsed as(
select lower(trim(u.email)) as email,
       u.user_id,
       u.signup_datetime ,
       u.promo_signup_flag,
case 
	when replace(replace(
	         split_part(
	             trim(u.signup_datetime),' ', 1),'.','-'), '/', '-') ~ '^\d{1,2}-\d{1,2}-\d{4}$'
    then to_date(replace(replace(split_part(trim(u.signup_datetime), ' ', 1), '.', '-'), '/', '-'), 'DD-MM-YYYY')::timestamp
when replace(replace(
	         split_part(
	             trim(u.signup_datetime),' ', 1),'.','-'), '/', '-') ~ '^\d{1,2}-\d{1,2}-\d{2}$'
    then to_date(replace(replace(split_part(trim(u.signup_datetime), ' ', 1), '.', '-'), '/', '-'), 'DD-MM-YY')::timestamp
    else null
end as signup_ts
from project.cohort_users_raw u),
events_parsed as(
select a.user_id,
       a.event_type,
case 
	when replace(replace(
	         split_part(
	             trim(a.event_datetime),' ', 1),'.','-'), '/', '-') ~ '^\d{1,2}-\d{1,2}-\d{4}$'
    then to_date(replace(replace(split_part(trim(a.event_datetime), ' ', 1), '.', '-'), '/', '-'), 'DD-MM-YYYY')::timestamp
when replace(replace(
	         split_part(
	             trim(a.event_datetime),' ', 1),'.','-'), '/', '-') ~ '^\d{1,2}-\d{1,2}-\d{2}$'
    then to_date(replace(replace(split_part(trim(a.event_datetime), ' ', 1), '.', '-'), '/', '-'), 'DD-MM-YY')::timestamp
    else null
end as event_ts
from project.cohort_events_raw a),
user_activity as(
select 
u.user_id,
date_trunc('month', signup_ts)::date as cohort_month,
u.promo_signup_flag,
date_trunc('month',event_ts)as activity_month,
(extract('year' from a.event_ts) - extract('year' from u.signup_ts)) * 12 
                                   +
(extract('month' from a.event_ts) - extract('month' from u.signup_ts)) AS month_offset
from users_parsed u left join events_parsed a
on u.user_id = a.user_id
where u.signup_ts is not null
and a.event_ts is not null
and a.event_type is not null 
and a.event_type <> 'test_event')
select promo_signup_flag,
       cohort_month,
       month_offset,
 count(distinct user_id) as users_total   
 from user_activity
where activity_month between '2025-01-01'and '2025-06-30'
 group by promo_signup_flag,
          cohort_month,
          month_offset
 order by promo_signup_flag,
          cohort_month ,
          month_offset ;       
          
          
          


