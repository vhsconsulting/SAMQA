create or replace force editionable view samqa.new_catchup_65_age_v (
    pers_id,
    acc_id,
    name,
    birth_date,
    acc_num,
    email_address
) as
    select
        a.pers_id,
        b.acc_id,
        a.first_name
        || ' '
        || a.last_name        name,
        a.birth_date,
        b.acc_num,
        nvl(c.email, a.email) email_address
    from
        person       a,
        account      b,
        online_users c,
        plans        d
    where
            trunc(months_between(sysdate, a.birth_date) / 12) = 64
        and mod(
            months_between(sysdate + 15, a.birth_date),
            12
        ) = 11
        and a.pers_id = b.pers_id
        and b.acc_num = c.find_key (+)
        and d.plan_code = b.plan_code
        and d.plan_sign = 'SHA'
        and b.account_type = 'HSA'
        and b.account_status <> 4;


-- sqlcl_snapshot {"hash":"1ded40f6521d0ce19ed14514912f008613e8eb6f","type":"VIEW","name":"NEW_CATCHUP_65_AGE_V","schemaName":"SAMQA","sxml":""}