-- liquibase formatted sql
-- changeset SAMQA:1754374151127 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\ach_transfer.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/ach_transfer.sql:null:cea0733a9299e24c6756f3cabcf5dd6763dfc6e2:create

create table samqa.ach_transfer (
    transaction_id   number,
    acc_id           number,
    bank_acct_id     number,
    transaction_type varchar2(10 byte),
    amount           number,
    fee_amount       number,
    total_amount     number,
    transaction_date date,
    reason_code      number,
    status           number,
    error_message    varchar2(3200 byte),
    processed_date   date,
    last_updated_by  number,
    created_by       number,
    last_update_date date,
    creation_date    date,
    bankserv_status  varchar2(255 byte),
    batch_number     number,
    claim_id         number,
    plan_type        varchar2(30 byte),
    pay_code         number default 5,
    invoice_id       varchar2(30 byte),
    ach_source       varchar2(30 byte) default 'ONLINE',
    scheduler_id     number
);

alter table samqa.ach_transfer add primary key ( transaction_id )
    using index enable;

