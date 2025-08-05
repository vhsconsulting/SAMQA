create or replace force editionable view samqa.myincome_new (
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
            ( n.fee_date - trunc(n.fee_date, 'cc') ) * 1e6 + mod(n.change_num * 10, 1e6) as change_num,
    --    N.CHANGE_NUM,
            n.fee_date,
            n.fee_code,
            n.amount,
            n.contributor,
            e.name                                                                           as ent_name,
            ar.cur_amo - n.amount                                                            as pre_balance, -- new
            null                                                                             as pre_days,
            null                                                                             as interest_rate,
            substr(to_char(n.fee_date, 'Mon YYYY ', 'nls_date_language = AMERICAN')
                   || f.fee_name
                   || ', '
                   || n.note,
                   1,
                   40)                                                                       as description,
            null                                                                             as term
        from
            income_v   n,
            fee_names  f,
            enterprise e,
            accres     ar -- new
        where
                n.fee_code = f.fee_code (+)
            and n.contributor = e.entrp_id (+)
            and n.change_num = ar.change_num (+) -- new
    );


-- sqlcl_snapshot {"hash":"29928dd13498423cf10b07988ebf4a057488fb10","type":"VIEW","name":"MYINCOME_NEW","schemaName":"SAMQA","sxml":""}