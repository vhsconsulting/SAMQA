create or replace force editionable view samqa.beneficiary_v (
    pers_id,
    beneficiary_name,
    relat_code,
    effective_date,
    distribution,
    beneficiary_type
) as
    select
        pers_id,
        beneficiary_name,
        relat_code,
        effective_date,
        distribution,
        meaning beneficiary_type
    from
        beneficiary a,
        lookups     b
    where
            a.beneficiary_type = b.lookup_code
        and b.lookup_name = 'BENEFICIARY_TYPE'
        and a.effective_end_date is null;


-- sqlcl_snapshot {"hash":"41da32ec1e73a79793a2595e614c8e84850c1416","type":"VIEW","name":"BENEFICIARY_V","schemaName":"SAMQA","sxml":""}