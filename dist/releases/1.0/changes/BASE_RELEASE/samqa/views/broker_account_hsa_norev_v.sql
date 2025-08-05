-- liquibase formatted sql
-- changeset SAMQA:1754374168785 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\broker_account_hsa_norev_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/broker_account_hsa_norev_v.sql:null:48daf14b44c25e7d7a088cdedd4aef37950fecfc:create

create or replace force editionable view samqa.broker_account_hsa_norev_v (
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
) as
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
                case
                    when a.salesrep_id is not null
                         and a.salesrep_id != 0 then
                        a.salesrep_id
                    else
                        bk.salesrep_id
                end        salesrep_id,
                replace(
                    trim(broker.first_name
                         || ' '
                         || broker.last_name),
                    '  ',
                    ' '
                )          as broker,
                0          as monthly_discount,
                0          as setup_discount,
                0          as setup_optional,
                case
                    when p.reason_code = 100 then
                        p.amount
                    else
                        0
                end        setup,
                case
                    when p.reason_code = 2 then
                        p.amount
                    else
                        0
                end        monthly,
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
                )          as revenue_amount,
                p.pay_date as pay_approved_date,
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
            q.salesrep_id = s.salesrep_id (+)
        and ( monthly_discount + setup_discount + setup + setup_optional + monthly + revenue_amount = 0 );

