-- Purpose: Count attended in-center footfalls by grain, city, service type, and optional GX sub-service cut.
-- Output: Grain, city_name, service_type, sub_service_type, footfalls.
-- Membership-date fix: transferred/upgraded packs use membership-service start/end dates for class eligibility windows.
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
        
    From (
        Select
            md.user_id,
            md.business_line,
            md.membership_type,
            md.attributed_center_key,
            md.purchase_center_key,
            -- Transfers/upgrades should use membership-service dates so the active window follows the latest pack lifecycle.
            Case
                When Lower(Cast(md.is_transferred_pack as Varchar)) = 'true' or Lower(Cast(md.is_upgrade_pack as Varchar)) = 'true' Then mdb."start"
                Else md.pack_start_date
            End as pack_start_date,
            Case
                When Lower(Cast(md.is_transferred_pack as Varchar)) = 'true' or Lower(Cast(md.is_upgrade_pack as Varchar)) = 'true' Then mdb."end"
                Else md.pack_end_date
            End as pack_end_date
        From dwh_fitness_mart.membership_dim md
        Left join pk_curefitplatforms_membershipdb.memberships mdb
            on mdb.id = md.membership_service_id
    ) membership_dim
    LEFT JOIN dwh_fitness_mart.center_dim ON center_key = coalesce(attributed_center_key,purchase_center_key)
    join dwh_fitness_mart.booking_fact on  dwh_fitness_mart.booking_fact.user_id = membership_dim.user_id and DATE(Class_date) BETWEEN Date(pack_start_date) and Date(pack_end_date)
            and 
                -- Trials are excluded so footfalls reflect paid/member usage.
                coalesce(booking_type,'xx') != 'TRIAL'
                and Date(class_date) between {{Start_Date}} and {{End_Date}}
                -- Only attended bookings count as footfalls.
                and attendance_time IS NOT NULL
                and date(class_date) >= date '1900-01-01'
    Where
        DATE(Class_date) between Date(pack_start_date) and Date(pack_end_date)
        -- Fitness membership lines covered in this footfall view.
        and membership_dim.business_line in ('ELITE', 'PRO', 'PLAY','LUX')
        -- Keep the base to paid memberships.
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

