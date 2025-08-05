create or replace force editionable view samqa.bank_acct_usage (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'BANK_ACCT_USAGE';


-- sqlcl_snapshot {"hash":"7e38bbb8132882636242b43af2e79f65f2262a40","type":"VIEW","name":"BANK_ACCT_USAGE","schemaName":"SAMQA","sxml":""}