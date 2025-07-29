create or replace force editionable view samqa.payment_source (
    pay_source,
    description
) as
    select
        lookup_code pay_source,
        description
    from
        lookups
    where
        lookup_name = 'PAYMENT_SOURCE';


-- sqlcl_snapshot {"hash":"4b0d85aea30889589e0ad83f2125ffa688d5c57e","type":"VIEW","name":"PAYMENT_SOURCE","schemaName":"SAMQA","sxml":""}