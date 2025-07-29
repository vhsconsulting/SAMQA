create or replace force editionable view samqa.account_status_v (
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


-- sqlcl_snapshot {"hash":"a6d575a7444e1cc5cdd04875f0c7f1bb7842003f","type":"VIEW","name":"ACCOUNT_STATUS_V","schemaName":"SAMQA","sxml":""}