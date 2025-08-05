-- liquibase formatted sql
-- changeset SAMQA:1754374176917 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\metavante_under_contrib_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/metavante_under_contrib_v.sql:null:470dd1f369663f51576777960062adb28e756005:create

create or replace force editionable view samqa.metavante_under_contrib_v (
    acc_num,
    acc_id,
    pers_id,
    sam_balance,
    metavante_balance,
    difference,
    pre_auth,
    edisbursement,
    receipt_not_posted,
    payment_not_posted
) as
    select
        b.acc_num,
        b.acc_id,
        b.pers_id,
        pc_account.acc_balance(b.acc_id)                         sam_balance,
        a.disbursable_balance                                    metavante_balance,
        pc_account.acc_balance(b.acc_id) - a.disbursable_balance difference,
        (
            select
                sum(amount)
            from
                balance_register
            where
                    balance_register.acc_id = b.acc_id
                and reason_code = 22
        )                                                        pre_auth,
        (
            select
                sum(amount)
            from
                balance_register
            where
                    balance_register.acc_id = b.acc_id
                and reason_mode = 'EP'
        )                                                        edisbursement,
        (
            select
                sum(amount + amount_add)
            from
                income
            where
                    income.acc_id = b.acc_id
                and nvl(debit_card_posted, 'N') = 'N'
        )                                                        receipt_not_posted,
        (
            select
                sum(amount)
            from
                payment
            where
                    payment.acc_id = b.acc_id
                and nvl(debit_card_posted, 'N') = 'N'
        )                                                        payment_not_posted
    from
        card_balance_external a,
        account               b
    where
            employee_id = b.acc_num
        and b.account_status = 1
        and a.disbursable_balance < pc_account.acc_balance(b.acc_id)
        and pc_account.acc_balance(b.acc_id) > 0;

