with base as 
(SELECT a.*, 
case when Class_status = 'Active' then null
when cast(json_extract(meta,'$.unAssignSource') as varchar) = 'LEAVE_HANDLER' and cast(json_extract(meta,'$.assignSource') as varchar) = 'SCHEDULER' and b.deletedat is null then 'Trainer Unavailability' 
         when toi.Cultclassid is not null then comment
         else 'Others' 
    end as cancellation_reason,
        cast(round(100.00*footfall/nullif(capacity,0),2) as varchar)||'%' utilization,
         CASE WHEN Number_of_days_OOS >= 3 and
           round(100.00*footfall/nullif(capacity,0),2) > 85.00 then 'Yes' else 'No' end as oos_flag,
      Case 
          when b.trainerid is Null then 'UNASSIGN' ELSE 'ASSIGN'
       End as Is_assigned,
      b.trainerid as trainerid,
       cultemployeeid as CST_employee_id,
       b.createdat trainer_assignedtime,
       c.name as trainer_name,
       email as Trainer_email,
       trainerattendancestatus,
       attendancedatetimeutc as trainer_attendant_time,
       json_extract(meta,'$.assignSource') as Assign_Source,
       json_extract(meta,'$.assignReason') as Assign_Reason,
       json_extract(meta,'$.assignAgent') as Assign_Agent,
       json_extract(meta,'$.unAssignSource') as UnAssign_Source,
       json_extract(meta,'$.unAssignReason') as Unassign_Reason,
       json_extract(meta,'$.unAssignAgent') as Unassign_Agent, 
       row_number() over(partition by class_id order by b.createdat desc) rk
FROM 
(SELECT a.id as class_id,
       date(a.date) as class_date,
       a.centerid,
       trim(cen.name) center_name,
       csc.center_model,
       pk_cultprod_cultapp.workout.name workoutname,
       wf.workoutfamily,
       pk_cultprod_cultapp.city.name city_name,
       lh2.name cluster,
       --a.startdatetimeutc class_start_time,
       --a.enddatetimeutc class_end_time,
       split_part(a.starttime,'.',1)||'-'||split_part(a.endtime,'.',1) as timeslot,
       case when (a.starttime between '07:00:00' and  '10:00:00') or (a.starttime between '18:00:00' and  '21:00:00') then 'peak' else 'non_peak' end as  slot_type,
       a.totalseats as Capacity,
       a.waitlistcapacity as Wait_list_capacity,
       wl_booked,
       wl_confirmed,
       wl_dropout,
       wl_dropout_not_confirmed,
       Case when isactive = 1 THEN 'Active' Else 'Cancelled' End as Class_status,
       case when isactive = 0 then date_diff('day',a.updatedat,a.startdatetimeutc) else null end as cancellation_days,
       case when isactive = 0 then a.updatedat else null end as cancellation_time,

       /*Case 
           When timeslot*/ 
       Count(distinct case when isactive = 1 and b.status = 'BOOKED' then elite_bookingid when isactive = 0 and a.updatedat = b.updated_at then elite_bookingid end) as Bookings,
       Count(distinct case when isactive = 1 and b.status = 'DROPPED_OUT' then elite_bookingid end) as confirmAndDropOut,
       Count(distinct case when attendance_time is not null then elite_bookingid end) as Footfall,
       Count(distinct case when isactive = 1 and b.status = 'BOOKED' and booking_type = 'TRIAL' then elite_bookingid when isactive = 0 and booking_type = 'TRIAL' then elite_bookingid end) as Trial_Booked,
       Count(distinct case when attendance_time is not null and booking_type = 'TRIAL' then elite_bookingid end) as Trial_attendant
FROM pk_cultprod_cultapp.cultclass a
left join pk_cultprod_cultapp.center cen on a.centerid = cen.id
left join pk_curefitprod_center_service.center csc on a.centerid = csc.meta_cultcenterid
LEFT JOIN pk_cultprod_cultapp.locationhierarchy lh on lh.id = cen.locationhierarchyid
    LEFT JOIN pk_cultprod_cultapp.locationhierarchy lh1 on lh1.id = lh.parentid
    LEFT JOIN  pk_cultprod_cultapp.locationhierarchy lh2 on lh2.id = lh1.parentid
left join pk_cultprod_cultapp.workout on a.workoutid = pk_cultprod_cultapp.workout.id
left join ( select wfwm.workoutid,max(wf.name) WorkoutFamily
from 
pk_cultprod_cultapp.WorkoutFamilyWorkoutMap wfwm 
left JOIN pk_cultprod_cultapp.WorkoutFamily wf ON wf.id = wfwm.workoutFamilyID
where lower(wf.name) not like '%family%'
group by 1
) wf on a.workoutid = wf.workoutid
left join pk_cultprod_cultapp.city on cen.cityid = pk_cultprod_cultapp.city.id
LEFT JOIN dwh_fitness.fitness_bookings b ON a.id = b.class_id and b.category = 'ELITE_CENTER' and date(class_date) between {{start}} and {{end}}
left join (Select classid, Count(distinct id) as wl_booked, Count(distinct Case when state = 'CONFIRMED' then id end) as wl_confirmed, 
Count(distinct Case when state = 'CANCELLED' then id end) as wl_dropout,
Count(distinct Case when state = 'REJECTED' then id end) as wl_dropout_not_confirmed
FROM pk_cultprod_cultapp.waitlist wl
Where date(createdat_date) between date_add('day',-20,date({{start}})) and {{end}}
-- and lower(state) not like '%cancel%'
Group by 1) wl ON a.id = wl.classid
WHERE date(a.date) between {{start}} and {{end}}
and a.deletedat is null
and Date(a.createdat_date) >= Date('2019-01-01')
and {{city}} and {{workout}} and cen.name in (select distinct name from pk_cultprod_cultapp.center where {{center_name}})
--and a.id IN (3611715)
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
) a 
LEFT JOIN pk_cultprod_cultapp.trainercultclassmap b ON a.class_id = b.classid and date(createdat_date) between date_add('month',-2,date({{start}})) and {{end}}
LEFT JOIN pk_cultprod_cultapp.cultemployee c ON b.trainerid = c.id
LEFT JOIN (SELECT classid,
       DATE(MIN(createdat)) as First_time_OOS,
       Count(distinct date(createdat)) as Number_of_days_OOS
FROM pk_cultprod_cultapp.Cultclassoos 
WHERE 
    eventname IN ('MEMBER_OOS')
    and Date(createdat_date) >= Date('2019-01-01')
GROUP BY 1) OOS ON a.class_id = OOS.classid
left join 
(SELECT cultclassid,max(comment) as comment 
FROM pk_cultprod_cultapp.Toainstance
where comment is not null and Date(createdat_date) >= Date('2019-01-01') group by 1) toi on a.class_id = toi.cultclassid and a.Class_status = 'Cancelled'
)


