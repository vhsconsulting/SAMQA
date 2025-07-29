create or replace force editionable view samqa.pay_period (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'ACC_PAY_PERIOD';


-- sqlcl_snapshot {"hash":"762d008978c0ffbae311d2228fa238387e4e46bc","type":"VIEW","name":"PAY_PERIOD","schemaName":"SAMQA","sxml":""}