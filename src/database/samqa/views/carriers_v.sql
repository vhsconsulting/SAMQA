create or replace force editionable view samqa.carriers_v (
    carrier_id,
    carrier_name
) as
    select
        entrp_id carrier_id,
        name     carrier_name
    from
        enterprise
    where
        en_code = 3;


-- sqlcl_snapshot {"hash":"576738f4fef42b5f9694539ab5d756ec8a4dbb37","type":"VIEW","name":"CARRIERS_V","schemaName":"SAMQA","sxml":""}