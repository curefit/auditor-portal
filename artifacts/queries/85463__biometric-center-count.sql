WITH center_day AS (
  SELECT
    date(b.class_date) AS date,
    c.hybrid_center_name,
    c.hybrid_center_service_id,

    count(distinct case 
      when b.service_type = 'GX' 
      then b.booking_key 
    end) as total_gx_sessions,

    count(distinct case 
      when b.service_type = 'GX' 
       and a.source = 'BIOMETRIC' 
      then b.booking_key 
    end) as total_gx_biometric,

    count(distinct case
      when date(ch.createdat) between {{startdate}} and {{enddate}}
       and ch.passcode = 'BiometricCheckin'
       and ch.state = 'VALIDATED'
       and ch.source = 'APP'
      then ch.id
    end) as total_gym_biometric_checkins

  FROM dwh_fitness_mart.booking_fact b
  INNER JOIN dwh_metabase_starburst.model_41616_center_dim c 
    ON c.center_key = b.center_key
  LEFT JOIN pk_curefitprod_gymfit.checkins ch 
    ON ch.id = b.gym_checkin_id
   AND date(ch.createdat) >= date('2023-01-01')
   AND ch.createdat_date >= date('2023-01-01')
  LEFT JOIN pk_cultprod_cultapp.attendance a 
    ON a.bookingid = b.elite_booking_id
   AND a.createdat_date >= date('2023-01-01')

  WHERE b.class_date BETWEEN {{startdate}} AND {{enddate}}
    AND b.class_date >= date('2023-01-01')
    AND b.attendance_time IS NOT NULL

  GROUP BY 1,2,3
)

SELECT
    date,

    count(distinct case when total_gx_biometric + total_gym_biometric_checkins > 0
                        then hybrid_center_service_id end)
      as biometric_center_count

FROM center_day
GROUP BY 1
ORDER BY 1
