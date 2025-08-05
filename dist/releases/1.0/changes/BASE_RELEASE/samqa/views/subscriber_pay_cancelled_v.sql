-- liquibase formatted sql
-- changeset SAMQA:1754374179030 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\subscriber_pay_cancelled_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/subscriber_pay_cancelled_v.sql:null:792daf96879bea0dd8ea5cfd5d91cd38f5626484:create

create or replace force editionable view samqa.subscriber_pay_cancelled_v (
    transaction_id,
    bank_name,
    amount,
    transaction_date,
    reason_name,
    acc_id
) as
    select
        transaction_id,
        c.display_name                          bank_name,
        amount                                  amount,
        to_char(transaction_date, 'MM/DD/YYYY') transaction_date,
        reason_name,
        b.acc_id
    from
        ach_transfer   b,
        user_bank_acct c,
        pay_reason     d
    where
            c.acc_id = b.acc_id
        and b.bank_acct_id = c.bank_acct_id
        and b.reason_code = d.reason_code
        and b.status = 9
        and b.transaction_type = 'D'
    order by
        transaction_id;