--select * from base order by trainer_assignedtime

select dwh_fitness_mart.employee_dim.emp_id trainer_employee_id,
a.*, emp_id as "Employee ID", business_type as "Business Type",
b.trainer_assignedtime trainer_assignedtime2,b.trainer_name trainer_name2,b.trainerattendancestatus trainerattendancestatus2,b.trainer_attendant_time trainer_attendant_time2,b.Assign_Source Assign_Source2,b.Assign_Reason Assign_Reason2,b.Assign_Agent  Assign_Agent2, 
c.trainer_assignedtime trainer_assignedtime3,c.trainer_name trainer_name3,c.trainerattendancestatus trainerattendancestatus3,c.trainer_attendant_time trainer_attendant_time3,c.Assign_Source Assign_Source3,c.Assign_Reason Assign_Reason3,c.Assign_Agent  Assign_Agent3,
(a.Bookings*100.00/nullif(a.Capacity,0)) as fill_rate
from 
(select * from base where rk = 1) a 
left join 
(select * from base where rk = 2) b 
on a.class_id = b.class_id
left join
(select * from base where rk = 3) c
[[where a.cluster = {{cluster}} and ]]
on a.class_id = c.class_id

-- left join (select distinct cast(id as varchar) as identity_id,empid as emp_id,row_number() over(partition by id order by createdat desc) as rf
-- from pk_curefitplatforms_identitydb.Identity) ed on ed.emp_id=def.employeeuin and rf=1

Left join dwh_fitness_mart.employee_dim on Cast(employee_dim.identity_id as Varchar) = Cast(a.trainerid as Varchar)
--left join dwh_fitness_mart.e

--select * from dwh_fitness_mart.employee_dim limit 10
