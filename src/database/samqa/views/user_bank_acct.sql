create or replace force editionable view samqa.user_bank_acct (
    bank_acct_id,
    acc_id,
    entity_type,
    display_name,
    bank_acct_type,
    bank_routing_num,
    bank_acct_num,
    bank_name,
    status,
    bank_account_usage,
    authorized_by,
    note,
    inactive_reason,
    inactive_date,
    bank_acct_code,
    creation_date,
    created_by,
    last_updated_by,
    last_update_date,
    masked_bank_acct_num,
    source,
    bank_acct_verified,
    business_name,
    giac_verify,
    giac_authenticate,
    giac_response,
    giac_bank_account_verified
) as
    select
        bank_acct_id,
        entity_id acc_id,
        entity_type,
        display_name,
        bank_acct_type,
        bank_routing_num,
        bank_acct_num,
        bank_name,
        status,
        bank_account_usage,
        authorized_by,
        note,
        inactive_reason,
        inactive_date,
        bank_acct_code,
        creation_date,
        created_by,
        last_updated_by,
        last_update_date,
        masked_bank_acct_num,
        source,
        bank_acct_verified,
        business_name,
        giac_verify -- Added by Swamy for Ticket#10978 06052024
        ,
        giac_authenticate,
        giac_response   -- Added by Swamy for Ticket#12534
        ,
        giac_bank_account_verified
    from
        bank_accounts
    where
        entity_type = 'ACCOUNT';


-- sqlcl_snapshot {"hash":"fc9f8954bc866b9ae99b91d5fa01abd1d2322911","type":"VIEW","name":"USER_BANK_ACCT","schemaName":"SAMQA","sxml":""}