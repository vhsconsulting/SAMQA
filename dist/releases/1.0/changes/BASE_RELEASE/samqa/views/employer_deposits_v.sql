-- liquibase formatted sql
-- changeset SAMQA:1754374172406 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\employer_deposits_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/employer_deposits_v.sql:null:183628d2d1a9925865355f5609aca7957f9ddda1:create

create or replace force editionable view samqa.employer_deposits_v (
    entrp_id,
    list_bill,
    check_number,
    check_amount,
    check_date,
    posted_balance,
    remaining_balance,
    fee_bucket_balance,
    note,
    refund_amount,
    plan_type,
    account_type,
    acc_num,
    acc_id,
    reason_code,
    pay_code,
    payment_method
) as
    select
        a.entrp_id,
        a.list_bill,
        a.check_number,
        a.check_amount,
        a.check_date,
        a.posted_balance,
        a.remaining_balance,
        a.fee_bucket_balance,
        a.note,
        a.refund_amount,
        a.plan_type,
        b.account_type,
        b.acc_num,
        b.acc_id,
        a.reason_code,
        a.pay_code,
        pc_lookups.get_pay_code(a.pay_code) payment_method
    from
        employer_deposits a,
        account           b
    where
        a.entrp_id = b.entrp_id;

