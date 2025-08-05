-- liquibase formatted sql
-- changeset SAMQA:1754374155687 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\deposit_reconcile_stage.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/deposit_reconcile_stage.sql:null:474f5ed4c96c071341830cf8889e865b8c1d18dc:create

create table samqa.deposit_reconcile_stage (
    first_name     varchar2(255 byte),
    last_name      varchar2(50 byte),
    check_number   varchar2(255 byte),
    check_amount   varchar2(255 byte),
    ssn            varchar2(20 byte),
    reason_code    varchar2(10 byte),
    er_fee_amount  varchar2(255 byte),
    ee_fee_amount  varchar2(255 byte),
    batch_number   number,
    error_message  varchar2(1000 byte),
    trans_date     varchar2(50 byte),
    acc_num        varchar2(20 byte),
    process_status varchar2(1 byte)
);

