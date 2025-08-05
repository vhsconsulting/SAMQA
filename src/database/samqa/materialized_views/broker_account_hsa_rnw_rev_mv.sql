create materialized view samqa.broker_account_hsa_rnw_rev_mv (
    revenue_amount,
    account_type,
    broker_id,
    pay_approved_date,
    start_date,
    salesrep_id,
    broker,
    city,
    state,
    zip,
    salesrep_name
) build immediate using index
    refresh force
    on demand
    using enforced constraints
    disable on query computation
    disable query rewrite
as
    select
        p.amount   as revenue_amount,
        d.account_type,
        d.broker_id,
        p.pay_date pay_approved_date,
        p.pay_date as start_date,
        br.salesrep_id,
        replace(
            trim(per.first_name
                 || ' '
                 || per.last_name),
            '  ',
            ' '
        )          as broker,
        per.city,
        per.state,
        per.zip,
        s.name     as salesrep_name			
            --,pc_sales_team.get_sales_rep_name(br.salesrep_id) "SALES"
    from
        person   a,
        person   per,
        broker   br,
        account  d,
        payment  p,
        account  er,
        salesrep s
    where
            d.account_type = 'HSA'
        and d.pers_id = a.pers_id
        and p.acc_id = d.acc_id
        and a.entrp_id = er.entrp_id
        and d.broker_id = br.broker_id
        and br.broker_id = per.pers_id
            --AND ( br.broker_id = :p90_broker OR :p90_broker IS NULL )
        and a.entrp_id is not null
            --AND trunc(p.pay_date) BETWEEN trunc(TO_DATE(:p90_start_date, 'MM/DD/YYYY')) AND trunc(TO_DATE(:p90_end_date, 'MM/DD/YYYY'))
        and p.reason_code in ( 2, 100 )
        and months_between(pay_date, er.start_date) > 12
        and br.salesrep_id = s.salesrep_id (+)
    union all
    select
        p.amount   as revenue_amount,
        d.account_type,
        d.broker_id,
        p.pay_date pay_approved_date,
        p.pay_date as start_date,
        br.salesrep_id,
        replace(
            trim(per.first_name
                 || ' '
                 || per.last_name),
            '  ',
            ' '
        )          as broker,
        per.city,
        per.state,
        per.zip,
        s.name     as salesrep_name
			--,pc_sales_team.get_sales_rep_name(br.salesrep_id) "SALES"
    from
        person   a,
        person   per,
        broker   br,
        account  d,
        payment  p,
        salesrep s
    where
            d.account_type = 'HSA'
        and d.pers_id = a.pers_id
        and p.acc_id = d.acc_id
        and d.broker_id = br.broker_id
        and br.broker_id = per.pers_id
            --AND ( br.broker_id = :p90_broker OR :p90_broker IS NULL )                 
        and a.entrp_id is null
            --AND trunc(p.pay_date) BETWEEN trunc(TO_DATE(:p90_start_date, 'MM/DD/YYYY')) AND trunc(TO_DATE(:p90_end_date, 'MM/DD/YYYY'))
        and p.reason_code in ( 2, 100 )
        and br.salesrep_id = s.salesrep_id (+);


-- sqlcl_snapshot {"hash":"3694254d24eb9103196a51a0529c71f5e7705161","type":"MATERIALIZED_VIEW","name":"BROKER_ACCOUNT_HSA_RNW_REV_MV","schemaName":"SAMQA","sxml":"\n  <MATERIALIZED_VIEW xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BROKER_ACCOUNT_HSA_RNW_REV_MV</NAME>\n   <COL_LIST>\n      <COL_LIST_ITEM>\n         <NAME>REVENUE_AMOUNT</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>ACCOUNT_TYPE</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>BROKER_ID</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>PAY_APPROVED_DATE</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>START_DATE</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>SALESREP_ID</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>BROKER</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>CITY</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>STATE</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>ZIP</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>SALESREP_NAME</NAME>\n      </COL_LIST_ITEM>\n   </COL_LIST>\n   <DEFAULT_COLLATION>USING_NLS_COMP</DEFAULT_COLLATION>\n   <PHYSICAL_PROPERTIES>\n      <HEAP_TABLE></HEAP_TABLE>\n   </PHYSICAL_PROPERTIES>\n   <BUILD>IMMEDIATE</BUILD>\n   <REFRESH>\n      <LOCAL_ROLLBACK_SEGMENT>\n         <DEFAULT></DEFAULT>\n      </LOCAL_ROLLBACK_SEGMENT>\n      <CONSTRAINTS>ENFORCED</CONSTRAINTS>\n   </REFRESH>\n   \n</MATERIALIZED_VIEW>"}