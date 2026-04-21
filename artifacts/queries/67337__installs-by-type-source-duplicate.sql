Select
    "Date",
    "Install Type - Source",
    Case
        When {{Value_Type}} = 'Users' Then "Users"
        When {{Value_Type}} = 'Devices' Then "Devices"
        When {{Value_Type}} = 'Installs' Then "Installs"
    End as "Installs"
From
(
    SELECT
      Date_Trunc ({{Time_Granularity}}, install_date) AS "Date",
      user_install_type || ' - ' || source AS "Install Type - Source",
      COUNT(DISTINCT user_id) AS "Users",
      COUNT(DISTINCT device_id) AS "Devices",
      COUNT(DISTINCT primary_key) AS "Installs"
    FROM
      dwh_growth_mart.growth_install_fact 
    WHERE
      install_date BETWEEN {{From}} AND {{To}}
      and fitness_membership_type='Non-Member'
      AND {{City}}
      AND {{Campaign}}
      and {{OS}}
    GROUP BY
      1,
      2
)


UNION ALL 

Select
    "Date",
    'TOTAL',
    SUM(Case
        When {{Value_Type}} = 'Users' Then "Users"
        When {{Value_Type}} = 'Devices' Then "Devices"
        When {{Value_Type}} = 'Installs' Then "Installs"
    End ) as "Installs"
From
(
    SELECT
      Date_Trunc ({{Time_Granularity}}, install_date) AS "Date",
      user_install_type || ' - ' || source AS "Install Type - Source",
      COUNT(DISTINCT user_id) AS "Users",
      COUNT(DISTINCT device_id) AS "Devices",
      COUNT(DISTINCT primary_key) AS "Installs"
    FROM
      dwh_growth_mart.growth_install_fact
    WHERE
      install_date BETWEEN {{From}} AND {{To}}
      and fitness_membership_type='Non-Member'
      AND {{City}}
      AND {{Campaign}}
    GROUP BY
      1,
      2
)
group by 1,2
ORDER BY
  1 DESC
