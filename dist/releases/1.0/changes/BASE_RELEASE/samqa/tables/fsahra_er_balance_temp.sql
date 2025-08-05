-- liquibase formatted sql
-- changeset SAMQA:1754374158872 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\fsahra_er_balance_temp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/fsahra_er_balance_temp.sql:null:aa45c3368c4cd678b75b32b5754eb7c485c3bed3:create

create table samqa.fsahra_er_balance_temp (
    transaction_type    varchar2(100 byte),
    acc_num             varchar2(100 byte),
    claim_invoice_id    varchar2(100 byte),
    check_amount        number,
    plan_type           varchar2(100 byte),
    reason_code         number,
    note                varchar2(4000 byte),
    transaction_date    date,
    paid_date           date,
    first_name          varchar2(100 byte),
    last_name           varchar2(100 byte),
    ord_no              number,
    employer_payment_id number
);

