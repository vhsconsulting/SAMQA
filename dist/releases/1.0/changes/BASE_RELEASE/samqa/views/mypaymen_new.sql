-- liquibase formatted sql
-- changeset SAMQA:1754374177224 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\mypaymen_new.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/mypaymen_new.sql:null:90f27efa95ef0a67aae0a7aac871da40ff80a196:create

create or replace force editionable view samqa.mypaymen_new (
    acc_id,
    group_n,
    change_num,
    pay_date,
    amount,
    reason_code,
    pay_num,
    payee_name,
    service_date,
    pre_balance,
    pre_days,
    interest_rate,
    description,
    qq,
    qn,
    nn,
    term
) as
    (
        select
            y.acc_id,
            ae.acc_num                                                                  as group_n,
            ( y.pay_date - trunc(y.pay_date, 'cc') ) * 1e6 + mod(y.change_num, 1e6) as change_num,
            y.pay_date,
            y.amount,
            y.reason_code,
            y.pay_num,
    -- DECODE( what??? NULL, 'Subscriber', c.PROV_NAME)
            c.prov_name                                                                 as payee_name,
            c.claim_date_start                                                          as service_date,
            ar.cur_amo + y.amount                                                       as pre_balance -- new, was NULL
            ,
            null                                                                        as pre_days,
            null                                                                        as interest_rate,
            substr(to_char(pay_date, 'Mon YYYY ', 'nls_date_language = AMERICAN')
                   || reason_name
                   || ', '
                   || y.note,
                   1,
                   40)                                                                  as description,
            y.amount * decode(service_status, 1, 1, 0)                                  as qq,
            y.amount * decode(service_status, 2, 1, 0)                                  as qn,
            y.amount * decode(service_status, 1, 0, 2, 0,
                              1)                                                                          as nn,
            null                                                                        as term
        from
            payment    y,
            pay_reason r,
            person     p,
            claimn     c,
            account    a,
            account    ae,
            accres     ar
        where
                y.acc_id = a.acc_id           -- Pay from person account
            and a.pers_id = p.pers_id         -- Person has account
            and y.reason_code = r.reason_code -- Pay has reason
            and p.entrp_id = ae.entrp_id (+)  -- Person's Enterprise may has account
            and y.claimn_id = c.claim_id (+)  -- Pay may refer to claim
            and y.change_num = ar.change_num (+) -- take balance from accres
    );

