create or replace force editionable view samqa.beneficiary_type (
    ben_type_code,
    ben_type
) as
    select
        lookup_code ben_type_code,
        meaning     ben_type
    from
        lookups
    where
        lookup_name = 'BENEFICIARY_TYPE';


-- sqlcl_snapshot {"hash":"ffb2cf35f911a4930d59c79902457800686fc013","type":"VIEW","name":"BENEFICIARY_TYPE","schemaName":"SAMQA","sxml":""}