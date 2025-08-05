-- liquibase formatted sql
-- changeset SAMQA:1754374159043 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\gp_fee_error_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/gp_fee_error_external.sql:null:e31fdb28d577508687c52bbc6d2ac1995d35c379:create

create table samqa.gp_fee_error_external (
    batch_number  varchar2(255 byte),
    entityid      varchar2(255 byte),
    docnum        varchar2(255 byte),
    doctype       varchar2(255 byte),
    docdate       varchar2(255 byte),
    duedate       varchar2(255 byte),
    description   varchar2(255 byte),
    txn_amount    varchar2(255 byte),
    gp_acc_number varchar2(255 byte),
    debitamt      varchar2(255 byte),
    creditamt     varchar2(255 byte),
    disttype      varchar2(255 byte),
    record_number varchar2(255 byte),
    error_message varchar2(255 byte)
)
organization

