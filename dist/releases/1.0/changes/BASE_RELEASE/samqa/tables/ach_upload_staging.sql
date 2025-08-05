-- liquibase formatted sql
-- changeset SAMQA:1754374151227 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\ach_upload_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/ach_upload_staging.sql:null:6744aa0a01ba1a15f57b6bbd3ae1280eaa647955:create

create table samqa.ach_upload_staging (
    ach_upload_id       number,
    tpa_id              varchar2(100 byte),
    group_name          varchar2(100 byte),
    ein                 varchar2(100 byte),
    entrp_id            number,
    er_acc_num          varchar2(100 byte),
    er_acc_id           varchar2(100 byte),
    source              varchar2(100 byte),
    first_name          varchar2(100 byte),
    last_name           varchar2(100 byte),
    ssn                 varchar2(100 byte),
    contribution_reason varchar2(100 byte),
    transaction_date    varchar2(100 byte),
    reason_code         varchar2(100 byte),
    er_amount           varchar2(100 byte),
    ee_amount           varchar2(100 byte),
    er_fee_amount       varchar2(100 byte),
    ee_fee_amount       varchar2(100 byte),
    total_amount        varchar2(100 byte),
    bank_acct_id        number,
    bank_name           varchar2(100 byte),
    bank_routing_num    varchar2(100 byte),
    bank_acct_num       varchar2(100 byte),
    acc_id              varchar2(100 byte),
    acc_num             varchar2(100 byte),
    account_type        varchar2(100 byte) default 'HSA',
    transaction_id      varchar2(100 byte),
    process_status      varchar2(100 byte),
    error_message       varchar2(2000 byte),
    error_column        varchar2(20 byte),
    batch_number        number,
    creation_date       date default sysdate,
    created_by          varchar2(30 byte),
    last_update_date    date default sysdate,
    last_updated_by     varchar2(30 byte),
    pay_code            number,
    plan_type           varchar2(30 byte),
    invoice_id          varchar2(30 byte),
    note                varchar2(3200 byte)
);

alter table samqa.ach_upload_staging add primary key ( ach_upload_id )
    using index enable;

