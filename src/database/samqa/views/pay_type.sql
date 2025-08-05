create or replace force editionable view samqa.pay_type (
    lookup_name,
    pay_code,
    pay_name
) as
    select
        lookup_name,
        lookup_code pay_code,
        meaning     pay_name
    from
        lookups
    where
        lookup_name = 'PAY_TYPE';


-- sqlcl_snapshot {"hash":"b946ef1904710c505af2db274b472058e7d10329","type":"VIEW","name":"PAY_TYPE","schemaName":"SAMQA","sxml":""}