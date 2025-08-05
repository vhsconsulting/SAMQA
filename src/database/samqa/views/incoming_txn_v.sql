create or replace force editionable view samqa.incoming_txn_v (
    transaction_type,
    check_date,
    check_amount
) as
    select
        'Employer Check'  transaction_type,
        trunc(check_date) check_date,
        sum(check_amount) check_amount
    from
        employer_deposits
    where
        check_date between sysdate - 2 and sysdate
        and ( check_number not like 'ACH%'
              or check_number not like 'BankServ%%'
              or check_number not like 'CNB%%'
              or check_number not like 'Wire%' )
        and check_amount > 0
    group by
        'Employer Check',
        trunc(check_date)
    union
    select
        'Individual Check',
        trunc(fee_date)                                                                          check_date,
        sum(nvl(amount, 0) + nvl(amount_add, 0) + nvl(er_fee_amount, 0) + nvl(ee_fee_amount, 0)) check_amount
    from
        income
    where
        contributor is null
        and fee_code not in ( 5, 8 )
        and pay_code = 1
        and cc_number not like 'Wire%'
        and fee_date between sysdate - 2 and sysdate
        and nvl(amount, 0) + nvl(amount_add, 0) + nvl(er_fee_amount, 0) + nvl(ee_fee_amount, 0) > 0
    group by
        trunc(fee_date)
    union
    select
        'Interest',
        trunc(fee_date)                                                                          check_date,
        sum(nvl(amount, 0) + nvl(amount_add, 0) + nvl(er_fee_amount, 0) + nvl(ee_fee_amount, 0)) check_amount
    from
        income
    where
            fee_code = 8
        and fee_date between sysdate - 2 and sysdate
    group by
        trunc(fee_date)
    union
    select
        'Employer BankDraft',
        trunc(check_date) check_date,
        sum(check_amount) check_amount
    from
        employer_deposits
    where
        check_date between sysdate - 2 and sysdate
        and check_number like 'ACH%'
        and check_amount > 0
    group by
        trunc(check_date)
    union
    select
        'Individual BankDraft',
        trunc(fee_date)                                                                          check_date,
        sum(nvl(amount, 0) + nvl(amount_add, 0) + nvl(er_fee_amount, 0) + nvl(ee_fee_amount, 0)) check_amount
    from
        income
    where
        contributor is null
        and fee_code not in ( 5, 8 )
        and cc_number like 'ACH%'
        and fee_date between sysdate - 2 and sysdate
        and nvl(amount, 0) + nvl(amount_add, 0) + nvl(er_fee_amount, 0) + nvl(ee_fee_amount, 0) > 0
    group by
        trunc(fee_date)
    union
    select
        'Individual RollOver',
        trunc(fee_date)                                                                          check_date,
        sum(nvl(amount, 0) + nvl(amount_add, 0) + nvl(er_fee_amount, 0) + nvl(ee_fee_amount, 0)) check_amount
    from
        income
    where
        contributor is null
        and fee_code = 5
        and cc_number like 'ACH%'
        and fee_date between sysdate - 2 and sysdate
        and nvl(amount, 0) + nvl(amount_add, 0) + nvl(er_fee_amount, 0) + nvl(ee_fee_amount, 0) > 0
    group by
        trunc(fee_date)
    union
    select
        'Online ACH from individual',
        trunc(transaction_date) transaction_date,
        sum(total_amount)
    from
        ach_transfer a,
        account      b
    where
            a.acc_id = b.acc_id
        and b.pers_id is not null
        and transaction_date between sysdate - 2 and sysdate
    group by
        trunc(transaction_date)
    union
    select
        'Online ACH from employer',
        trunc(transaction_date) transaction_date,
        sum(total_amount)
    from
        ach_transfer a,
        account      b
    where
            a.acc_id = b.acc_id
        and b.entrp_id is not null
        and transaction_date between sysdate - 2 and sysdate
    group by
        trunc(transaction_date)
    union
    select
        'Employer Wire',
        trunc(check_date) check_date,
        sum(check_amount) check_amount
    from
        employer_deposits
    where
        check_date between sysdate - 10 and sysdate
        and check_number like 'Wire%'
        and check_amount > 0
    group by
        'Employer Wire',
        trunc(check_date)
    union
    select
        'Individual Wire',
        trunc(fee_date)                                                                          check_date,
        sum(nvl(amount, 0) + nvl(amount_add, 0) + nvl(er_fee_amount, 0) + nvl(ee_fee_amount, 0)) check_amount
    from
        income
    where
        contributor is null
        and cc_number like 'Wire%'
        and nvl(amount, 0) + nvl(amount_add, 0) + nvl(er_fee_amount, 0) + nvl(ee_fee_amount, 0) > 0
        and fee_date between sysdate - 10 and sysdate
    group by
        trunc(fee_date)
    union
    select
        'Employer adjustment',
        trunc(check_date) check_date,
        sum(check_amount) check_amount
    from
        employer_deposits
    where
        check_date between sysdate - 2 and sysdate
        and check_amount < 0
    group by
        'Employer Check',
        trunc(check_date)
    union
    select
        'Individual adjustment',
        trunc(fee_date)                                                                          check_date,
        sum(nvl(amount, 0) + nvl(amount_add, 0) + nvl(er_fee_amount, 0) + nvl(ee_fee_amount, 0)) check_amount
    from
        income
    where
        contributor is null
        and fee_date between sysdate - 2 and sysdate
        and nvl(amount, 0) + nvl(amount_add, 0) + nvl(er_fee_amount, 0) + nvl(ee_fee_amount, 0) < 0
    group by
        trunc(fee_date);


-- sqlcl_snapshot {"hash":"cda8b9db24dd79205dbd0eac4b686a8dd00677ec","type":"VIEW","name":"INCOMING_TXN_V","schemaName":"SAMQA","sxml":""}