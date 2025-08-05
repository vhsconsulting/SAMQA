-- liquibase formatted sql
-- changeset SAMQA:1754374159233 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\gp_receipt_result_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/gp_receipt_result_external.sql:null:c5e53bc4f26be7c5a44be9750118677221389959:create

create table samqa.gp_receipt_result_external (
    batch_number  varchar2(255 byte),
    entityid      varchar2(255 byte),
    docdate       varchar2(255 byte),
    txn_amount    varchar2(255 byte),
    paytype       varchar2(255 byte),
    checkbook_id  varchar2(255 byte),
    check_number  varchar2(255 byte),
    description   varchar2(255 byte),
    invoice_id    varchar2(255 byte),
    record_number varchar2(255 byte),
    error_message varchar2(4000 byte)
)
organization external ( type oracle_loader
    default directory gp access parameters (
        records delimited by'\r\n'
            badfile gp : 'GP_RECEIPT_RESULT_EXTERNAL.bad'
            logfile gp : 'GP_RECEIPT_RESULT_EXTERNAL.log'
            skip 1
        fields terminated by ',' optionally enclosed by '"' missing field values are null
    ) location ( gp : 'GP_6303623_ach_receipt100417_ERRORS.csv' )
) reject limit unlimited;

