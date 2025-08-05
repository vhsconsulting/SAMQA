-- liquibase formatted sql
-- changeset SAMQA:1754374159148 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\gp_invoice_result_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/gp_invoice_result_external.sql:null:4455033b8e658a71e45b9332d0c486874ad83acc:create

create table samqa.gp_invoice_result_external (
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
    error_message varchar2(4000 byte)
)
organization external ( type oracle_loader
    default directory gp access parameters (
        records delimited by newline
            badfile gp : 'GP_INVOICE_RESULT_EXTERNAL.bad'
            logfile gp : 'GP_INVOICE_RESULT_EXTERNAL.log'
            skip 1
        fields terminated by ',' optionally enclosed by '"' missing field values are null
    ) location ( gp : 'GP_6303259_inv100317_ERRORS.csv' )
) reject limit unlimited;

