with base as (
		select 
		-- a.advertiserid as device_aid,
		-- b.advertising_id as install_aid , 
		-- created_on , 
		DATE(installdate) as installdate,
		-- installdate as installtimestamp, 
		a.USERID,
        -- mediasource,
		-- created_on_year,
        channel, -- Ex: (youtube, facebook, Partnerships, Hotstar,...so on)
        -- os,                
        -- campaign,
        -- ad,
        -- adset,
        -- placements,
        -- b.city,
        -- advertising_id,
        -- keyword_id, 
		row_number() over(partition by userid order by installdate) as rn
        FROM  pk_cfuserservice_cultapp.devicedetail a 
		JOIN dwh_curefit.branch_installs b 
				ON b.advertising_id =  CASE WHEN a.advertiserid like '%|%' then split_part(a.advertiserid,'|',1) else a.advertiserid end 
				and installdate between date('2016-01-01') and {{End}}
    where 1=1 
	and LOWER(osname) IN ('ios', 'android')
	and created_on_year>=2017
	AND LOWER(tenant) = 'curefit'
)

select 
	date_trunc('month',installdate) as "Month", 
	case when channel='Organic' then 'Organic' else 'Paid' end as "Source",
	case when rn=1 then 'New' else 'Re-Install' end as "User Install Type",
	count(distinct userid) as "#Installs"
from base 
where installdate between {{Start}} and {{End}}
group by 1,2,3 
order by 1,2,3 

-- January 1, 2017 is min date | select min(installdate) from dwh_curefit.branch_installs where installdate > date '2000-01-01' and installdate <> date '2009-01-04' and installdate <> date '2012-01-01' and installdate <> date '2014-12-22' after excluding the glitch in data
