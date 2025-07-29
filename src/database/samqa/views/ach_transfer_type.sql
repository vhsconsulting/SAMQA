create or replace force editionable view samqa.ach_transfer_type (
    transfer_type,
    transfer_name
) as
    select
        lookup_code transfer_type,
        meaning     transfer_name
    from
        lookups
    where
        lookup_name = 'ACH_TRANSFER_TYPE';


-- sqlcl_snapshot {"hash":"1a8b770dc1e8d3102898b2b5c13d1d509010bf7c","type":"VIEW","name":"ACH_TRANSFER_TYPE","schemaName":"SAMQA","sxml":""}