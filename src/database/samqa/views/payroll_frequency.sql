create or replace force editionable view samqa.payroll_frequency (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'PAYROLL_FREQUENCY';


-- sqlcl_snapshot {"hash":"8581fc4833d1f7792f3c17eff79ffbf0dd804ff6","type":"VIEW","name":"PAYROLL_FREQUENCY","schemaName":"SAMQA","sxml":""}