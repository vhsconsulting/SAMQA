create or replace force editionable view samqa.claim_deny_code (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'CLAIM_DENY_CODE';


-- sqlcl_snapshot {"hash":"c00f2d19854bdc448fe4c845b0073d8e11e26316","type":"VIEW","name":"CLAIM_DENY_CODE","schemaName":"SAMQA","sxml":""}