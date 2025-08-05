-- liquibase formatted sql
-- changeset SAMQA:1754374152527 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\bps_sam_balances.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/bps_sam_balances.sql:null:b01e435e4cd31b51bf67d9b5c65c090066a4611c:create

create table samqa.bps_sam_balances (
    acc_num             varchar2(20 byte) not null enable,
    acc_id              number(9, 0) not null enable,
    bps_cont_ptd        number,
    sam_cont_ptd        number,
    sam_disb_ptd        number,
    disbursable_balance number,
    sam_bal             number,
    account_status      number,
    bps_disb_ptd        number,
    payment_count       number,
    receipt_count       number,
    payment_amount      number,
    receipt_amount      number,
    pending_disb        number,
    plan_type           varchar2(30 byte),
    plan_start_date     date,
    plan_end_date       date,
    account_type        varchar2(30 byte),
    product_type        varchar2(30 byte),
    entrp_id            number,
    bal_dff             number
);

