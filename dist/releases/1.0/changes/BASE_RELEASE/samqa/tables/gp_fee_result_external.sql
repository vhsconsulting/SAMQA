-- liquibase formatted sql
-- changeset SAMQA:1754374159069 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\gp_fee_result_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/gp_fee_result_external.sql:null:7c4d4e702a6c72db5ff36fa08e347bc986db45b3:create

create table samqa.gp_fee_result_external (
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
    error_message varchar2(4000 byte)
)
organization external ( type oracle_loader
    default directory gp access parameters (
        records delimited by newline
            badfile gp : 'GP_FEE_RESULT_EXTERNAL.bad'
            logfile gp : 'GP_FEE_RESULT_EXTERNAL.log'
            skip 1
        fields terminated by ',' optionally enclosed by '"' missing field values are null
    ) location ( gp : 'GP_6303624_hsa_fee100417_ERRORS.csv' )
) reject limit unlimited;

