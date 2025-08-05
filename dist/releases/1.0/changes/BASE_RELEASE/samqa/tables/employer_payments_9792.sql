-- liquibase formatted sql
-- changeset SAMQA:1754374156498 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\employer_payments_9792.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/employer_payments_9792.sql:null:4dd8321e41b00567c7ad308553a6295acc32b115:create

create table samqa.employer_payments_9792 (
    employer_payment_id number,
    entrp_id            number,
    check_amount        number,
    check_number        varchar2(255 byte),
    check_date          date,
    creation_date       date,
    created_by          number,
    last_update_date    date,
    last_updated_by     number,
    note                varchar2(3200 byte),
    bank_acct_id        number,
    payment_register_id number,
    list_bill           varchar2(255 byte),
    reason_code         number,
    transaction_date    date,
    plan_type           varchar2(30 byte),
    pay_code            number,
    transaction_source  varchar2(30 byte),
    plan_start_date     date,
    plan_end_date       date,
    memo                varchar2(255 byte),
    invoice_id          number
);

