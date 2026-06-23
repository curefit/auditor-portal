WITH base AS (
    SELECT
        a.advertiserid AS device_aid,
        b.advertising_id AS install_aid,
        created_on,
        DATE(installdate) AS installdate,
        installdate AS installtimestamp,
        a.userid,
        mediasource,
        created_on_year,
        ROW_NUMBER() OVER (PARTITION BY userid ORDER BY installdate) AS rn,
        ROW_NUMBER() OVER (ORDER BY installdate) AS install_rn
    FROM pk_cfuserservice_cultapp.devicedetail a
    JOIN dwh_curefit.branch_installs b
        ON b.advertising_id = CASE
            WHEN a.advertiserid LIKE '%|%' THEN split_part(a.advertiserid, '|', 1)
            ELSE a.advertiserid
        END
       AND installdate >= DATE('2016-01-01')
    WHERE LOWER(osname) IN ('ios', 'android')
      AND created_on_year >= 2016
      AND LOWER(tenant) = 'curefit'
)
SELECT
    installdate AS date_1_million_downloads_reached
FROM base
WHERE install_rn = 1000000
