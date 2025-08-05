-- liquibase formatted sql
-- changeset SAMQA:1754374159193 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\gp_payment_result_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/gp_payment_result_external.sql:null:bb83df61ce5a7a507564eb7f72732cccd2ac7358:create

create table samqa.gp_payment_result_external (
    batch_number  varchar2(255 byte),
    entityid      varchar2(255 byte),
    docnum        varchar2(255 byte),
    txn_amount    varchar2(255 byte),
    docdate       varchar2(255 byte),
    paytype       varchar2(255 byte),
    checkbook_id  varchar2(255 byte),
    description   varchar2(255 byte),
    record_number varchar2(255 byte),
    error_message varchar2(4000 byte)
)
organization external ( type oracle_loader
    default directory gp access parameters (
        records delimited by newline
            badfile gp : 'GP_PAYMENT_RESULT_EXTERNAL.bad'
            logfile gp : 'GP_PAYMENT_RESULT_EXTERNAL.log'
            skip 1
        fields terminated by ',' optionally enclosed by '"' missing field values are null
    ) location ( gp : 'GP_6303622_dr_card_payment100417_ERRORS.csv' )
) reject limit unlimited;

