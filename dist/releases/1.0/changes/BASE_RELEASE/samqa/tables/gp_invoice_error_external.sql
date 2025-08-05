-- liquibase formatted sql
-- changeset SAMQA:1754374159127 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\gp_invoice_error_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/gp_invoice_error_external.sql:null:4ea3fb05c5639f3f5943700107ce6704baf218b9:create

create table samqa.gp_invoice_error_external (
    soptype       varchar2(255 byte),
    docid         varchar2(255 byte),
    invoiceid     varchar2(255 byte),
    docdate       varchar2(255 byte),
    primarysite   varchar2(255 byte),
    batch_number  varchar2(255 byte),
    custnumber    varchar2(255 byte),
    custname      varchar2(255 byte),
    itemnumber    varchar2(255 byte),
    uom           varchar2(255 byte),
    quantity      varchar2(255 byte),
    unitprice     varchar2(255 byte),
    record_number varchar2(255 byte),
    error_message varchar2(255 byte)
)
organization

