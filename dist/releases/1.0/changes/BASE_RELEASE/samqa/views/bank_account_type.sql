-- liquibase formatted sql
-- changeset SAMQA:1754374168348 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\bank_account_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/bank_account_type.sql:null:dc19f4a70fe984b5d4e4b3553bd584f511ea29a6:create

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

