create or replace force editionable view samqa.er_reimbursement_type (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'ER_REIMBURSEMENT_TYPE';


-- sqlcl_snapshot {"hash":"5b77841226b4243e4110e33a44f44d11b398baf7","type":"VIEW","name":"ER_REIMBURSEMENT_TYPE","schemaName":"SAMQA","sxml":""}