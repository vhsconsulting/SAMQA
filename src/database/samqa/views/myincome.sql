create or replace force editionable view samqa.myincome (
    acc_id,
    change_num,
    fee_date,
    fee_code,
    amount,
    contributor,
    ent_name,
    pre_balance,
    pre_days,
    interest_rate,
    description,
    term
) as
    (
        select
            n.acc_id,
            n.change_num as change_num,
            n.fee_date,
            n.fee_code,
            n.amount,
            n.contributor,
            e.name       as ent_name,
            0            as pre_balance, -- new
            null         as pre_days,
            null         as interest_rate,
            substr(to_char(n.fee_date, 'Mon YYYY ', 'nls_date_language = AMERICAN')
                   || f.fee_name
                   || ', '
                   || n.note,
                   1,
                   40)   as description,
            null         as term
        from
            income_v   n,
            fee_names  f,
            enterprise e
        where
                n.fee_code = f.fee_code (+)
            and n.contributor = e.entrp_id (+)
    );


-- sqlcl_snapshot {"hash":"d918329da76446dd7800629e13b9f174b27e3342","type":"VIEW","name":"MYINCOME","schemaName":"SAMQA","sxml":""}