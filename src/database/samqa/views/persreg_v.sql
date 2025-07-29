create or replace force editionable view samqa.persreg_v (
    pers_id,
    reg_date,
    account,
    plan,
    subscriber_name,
    age,
    county,
    broker,
    health_carrier
) as
    (
        select
            p.pers_id,
            a.reg_date,
            a.acc_num                                    as account,
            substr(l.plan_name, 1, 1)                    as plan,
            pc_person.pers_fld(p.pers_id, 'full_name')   as subscriber_name,
            round((sysdate - birth_date) / 365.25)       as age,
            p.city
            || ' '
            || p.county                                  as county,
            pc_person.pers_fld(a.broker_id, 'full_name') as broker,
            substr(e.name, 1, 11)                        as health_carrier
        from
            person     p,
            account    a,
            insure     i,
            plans      l,
            enterprise e
        where
                p.pers_id = a.pers_id
            and a.account_status <> 5
            and p.pers_id = i.pers_id
            and a.plan_code = l.plan_code
            and i.insur_id = e.entrp_id
    );


-- sqlcl_snapshot {"hash":"cb1d24db14ac1ecfa503ab63826536243e8b6ccc","type":"VIEW","name":"PERSREG_V","schemaName":"SAMQA","sxml":""}