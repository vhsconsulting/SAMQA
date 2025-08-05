-- liquibase formatted sql
-- changeset SAMQA:1754374158856 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\fsahra_er_balance_gtt.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/fsahra_er_balance_gtt.sql:null:c3a7b01c566ca9edd7447efb1f168298e2ae39a4:create

create global temporary table samqa.fsahra_er_balance_gtt (
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
) on commit preserve rows;

