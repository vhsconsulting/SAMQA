-- liquibase formatted sql
-- changeset SAMQA:1754374156005 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\employer_deposits.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/employer_deposits.sql:null:16a1db21bca00d9bba3624e405577a0b63f97ee9:create

create table samqa.employer_deposits (
    employer_deposit_id number,
    entrp_id            number,
    list_bill           varchar2(255 byte),
    check_number        varchar2(255 byte),
    check_amount        number,
    check_date          date,
    posted_balance      number,
    remaining_balance   number,
    fee_bucket_balance  number,
    created_by          number,
    creation_date       date,
    last_updated_by     number,
    last_update_date    date,
    note                varchar2(3200 byte),
    refund_amount       number,
    plan_type           varchar2(30 byte),
    reason_code         number,
    pay_code            varchar2(30 byte),
    invoice_id          number,
    gp_posted           varchar2(2 byte) default 'N'
);

