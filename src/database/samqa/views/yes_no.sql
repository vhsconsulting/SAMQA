create or replace force editionable view samqa.yes_no (
    yes_no_code,
    yes_no_meaning
) as
    select
        lookup_code yes_no_code,
        meaning     yes_no_meaning
    from
        lookups
    where
        lookup_name = 'YES_NO';


-- sqlcl_snapshot {"hash":"e8fe0626ad9588423bed87f63990dd5616220000","type":"VIEW","name":"YES_NO","schemaName":"SAMQA","sxml":""}