create or replace force editionable view samqa.user_bank_acct_v (
    bank_acct_id,
    acc_num,
    display_name,
    bank_acct_type,
    bank_routing_num,
    bank_acct_num,
    bank_name,
    acc_id,
    status,
    bank_account_usage,
    inactive_reason,
    inactive_date,
    account_type,
    bank_acct_code,
    masked_bank_acct_num,
    business_name,
    last_updated_by,
    last_update_date,
    giac_verify,
    giac_authenticate,
    giac_response,
    giac_bank_account_verified
) as
    select
        bank_acct_id,
        acc_num,
        display_name,
        bank_acct_type,
        bank_routing_num,
        bank_acct_num,
        bank_name,
        b.acc_id,
        a.status,
        bank_account_usage,
        inactive_reason,
        inactive_date,
        b.account_type,
        a.bank_acct_code,
        masked_bank_acct_num,
        a.business_name,   -- Added by Swamy for Ticket#10978 06052024
        a.last_updated_by,  -- Added by Swamy for Ticket#10978 06052024
        a.last_update_date,  -- Added by Swamy for Ticket#10978 06052024
        a.giac_verify,        -- Added by Swamy for Ticket#10978 06052024
        a.giac_authenticate,  -- Added by Swamy for Ticket#12534
        a.giac_response,       -- Added by Swamy for Ticket#12534
        a.giac_bank_account_verified
    from
        user_bank_acct a,
        account        b
    where
        a.acc_id = b.acc_id;


-- sqlcl_snapshot {"hash":"1bf9badbe5a8d5e6ff196defcdf0e9be40a79c67","type":"VIEW","name":"USER_BANK_ACCT_V","schemaName":"SAMQA","sxml":""}