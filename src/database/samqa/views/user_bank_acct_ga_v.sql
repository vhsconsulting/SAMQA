create or replace force editionable view samqa.user_bank_acct_ga_v (
    bank_acct_id,
    entity_id,
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
    giac_verify
) as
    select
        bank_acct_id,
        entity_id,
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
        giac_verify
    from
        bank_accounts
    where
        entity_type = 'GA';


-- sqlcl_snapshot {"hash":"f5a17827a5be28281f7b499d6be978e44e741f58","type":"VIEW","name":"USER_BANK_ACCT_GA_V","schemaName":"SAMQA","sxml":""}