-- liquibase formatted sql
-- changeset SAMQA:1754374159167 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\gp_payment_error_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/gp_payment_error_external.sql:null:55eec40a2dae136ce6f56c3ac78d580b3c555e87:create

create table samqa.gp_payment_error_external (
    batch_number  varchar2(255 byte),
    entityid      varchar2(255 byte),
    docnum        varchar2(255 byte),
    txn_amount    varchar2(255 byte),
    docdate       varchar2(255 byte),
    paytype       varchar2(255 byte),
    checkbook_id  varchar2(255 byte),
    description   varchar2(255 byte),
    record_number varchar2(255 byte),
    error_message varchar2(255 byte)
)
organization

