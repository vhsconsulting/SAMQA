-- liquibase formatted sql
-- changeset SAMQA:1754374159088 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\gp_interest_error_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/gp_interest_error_external.sql:null:a4f2a9046f433d6817567c00f0cd49f301603d78:create

create table samqa.gp_interest_error_external (
    batch_number  varchar2(255 byte),
    custnmbr      varchar2(255 byte),
    docnumbr      varchar2(255 byte),
    rmdtypal      varchar2(255 byte),
    docdate       varchar2(255 byte),
    duedate       varchar2(255 byte),
    description   varchar2(255 byte),
    po_number     varchar2(255 byte),
    txn_amount    varchar2(255 byte),
    gp_acc_number varchar2(255 byte),
    debitamt      varchar2(255 byte),
    creditamt     varchar2(255 byte),
    disttype      varchar2(255 byte),
    record_number varchar2(255 byte),
    error_message varchar2(255 byte)
)
organization

