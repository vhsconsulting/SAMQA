create materialized view samqa.broker_account_hsa_rev_mv (
    acc_id,
    account_type,
    broker_id,
    salesrep_id,
    broker,
    monthly_discount,
    setup_discount,
    setup,
    setup_optional,
    monthly,
    revenue_amount,
    pay_approved_date,
    start_date,
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
        q.acc_id,
        q.account_type,
        q.broker_id,
        nvl(q.salesrep_id, 0) salesrep_id,
        q.broker,
        q.monthly_discount,
        q.setup_discount,
        q.setup,
        q.setup_optional,
        q.monthly,
        q.revenue_amount,
        q.pay_approved_date,
        q.start_date,
        q.city,
        q.state,
        q.zip,
        s.name                as salesrep_name
    from
        (
            select
                a.acc_id,
                a.account_type,
                a.broker_id,
    /* case when a.salesrep_id is not null and a.salesrep_id != 0 then a.salesrep_id
            else bk.salesrep_id  end */
                bk.salesrep_id as salesrep_id,
                replace(
                    trim(broker.first_name
                         || ' '
                         || broker.last_name),
                    '  ',
                    ' '
                )              as broker,
                0              as monthly_discount,
                0              as setup_discount,
                0              as setup_optional,
                case
                    when p.reason_code = 100 then
                        p.amount
                    else
                        0
                end            setup,
                case
                    when p.reason_code = 2 then
                        p.amount
                    else
                        0
                end            monthly,
                case
                    when p.reason_code = 100 then
                            p.amount
                    else
                        0
                end
                + (
                    case
                        when p.reason_code = 2 then
                            p.amount
                        else
                            0
                    end
                )              as revenue_amount,
                p.pay_date     as pay_approved_date,
                er.start_date,
                broker.city,
                broker.state,
                broker.zip
            from
                person  pers,
                account a,
                payment p,
                account er,
                person  broker,
                broker  bk
            where
                    a.account_type = 'HSA'
                and a.pers_id = pers.pers_id
                and p.acc_id = a.acc_id
                and pers.entrp_id = er.entrp_id
                and pers.entrp_id is not null
                and p.reason_code in ( 2, 100 )
                and months_between(pay_date, er.start_date) <= 12
                and a.broker_id = broker.pers_id (+)
                and a.broker_id = bk.broker_id
        )        q,
        salesrep s
    where
        q.salesrep_id = s.salesrep_id (+);


-- sqlcl_snapshot {"hash":"f79225cb3caba6583dd92ec7502f7feaf52962c2","type":"MATERIALIZED_VIEW","name":"BROKER_ACCOUNT_HSA_REV_MV","schemaName":"SAMQA","sxml":"\n  <MATERIALIZED_VIEW xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BROKER_ACCOUNT_HSA_REV_MV</NAME>\n   <COL_LIST>\n      <COL_LIST_ITEM>\n         <NAME>ACC_ID</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>ACCOUNT_TYPE</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>BROKER_ID</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>SALESREP_ID</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>BROKER</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>MONTHLY_DISCOUNT</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>SETUP_DISCOUNT</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>SETUP</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>SETUP_OPTIONAL</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>MONTHLY</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>REVENUE_AMOUNT</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>PAY_APPROVED_DATE</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>START_DATE</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>CITY</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>STATE</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>ZIP</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>SALESREP_NAME</NAME>\n      </COL_LIST_ITEM>\n   </COL_LIST>\n   <DEFAULT_COLLATION>USING_NLS_COMP</DEFAULT_COLLATION>\n   <PHYSICAL_PROPERTIES>\n      <HEAP_TABLE></HEAP_TABLE>\n   </PHYSICAL_PROPERTIES>\n   <BUILD>IMMEDIATE</BUILD>\n   <REFRESH>\n      <LOCAL_ROLLBACK_SEGMENT>\n         <DEFAULT></DEFAULT>\n      </LOCAL_ROLLBACK_SEGMENT>\n      <CONSTRAINTS>ENFORCED</CONSTRAINTS>\n   </REFRESH>\n   \n</MATERIALIZED_VIEW>"}