create or replace force editionable view samqa.reimbursement_mode (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'REIMBURSEMENT_MODE';


-- sqlcl_snapshot {"hash":"6cb8ed42e97667ee9881395a330b99d354e9df63","type":"VIEW","name":"REIMBURSEMENT_MODE","schemaName":"SAMQA","sxml":""}