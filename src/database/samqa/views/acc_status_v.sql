create or replace force editionable view samqa.acc_status_v (
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


-- sqlcl_snapshot {"hash":"4b2ae8dbf611b334eb8e6896e20efc5580db3026","type":"VIEW","name":"ACC_STATUS_V","schemaName":"SAMQA","sxml":""}