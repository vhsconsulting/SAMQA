create or replace force editionable view samqa.claim_medical_codes (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'CLAIM_MEDICAL_CODES';


-- sqlcl_snapshot {"hash":"4279e7666603607df76ed9b8cdfc14814b3c44a5","type":"VIEW","name":"CLAIM_MEDICAL_CODES","schemaName":"SAMQA","sxml":""}