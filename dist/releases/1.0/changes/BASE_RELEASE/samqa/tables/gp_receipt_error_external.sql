-- liquibase formatted sql
-- changeset SAMQA:1754374159214 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\gp_receipt_error_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/gp_receipt_error_external.sql:null:19295ed9e22d4cfe3362e9f30c4814d6c0e86247:create

create table samqa.gp_receipt_error_external (
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
    error_message varchar2(255 byte)
)
organization

