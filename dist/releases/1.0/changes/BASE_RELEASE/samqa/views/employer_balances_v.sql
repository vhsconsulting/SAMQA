-- liquibase formatted sql
-- changeset SAMQA:1754374172352 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\employer_balances_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/employer_balances_v.sql:null:94528d1bcd1285e65438d42b56aa7ff728ab2f36:create

create or replace force editionable view samqa.employer_balances_v (
    rn,
    entrp_id,
    acc_id,
    transaction_type,
    check_amount,
    transaction_date,
    fee_name,
    plan_type,
    note,
    product_type,
    employer_payment_id
) as
    select
        rownum                                                   rn,
        entrp_id,
        pc_entrp.get_acc_id(entrp_id)                            acc_id,
        transaction_type,
        check_amount,
        transaction_date,
        fee_name,
        plan_type,
        note,
        pc_lookups.get_meaning(plan_type, 'FSA_HRA_PRODUCT_MAP') product_type,
        employer_payment_id
    from
        (
            select
                a.entrp_id,
                'RECEIPT'             transaction_type,
                check_amount,
                trunc(check_date)     transaction_date,
                b.fee_name,
                a.plan_type,
                a.note,
                a.employer_deposit_id employer_payment_id
            from
                employer_deposits a,
                fee_names         b,
                account           c
            where
                    a.reason_code = b.fee_code
                and a.entrp_id = c.entrp_id
                and c.account_type in ( 'HRA', 'FSA' )
                and a.reason_code not in ( 5, 11, 12, 15, 8,
                                           17, 18, 40 )
                and c.payroll_integration = 'N'
            union all
            select
                entrp_id,
                transaction_type,
                amount,
                trunc(transaction_date),
                reason_name,
                plan_type,
                description,
                employer_payment_id
            from
                hrafsa_employee_payments_v
        );

