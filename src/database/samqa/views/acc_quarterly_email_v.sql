create or replace force editionable view samqa.acc_quarterly_email_v (
    rn,
    email,
    acc_num,
    end_date,
    account_status,
    plan_code
) as
    select
        rownum    rn,
        email,
        p.acc_num,
        p.end_date,
        c.meaning account_status,
        p.plan_code
    from
        online_users u,
        account      p,
        lookups      c
    where
            user_type = 'S'
        and u.find_key = p.acc_num
        and p.account_status in ( 1, 2 )
        and c.lookup_code = p.account_status
        and c.lookup_name = 'ACCOUNT_STATUS'
        and u.user_status = 'A'
        and p.plan_code in ( 1, 2, 3 )
        and p.account_type = 'HSA'
    order by
        p.end_date asc;


-- sqlcl_snapshot {"hash":"78e0c3a4c1229a4d8c4922e92a08583f1598deb4","type":"VIEW","name":"ACC_QUARTERLY_EMAIL_V","schemaName":"SAMQA","sxml":""}