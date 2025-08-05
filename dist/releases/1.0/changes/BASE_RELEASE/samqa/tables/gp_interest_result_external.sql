-- liquibase formatted sql
-- changeset SAMQA:1754374159110 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\gp_interest_result_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/gp_interest_result_external.sql:null:9ad9df450b156c8e5a581e6f644877d3eb40025d:create

create table samqa.gp_interest_result_external (
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
    error_message varchar2(4000 byte)
)
organization external ( type oracle_loader
    default directory gp access parameters (
        records delimited by newline
            badfile gp : 'GP_INTEREST_RESULT_EXTERNAL.bad'
            logfile gp : 'GP_INTEREST_RESULT_EXTERNAL.log'
            skip 1
        fields terminated by ',' optionally enclosed by '"' missing field values are null
    ) location ( gp : 'GP_5507186_hsa_int022317_ERRORS.csv' )
) reject limit unlimited;

