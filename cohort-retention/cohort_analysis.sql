with cohort_users as (
    select *
    from (
        select *,
            to_timestamp(
                split_part(new_signup_datetime, '-', 1) || '-' ||
                split_part(new_signup_datetime, '-', 2) || '-' ||
                case
                    when length(split_part(new_signup_datetime, '-', 3)) = 2
                    then '20' || split_part(new_signup_datetime, '-', 3)
                    else split_part(new_signup_datetime, '-', 3)
                end,
                'dd-mm-yyyy'
            ) as clean_signup_datetime
        from (
            select *,
                regexp_replace(split_part(trim(signup_datetime), ' ', 1), '[./]', '-', 'g') as new_signup_datetime
            from ads_analysis_goit_course.project.cohort_users_raw
        ) t
    ) t2
    where clean_signup_datetime is not null
),
cohort_events as (
    select *
    from (
        select *,
            to_timestamp(
                split_part(new_event_datetime, '-', 1) || '-' ||
                split_part(new_event_datetime, '-', 2) || '-' ||
                case
                    when length(split_part(new_event_datetime, '-', 3)) = 2
                    then '20' || split_part(new_event_datetime, '-', 3)
                    else split_part(new_event_datetime, '-', 3)
                end,
                'dd-mm-yyyy'
            ) as clean_event_datetime
        from (
            select *,
                regexp_replace(split_part(trim(event_datetime), ' ', 1), '[./]', '-', 'g') as new_event_datetime
            from ads_analysis_goit_course.project.cohort_events_raw
        ) t
    ) t2
    where clean_event_datetime is not null
      and event_type is not null
      and event_type <> 'test_event'
)
select
    promo_signup_flag,
    date(date_trunc('month', u.clean_signup_datetime)) as cohort_month,
    (extract(year from e.clean_event_datetime) - extract(year from u.clean_signup_datetime)) * 12
    + (extract(month from e.clean_event_datetime) - extract(month from u.clean_signup_datetime)) as month_offset,
    count(distinct u.user_id) as users_total
from cohort_users u
left join cohort_events e on u.user_id = e.user_id
where date(date_trunc('month', e.clean_event_datetime)) between '2025-01-01' and '2025-06-01'
group by promo_signup_flag, cohort_month, month_offset
order by promo_signup_flag, cohort_month, month_offset
