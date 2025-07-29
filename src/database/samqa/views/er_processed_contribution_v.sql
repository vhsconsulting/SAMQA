create or replace force editionable view samqa.er_processed_contribution_v (
    transaction_id,
    list_bill,
    employer_deposit_id,
    acc_id,
    payment_method,
    pay_type,
    check_number,
    check_amount,
    check_date,
    amount,
    fee_amount,
    entrp_id,
    refund_amount
) as
    select
        case
            when a.check_number like 'BankServ%' then
                replace(a.check_number, 'BankServ')
            when a.check_number like 'CNB%'           -- Added by Swamy for Ticket#7723(Nacha)
             then
                replace(a.check_number, 'CNB')      -- Added by Swamy for Ticket#7723(Nacha)
            else
                null
        end                                                    transaction_id,
        a.list_bill,
        a.employer_deposit_id,
        c.acc_id,
        pc_lookups.get_pay_code(a.pay_code)                    payment_method,
        a.pay_code                                             pay_type,
        case
            when a.check_number like 'BankServ%' then
                replace(a.check_number, 'BankServ')
            when a.check_number like 'CNB%'             -- Added by Swamy for Ticket#7723(Nacha)
             then
                replace(a.check_number, 'CNB')        -- Added by Swamy for Ticket#7723(Nacha)
            else
                a.check_number
        end                                                    check_number,
        check_amount                                           check_amount,
        check_date,
        sum(nvl(d.amount, 0) + nvl(d.amount_add, 0))           amount,
        sum(nvl(d.er_fee_amount, 0) + nvl(d.ee_fee_amount, 0)) fee_amount,
        b.entrp_id,
        a.refund_amount
    from
        employer_deposits a,
        enterprise        b,
        account           c,
        income            d
    where
            a.entrp_id = b.entrp_id
        and b.entrp_id = c.entrp_id
        and d.list_bill (+) = a.list_bill
        and a.entrp_id = d.contributor (+)
        and nvl(a.reason_code, -1) <> 12
    group by
        a.list_bill,
        a.employer_deposit_id,
        c.acc_id,
        a.pay_code,
        a.pay_code,
        a.check_number,
        check_amount,
        check_date,
        b.entrp_id,
        a.refund_amount
    order by
        check_date desc;


-- sqlcl_snapshot {"hash":"0ea4e905262c5670f31de149f087bc5c4bb2f952","type":"VIEW","name":"ER_PROCESSED_CONTRIBUTION_V","schemaName":"SAMQA","sxml":""}