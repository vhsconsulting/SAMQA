-- liquibase formatted sql
-- changeset SAMQA:1754374151926 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\bank_accounts_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/bank_accounts_external.sql:null:655a28fde4c8a15e0a3d0c23241d33cce971b25a:create

create table samqa.bank_accounts_external (
    acc_num            varchar2(20 byte),
    bank_name          varchar2(255 byte),
    display_name       varchar2(255 byte),
    bank_routing_num   varchar2(9 byte),
    bank_acct_num      varchar2(20 byte),
    bank_account_usage varchar2(30 byte),
    bank_acct_type     varchar2(15 byte)
)
organization external ( type oracle_loader
    default directory invoice_upload_dir access parameters (
        records delimited by newline
            skip 1
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( invoice_upload_dir : 'USER_bank_upload.csv' )
) reject limit 0;

