create or replace force editionable view samqa.pay_source (
    pay_source_code,
    pay_source_name
) as
    select
        lookup_code pay_source_code,
        meaning     pay_source_name
    from
        lookups
    where
        lookup_name = 'PAY_SOURCE';


-- sqlcl_snapshot {"hash":"66eaae24e738f69acc0ec2b4a3f6e0e5a485718e","type":"VIEW","name":"PAY_SOURCE","schemaName":"SAMQA","sxml":""}