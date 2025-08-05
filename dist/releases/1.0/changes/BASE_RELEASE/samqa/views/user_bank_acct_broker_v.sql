-- liquibase formatted sql
-- changeset SAMQA:1754374180093 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\user_bank_acct_broker_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/user_bank_acct_broker_v.sql:null:b02fa9da6286a3bde278bbe6241123786ebf27a7:create

create or replace force editionable view samqa.user_bank_acct_broker_v (
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
        entity_type = 'BROKER';

