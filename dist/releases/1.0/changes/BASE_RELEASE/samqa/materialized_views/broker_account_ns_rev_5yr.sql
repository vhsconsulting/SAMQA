-- liquibase formatted sql
-- changeset SAMQA:1754373934670 stripComments:false logicalFilePath:BASE_RELEASE\samqa\materialized_views\broker_account_ns_rev_5yr.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/materialized_views/broker_account_ns_rev_5yr.sql:null:e62cc7ed4c6131cde806400ec57e27ff4eded2b2:create

create materialized view samqa.broker_account_ns_rev_5yr (
    "0",
    year,
    cnt
) build immediate using index
    refresh force
    on demand
    using enforced constraints
    disable on query computation
    disable query rewrite
as
    select
        0,
        extract(year from sysdate) year,
        count(distinct broker_id)  cnt
    from
        (
            select
                broker,
                broker_id,
                salesrep_id,
                salesrep_name,
                city,
                state,
                zip,
                ( sum(setup) + sum(setup_discount) + sum(setup_optional) ) as setup,
                ( sum(monthly) + sum(monthly_discount) )                   as monthly,
                sum(revenue_amount)                                        as sum_revenue,
                count(distinct(account_type))                              account_type_count,
                regexp_replace(
                    listagg(account_type, ',' on overflow truncate '...') within group(
                    order by
                        account_type
                    ),
                    '([^,]+)(,\1)*(,|$)',
                    '\1\3')                                     account_types
            from
                (
                    select
                        *
                    from
                        broker_account_nohsa_rev_mv
                    where
                        ( trunc(pay_approved_date) between add_months(
                            trunc(sysdate, 'YEAR'),
                            -0
                        ) and add_months(
                            trunc(sysdate, 'YEAR'),
                            -0 + 11
                        ) + 30
                          and trunc(start_date) <= add_months(
                            trunc(sysdate, 'YEAR'),
                            -0 + 11
                        ) + 30 )
                        or ( trunc(start_date) between add_months(
                            trunc(sysdate, 'YEAR'),
                            -0
                        ) and add_months(
                            trunc(sysdate, 'YEAR'),
                            -0 + 11
                        ) + 30
                             and trunc(pay_approved_date) < add_months(
                            trunc(sysdate, 'YEAR'),
                            -0
                        ) )
                    union all
                    select
                        *
                    from
                        broker_account_hsa_rev_mv
                    where
                        trunc(pay_approved_date) between add_months(
                            trunc(sysdate, 'YEAR'),
                            -0
                        ) and add_months(
                            trunc(sysdate, 'YEAR'),
                            -0 + 11
                        ) + 30
                )
            having
                sum(revenue_amount) > 0
            group by
                broker,
                broker_id,
                salesrep_id,
                salesrep_name,
                city,
                state,
                zip
            order by
                sum(revenue_amount) desc
        )
    union
    select
        12,
        extract(year from sysdate) - 1 year,
        count(distinct broker_id)      cnt
    from
        (
            select
                broker,
                broker_id,
                salesrep_id,
                salesrep_name,
                city,
                state,
                zip,
                ( sum(setup) + sum(setup_discount) + sum(setup_optional) ) as setup,
                ( sum(monthly) + sum(monthly_discount) )                   as monthly,
                sum(revenue_amount)                                        as sum_revenue,
                count(distinct(account_type))                              account_type_count,
                regexp_replace(
                    listagg(account_type, ',' on overflow truncate '...') within group(
                    order by
                        account_type
                    ),
                    '([^,]+)(,\1)*(,|$)',
                    '\1\3')                                     account_types
            from
                (
                    select
                        *
                    from
                        broker_account_nohsa_rev_mv
                    where
                        ( trunc(pay_approved_date) between add_months(
                            trunc(sysdate, 'YEAR'),
                            -12
                        ) and add_months(
                            trunc(sysdate, 'YEAR'),
                            -12 + 11
                        ) + 30
                          and trunc(start_date) <= add_months(
                            trunc(sysdate, 'YEAR'),
                            -12 + 11
                        ) + 30 )
                        or ( trunc(start_date) between add_months(
                            trunc(sysdate, 'YEAR'),
                            -12
                        ) and add_months(
                            trunc(sysdate, 'YEAR'),
                            -12 + 11
                        ) + 30
                             and trunc(pay_approved_date) < add_months(
                            trunc(sysdate, 'YEAR'),
                            -12
                        ) )
                    union all
                    select
                        *
                    from
                        broker_account_hsa_rev_mv
                    where
                        trunc(pay_approved_date) between add_months(
                            trunc(sysdate, 'YEAR'),
                            -12
                        ) and add_months(
                            trunc(sysdate, 'YEAR'),
                            -12 + 11
                        ) + 30
                )
            having
                sum(revenue_amount) > 0
            group by
                broker,
                broker_id,
                salesrep_id,
                salesrep_name,
                city,
                state,
                zip
            order by
                sum(revenue_amount) desc
        )
    union
    select
        24,
        extract(year from sysdate) - 2 year,
        count(distinct broker_id)      cnt
    from
        (
            select
                broker,
                broker_id,
                salesrep_id,
                salesrep_name,
                city,
                state,
                zip,
                ( sum(setup) + sum(setup_discount) + sum(setup_optional) ) as setup,
                ( sum(monthly) + sum(monthly_discount) )                   as monthly,
                sum(revenue_amount)                                        as sum_revenue,
                count(distinct(account_type))                              account_type_count,
                regexp_replace(
                    listagg(account_type, ',' on overflow truncate '...') within group(
                    order by
                        account_type
                    ),
                    '([^,]+)(,\1)*(,|$)',
                    '\1\3')                                     account_types
            from
                (
                    select
                        *
                    from
                        broker_account_nohsa_rev_mv
                    where
                        ( trunc(pay_approved_date) between add_months(
                            trunc(sysdate, 'YEAR'),
                            -24
                        ) and add_months(
                            trunc(sysdate, 'YEAR'),
                            -24 + 11
                        ) + 30
                          and trunc(start_date) <= add_months(
                            trunc(sysdate, 'YEAR'),
                            -24 + 11
                        ) + 30 )
                        or ( trunc(start_date) between add_months(
                            trunc(sysdate, 'YEAR'),
                            -24
                        ) and add_months(
                            trunc(sysdate, 'YEAR'),
                            -24 + 11
                        ) + 30
                             and trunc(pay_approved_date) < add_months(
                            trunc(sysdate, 'YEAR'),
                            -24
                        ) )
                    union all
                    select
                        *
                    from
                        broker_account_hsa_rev_mv
                    where
                        trunc(pay_approved_date) between add_months(
                            trunc(sysdate, 'YEAR'),
                            -24
                        ) and add_months(
                            trunc(sysdate, 'YEAR'),
                            -24 + 11
                        ) + 30
                )
            having
                sum(revenue_amount) > 0
            group by
                broker,
                broker_id,
                salesrep_id,
                salesrep_name,
                city,
                state,
                zip
            order by
                sum(revenue_amount) desc
        )
    union
    select
        36,
        extract(year from sysdate) - 3 year,
        count(distinct broker_id)      cnt
    from
        (
            select
                broker,
                broker_id,
                salesrep_id,
                salesrep_name,
                city,
                state,
                zip,
                ( sum(setup) + sum(setup_discount) + sum(setup_optional) ) as setup,
                ( sum(monthly) + sum(monthly_discount) )                   as monthly,
                sum(revenue_amount)                                        as sum_revenue,
                count(distinct(account_type))                              account_type_count,
                regexp_replace(
                    listagg(account_type, ',' on overflow truncate '...') within group(
                    order by
                        account_type
                    ),
                    '([^,]+)(,\1)*(,|$)',
                    '\1\3')                                     account_types
            from
                (
                    select
                        *
                    from
                        broker_account_nohsa_rev_mv
                    where
                        ( trunc(pay_approved_date) between add_months(
                            trunc(sysdate, 'YEAR'),
                            -36
                        ) and add_months(
                            trunc(sysdate, 'YEAR'),
                            -36 + 11
                        ) + 30
                          and trunc(start_date) <= add_months(
                            trunc(sysdate, 'YEAR'),
                            -36 + 11
                        ) + 30 )
                        or ( trunc(start_date) between add_months(
                            trunc(sysdate, 'YEAR'),
                            -36
                        ) and add_months(
                            trunc(sysdate, 'YEAR'),
                            -36 + 11
                        ) + 30
                             and trunc(pay_approved_date) < add_months(
                            trunc(sysdate, 'YEAR'),
                            -36
                        ) )
                    union all
                    select
                        *
                    from
                        broker_account_hsa_rev_mv
                    where
                        trunc(pay_approved_date) between add_months(
                            trunc(sysdate, 'YEAR'),
                            -36
                        ) and add_months(
                            trunc(sysdate, 'YEAR'),
                            -36 + 11
                        ) + 30
                )
            having
                sum(revenue_amount) > 0
            group by
                broker,
                broker_id,
                salesrep_id,
                salesrep_name,
                city,
                state,
                zip
            order by
                sum(revenue_amount) desc
        )
    union
    select
        48,
        extract(year from sysdate) - 4 year,
        count(distinct broker_id)      cnt
    from
        (
            select
                broker,
                broker_id,
                salesrep_id,
                salesrep_name,
                city,
                state,
                zip,
                ( sum(setup) + sum(setup_discount) + sum(setup_optional) ) as setup,
                ( sum(monthly) + sum(monthly_discount) )                   as monthly,
                sum(revenue_amount)                                        as sum_revenue,
                count(distinct(account_type))                              account_type_count,
                regexp_replace(
                    listagg(account_type, ',' on overflow truncate '...') within group(
                    order by
                        account_type
                    ),
                    '([^,]+)(,\1)*(,|$)',
                    '\1\3')                                     account_types
            from
                (
                    select
                        *
                    from
                        broker_account_nohsa_rev_mv
                    where
                        ( trunc(pay_approved_date) between add_months(
                            trunc(sysdate, 'YEAR'),
                            -48
                        ) and add_months(
                            trunc(sysdate, 'YEAR'),
                            -48 + 11
                        ) + 30
                          and trunc(start_date) <= add_months(
                            trunc(sysdate, 'YEAR'),
                            -48 + 11
                        ) + 30 )
                        or ( trunc(start_date) between add_months(
                            trunc(sysdate, 'YEAR'),
                            -48
                        ) and add_months(
                            trunc(sysdate, 'YEAR'),
                            -48 + 11
                        ) + 30
                             and trunc(pay_approved_date) < add_months(
                            trunc(sysdate, 'YEAR'),
                            -48
                        ) )
                    union all
                    select
                        *
                    from
                        broker_account_hsa_rev_mv
                    where
                        trunc(pay_approved_date) between add_months(
                            trunc(sysdate, 'YEAR'),
                            -48
                        ) and add_months(
                            trunc(sysdate, 'YEAR'),
                            -48 + 11
                        ) + 30
                )
            having
                sum(revenue_amount) > 0
            group by
                broker,
                broker_id,
                salesrep_id,
                salesrep_name,
                city,
                state,
                zip
            order by
                sum(revenue_amount) desc
        )
    union
    select
        60,
        extract(year from sysdate) - 5 year,
        count(distinct broker_id)      cnt
    from
        (
            select
                broker,
                broker_id,
                salesrep_id,
                salesrep_name,
                city,
                state,
                zip,
                ( sum(setup) + sum(setup_discount) + sum(setup_optional) ) as setup,
                ( sum(monthly) + sum(monthly_discount) )                   as monthly,
                sum(revenue_amount)                                        as sum_revenue,
                count(distinct(account_type))                              account_type_count,
                regexp_replace(
                    listagg(account_type, ',' on overflow truncate '...') within group(
                    order by
                        account_type
                    ),
                    '([^,]+)(,\1)*(,|$)',
                    '\1\3')                                     account_types
            from
                (
                    select
                        *
                    from
                        broker_account_nohsa_rev_mv
                    where
                        ( trunc(pay_approved_date) between add_months(
                            trunc(sysdate, 'YEAR'),
                            -60
                        ) and add_months(
                            trunc(sysdate, 'YEAR'),
                            -60 + 11
                        ) + 30
                          and trunc(start_date) <= add_months(
                            trunc(sysdate, 'YEAR'),
                            -60 + 11
                        ) + 30 )
                        or ( trunc(start_date) between add_months(
                            trunc(sysdate, 'YEAR'),
                            -60
                        ) and add_months(
                            trunc(sysdate, 'YEAR'),
                            -60 + 11
                        ) + 30
                             and trunc(pay_approved_date) < add_months(
                            trunc(sysdate, 'YEAR'),
                            -60
                        ) )
                    union all
                    select
                        *
                    from
                        broker_account_hsa_rev_mv
                    where
                        trunc(pay_approved_date) between add_months(
                            trunc(sysdate, 'YEAR'),
                            -60
                        ) and add_months(
                            trunc(sysdate, 'YEAR'),
                            -60 + 11
                        ) + 30
                )
            having
                sum(revenue_amount) > 0
            group by
                broker,
                broker_id,
                salesrep_id,
                salesrep_name,
                city,
                state,
                zip
            order by
                sum(revenue_amount) desc
        );

