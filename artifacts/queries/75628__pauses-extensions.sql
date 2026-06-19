-- Purpose: Classify memberships by pause usage, transfer usage, both, or neither.
-- Output: type, memberships.
-- Membership-date fix: transferred/upgraded packs use membership-service created_date before entering the base cohort.
WITH
  base AS (
    SELECT
      m.membership_key,
      fitness_next_membership
    FROM
      dwh_fitness_mart.membership_fact m
      LEFT JOIN pk_curefitplatforms_membershipdb.memberships mdb
        ON mdb.id = m.membership_service_id
    WHERE 1=1
      -- Use membership-service created_date for transferred/upgraded packs before classifying pause/transfer usage.
      AND DATE(
        CASE
          WHEN LOWER(CAST(m.is_transferred_pack AS VARCHAR)) = 'true' OR LOWER(CAST(m.is_upgrade_pack AS VARCHAR)) = 'true' THEN mdb.created_date
          ELSE m.membership_created_date
        END
      ) between date('2017-10-01') and {{ed}}
      -- Pause/transfer usage is reviewed for the main fitness membership lines.
      and m.business_line in ('ELITE','PRO','PLAY')
	  -- Freeze to a single fact-table snapshot so results do not move because of
	  -- late-arriving tech changes or partition refreshes.
	  AND m.transaction_date = date '2026-06-16'
    GROUP BY
      1,
      2
  ),

  parent_child_map AS (
    SELECT * FROM (
      SELECT 
        DISTINCT CAST(JSON_EXTRACT_SCALAR(m.metadata, '$.parentMembershipId') AS VARCHAR) AS parent_membership_id,
        cast(m.id as VARCHAR) AS child_membership_id,
        CASE 
          WHEN CAST(JSON_EXTRACT_SCALAR(m.metadata, '$.isUpgradePack') AS VARCHAR) = 'true' THEN 'Upgrade'
          WHEN CAST(JSON_EXTRACT_SCALAR(m.metadata, '$.isTransferredPack') AS VARCHAR) = 'true' THEN 'Transfer'
          ELSE 'Undefined' 
        END AS relationship,
        md.membership_key, -- needed to join back to base
        md.business_line,
        DATE(m2.start) AS parent_pack_start_date,
        DATE(m2."end") AS parent_pack_end_date_latest,
        DATE(m.start) AS child_pack_start_date,
        DATE(m."end") AS child_pack_end_date_latest, 
        COALESCE(COALESCE(CAST(of2.price AS DOUBLE),CAST(m2.price AS DOUBLE)),0) AS parent_amount_paid,
        COALESCE(COALESCE(CAST(of.price AS DOUBLE),CAST(m.price AS DOUBLE)),0) AS child_amount_paid,
        DATE(m.cancellation_date) AS child_cancellation_date,
        DATE(m2.cancellation_date) AS parent_cancellation_date,
        DATE(m2.created_date) AS parent_created_date,
        DATE(m.created_date) AS child_created_date,
        ROW_NUMBER() OVER(PARTITION BY CAST(JSON_EXTRACT_SCALAR(m.metadata, '$.parentMembershipId') AS INT) ORDER BY m.created_date DESC) AS row_num
      FROM pk_curefitplatforms_membershipdb.memberships m
      LEFT JOIN dwh_fitness_mart.membership_fact md on m.id = md.membership_service_id and md.transaction_date = date '2026-06-16'
      LEFT JOIN pk_curefitplatforms_membershipdb.memberships m2 ON CAST(JSON_EXTRACT_SCALAR(m.metadata, '$.parentMembershipId') AS INT) = m2.id
      LEFT JOIN dwh_fitness_mart.orders_fact of ON of.order_id = m.order_id AND of.purchase_date >= date('2017-10-01') AND of.purchase_date <= {{ed}}
      LEFT JOIN dwh_fitness_mart.orders_fact of2 ON of2.order_id = m2.order_id AND of2.purchase_date >= date('2017-10-01') AND of2.purchase_date <= {{ed}}
      WHERE TRUE
        AND m.created_date between date('2017-10-01') and {{ed}}
        AND (
          CAST(JSON_EXTRACT_SCALAR(m.metadata, '$.isTransferredPack') AS VARCHAR) = 'true'
          OR 
          CAST(JSON_EXTRACT_SCALAR(m.metadata, '$.isUpgradePack') AS VARCHAR) = 'true'
        ) 
        AND (m.product_id LIKE 'CULTPACK%' OR m.product_id LIKE 'GYMFIT%')
    )
    WHERE row_num = 1
    -- Only transfers are counted in the transfer-used bucket; upgrades are not part of this audit cut.
    AND relationship = 'Transfer'
  )

SELECT
  CASE 
    WHEN f.membership_key IS NOT NULL AND pcm.parent_membership_id IS NOT NULL THEN 'Both used'
    WHEN f.membership_key IS NOT NULL THEN 'Pause used'
    WHEN pcm.parent_membership_id IS NOT NULL THEN 'Transfer used'
    ELSE 'Unused'
  END AS type,
  count(DISTINCT b.membership_key) AS memberships
FROM base b
LEFT JOIN dwh_fitness_bi.pause_and_extension_fact f 
  ON b.membership_key = f.membership_key
  AND UPPER(event_type) = 'PAUSE'
  AND event_date <= {{ed}} + interval '12' month
LEFT JOIN parent_child_map pcm
  ON b.membership_key = pcm.membership_key  -- join on parent's membership_key

GROUP BY 1
