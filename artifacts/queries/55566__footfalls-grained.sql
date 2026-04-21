with base as 
    (
    Select
        -- dwh_fitness_mart.membership_dim.business_line,
        Date_Trunc({{grain}}, Class_date) as "Grain",
        CASE WHEN city_name = 'Bangalore' THEN 'Bangalore'
                 WHEN city_name = 'Gurgaon' THEN 'Gurgaon'
                 WHEN city_name = 'Hyderabad' THEN 'Hyderabad'
                 WHEN city_name IN ('Mumbai','Navi_Mum_And_Thane') THEN 'Mumbai' ELSE 'Others' END city_name, 
        dwh_fitness_mart.booking_fact.service_type,
        CASE WHEN {{gx_class_cuts}} = 'yes' then dwh_fitness_mart.booking_fact.sub_service_type else 'all' end as sub_service_type,
                 
        COUNT(DISTINCT booking_key) as footfalls
        
    From dwh_fitness_mart.membership_dim
    LEFT JOIN dwh_fitness_mart.center_dim ON center_key = coalesce(attributed_center_key,purchase_center_key)
    join dwh_fitness_mart.booking_fact on  dwh_fitness_mart.booking_fact.user_id = membership_dim.user_id and DATE(Class_date) BETWEEN Date(pack_start_date) and Date(pack_end_date)
            and 
                coalesce(booking_type,'xx') != 'TRIAL'
                and Date(class_date) between {{Start_Date}} and {{End_Date}}
                and attendance_time IS NOT NULL
                and date(class_date) >= date '1900-01-01'
    Where
        DATE(Class_date) between Date(pack_start_date) and Date(pack_end_date)
        and dwh_fitness_mart.membership_dim.business_line in ('ELITE', 'PRO', 'PLAY','LUX')
        and membership_type = 'PAID'
        and Date(class_date) between {{Start_Date}} and {{End_Date}}
    Group by
        1,2,3,4
) 
    
    -- select ' overall',month, null, sum(footfalls) footfalls
    -- from base
    -- group by 1,2
    -- union all
select * from base 
Order by
    1,2,3
