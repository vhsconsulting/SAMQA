create or replace force editionable view samqa.bank_account_type (
    bank_acct_type,
    bank_acct_name
) as
    select
        lookup_code bank_acct_type,
        meaning     bank_acct_name
    from
        lookups
    where
        lookup_name = 'BANK_ACCOUNT_TYPE';


-- sqlcl_snapshot {"hash":"dc19f4a70fe984b5d4e4b3553bd584f511ea29a6","type":"VIEW","name":"BANK_ACCOUNT_TYPE","schemaName":"SAMQA","sxml":""}