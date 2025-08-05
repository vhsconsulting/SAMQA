create or replace force editionable view samqa.bal_rate (
    bank,
    low,
    hi,
    rate,
    dfrom,
    active,
    note
) as
    (
        select
            bank_code,
            low_balance,
            high_balance,
            interest_rate,
            effective_date,
            active,
            notes
        from
            bank_rate
    )
with check option;


-- sqlcl_snapshot {"hash":"0720b9f83e3c0a7aa09831895d7a7031dcec0c0d","type":"VIEW","name":"BAL_RATE","schemaName":"SAMQA","sxml":""}