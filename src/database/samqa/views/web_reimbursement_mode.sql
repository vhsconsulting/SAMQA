create or replace force editionable view samqa.web_reimbursement_mode (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'WEB_REIMBURSEMENT_MODE';


-- sqlcl_snapshot {"hash":"b13952c371e298048c3f95a6396c7620d1faa7c1","type":"VIEW","name":"WEB_REIMBURSEMENT_MODE","schemaName":"SAMQA","sxml":""}