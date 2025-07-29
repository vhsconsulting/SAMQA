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


-- sqlcl_snapshot {"hash":"e62cc7ed4c6131cde806400ec57e27ff4eded2b2","type":"MATERIALIZED_VIEW","name":"BROKER_ACCOUNT_NS_REV_5YR","schemaName":"SAMQA","sxml":"\n  <MATERIALIZED_VIEW xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BROKER_ACCOUNT_NS_REV_5YR</NAME>\n   <COL_LIST>\n      <COL_LIST_ITEM>\n         <NAME>0</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>YEAR</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>CNT</NAME>\n      </COL_LIST_ITEM>\n   </COL_LIST>\n   <DEFAULT_COLLATION>USING_NLS_COMP</DEFAULT_COLLATION>\n   <PHYSICAL_PROPERTIES>\n      <HEAP_TABLE></HEAP_TABLE>\n   </PHYSICAL_PROPERTIES>\n   <BUILD>IMMEDIATE</BUILD>\n   <REFRESH>\n      <LOCAL_ROLLBACK_SEGMENT>\n         <DEFAULT></DEFAULT>\n      </LOCAL_ROLLBACK_SEGMENT>\n      <CONSTRAINTS>ENFORCED</CONSTRAINTS>\n   </REFRESH>\n   \n</MATERIALIZED_VIEW>"}