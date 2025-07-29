create or replace force editionable view samqa.myinvest (
    id,
    acc_id,
    invest_id,
    invest_name,
    invest_acc,
    invest_date,
    invest_amount,
    note
) as
    (
        select
            ' ',
            i.acc_id,
            i.invest_id,
            e.name,
            i.invest_acc,
            t.invest_date,
            t.invest_amount,
            t.note
        from
            invest_transfer t,
            investment      i,
            enterprise      e
        where
                t.investment_id = i.investment_id
            and i.invest_id = e.entrp_id
    );


-- sqlcl_snapshot {"hash":"0e736bcec33222841729ad7aeed00f3398f4f23d","type":"VIEW","name":"MYINVEST","schemaName":"SAMQA","sxml":""}