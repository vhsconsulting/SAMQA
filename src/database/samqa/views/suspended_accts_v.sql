create or replace force editionable view samqa.suspended_accts_v (
    pers_id,
    plan_code,
    acc_id,
    cur_bal,
    activedays,
    email,
    acc_num
) as
    select
        a.pers_id,
        a.plan_code,
        a.acc_id,
        pc_account.acc_balance(a.acc_id, '01-JAN-2004', sysdate) cur_bal,
        round(sysdate - trunc(suspended_date))                   activedays,
        nvl(
            pc_users.get_email(a.acc_num, a.acc_id, a.pers_id),
            c.email
        )                                                        email,
        a.acc_num
    from
        account a,
        person  c,
        plans   d
    where
            c.pers_id = a.pers_id
        and d.plan_code = a.plan_code
        and d.plan_sign = 'SHA'
        and a.account_type = 'HSA'
        and c.pers_id is not null
        and a.account_status = 2;


-- sqlcl_snapshot {"hash":"4a2b9e0fe4b8faeb79a9463cfc5dec607d97e90c","type":"VIEW","name":"SUSPENDED_ACCTS_V","schemaName":"SAMQA","sxml":""}