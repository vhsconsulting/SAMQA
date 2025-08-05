-- liquibase formatted sql
-- changeset SAMQA:1754374177189 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\mypaymen.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/mypaymen.sql:null:a932d0211a118532ba7bcd67dfea7dab7f2735b0:create

create or replace force editionable view samqa.mypaymen (
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
    select
        y.acc_id,
        ae.acc_num                                 as group_n,
        y.change_num                               as change_num,
        y.pay_date,
        nvl(y.amount, 0)                           amount,
        y.reason_code,
        y.pay_num,
        c.prov_name                                as payee_name,
        c.claim_date_start                         as service_date,
        y.cur_bal + y.amount                       as pre_balance -- new, was NULL
        ,
        null                                       as pre_days,
        null                                       as interest_rate,
        substr(to_char(pay_date, 'Mon YYYY ', 'nls_date_language = AMERICAN')
               || reason_name
               || ', '
               || y.note,
               1,
               40)                                 as description,
        y.amount * decode(service_status, 1, 1, 0) as qq,
        y.amount * decode(service_status, 2, 1, 0) as qn,
        y.amount * decode(service_status, 1, 0, 2, 0,
                          1)                                         as nn,
        null                                       as term
    from
        payment    y,
        pay_reason r,
        person     p,
        claimn     c,
        account    a,
        account    ae
    where
            y.acc_id = a.acc_id           -- Pay from person account
        and a.pers_id = p.pers_id         -- Person has account
        and y.reason_code = r.reason_code -- Pay has reason
        and p.entrp_id = ae.entrp_id (+)  -- Person's Enterprise may has account
        and y.claimn_id = c.claim_id (+)  -- Pay may refer to claim  
    union
    select
        y.acc_id,
        ae.acc_num      as group_n,
        y.change_id     as change_num,
        y.fee_date,
        nvl(
            abs(y.amount),
            0
        )               amount,
        to_number(y.reason_code),
        to_number(null) pay_num,
        to_char(null)   as payee_name,
        y.fee_date      as service_date,
        0               as pre_balance,
        to_number(null) as pre_days,
        to_number(null) as interest_rate,
        reason_name     as description,
        0               as qq,
        0               as qn,
        y.amount        as nn,
        null            as term
    from
        balance_register y,
        pay_reason       r,
        person           p,
        account          a,
        account          ae
    where
            y.acc_id = a.acc_id           -- Pay from person account
        and a.pers_id = p.pers_id         -- Person has account
        and y.reason_code = r.reason_code -- Pay has reason
        and p.entrp_id = ae.entrp_id (+)  -- Person's Enterprise may has account
        and y.reason_mode = 'D';

