create or replace force editionable view samqa.ag_v (
    low,
    age,
    gender,
    cnt,
    balance
) as
    (
        select
            low,
            age,
            gender,
            count(*) cnt,
            sum(bal) balance
        from
            agender,
            (
                select
                    gender,
                    round((sysdate - birth_date) / 365.25) as let,
                    pc_person.acc_balance(p.pers_id)       as bal
                from
                    person  p,
                    account a
                where
                        p.pers_id = a.pers_id
                    and a.account_type = 'HSA'
                    and a.account_status in ( 1, 3 )
            )
        where
            nvl(let, -1) between low and hi
        group by
            low,
            age,
            gender
    );


-- sqlcl_snapshot {"hash":"26adb0ced9135302a119d77f68e69e1802e05b0a","type":"VIEW","name":"AG_V","schemaName":"SAMQA","sxml":""}