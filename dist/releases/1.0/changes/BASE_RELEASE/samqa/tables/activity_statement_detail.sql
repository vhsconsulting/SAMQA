-- liquibase formatted sql
-- changeset SAMQA:1754374151315 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\activity_statement_detail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/activity_statement_detail.sql:null:43670eee8ff0cfd70c5e6f07dde2be5f0d8b58a8:create

create table samqa.activity_statement_detail (
    stmt_detail_id       number,
    statement_id         number,
    acc_id               number,
    transaction_date     date,
    expense_code         varchar2(255 byte),
    description          varchar2(3200 byte),
    total_receipt_amount number,
    total_disb_amount    number,
    receipt_amount       number,
    disb_amount          number,
    fee_receipt          number,
    fee_disb             number,
    creation_date        date
);

