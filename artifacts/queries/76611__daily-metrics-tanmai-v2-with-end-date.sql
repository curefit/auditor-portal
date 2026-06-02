-- Purpose: Report daily membership revenue, packs, duration, realization, spot offers, and no-cost EMI metrics.
-- Output: Purchase Date, SKU, Type, Membership Type, City, Pack Duration, Presales, Revenue, Packs, Duration, realization and offer metrics.
-- Membership-date fix: transferred/upgraded packs use membership-service created/start/end dates for purchase windows and duration.
Select
        purchase_date as "Purchase Date",
        business_line as "SKU",
        Case
            When is_select = 0 Then 'Pass'
            When is_select = 1 Then 'Select'
        End as "Type",
        Case
            When membership_type = 'Repeat' Then 'Repeat'
            When membership_type = 'New' Then 'New'
            Else 'Error'
        End as "Membership Type",
        Case
            When order_cityname in ('Bangalore', 'Hyderabad', 'Gurgaon', 'Pune') Then order_cityname
            When order_cityname in ('Navi_Mum_And_Thane', 'Mumbai') Then 'Mumbai'
            When order_cityname is Null Then 'Empty City'
            Else 'Others'
        End as "City",
        Case
            When Lower(pack_name) like '%12m%' or Lower(pack_name) like '%12%m%' Then '2. 12 Months'
            When Lower(pack_name) like '%1m%' or Lower(pack_name) like '%1%m%' or Lower(pack_name) like '%monthly%' Then '5. 1 Month'
            When Lower(pack_name) like '%3m%' or Lower(pack_name) like '%3%m%' Then '4. 3 Months'
            When Lower(pack_name) like '%6m%' or Lower(pack_name) like '%6%m%' or Lower(pack_name) = '4. 3 Months' Then '3. 6 Months'
            Else '6. >12 Months'
        End as "Pack Duration",
        pre_sales_flag as "Presales",
        Sum(amount_paid1) as "Revenue",
        Count(Distinct(Case When amount_paid > 0 Then order_id Else Null End)) as "Packs",
        ((Sum(day_difference))/30.42) as "Duration",
        (Sum(amount_paid1)/Sum(day_difference))*30.42 as "Realisation per Month",
        Count(Distinct(Case When Coalesce(spot_offer_value, 0) > 0 Then order_id Else Null End)) as "# Spot Offer",
        Count(Distinct(Case When Coalesce(no_cost_emi, 0) > 0 Then order_id Else Null End)) as "# NCEMI",
        Sum(Case When Coalesce(spot_offer_value, 0) > 0 Then spot_offer_value Else Null End) as "Spot Offer Value",
        Sum(Case When Coalesce(no_cost_emi, 0) > 0 Then no_cost_emi Else Null End) as "NCEMI Value"
        
    
    From
    (
        Select
            Coalesce(membership_dim.elite_membership_id, membership_dim.pro_membership_id) as membership_id,
            CASE
                WHEN Lower(Cast(membership_dim.is_transferred_pack as Varchar)) = 'true' or Lower(Cast(membership_dim.is_upgrade_pack as Varchar)) = 'true' Then membership_mdb."start"
                Else membership_dim.pack_start_date
            End as pack_start_date,
            Coalesce(
                original_pack_end_date,
                CASE
                    WHEN Lower(Cast(membership_dim.is_transferred_pack as Varchar)) = 'true' or Lower(Cast(membership_dim.is_upgrade_pack as Varchar)) = 'true' Then membership_mdb."end"
                    Else membership_dim.pack_end_date
                End
            ) as pack_end_date,
            Date_Diff(
                'Day',
                CASE
                    WHEN Lower(Cast(membership_dim.is_transferred_pack as Varchar)) = 'true' or Lower(Cast(membership_dim.is_upgrade_pack as Varchar)) = 'true' Then membership_mdb."start"
                    Else membership_dim.pack_start_date
                End,
                Coalesce(
                    original_pack_end_date,
                    CASE
                        WHEN Lower(Cast(membership_dim.is_transferred_pack as Varchar)) = 'true' or Lower(Cast(membership_dim.is_upgrade_pack as Varchar)) = 'true' Then membership_mdb."end"
                        Else membership_dim.pack_end_date
                    End
                )
            ) as day_difference,
            membership_dim.user_id,
            Date(
                CASE
                    WHEN Lower(Cast(membership_dim.is_transferred_pack as Varchar)) = 'true' or Lower(Cast(membership_dim.is_upgrade_pack as Varchar)) = 'true' Then membership_mdb.created_date
                    Else membership_dim.membership_created_date
                End
            ) as purchase_date,
            attributed_center.city_name as attributed_city,
            membership_dim.business_line as business_line,
            membership_dim.amount_paid,
            (membership_dim.amount_paid + Coalesce(orders_fact.payable_platform_fee, 0)) as amount_paid1,
            membership_dim.source,
            purchase_center.city_name as purchase_city, purchase_center.ownership_type as purchase_center_model,
            purchase_center.center_type as purchase_center_type,
            purchase_center.center_name as purchase_center_name,
            purchase_center.center_service_id as purchase_center_service_id,
            purchase_center.category as purchase_center_category,
            attributed_center.ownership_type as attributed_center_model,
            membership_dim.order_key as order_id,
            membership_dim.pack_name,
            Case
                When membership.previous_sku is Null and (membership.membership_rank = 1 or membership.membership_rank is Null) Then 'New'
                When membership.membership_key is not Null and membership.membership_rank > 1 Then 'Repeat'
                When membership.previous_sku is not Null Then 'Repeat'
                Else 'Check'
            End as membership_type,
            attributed_center.center_type as attributed_center_type,
            attributed_center.center_name as attributed_center_name,
            attributed_center.center_launch_date as launch_date,
            attributed_center.center_service_id as attributed_center_service_id,
            attributed_center.category as attributed_center_category,
            membership_dim.pack_category,
            Coalesce(orders_fact.city_name, attributed_center.city_name, purchase_center.city_name) as order_cityname,
            is_select,
            Case
                When Date(
                    CASE
                        WHEN Lower(Cast(membership_dim.is_transferred_pack as Varchar)) = 'true' or Lower(Cast(membership_dim.is_upgrade_pack as Varchar)) = 'true' Then membership_mdb.created_date
                        Else membership_dim.membership_created_date
                    End
                ) < Date(purchase_center.center_launch_date) Then 1
                Else 0
            End as pre_sales_flag,
            orders_fact.spot_offer_value,
            orders_fact.instant_discount as no_cost_emi
            
        From dwh_fitness_mart.membership_dim
        Left join pk_curefitplatforms_membershipdb.memberships membership_mdb
            on membership_mdb.id = membership_dim.membership_service_id
        Left join dwh_fitness_mart.orders_fact on dwh_fitness_mart.orders_fact.order_key = dwh_fitness_mart.membership_dim.order_key
            and Date(orders_fact.purchase_date) >= Date(current_date) - Interval '3' Year
        Left join dwh_fitness_mart.center_dim purchase_center on purchase_center.center_key = membership_dim.purchase_center_key
        /*Repeat Logic*/
        Left join 
            (
                Select 
                    membership_key,
                    -- Repeat logic should order transfers/upgrades by membership-service created_date.
                    Row_Number() Over(Partition By membership_dim.user_id Order by CASE
                        WHEN Lower(Cast(membership_dim.is_transferred_pack as Varchar)) = 'true' or Lower(Cast(membership_dim.is_upgrade_pack as Varchar)) = 'true' Then repeat_mdb.created_date
                        Else membership_dim.membership_created_date
                    END) as membership_rank,
                    Lag(membership_dim.business_line) Over(Partition By membership_dim.user_id Order by CASE
                        WHEN Lower(Cast(membership_dim.is_transferred_pack as Varchar)) = 'true' or Lower(Cast(membership_dim.is_upgrade_pack as Varchar)) = 'true' Then repeat_mdb.created_date
                        Else membership_dim.membership_created_date
                    END) as previous_sku
                From dwh_fitness_mart.membership_dim
                Left join pk_curefitplatforms_membershipdb.memberships repeat_mdb
                    on repeat_mdb.id = membership_dim.membership_service_id
                Where
                    -- Cancelled packs are not used while deciding New vs Repeat.
                    (lower(Coalesce(membership_dim.status,'xx')) not like '%canc%') and
                    (
                        membership_dim.amount_paid > 0 or Coalesce(membership_dim.membership_type,'xx')  in ('MEMBER_MIGRATION','ENTERPRISE','MIGRATION') or
                        Coalesce(membership_dim.pack_name,'xx')  in ('Transferred Pack') or Coalesce(membership_dim.status,'xx')  in ('MEMBERSHIP_TRANSFERRED') or
                        Coalesce(membership_dim.source,'xx')  in ('MIGRATION')
                    )
            ) as membership
            on membership.membership_key = membership_dim.membership_key
        Left join dwh_fitness_mart.center_dim attributed_center on membership_dim.final_center_key = attributed_center.center_key
        Left join dwh_fitness.fitness_orders on fitness_orders.order_id = orders_fact.order_id
            and
                (
                    Lower(fitness_orders.product_info) like '%spot offer%' or
                    Lower(fitness_orders.product_info) like '%birthday sale special spot offer for retention pack%'
                )
            and Date(fitness_orders.purchase_date) >= Date(current_date) - Interval '3' Year
        Left join
            (
                Select
                    orderid, instantdiscount_amount/100 as instantdiscount_amount
                From pk_prod_curefit_prod.orders
                Left join pk_prod_curefit_prod.orders_payments on orders.createddate_date = orders_payments.root_createddate_date
                    and orders._id = orders_payments.root_ref_id
                    and createddate_date >= date('2019-01-01')
                Where
                    (
                        Lower(data_paymethod) like '%emi%' or
                        Lower(data_selectedpaymentmode) like '%emi%'
                    )
                    and instantdiscount_amount > 0
                    and Date(createddate) between {{Start_Date}} and {{End_Date}}
            ) as emi_order_data
            on emi_order_data.orderid = orders_fact.order_id
        
        Where
            -- Daily revenue view is for ELITE and PRO memberships.
            membership_dim.business_line IN ('ELITE','PRO')
            -- Use membership-service created_date for transferred/upgraded packs in purchase-window reporting.
            and Date(CASE
                WHEN Lower(Cast(membership_dim.is_transferred_pack as Varchar)) = 'true' or Lower(Cast(membership_dim.is_upgrade_pack as Varchar)) = 'true' Then membership_mdb.created_date
                Else membership_dim.membership_created_date
            END) >= {{Start_Date}}
            and Date(CASE
                WHEN Lower(Cast(membership_dim.is_transferred_pack as Varchar)) = 'true' or Lower(Cast(membership_dim.is_upgrade_pack as Varchar)) = 'true' Then membership_mdb.created_date
                Else membership_dim.membership_created_date
            END) <= {{End_Date}}
            -- Revenue metrics use paid packs only.
            and membership_dim.amount_paid is not Null 
            and membership_dim.amount_paid > 0
            
    )
    
    Where
        -- Avoid divide-by-zero and invalid duration packs.
        day_difference > 0
        -- Upgraded/transfer pack names are excluded from final pack-sale reporting.
        and Lower(pack_name) not like '%upgraded%'
        and Lower(pack_name) not like '%transfer%'
        
    
    Group by
        1, 2, 3, 4, 5, 6, 7
    Order by
        1 Desc, 3
