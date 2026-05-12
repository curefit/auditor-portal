Select
    *,
    "Revenue"*1.00/Sum("Revenue") Over(Partition by Split_Part("Business Line", ' - ', 2)) as "Distribution"

From
(
    Select
        Case
            When orders_offer_fact.order_id is not Null and membership_dim.business_line = 'ELITE' Then '1. Referred - Elite'
            When orders_offer_fact.order_id is Null and membership_dim.business_line = 'ELITE' Then '2. Regular - Elite'
            When orders_offer_fact.order_id is not Null and membership_dim.business_line = 'PRO' Then '3. Referred - Pro'
            When orders_offer_fact.order_id is Null and membership_dim.business_line = 'PRO' Then '4. Regular - Pro'
        End as "Business Line",
        Count(Distinct(membership_dim.user_id)) as "# Packs",
        Sum(amount_paid + Coalesce(orders_fact.payable_platform_fee, 0)) as "Revenue"
    From dwh_fitness_mart.membership_dim
    Left join
        (
            Select
                order_id
            From dwh_fitness_mart.orders_offer_fact
            Where
                offer_id in ('SJETGo_cm', '7CvtJxzWA')
                and orders_offer_fact.purchase_date >= Date('2020-01-01')
        ) as orders_offer_fact
        on orders_offer_fact.order_id = membership_dim.order_id
    Left join dwh_fitness_mart.orders_fact on orders_fact.order_key = membership_dim.order_key
        and orders_fact.membership_key = membership_dim.membership_key
        and orders_fact.purchase_date >= Date('2020-01-01')
    Where
        amount_paid > 0
        and membership_created_date BETWEEN {{start_date}} AND {{end_date}}
        and membership_dim.business_line in ('ELITE', 'PRO')
        and pack_category in ('12 Months', '6 Months', '3 Months')
    Group by
        1
)

Order by
    1
