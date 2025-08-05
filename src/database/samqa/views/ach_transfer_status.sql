create or replace force editionable view samqa.ach_transfer_status (
    status_code,
    status
) as
    select
        lookup_code status_code,
        meaning     status
    from
        lookups
    where
        lookup_name = 'ACH_TRANSFER_STATUS';


-- sqlcl_snapshot {"hash":"f467d6d74c1cb657dd2ab97ef22682228311f152","type":"VIEW","name":"ACH_TRANSFER_STATUS","schemaName":"SAMQA","sxml":""}