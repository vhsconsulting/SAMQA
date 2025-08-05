-- liquibase formatted sql
-- changeset SAMQA:1754374159690 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\invoice_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/invoice_external.sql:null:2e6aa4018c8bf1a2e3baec24b5a4fd9848219199:create

create table samqa.invoice_external (
    acc_num        varchar2(20 byte),
    start_date     varchar2(20 byte),
    end_date       varchar2(20 byte),
    invoice_date   varchar2(20 byte),
    invoice_amount varchar2(255 byte),
    account_type   varchar2(30 byte),
    reason_name    varchar2(255 byte)
)
organization external ( type oracle_loader
    default directory invoice_upload_dir access parameters (
        records delimited by newline
            skip 1
            badfile 'Upload_Invoice_Template.csv.bad'
            logfile 'Upload_Invoice_Template.csv.log'
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( invoice_upload_dir : 'Upload_Invoice_Template.csv' )
) reject limit 0;

