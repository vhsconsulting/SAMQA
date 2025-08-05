create or replace force editionable view samqa.agc_v (
    low,
    age,
    male,
    female,
    na,
    total,
    balance
) as
    (
        select
            low,
            age,
            sum(cm)                     as male,
            sum(cf)                     as female,
            sum(cn)                     as na,
            sum(cm) + sum(cf) + sum(cn) as total,
            sum(balance)                as "Balance"
        from
            (
                select
                    low,
                    age,
                    cnt as cm,
                    0   as cf,
                    0   as cn,
                    balance
                from
                    ag_v
                where
                    gender = 'M'
                union all
                select
                    low,
                    age,
                    0,
                    cnt,
                    0,
                    balance
                from
                    ag_v
                where
                    gender = 'F'
                union all
                select
                    low,
                    age,
                    0,
                    0,
                    cnt,
                    balance
                from
                    ag_v
                where
                    gender is null
            )
        group by
            low,
            age
    );


-- sqlcl_snapshot {"hash":"e00db9526dc877a2a8caf4f460c99866de54b152","type":"VIEW","name":"AGC_V","schemaName":"SAMQA","sxml":""}