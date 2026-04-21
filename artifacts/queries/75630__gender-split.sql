WITH
  base AS (
    SELECT
      --date_trunc('quarter', dd.full_date) AS "quarter",
      m.USER_ID
    FROM
      dwh_fitness_mart.membership_dim m
    --   JOIN dwh_curefit.dim_date dd ON dd.full_date BETWEEN m.pack_start_date AND m.pack_end_date
    WHERE 1=1
    -- dd.full_date >= DATE('2025-01-01')
      AND m.membership_created_date between date('2017-10-01') AND {{ed}}
      and m.business_line in ('ELITE','PRO','PLAY')
      and amount_paid>0
    GROUP BY
      1
  )
, birthday_base as (


select 
user_id
,case when birthday between date('1970-01-01') and date_add('year',-18,now()) THEN cast(birthday as varchar) end as birthday
,coalesce(case when cast(birthday as varchar)='-1' then null else age end,'NA') as age
,coalesce(gender,'NA') as Gender
,age_source
,age_nos
from (with age_onboarding as  (select nrs.userid
,date_diff('year',date(substr(max(case when  nrs.questionid='onboarding_user_dob_v1' then  nrs.answer end),1,10)),current_date) as age 
,date(substr(max(case when  nrs.questionid='onboarding_user_dob_v1' then  nrs.answer end),1,10)) as birthday
,substr(max(case when questionid='@Home Guidance_Gender_v1' and lower(trim(answer)) in ('m','f') then lower(trim(answer)) end),1,1) as gender
from pk_curefitprod_cfdb.npsresponses nrs 
where 1=1
and nrs.answer is not null and nrs.answer!=''
-- filter for onboarding forms 
and nrs.formid='post_pack_purchase_onboarding' and nrs.questionid in ('onboarding_user_dob_v1','@Home Guidance_Gender_v1')
group by 1)


, user_age as (select cast(id as varchar) userid
,case when substr(lower(trim(gender)),1,1) in ('m','f') then substr(lower(trim(gender)),1,1) end as gender
,date_diff('year',cast(substr(birthday,1,10) as date),current_date) as age
,cast(substr(birthday,1,10) as date) birthday
from (select id, gender,birthday,row_number() over (partition by id order by updatedat desc) rf 
 from pk_cfuserservice_cultapp.User) user where rf=1)


, rashi_age as  (select  cast(Userid as varchar) as userid 
,date_diff('year',min(date(from_unixtime(cast(case when Attribute in ('birthday') then value end as double)/1000)+interval '330' minute)),current_date) as age
,min(date(from_unixtime(cast(case when Attribute in ('birthday') then value end as double)/1000)+interval '330' minute)) as birthday
, max(case when Attribute in ('Gender','gender','predictedgender') and coalesce(substr(lower(CAST(json_extract(value, '$.gender') AS VARCHAR)),1,1),substr(trim(lower(value)),1,1)) in ('m','f') then coalesce(substr(lower(CAST(json_extract(value, '$.gender') AS VARCHAR)),1,1),substr(trim(lower(value)),1,1)) end) as gender
from
pk_cfprodplatforms_rashi.User_Attribute where  Attribute in (
 'Gender'
,'gender'
, 'birthday'
) and value !=''
group by 1
--having min(date(from_unixtime(cast(value as double)/1000)+interval '330' minute)) > date_trunc('year',current_date) - interval '100' year  and min(date(from_unixtime(cast(value as double)/1000)+interval '330' minute))<=date_trunc('year',current_date)
)



select cast(u.id as varchar) as user_id , case when coalesce(ua.age,ra.age,ab.age) is null then 'AGE NA'
when coalesce(ua.age,ra.age,ab.age) between 0 and 20 then '0-20 yrs'
when coalesce(ua.age,ra.age,ab.age) between 20 and 60 then concat(cast(coalesce(ua.age,ra.age,ab.age) as varchar),' yrs')
when coalesce(ua.age,ra.age,ab.age) >60 then '>60 yrs' end age
,coalesce(ua.age,ra.age,ab.age) as age_nos
,coalesce(ua.gender,ra.gender,ab.gender,'NA') as gender
,coalesce(ua.birthday,ra.birthday,ab.birthday) as birthday
,case when ua.age is not null then 'user_table'
 when ra.age is not null then 'rashi_table'
 when ab.age is not null then 'onboarding_table'
else 'no_value' end as age_source
from pk_cfuserservice_cultapp.User u
left join user_age ua on ua.userid=cast(u.id as varchar)
left join rashi_age ra on  cast(ra.userid as varchar)=cast(u.id as varchar)
left join age_onboarding ab on  cast(ab.userid as varchar)=cast(u.id as varchar)
)
m
)
,GENDER_BASE AS ( 
select gender,USER_ID
from birthday_base)

SELECT  gender,COUNT(BASE.USER_ID) MEMBERS--,COUNT_IF(UPPER(GENDER)='F') FEMALE_MEMBERS,COUNT_IF(UPPER(GENDER)='M') MALE_MEMBERS
FROM BASE 
LEFT JOIN GENDER_BASE ON GENDER_BASE.USER_ID = BASE.USER_ID
GROUP BY 1
order by 1
