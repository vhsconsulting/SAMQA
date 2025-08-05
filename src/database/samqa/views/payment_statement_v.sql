create or replace force editionable view samqa.payment_statement_v (
    pay_date,
    expense_code,
    pay_num,
    fee_amount,
    description,
    amount,
    claimn_id,
    pers_id,
    acc_id,
    reason_mode
) as
    select
        y.pay_date,
        case
            when y.reason_code in ( 11, 12, 13, 19, 60 )
                 and c.service_status in ( 1, 2 ) then
                'Q'
            when c.service_status = 3 then
                'NQ'
            else
                null
        end      expense_code,
        y.pay_num,
        case
            when y.reason_mode = 'P'  then
                0
            when y.reason_mode = 'FP' then
                y.amount
            else
                0
        end      fee_amount,
        case
            when y.reason_code = 11 then
                ' Provider Check:' || c.prov_name
            when y.reason_code = 12 then
                'Reimbursement'
            when y.reason_code = 13 then
                c.prov_name
            else
                pr.reason_name
        end      description,
        y.amount amount,
        y.claimn_id,
        c.pers_id,
        y.acc_id,
        y.reason_mode
    from
        payment    y,
        pay_reason pr,
        claimn     c,
        account    a
    where
            y.acc_id = a.acc_id -- Pay from person account
        and y.reason_code = pr.reason_code
        and y.claimn_id = c.claim_id (+) -- Pay may refer to claim;;;;;;;;;;;;;
        ;


-- sqlcl_snapshot {"hash":"4775f422dd6624793090cceb9a0081c335a387fb","type":"VIEW","name":"PAYMENT_STATEMENT_V","schemaName":"SAMQA","sxml":""}