create or replace force editionable view samqa.account_status (
    status_code,
    status
) as
    select
        lookup_code status_code,
        meaning     status
    from
        lookups
    where
        lookup_name = 'ACCOUNT_STATUS';


-- sqlcl_snapshot {"hash":"780656b818d634243976f078a26b316c16f61ed9","type":"VIEW","name":"ACCOUNT_STATUS","schemaName":"SAMQA","sxml":""}