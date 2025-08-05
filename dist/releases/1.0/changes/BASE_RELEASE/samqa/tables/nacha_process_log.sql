-- liquibase formatted sql
-- changeset SAMQA:1754374160939 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\nacha_process_log.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/nacha_process_log.sql:null:f43a1f6c6ee59e6c6490033b5e62bf517b57e92b:create

create table samqa.nacha_process_log (
    account_type     varchar2(10 byte),
    transaction_type varchar2(10 byte),
    transaction_id   number,
    acc_num          varchar2(20 byte),
    amount           number,
    processed_date   date,
    batch_number     number,
    file_name        varchar2(100 byte),
    trace_number     number,
    flg_processed    varchar2(1 byte),
    first_name       varchar2(255 byte),
    last_name        varchar2(50 byte),
    plan_type        varchar2(30 byte),
    claim_id         number
);

