-- liquibase formatted sql
-- changeset SAMQA:1754374169142 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\broker_renewal_rev_hsa_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/broker_renewal_rev_hsa_v.sql:null:b269b979bd94886c6f4f7b4497b0443166b89897:create

create or replace force editionable view samqa.broker_renewal_rev_hsa_v (
    amount,
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
) as
    select
        p.amount,
        d.account_type,
        d.broker_id,
        p.pay_date pay_approved_date,
        null       as start_date,
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
        p.amount,
        d.account_type,
        d.broker_id,
        p.pay_date pay_approved_date,
        null       as start_date,
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

